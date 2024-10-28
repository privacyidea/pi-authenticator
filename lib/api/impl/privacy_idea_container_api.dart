// ignore_for_file: constant_identifier_names

/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart';

import '../../../../../../../../l10n/app_localizations_en.dart';
import '../../../../../../../../model/extensions/token_folder_extension.dart';
import '../../../../../../../../processors/scheme_processors/token_import_scheme_processors/otp_auth_processor.dart';
import '../../../../../../../../utils/ecc_utils.dart';
import '../../../../../../../../utils/privacyidea_io_client.dart';
import '../../model/api_results/pi_server_results/pi_server_result_value.dart';
import '../../model/exception_errors/localized_exception.dart';
import '../../model/exception_errors/response_error.dart';
import '../../model/pi_server_response.dart';
import '../../model/riverpod_states/token_state.dart';
import '../../model/token_container.dart';
import '../../model/token_template.dart';
import '../../model/tokens/token.dart';
import '../../utils/globals.dart';
import '../../utils/identifiers.dart';
import '../../utils/logger.dart';
import '../../widgets/dialog_widgets/enter_passphrase_dialog.dart';
import '../interfaces/container_api.dart';

class PiContainerApi implements TokenContainerApi {
  final PrivacyideaIOClient _ioClient;
  const PiContainerApi({required PrivacyideaIOClient ioClient}) : _ioClient = ioClient;

  // Returns a tuple of updated/new tokens and serials of deleted tokens
  @override
  Future<(List<Token>, List<String>)?> sync(TokenContainerFinalized container, TokenState tokenState) async {
    final containerTokenTemplates = tokenState.containerTokens(container.serial).toTemplates();
    final maybePiTokensTemplates = tokenState.maybePiTokens.toTemplates();

    final ContainerChallenge challenge = await _getChallenge(container, container.syncUrl);

    final decryptedContainerDictJson = await _getContainerDict(
      container: container,
      challenge: challenge,
      otpAuthMaps: [
        for (var template in [...containerTokenTemplates, ...maybePiTokensTemplates]) template.otpAuthMapSafeToSend
      ],
    );
    if (decryptedContainerDictJson == null) return null;

    final tokens = decryptedContainerDictJson[CONTAINER_DICT_TOKENS] as Map<String, dynamic>;
    final newOtpAuthTokens = (tokens[CONTAINER_DICT_TOKENS_ADD] as List).whereType<String>().map(Uri.parse).toList();
    final newTokens = await _parseNewTokens(otpAuthUris: newOtpAuthTokens, container: container);

    // All server tokens should have a serial but if client token has no serial the server token also has otps
    final serverTokensUpdate = (tokens[CONTAINER_DICT_TOKENS_UPDATE] as List).cast<Map<String, dynamic>>();
    final serverTokensWithOtps = serverTokensUpdate.where((element) => element[OTP_AUTH_OTP_VALUES] != null).toList();
    serverTokensWithOtps.forEach(serverTokensUpdate.remove);

    // Now we have to find all tokens that are in the server lists but not in the local list
    // These tokens should be deleted

    // MaybePiTokens Should not be deleted
    final mergedTemplatesWithOtps = _handleMaybePiTokens(
      maybePiTokensTemplates: maybePiTokensTemplates,
      serverTokensWithOtps: serverTokensWithOtps,
      container: container,
    );

    final serverTokensWithSerial = serverTokensUpdate.where((element) => element[OTP_AUTH_SERIAL] != null).toList();
    serverTokensWithSerial.forEach(serverTokensUpdate.remove);
    assert(serverTokensUpdate.isEmpty, 'Server token otps map should be empty after removing all tokens with serial and otps');
    // Container tokens can be deleted if they are not in the server list
    final List<TokenTemplate> mergedTemplatesWithSerial;
    final List<String> deleteSerials;
    (mergedTemplatesWithSerial, deleteSerials) = _handlePiTokens(
      containerTokenTemplates: containerTokenTemplates,
      serverTokensWithSerial: serverTokensWithSerial,
      container: container,
    );

    final updatedTokens = <Token>[];
    // Add updated Tokens
    for (var mergedTemplate in [...mergedTemplatesWithOtps, ...mergedTemplatesWithSerial]) {
      final token = container.addOriginToToken(token: mergedTemplate.toToken());
      updatedTokens.add(token);
    }

    return ([...updatedTokens, ...newTokens], deleteSerials);
  }

