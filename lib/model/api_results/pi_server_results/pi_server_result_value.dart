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

import 'package:pointycastle/ecc/api.dart';

import '../../../utils/ecc_utils.dart';
import '../../../utils/logger.dart';
import '../../../utils/object_validator.dart';
import '../../container_policies.dart';
import '../../encryption/encryption_params.dart';
import '../../token_container.dart';
import 'pi_server_result.dart';

sealed class PiServerResultValue extends PiServerResult {
  @override
  bool get status => true;

  static T fromJsonOfType<T extends PiServerResultValue>(Map<String, dynamic> json) {
    Logger.debug('PiServerResultValue.fromJsonOfType<$T>');
    return switch (T) {
      const (ContainerChallenge) => ContainerChallenge.fromJson(json) as T,
      const (ContainerFinalizationResponse) => ContainerFinalizationResponse.fromJson(json) as T,
      const (ContainerSyncResult) => ContainerSyncResult.fromJson(json) as T,
      const (TransferQrData) => TransferQrData.fromJson(json) as T,
      const (UnregisterContainerResultValue) => UnregisterContainerResultValue.fromJson(json) as T,
      _ => throw UnimplementedError('PiServerResultValue.fromJsonOfType<$T>'),
    };
  }

  const PiServerResultValue();
}

class ContainerChallenge extends PiServerResultValue {
// Container challenge:
  static const String KEY_ALGORITHM = 'enc_key_algorithm';
  static const String NONCE = 'nonce';
  static const String TIMESTAMP = 'time_stamp';
  static const String SIGNATURE = 'signature';

  final String keyAlgorithm;
  final String nonce;
  final String timeStamp;

  get timeAsDatetime => DateTime.parse(timeStamp);

  const ContainerChallenge({
    required this.keyAlgorithm,
    required this.nonce,
    required this.timeStamp,
  });

  factory ContainerChallenge.fromJson(Map<String, dynamic> json) {
    final map = validateMap(
      map: json,
      validators: {
        KEY_ALGORITHM: const ObjectValidator<String>(),
        NONCE: const ObjectValidator<String>(),
        TIMESTAMP: const ObjectValidator<String>(),
      },
      name: 'ContainerChallenge#fromJson',
    );
    return ContainerChallenge(
      keyAlgorithm: map[KEY_ALGORITHM] as String,
      nonce: map[NONCE] as String,
      timeStamp: map[TIMESTAMP] as String,
    );
  }
}

class ContainerFinalizationResponse extends PiServerResultValue {
  final ECPublicKey publicServerKey;
  final ContainerPolicies policies;

  const ContainerFinalizationResponse({
    required this.publicServerKey,
    required this.policies,
  });

  static ContainerFinalizationResponse fromJson(Map<String, dynamic> json) {
    final map = validateMap(
      map: json,
      validators: {
        TokenContainer.SYNC_PUBLIC_SERVER_KEY: ObjectValidator<ECPublicKey>(transformer: (v) => const EccUtils().deserializeECPublicKey(v)),
        TokenContainer.SYNC_POLICIES: ObjectValidator<ContainerPolicies>(transformer: (v) => ContainerPolicies.fromUriMap(v)),
      },
      name: 'ContainerFinalizationResponse#fromJson',
    );
    return ContainerFinalizationResponse(
      publicServerKey: map[TokenContainer.SYNC_PUBLIC_SERVER_KEY] as ECPublicKey,
      policies: map[TokenContainer.SYNC_POLICIES] as ContainerPolicies,
    );
  }
}

class ContainerSyncResult extends PiServerResultValue {
  final String containerDictEncrypted;
  final String encryptionAlgorithm;
  final EncryptionParams encryptionParams;
  final ContainerPolicies policies;
  final String publicServerKey;
  final String serverUrl;

  Uint8List get publicServerKeyBytes => base64Decode(publicServerKey);

  const ContainerSyncResult({
    required this.containerDictEncrypted,
    required this.encryptionAlgorithm,
    required this.encryptionParams,
    required this.policies,
    required this.publicServerKey,
    required this.serverUrl,
  });

  static ContainerSyncResult fromJson(Map<String, dynamic> json) {
    final map = validateMap(
      map: json,
      validators: {
        TokenContainer.SYNC_DICT_SERVER: const ObjectValidator<String>(),
        TokenContainer.SYNC_ENC_ALGORITHM: const ObjectValidator<String>(),
        TokenContainer.SYNC_ENC_PARAMS: ObjectValidator<EncryptionParams>(transformer: (v) => EncryptionParams.fromParams(v)),
        TokenContainer.SYNC_POLICIES: ObjectValidator<ContainerPolicies>(transformer: (v) => ContainerPolicies.fromUriMap(v)),
        TokenContainer.SYNC_PUBLIC_SERVER_KEY: const ObjectValidator<String>(),
        TokenContainer.SYNC_SERVER_URL: const ObjectValidator<String>(),
      },
      name: 'ContainerSyncResult#fromJson',
    );
    return ContainerSyncResult(
      containerDictEncrypted: map[TokenContainer.SYNC_DICT_SERVER] as String,
      encryptionAlgorithm: map[TokenContainer.SYNC_ENC_ALGORITHM] as String,
      encryptionParams: map[TokenContainer.SYNC_ENC_PARAMS] as EncryptionParams,
      policies: map[TokenContainer.SYNC_POLICIES] as ContainerPolicies,
      publicServerKey: map[TokenContainer.SYNC_PUBLIC_SERVER_KEY] as String,
      serverUrl: map[TokenContainer.SYNC_SERVER_URL] as String,
    );
  }
}

class TransferQrData extends PiServerResultValue {
  final String description;
  final String value;
  TransferQrData(this.description, this.value);

  factory TransferQrData.fromJson(Map<String, dynamic> json) {
    Logger.debug(jsonEncode(json));
    final map = validateMap<String>(
      map: json['container_url'] as Map<String, dynamic>,
      validators: {
        'description': const ObjectValidator<String>(),
        'value': const ObjectValidator<String>(),
      },
      name: 'TransferQrData',
    );
    return TransferQrData(map['description'] as String, map['value'] as String);
  }
}

class UnregisterContainerResultValue extends PiServerResultValue {
  static const String CONTAINER_UNREGISTER_SUCCESS = 'success';

  final bool success;

  const UnregisterContainerResultValue({
    required this.success,
  });

  factory UnregisterContainerResultValue.fromJson(Map<String, dynamic> json) {
    final map = validateMap(
      map: json,
      validators: {
        CONTAINER_UNREGISTER_SUCCESS: const ObjectValidator<bool>(),
      },
      name: 'UnregisterContainerResultValue#fromJson',
    );
    return UnregisterContainerResultValue(
      success: map[CONTAINER_UNREGISTER_SUCCESS] as bool,
    );
  }
}
