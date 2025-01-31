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
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/utils/app_info_utils.dart';

import '../../../../../../../../l10n/app_localizations_en.dart';
import '../../../../../../../../model/extensions/token_folder_extension.dart';
import '../../../../../../../../processors/scheme_processors/token_import_scheme_processors/otp_auth_processor.dart';
import '../../../../../../../../utils/ecc_utils.dart';
import '../../../../../../../../utils/privacyidea_io_client.dart';
import '../../model/api_results/pi_server_results/pi_server_result_value.dart';
import '../../model/exception_errors/localized_exception.dart';
import '../../model/exception_errors/pi_server_result_error.dart';
import '../../model/exception_errors/response_error.dart';
import '../../model/pi_server_response.dart';
import '../../model/riverpod_states/token_state.dart';
import '../../model/token_container.dart';
import '../../model/token_template.dart';
import '../../model/tokens/token.dart';
import '../../utils/logger.dart';
import '../../widgets/dialog_widgets/container_dialogs/initial_token_assignment_dialog.dart';
import '../../widgets/dialog_widgets/enter_passphrase_dialog.dart';
import '../interfaces/container_api.dart';

class PiContainerApi implements TokenContainerApi {
  final PrivacyideaIOClient _ioClient;
  const PiContainerApi({required PrivacyideaIOClient ioClient}) : _ioClient = ioClient;

  /* //////////////////////////////
  //////// PUBLIC METHODS /////////
  ////////////////////////////// */

  @override
  Future<ContainerSyncUpdates> sync(
    TokenContainerFinalized container,
    TokenState tokenState, {
    SimpleKeyPair? withX25519Key,
    bool isInitSync = false,
    bool? sendOTPs,
  }) async {
    final containerTokenTemplates = tokenState.containerTokens(container.serial).toTemplates();

    final initialTokenAssignment = isInitSync && container.policies.initialTokenAssignment;
    final notLinkedTokenTemplates = initialTokenAssignment ? tokenState.notLinkedTokens.toTemplates() : <TokenTemplate>[];
    if (initialTokenAssignment) {
      sendOTPs ??= await InitialTokenAssignmentDialog.showDialog(container) ?? false;
      if (sendOTPs == false) {
        notLinkedTokenTemplates.removeWhere((element) => element.otpValues != null && element.otpValues!.isNotEmpty);
      }
    }

    final ContainerChallenge challenge = await _getChallenge(container, container.syncUrl);

    final encKeyPair = withX25519Key ?? await X25519().newKeyPair();
    final syncResult = await _getContainerSyncResult(
      container: container,
      challenge: challenge,
      encKeyPair: encKeyPair,
      otpAuthMaps: [
        for (var template in [...containerTokenTemplates, ...notLinkedTokenTemplates]) template.otpAuthMapSafeToSend
      ],
    );

    final decryptedContainerDict = await _getContainerDict(
      syncResult: syncResult,
      encKeyPair: encKeyPair,
    );

    final tokens = decryptedContainerDict[TokenContainer.DICT_TOKENS] as Map<String, dynamic>;
    final newOtpAuthTokens = (tokens[TokenContainer.DICT_TOKENS_ADD] as List).whereType<String>().map(Uri.parse).toList();
    final newTokens = await _parseNewTokens(otpAuthUris: newOtpAuthTokens, container: container);

    // All server tokens should have a serial but if client token has no serial the server token also has otps
    final serverTokensUpdate = (tokens[TokenContainer.DICT_TOKENS_UPDATE] as List).cast<Map<String, dynamic>>();
    final serverTokensWithOtps = serverTokensUpdate.where((element) => element[OTPToken.OTP_VALUES] != null).toList();
    serverTokensWithOtps.forEach(serverTokensUpdate.remove);

    // Now we have to find all tokens that are in the server lists but not in the local list
    // These tokens should be deleted

    // MaybePiTokens Should not be deleted
    final mergedTemplatesWithOtps = _handleMaybePiTokens(
      maybePiTokensTemplates: notLinkedTokenTemplates,
      serverTokensWithOtps: serverTokensWithOtps,
      container: container,
    );

    final serverTokensWithSerial = serverTokensUpdate.where((element) => element[Token.SERIAL] != null).toList();
    serverTokensWithSerial.forEach(serverTokensUpdate.remove);
    assert(serverTokensUpdate.isEmpty, 'Server token otps map should be empty after removing all tokens with serial and otps');
    // Container tokens can be deleted if they are not in the server list
    final List<TokenTemplate> mergedTemplatesWithSerial;
    final List<TokenTemplate> deleteTemplates;
    final notLinkedSerialTemplates = notLinkedTokenTemplates.where((e) => e.serial != null).toList();
    (mergedTemplatesWithSerial, deleteTemplates) = _handlePiTokens(
      containerTokenTemplates: [...containerTokenTemplates, ...notLinkedSerialTemplates],
      serverTokensWithSerial: serverTokensWithSerial,
      container: container,
    );

    final updatedTokens = <Token>[];
    // Add updated Tokens
    for (var mergedTemplate in [...mergedTemplatesWithOtps, ...mergedTemplatesWithSerial]) {
      final token = container.addOriginToToken(token: mergedTemplate.toToken());
      updatedTokens.add(token);
    }

    final deleteTokens = deleteTemplates.map((e) => container.addOriginToToken(token: e.toToken())).toList();

    return ContainerSyncUpdates(
      newTokens: newTokens,
      updatedTokens: updatedTokens,
      deletedTokens: deleteTokens,
      newPolicies: syncResult.policies,
      containerSerial: container.serial,
    );
  }

