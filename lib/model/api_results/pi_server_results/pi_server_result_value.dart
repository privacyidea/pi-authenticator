/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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

import '../../../utils/logger.dart';
import '../../../utils/object_validator/object_validators.dart';
import '../../container_policies.dart';
import '../../encryption/encryption_params.dart';
import '../../token_container.dart';

sealed class PiServerResultValue {
  static V? fromResultValue<V extends PiServerResultValue>(dynamic value) {
    Logger.debug('PiServerResultValue.uriMapOfType<$V>');
    return switch (V) {
      const (PiServerResultValue) => null,
      const (ContainerChallenge) => ContainerChallenge.fromUriMap(value) as V,
      const (ContainerFinalizationResponse) =>
        ContainerFinalizationResponse.fromUriMap(value) as V,
      const (ContainerSyncResult) => ContainerSyncResult.fromUriMap(value) as V,
      const (TransferQrData) => TransferQrData.fromUriMap(value) as V,
      const (UnregisterContainerResult) =>
        UnregisterContainerResult.fromUriMap(value) as V,
      const (PushResultValue) => PushResultValue.fromResultValue(value) as V,
      _ => throw ArgumentError('No fromResultValue implementation for type $V'),
    };
  }

  const PiServerResultValue();
}

class PushResultValue extends PiServerResultValue {
  final bool value;

  static final validator = Validators.boolType;

  factory PushResultValue.fromResultValue(bool value) {
    return PushResultValue(value);
  }
  const PushResultValue(this.value);

  @override
  String toString() => 'PushResultValue(value: $value)';
}

class ContainerChallenge extends PiServerResultValue {
  static const String KEY_ALGORITHM = 'enc_key_algorithm';
  static const String NONCE = 'nonce';
  static const String TIMESTAMP = 'time_stamp';
  static const String SIGNATURE = 'signature';

  final String keyAlgorithm;
  final String nonce;
  final String timeStamp;

  DateTime get timeAsDatetime => DateTime.parse(timeStamp);

  static final validator = RequiredObjectValidator<Map<String, dynamic>>();

  const ContainerChallenge({
    required this.keyAlgorithm,
    required this.nonce,
    required this.timeStamp,
  });

  factory ContainerChallenge.fromUriMap(Map<String, dynamic> uriMap) {
    final map = validateMap(
      map: uriMap,
      validators: {
        KEY_ALGORITHM: Validators.string,
        NONCE: Validators.string,
        TIMESTAMP: Validators.string,
      },
      name: 'ContainerChallenge#fromUriMap',
    );
    return ContainerChallenge(
      keyAlgorithm: map[KEY_ALGORITHM] as String,
      nonce: map[NONCE] as String,
      timeStamp: map[TIMESTAMP] as String,
    );
  }
  @override
  String toString() =>
      'ContainerChallenge(keyAlgorithm: $keyAlgorithm, nonce: $nonce, timeStamp: $timeStamp)';
}

class ContainerFinalizationResponse extends PiServerResultValue {
  final ContainerPolicies policies;

  static final validator = RequiredObjectValidator<Map<String, dynamic>>();

  const ContainerFinalizationResponse({required this.policies});

  static ContainerFinalizationResponse fromUriMap(Map<String, dynamic> uriMap) {
    final map = validateMap(
      map: uriMap,
      validators: {TokenContainer.SYNC_POLICIES: ContainerPolicies.validator},
      name: 'ContainerFinalizationResponse#fromUriMap',
    );
    return ContainerFinalizationResponse(
      policies: map[TokenContainer.SYNC_POLICIES] as ContainerPolicies,
    );
  }

  @override
  String toString() => 'ContainerFinalizationResponse(policies: $policies)';
}

class ContainerSyncResult extends PiServerResultValue {
  final String containerDictEncrypted;
  final String encryptionAlgorithm;
  final EncryptionParams encryptionParams;
  final ContainerPolicies policies;
  final String publicServerKey;

  static final validator = RequiredObjectValidator<Map<String, dynamic>>();

  Uint8List get publicServerKeyBytes => base64Decode(publicServerKey);

  const ContainerSyncResult({
    required this.containerDictEncrypted,
    required this.encryptionAlgorithm,
    required this.encryptionParams,
    required this.policies,
    required this.publicServerKey,
  });

  static ContainerSyncResult fromUriMap(Map<String, dynamic> uriMap) {
    final map = validateMap(
      map: uriMap,
      validators: {
        TokenContainer.SYNC_DICT_SERVER: Validators.string,
        TokenContainer.SYNC_ENC_ALGORITHM: Validators.string,
        TokenContainer.SYNC_ENC_PARAMS: EncryptionParams.validator,
        TokenContainer.SYNC_POLICIES: ContainerPolicies.validator,
        TokenContainer.SYNC_PUBLIC_SERVER_KEY: Validators.string,
      },
      name: 'ContainerSyncResult#fromUriMap',
    );
    return ContainerSyncResult(
      containerDictEncrypted: map[TokenContainer.SYNC_DICT_SERVER] as String,
      encryptionAlgorithm: map[TokenContainer.SYNC_ENC_ALGORITHM] as String,
      encryptionParams: map[TokenContainer.SYNC_ENC_PARAMS] as EncryptionParams,
      policies: map[TokenContainer.SYNC_POLICIES] as ContainerPolicies,
      publicServerKey: map[TokenContainer.SYNC_PUBLIC_SERVER_KEY] as String,
    );
  }

  @override
  String toString() =>
      'ContainerSyncResult(containerDictEncrypted: $containerDictEncrypted, encryptionAlgorithm: $encryptionAlgorithm, encryptionParams: $encryptionParams, policies: $policies, publicServerKey: $publicServerKey)';
}

class TransferQrData extends PiServerResultValue {
  static const String KEY_CONTAINER_URL = 'container_url';
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_VALUE = 'value';

  final String description;
  final String value;

  static final validator = RequiredObjectValidator<Map<String, dynamic>>();

  const TransferQrData({required this.description, required this.value});

  factory TransferQrData.fromUriMap(Map<String, dynamic> uriMap) {
    final map = validateMap<String>(
      map: uriMap[KEY_CONTAINER_URL] as Map<String, dynamic>,
      validators: {
        KEY_DESCRIPTION: Validators.string,
        KEY_VALUE: Validators.string,
      },
      name: 'TransferQrData',
    );
    return TransferQrData(
      description: map[KEY_DESCRIPTION] as String,
      value: map[KEY_VALUE] as String,
    );
  }

  @override
  String toString() =>
      'TransferQrData(description: $description, value: $value)';
}

class UnregisterContainerResult extends PiServerResultValue {
  static const String KEY_SUCCESS = 'success';

  static final validator = RequiredObjectValidator<Map<String, dynamic>>();

  final bool success;

  const UnregisterContainerResult({required this.success});

  factory UnregisterContainerResult.fromUriMap(Map<String, dynamic> uriMap) {
    final map = validateMap(
      map: uriMap,
      validators: {KEY_SUCCESS: Validators.boolType},
      name: 'UnregisterContainerResultValue#fromUriMap',
    );
    return UnregisterContainerResult(success: map[KEY_SUCCESS] as bool);
  }

  @override
  String toString() => 'UnregisterContainerResult(success: $success)';
}