  @override
  Future<Response> finalizeContainer(TokenContainerUnfinalized container, EccUtils eccUtils) async {
    final ecPrivateClientKey = container.ecPrivateClientKey;
    if (ecPrivateClientKey == null) {
      throw LocalizedException(localizedMessage: (l) => l.errorMissingPrivateKey, unlocalizedMessage: AppLocalizationsEn().errorMissingPrivateKey);
    }

    final passphrase = container.passphraseQuestion?.isNotEmpty == true ? await EnterPassphraseDialog.show(await globalContext) : null;
    final message = '${container.nonce}'
        '|${container.timestamp.toIso8601String().replaceFirst('Z', '+00:00')}'
        '|${container.serial}'
        '|${container.registrationUrl}'
        '${passphrase != null ? '|$passphrase' : ''}';

    final signature = eccUtils.signWithPrivateKey(ecPrivateClientKey, message);

    final body = {
      CONTAINER_CONTAINER_SERIAL: container.serial,
      CONTAINER_PUBLIC_CLIENT_KEY: container.publicClientKey,
      CONTAINER_CHAL_SIGNATURE: signature,
    };
    return await _ioClient.doPost(url: container.registrationUrl, body: body, sslVerify: container.sslVerify);
  }

  /* //////////////////////////////
  /////// PRIVATE FUNCTIONS ///////
  ////////////////////////////// */

  Future<ContainerChallenge> _getChallenge(TokenContainerFinalized container, Uri requestUrl) async {
    final body = {
      CONTAINER_SCOPE: requestUrl.toString(),
    };
    final challengeResponse = await _ioClient.doPost(
      url: container.challengeUrl,
      body: body,
    );
    if (challengeResponse.statusCode != 200) {
      final errorResponse = challengeResponse.asPiErrorResponse();
      if (errorResponse != null) throw errorResponse.piServerResultError;
      throw ResponseError(challengeResponse);
    }

    Logger.debug('Received container sync challenge: ${challengeResponse.body}');
    final piResponse = PiServerResponse<ContainerChallenge>.fromResponse(challengeResponse);
    if (piResponse.isError) {
      throw piResponse.asError!.piServerResultError;
    }
    return piResponse.asSuccess!.resultValue;
  }

  Future<Map<String, dynamic>?> _getContainerDict({
    required TokenContainerFinalized container,
    required ContainerChallenge challenge,
    required List<Map> otpAuthMaps,
  }) async {
    final encKeyPair = await X25519().newKeyPair();
    final publicKey = await encKeyPair.extractPublicKey();

    final algorithm = X25519();

    final publicKeyBase64 = base64.encode(publicKey.bytes);

    final containerDict = {
      CONTAINER_DICT_SERIAL: container.serial,
      CONTAINER_DICT_TYPE: CONTAINER_DICT_TYPE_SMARTPHONE,
      CONTAINER_DICT_TOKENS: otpAuthMaps,
    };
    final signMessage = '${challenge.nonce}|${challenge.timeStamp}|${container.serial}|${container.syncUrl}|$publicKeyBase64|${jsonEncode(containerDict)}';
    Logger.debug(signMessage);
    final signature = container.signMessage(signMessage);
    Logger.debug('Sended container: ${jsonEncode(containerDict)}');
    final body = <String, String>{
      CONTAINER_SYNC_PUBLIC_CLIENT_KEY: publicKeyBase64,
      CONTAINER_SYNC_DICT_CLIENT: jsonEncode(containerDict),
      CONTAINER_CHAL_SIGNATURE: signature,
    };

    final response = await _ioClient.doPost(url: container.syncUrl, body: body);
    if (response.statusCode != 200) {
      final piErrorResponse = response.asPiErrorResponse();
      if (piErrorResponse != null) throw piErrorResponse.piServerResultError;
      throw ResponseError(response);
    }

    final containerSyncResponse = PiServerResponse<ContainerSyncResult>.fromResponse(response);
    if (containerSyncResponse.isError) {
      Logger.error('Error while reciving sync response: ${containerSyncResponse.asError!.piServerResultError}');
      return null;
    }

    final syncResult = containerSyncResponse.asSuccess!.resultValue;

    final remotePublicKey = SimplePublicKey(syncResult.publicServerKeyBytes, type: KeyPairType.x25519);
    final sharedKey = await algorithm.sharedSecretKey(keyPair: encKeyPair, remotePublicKey: remotePublicKey);
    Logger.debug('Shared key: ${await sharedKey.extractBytes()}');

    final params = syncResult.encryptionParams;

    final secretMsgBytes = base64Url.decoder.convert(syncResult.containerDictEncrypted);
    final ivBytes = base64Url.decoder.convert(params.initVector);
    final tagBytes = base64Url.decoder.convert(params.tag);

    final decryptedContainerDict = await AesGcm.with256bits(nonceLength: 16).decrypt(
      SecretBox(
        secretMsgBytes,
        nonce: ivBytes,
        mac: Mac(tagBytes),
      ),
      secretKey: sharedKey,
    );

    Logger.debug('Decrypted container dict: ${utf8.decode(decryptedContainerDict)}');
    return jsonDecode(utf8.decode(decryptedContainerDict)) as Map<String, dynamic>;
  }

