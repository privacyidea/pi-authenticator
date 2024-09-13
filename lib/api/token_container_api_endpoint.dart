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
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:cryptography/cryptography.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/otp_auth_processor.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';

import '../model/riverpod_states/token_state.dart';
import '../model/token_template.dart';
import '../model/tokens/container_credentials.dart';
import '../model/tokens/token.dart';
import '../utils/globals.dart';
import '../utils/identifiers.dart';
import '../utils/logger.dart';
import '../widgets/dialog_widgets/enter_passphrase_dialog.dart';

part 'token_container_api_endpoint.freezed.dart';

class PrivacyideaContainerApi {
  final PrivacyideaIOClient _ioClient;
  const PrivacyideaContainerApi({required PrivacyideaIOClient ioClient}) : _ioClient = ioClient;

  // Returns a tuple of updated/new tokens and serials of deleted tokens
  Future<(List<Token>, List<String>)?> sync(ContainerCredentialFinalized container, TokenState tokenState) async {
    final containerTokenTemplates = tokenState.containerTokens(container.serial).toTemplates();
    final maybePiTokensTemplates = tokenState.maybePiTokens.toTemplates();

    final ContainerChallenge? challenge = await _getChallenge(container);
    if (challenge == null) return null;

    final decryptedContainerDictJson = await _getContainerDict(
      container: container,
      challenge: challenge,
      otpAuthMaps: [
        for (var template in [...containerTokenTemplates, ...maybePiTokensTemplates]) template.otpAuthMapSafeToSend
      ],
    );
    if (decryptedContainerDictJson == null) return null;

    final tokens = decryptedContainerDictJson[CONTAINER_DICT_TOKENS] as Map<String, dynamic>;
    final newOtpAuthTokens = (tokens[CONTAINER_DICT_TOKENS_ADD] as List).cast<String>().map(Uri.parse).toList();
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

  Future<Response?> finalizeContainer(ContainerCredentialUnfinalized container, EccUtils eccUtils) async {
    final ecPrivateClientKey = container.ecPrivateClientKey;
    if (ecPrivateClientKey == null) return null;

    final passphrase = container.passphraseQuestion?.isNotEmpty == true ? await EnterPassphraseDialog.show(await globalContext) : null;
    final message = '${container.nonce}'
        '|${container.timestamp.toIso8601String().replaceFirst('Z', '+00:00')}'
        '|${container.finalizationUrl}'
        '|${container.serial}'
        '${passphrase != null ? '|$passphrase' : ''}';

    final signature = eccUtils.signWithPrivateKey(ecPrivateClientKey, message);

    final body = {
      'container_serial': container.serial,
      'public_client_key': container.publicClientKey,
      'signature': signature,
    };

    return _ioClient.doPost(url: container.finalizationUrl, body: body, sslVerify: false); //TODO: sslVerify
  }

  /* ////////////////////////////
  ////// PRIVATE FUNCTIONS //////
  ////////////////////////////// */

  Future<ContainerChallenge?> _getChallenge(ContainerCredentialFinalized container) async {
    final initResponse = await _ioClient.doGet(url: container.syncUrl, parameters: {CONTAINER_SERIAL: container.serial});
    try {
      Logger.debug('Received container sync challenge: ${initResponse.body}', name: 'TokenContainerApiEndpoint#sync');
      final piResponse = PiServerResponse<ContainerChallenge>.fromResponse(initResponse);
      if (piResponse.isError) {
        Logger.error('Error while syncing container: ${piResponse.asError.resultError}', name: 'TokenContainerApiEndpoint#sync');
        return null;
      }
      return piResponse.asSuccess.resultValue;
    } catch (e, s) {
      Logger.error('Error while syncing container: $e', name: 'TokenContainerApiEndpoint#sync', stackTrace: s);
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getContainerDict({
    required ContainerCredentialFinalized container,
    required ContainerChallenge challenge,
    required List<Map> otpAuthMaps,
  }) async {
    final encKeyPair = await X25519().newKeyPair();
    final publicKey = await encKeyPair.extractPublicKey();

    final algorithm = X25519();

    final publicKeyBase64 = base64.encode(publicKey.bytes);

    final containerDict = {
      CONTAINER_DICT_SERIAL: container.serial,
      CONTAINER_DICT_TYPE: 'smartphone',
      'tokens': otpAuthMaps,
    };
    final signMessage =
        '${challenge.nonce}|${challenge.timeStamp}|${container.serial}|${challenge.finalizeSyncUrl}|$publicKeyBase64|${jsonEncode(containerDict)}';
    Logger.debug(signMessage);
    final signature = container.signMessage(signMessage);
    Logger.debug('Sended container: ${jsonEncode(containerDict)}');
    final body = <String, String>{
      CONTAINER_SYNC_SIGNATURE: signature,
      CONTAINER_SYNC_PUBLIC_CLIENT_KEY: publicKeyBase64,
      CONTAINER_SYNC_DICT_CLIENT: jsonEncode(containerDict),
    };

    final response = await _ioClient.doPost(url: Uri.parse(challenge.finalizeSyncUrl), body: body);
    final containerSyncResponse = PiServerResponse<ContainerSyncResult>.fromResponse(response);
    if (containerSyncResponse.isError) {
      Logger.error('Error while syncing container: ${containerSyncResponse.asError.resultError}', name: 'TokenContainerApiEndpoint#sync');
      return null;
    }

    final syncResult = containerSyncResponse.asSuccess.resultValue;

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

  Future<List<Token>> _parseNewTokens({required ContainerCredentialFinalized container, required List<Uri> otpAuthUris}) async {
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
    required ContainerCredentialFinalized container,
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
    required ContainerCredentialFinalized container,
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
}

abstract class PiServerResult {
  bool get status;
  PiServerResultError? get asError => this is PiServerResultError ? this as PiServerResultError : null;
  PiServerResultValue? get asValue => this is PiServerResultValue ? this as PiServerResultValue : null;
  const PiServerResult();
}

@freezed
class PiServerResponse<T extends PiServerResultValue> with _$PiServerResponse {
  static const RESULT = 'result';
  static const DETAIL = 'detail';
  static const ID = 'id';
  static const JSONRPC = 'jsonrpc';
  static const TIME = 'time';
  static const VERSION = 'version';
  static const SIGNATURE = 'signature';

  static const RESULT_STATUS = 'status';
  static const RESULT_VALUE = 'value';
  static const RESULT_ERROR = 'error';

  const PiServerResponse._();
  factory PiServerResponse.success({
    required dynamic detail,
    required int id,
    required String jsonrpc,
    required T resultValue,
    required double time,
    required String version,
    required String signature,
  }) = PiServerResponseSuccess;
  bool get isSuccess => this is PiServerResponseSuccess;
  PiServerResponseSuccess<T> get asSuccess => this as PiServerResponseSuccess<T>;

  factory PiServerResponse.error({
    required dynamic detail,
    required int id,
    required String jsonrpc,
    required PiServerResultError resultError,
    required double time,
    required String version,
    required String signature,
  }) = PiServerResponseError;
  bool get isError => this is PiServerResponseError;
  PiServerResponseError get asError => this as PiServerResponseError;

  factory PiServerResponse.fromJson(Map<String, dynamic> json) {
    Logger.debug('Received container sync response: $json', name: 'PiServerResponse#fromJson');
    final map = validateMap<dynamic>(
      map: json,
      validators: {
        RESULT: const TypeValidatorRequired<Map<String, dynamic>>(),
        ID: const TypeValidatorRequired<int>(),
        JSONRPC: const TypeValidatorRequired<String>(),
        DETAIL: const TypeValidatorOptional<dynamic>(),
        TIME: const TypeValidatorRequired<double>(),
        VERSION: const TypeValidatorRequired<String>(),
        SIGNATURE: const TypeValidatorRequired<String>(),
      },
      name: 'PiServerResponse#fromJson',
    );
    final result = validateMap<dynamic>(
      map: map[RESULT],
      validators: {
        RESULT_STATUS: const TypeValidatorRequired<bool>(),
        RESULT_VALUE: const TypeValidatorOptional<Map<String, dynamic>>(),
        RESULT_ERROR: const TypeValidatorOptional<Map<String, dynamic>>(),
      },
      name: 'PiServerResponse#fromJson#result',
    );
    if (result[RESULT_STATUS] == true && result.containsKey(RESULT_VALUE)) {
      return PiServerResponse.success(
        detail: map[DETAIL],
        id: map[ID],
        jsonrpc: map[JSONRPC],
        resultValue: PiServerResultValue.fromJsonOfType<T>(result[RESULT_VALUE]),
        time: map[TIME],
        version: map[VERSION],
        signature: map[SIGNATURE],
      );
    }
    if (result[RESULT_STATUS] == false && result.containsKey(RESULT_ERROR)) {
      return PiServerResponse.error(
        detail: map[DETAIL],
        id: json[ID],
        jsonrpc: map[JSONRPC],
        resultError: PiServerResultError.fromJson(result[RESULT_ERROR]),
        time: map[TIME],
        version: map[VERSION],
        signature: map[SIGNATURE],
      );
    }
    Logger.info(
        'Status: ${result[RESULT_STATUS]}'
        '\nContains error: ${result.containsKey(RESULT_ERROR)}'
        '\nContains value: ${result.containsKey(RESULT_VALUE)}',
        name: 'PiServerResponse#fromJson');

    throw UnimplementedError('Unknown PiServerResponse type');
  }

  factory PiServerResponse.fromResponse(Response response) {
    return PiServerResponse.fromJson(jsonDecode(response.body));
  }
}

class EncryptionParams {
  final String algorithm;
  final String initVector;
  final String mode;
  final String tag;

  const EncryptionParams({
    required this.algorithm,
    required this.mode,
    required this.initVector,
    required this.tag,
  });

  static EncryptionParams fromJson(Map<String, dynamic> json) {
    final map = validateMap(
      map: json,
      validators: {
        'algorithm': const TypeValidatorRequired<String>(),
        'init_vector': const TypeValidatorRequired<String>(),
        'mode': const TypeValidatorRequired<String>(),
        'tag': const TypeValidatorRequired<String>(),
      },
      name: 'EncryptionParams#fromJson',
    );
    return EncryptionParams(
      algorithm: map['algorithm'] as String,
      initVector: map['init_vector'] as String,
      mode: map['mode'] as String,
      tag: map['tag'] as String,
    );
  }
}
/* ////////////////////////////
////// PI SERVER RESULTS //////
//////////////////////////// */

class PiServerResultError extends PiServerResult {
  @override
  bool get status => false;
  final int code;
  final String message;

  const PiServerResultError({
    required this.code,
    required this.message,
  });

  factory PiServerResultError.fromJson(Map<String, dynamic> json) {
    final map = validateMap(
      map: json,
      validators: {
        PI_SERVER_ERROR_CODE: const TypeValidatorRequired<int>(),
        PI_SERVER_ERROR_MESSAGE: const TypeValidatorRequired<String>(),
      },
      name: 'PiServerResultError#fromJson',
    );
    return PiServerResultError(
      code: map[PI_SERVER_ERROR_CODE] as int,
      message: map[PI_SERVER_ERROR_MESSAGE] as String,
    );
  }
  @override
  String toString() => 'PiError(code: $code, message: $message)';
}

sealed class PiServerResultValue extends PiServerResult {
  @override
  bool get status => true;

  static T fromJsonOfType<T extends PiServerResultValue>(Map<String, dynamic> json) {
    return switch (T) {
      const (ContainerChallenge) => ContainerChallenge.fromJson(json) as T,
      const (ContainerSyncResult) => ContainerSyncResult.fromJson(json) as T,
      _ => throw UnimplementedError('Unknown PiServerResultValue type'),
    };
  }

  const PiServerResultValue();
}

class ContainerChallenge extends PiServerResultValue {
  final String finalizeSyncUrl;
  final String keyAlgorithm;
  final String nonce;
  final String timeStamp;

  get timeAsDatetime => DateTime.parse(timeStamp);

  const ContainerChallenge({
    required this.finalizeSyncUrl,
    required this.keyAlgorithm,
    required this.nonce,
    required this.timeStamp,
  });

  factory ContainerChallenge.fromJson(Map<String, dynamic> json) {
    final map = validateMap(
      map: json,
      validators: {
        CONTAINER_SYNC_URL: const TypeValidatorRequired<String>(),
        CONTAINER_SYNC_KEY_ALGORITHM: const TypeValidatorRequired<String>(),
        CONTAINER_SYNC_NONCE: const TypeValidatorRequired<String>(),
        CONTAINER_SYNC_TIMESTAMP: const TypeValidatorRequired<String>(),
      },
      name: 'ContainerChallenge#fromJson',
    );
    return ContainerChallenge(
      finalizeSyncUrl: map[CONTAINER_SYNC_URL] as String,
      keyAlgorithm: map[CONTAINER_SYNC_KEY_ALGORITHM] as String,
      nonce: map[CONTAINER_SYNC_NONCE] as String,
      timeStamp: map[CONTAINER_SYNC_TIMESTAMP] as String,
    );
  }
}

class ContainerSyncResult extends PiServerResultValue {
  final String publicServerKey;
  Uint8List get publicServerKeyBytes => base64Decode(publicServerKey);
  final String encryptionAlgorithm;
  final EncryptionParams encryptionParams;
  final String containerDictEncrypted;

  const ContainerSyncResult({
    required this.publicServerKey,
    required this.encryptionAlgorithm,
    required this.encryptionParams,
    required this.containerDictEncrypted,
  });

  static ContainerSyncResult fromJson(Map<String, dynamic> json) {
    final map = validateMap(
      map: json,
      validators: {
        CONTAINER_SYNC_PUBLIC_SERVER_KEY: const TypeValidatorRequired<String>(),
        CONTAINER_SYNC_ENC_ALGORITHM: const TypeValidatorRequired<String>(),
        CONTAINER_SYNC_ENC_PARAMS: TypeValidatorRequired<EncryptionParams>(transformer: (v) => EncryptionParams.fromJson(v)),
        CONTAINER_SYNC_DICT_SERVER: const TypeValidatorRequired<String>(),
      },
      name: 'ContainerSyncResult#fromJson',
    );
    return ContainerSyncResult(
      publicServerKey: map[CONTAINER_SYNC_PUBLIC_SERVER_KEY] as String,
      encryptionAlgorithm: map[CONTAINER_SYNC_ENC_ALGORITHM] as String,
      encryptionParams: map[CONTAINER_SYNC_ENC_PARAMS] as EncryptionParams,
      containerDictEncrypted: map[CONTAINER_SYNC_DICT_SERVER] as String,
    );
  }
}