  @override
  Future<ContainerFinalizationResponse> finalizeContainer(TokenContainerUnfinalized container, [EccUtils eccUtils = const EccUtils()]) async {
    final ecPrivateClientKey = container.ecPrivateClientKey;
    if (ecPrivateClientKey == null) {
      throw LocalizedException(localizedMessage: (l) => l.errorMissingPrivateKey, unlocalizedMessage: AppLocalizationsEn().errorMissingPrivateKey);
    }

    final passphrase = container.passphraseQuestion?.isNotEmpty == true ? await EnterPassphraseDialog.show(container.passphraseQuestion!) : null;
    final message = '${container.nonce}'
        '|${container.timestamp.toIso8601String().replaceFirst('Z', '+00:00')}'
        '|${container.serial}'
        '|${container.registrationUrl}'
        '${(container.addDeviceInfos == true) ? '|${InfoUtils.deviceBrand}' : ''}'
        '${(container.addDeviceInfos == true) ? '|${InfoUtils.deviceModel}' : ''}'
        '${passphrase != null ? '|$passphrase' : ''}';

    final signature = eccUtils.signWithPrivateKey(ecPrivateClientKey, message);

    final body = {
      TokenContainer.CONTAINER_SERIAL: container.serial,
      TokenContainer.FINALIZE_PUBLIC_CLIENT_KEY: container.publicClientKey,
      if (container.addDeviceInfos == true) TokenContainer.FINALIZE_DEVICE_BRAND: InfoUtils.deviceBrand,
      if (container.addDeviceInfos == true) TokenContainer.FINALIZE_DEVICE_MODEL: InfoUtils.deviceModel,
      TokenContainer.FINALIZE_SIGNATURE: signature,
    };
    final Response response = await _ioClient.doPost(url: container.registrationUrl, body: body, sslVerify: container.sslVerify);

    PiServerResponse<ContainerFinalizationResponse>? piResponse;
    try {
      piResponse = response.asPiServerResponse<ContainerFinalizationResponse>();
    } catch (e) {
      Logger.error('Failed to parse response', error: e);
      rethrow;
    }

    if (piResponse == null || piResponse.isError) {
      Logger.debug('Status code: ${response.statusCode}');
      Logger.debug('Response body: ${response.body}');
      final error = piResponse?.asError;
      if (error != null) throw error;
      throw ResponseError(response);
    }

    ContainerFinalizationResponse finalizationResponse;
    try {
      finalizationResponse = piResponse.asSuccess!.resultValue;
    } catch (e) {
      Logger.error('Failed to parse response', error: e);
      rethrow;
    }

    if (piResponse.isError) {
      Logger.error('Error while getting container finalization response: ${piResponse.asError!.piServerResultError}');
      throw piResponse.asError!.piServerResultError;
    }

    return finalizationResponse;
  }