  Future<List<Token>> _parseNewTokens({required TokenContainerFinalized container, required List<Uri> otpAuthUris}) async {
    final newTokens = <Token>[];
    for (var otpAuthUri in otpAuthUris) {
      Logger.debug('Processing token: $otpAuthUri');
      var newToken = (await const OtpAuthProcessor().processUri(otpAuthUri)).firstOrNull?.asSuccess?.resultData;
      if (newToken != null) {
        newToken = container.addOriginToToken(token: newToken, tokenData: otpAuthUri.toString());
        newTokens.add(newToken);
      }
    }
    return newTokens;
  }

  List<TokenTemplate> _handleMaybePiTokens({
    required List<TokenTemplate> maybePiTokensTemplates,
    required List<Map<String, dynamic>> serverTokensWithOtps,
    required TokenContainerFinalized container,
  }) {
    final merged = <TokenTemplate>[];
    for (var serverTokenWithOtp in serverTokensWithOtps) {
      final otps = (serverTokenWithOtp[OTP_AUTH_OTP_VALUES] as List).cast<String>();
      var mergedTemplate = maybePiTokensTemplates.firstWhere(
        (maybePiToken) => const IterableEquality().equals(otps, maybePiToken.otpValues),
        orElse: () => TokenTemplate.withOtps(
          otps: serverTokenWithOtp[OTP_AUTH_OTP_VALUES]!,
          otpAuthMap: serverTokenWithOtp,
          container: container,
          additionalData: {
            Token.CHECKED_CONTAINERS: [container.serial],
          },
        ),
      );
      mergedTemplate = mergedTemplate.withOtpAuthData(serverTokenWithOtp);
      mergedTemplate = mergedTemplate.copyWith(container: container);
      merged.add(mergedTemplate);
    }
    return merged;
  }

  (List<TokenTemplate>, List<String>) _handlePiTokens({
    required List<TokenTemplate> containerTokenTemplates,
    required List<Map<String, dynamic>> serverTokensWithSerial,
    required TokenContainerFinalized container,
  }) {
    final deleteSerials = <String>[];
    final mergedTemplatesWithSerial = <TokenTemplate>[];
    for (var containerToken in containerTokenTemplates) {
      final serverToken = serverTokensWithSerial.firstWhereOrNull((element) => element[OTP_AUTH_SERIAL] == containerToken.serial);
      serverTokensWithSerial.remove(serverToken);
      if (serverToken == null) {
        deleteSerials.add(containerToken.serial!);
      } else {
        var mergedTemplate = containerToken.withOtpAuthData(serverToken);
        mergedTemplate = mergedTemplate.copyWith(container: container);
        mergedTemplatesWithSerial.add(mergedTemplate);
      }
    }
    return (mergedTemplatesWithSerial, deleteSerials);
  }

  @override
  Future<String> getTransferQrData(TokenContainerFinalized container) async {
    final requestUrl = container.transferUrl;
    final challenge = await _getChallenge(container, requestUrl);

    final ecKeyPair = container.ecPrivateClientKey;
    if (ecKeyPair == null) {
      throw LocalizedException(localizedMessage: (l) => l.errorMissingPrivateKey, unlocalizedMessage: AppLocalizationsEn().errorMissingPrivateKey);
    }

    final signMessage = '${challenge.nonce}|${challenge.timeStamp}|${container.serial}';

    final body = {
      CONTAINER_SERIAL: container.serial,
      CONTAINER_CHAL_SIGNATURE: container.signMessage(signMessage),
    };

    final response = await _ioClient.doPost(url: requestUrl, body: body);
    if (response.statusCode != 200) {
      final errorResponse = response.asPiErrorResponse();
      if (errorResponse != null) throw errorResponse.piServerResultError;
      throw ResponseError(response);
    }

    final piResponse = PiServerResponse<TransferQrData>.fromResponse(response);
    if (piResponse.isError) {
      Logger.error('Error while getting transfer qr data: ${piResponse.asError!.piServerResultError}');
      throw piResponse.asError!.piServerResultError;
    }

    return piResponse.asSuccess!.resultValue.qrData;
  }
}