  @override
  Future<TransferQrData> getRolloverQrData(TokenContainerFinalized container) async {
    if (container.policies.rolloverAllowed == false) {
      throw LocalizedException(
        localizedMessage: (l) => l.errorRolloverNotAllowed,
        unlocalizedMessage: AppLocalizationsEn().errorRolloverNotAllowed,
      );
    }
    final requestUrl = container.transferUrl;
    final challenge = await _getChallenge(container, requestUrl);

    final ecKeyPair = container.ecPrivateClientKey;
    if (ecKeyPair == null) {
      throw LocalizedException(localizedMessage: (l) => l.errorMissingPrivateKey, unlocalizedMessage: AppLocalizationsEn().errorMissingPrivateKey);
    }

    final signMessage = '${challenge.nonce}|${challenge.timeStamp}|${container.serial}|$requestUrl';
    Logger.debug(signMessage);

    final body = {
      TokenContainer.CONTAINER_SERIAL: container.serial,
      TokenContainer.SCOPE: '$requestUrl',
      ContainerChallenge.SIGNATURE: container.signMessage(signMessage),
    };

    final response = await _ioClient.doPost(url: requestUrl, body: body, sslVerify: container.sslVerify);
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

    return piResponse.asSuccess!.resultValue;
  }

  @override
  Future<UnregisterContainerResult> unregister(TokenContainerFinalized container) async {
    if (container.policies.disabledUnregister) {
      throw LocalizedException(
        localizedMessage: (l) => l.errorUnregisterNotAllowed,
        unlocalizedMessage: AppLocalizationsEn().errorUnregisterNotAllowed,
      );
    }
    final unregisterUrl = container.unregisterUrl;
    final ContainerChallenge challenge;
    try {
      challenge = await _getChallenge(container, unregisterUrl);
    } on PiServerResultError catch (e) {
      if (e.code == 3001 || e.code == 601) {
        return UnregisterContainerResult(success: true);
      }
      rethrow;
    }

    final body = {
      TokenContainer.CONTAINER_SERIAL: container.serial,
      TokenContainer.SCOPE: unregisterUrl.toString(),
      ContainerChallenge.SIGNATURE: container.signMessage('${challenge.nonce}|${challenge.timeStamp}|${container.serial}|$unregisterUrl'),
    };

    final response = await _ioClient.doPost(url: unregisterUrl, body: body, sslVerify: container.sslVerify);

    final piResponse = response.asPiServerResponse<UnregisterContainerResult>();
    final errorResponse = piResponse?.asError;
    if (errorResponse != null) {
      throw errorResponse.piServerResultError;
    }
    if (response.statusCode != 200 || piResponse == null) throw ResponseError(response);

    return piResponse.asSuccess!.resultValue;
  }

  /* //////////////////////////////
  /////// PRIVATE FUNCTIONS ///////
  ////////////////////////////// */

  Future<ContainerChallenge> _getChallenge(TokenContainerFinalized container, Uri requestUrl) async {
    final body = {
      TokenContainer.CONTAINER_SERIAL: container.serial,
      TokenContainer.SCOPE: requestUrl.toString(),
    };
    final challengeResponse = await _ioClient.doPost(url: container.challengeUrl, body: body, sslVerify: container.sslVerify);
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

  Future<ContainerSyncResult> _getContainerSyncResult({
    required TokenContainerFinalized container,
    required ContainerChallenge challenge,
    required List<Map<String, dynamic>> otpAuthMaps,
    required SimpleKeyPair encKeyPair,
  }) async {
    final publicKey = await encKeyPair.extractPublicKey();
    final publicKeyBase64 = base64.encode(publicKey.bytes);
    final containerDict = {
      TokenContainer.CONTAINER_SERIAL: container.serial,
      TokenContainer.DICT_TYPE: TokenContainer.DICT_TYPE_SMARTPHONE,
      TokenContainer.DICT_TOKENS: otpAuthMaps,
    };
    final signMessage = '${challenge.nonce}|${challenge.timeStamp}|${container.serial}|${container.syncUrl}|$publicKeyBase64|${jsonEncode(containerDict)}';
    Logger.debug(signMessage);
    final signature = container.signMessage(signMessage);
    Logger.debug('Sended container: ${jsonEncode(containerDict)}');
    final body = {
      TokenContainer.CONTAINER_SERIAL: container.serial,
      TokenContainer.SYNC_PUBLIC_CLIENT_KEY: publicKeyBase64,
      TokenContainer.SYNC_DICT_CLIENT: jsonEncode(containerDict),
      ContainerChallenge.SIGNATURE: signature,
    };

    final response = await _ioClient.doPost(url: container.syncUrl, body: body, sslVerify: container.sslVerify);
    if (response.statusCode != 200) {
      final piErrorResponse = response.asPiErrorResponse();
      if (piErrorResponse != null) throw piErrorResponse.piServerResultError;
      throw ResponseError(response);
    }

    final containerSyncResponse = PiServerResponse<ContainerSyncResult>.fromResponse(response);
    if (containerSyncResponse.isError) {
      throw containerSyncResponse.asError!.piServerResultError;
    }

    final syncResult = containerSyncResponse.asSuccess!.resultValue;
    return syncResult;
  }

  Future<Map<String, dynamic>> _getContainerDict({
    required ContainerSyncResult syncResult,
    required KeyPair encKeyPair,
  }) async {
    final algorithm = X25519();
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
      final otps = (serverTokenWithOtp[OTPToken.OTP_VALUES] as List).cast<String>();
      var mergedTemplate = maybePiTokensTemplates.firstWhereOrNull(
        (maybePiToken) => const IterableEquality().equals(otps, maybePiToken.otpValues),
      );
      if (mergedTemplate == null) {
        Logger.warning('Server token with otps not found in local tokens: ${serverTokenWithOtp[OTPToken.OTP_VALUES]}');
        continue;
      }
      mergedTemplate = mergedTemplate.withOtpAuthData(serverTokenWithOtp);
      mergedTemplate = mergedTemplate.copyWith(container: container);
      merged.add(mergedTemplate);
    }
    return merged;
  }

  (List<TokenTemplate>, List<TokenTemplate>) _handlePiTokens({
    required List<TokenTemplate> containerTokenTemplates,
    required List<Map<String, dynamic>> serverTokensWithSerial,
    required TokenContainerFinalized container,
  }) {
    final deleteSerials = <TokenTemplate>[];
    final mergedTemplatesWithSerial = <TokenTemplate>[];
    for (var containerToken in containerTokenTemplates) {
      final serverToken = serverTokensWithSerial.firstWhereOrNull((element) => element[Token.SERIAL] == containerToken.serial);
      serverTokensWithSerial.remove(serverToken);
      if (serverToken == null) {
        if (containerToken.containerSerial == container.serial) {
          deleteSerials.add(containerToken);
        }
      } else {
        var mergedTemplate = containerToken.withOtpAuthData(serverToken);
        mergedTemplate = mergedTemplate.copyWith(container: container);
        mergedTemplatesWithSerial.add(mergedTemplate);
      }
    }
    return (mergedTemplatesWithSerial, deleteSerials);
  }
}
