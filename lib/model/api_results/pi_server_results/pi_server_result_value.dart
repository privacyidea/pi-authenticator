/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
import '../../../utils/object_validator.dart';
import '../../container_policies.dart';
import '../../encryption/encryption_params.dart';
import '../../token_container.dart';
import 'pi_server_result.dart';

sealed class PiServerResultValue<V> extends PiServerResult {
  @override
  bool get status => true;

  static T fromResultValue<T extends PiServerResultValue>(dynamic value) {
    Logger.debug('PiServerResultValue.uriMapOfType<$T>');
    return switch (T) {
      const (ContainerChallenge) => ContainerChallenge.fromUriMap(value) as T,
      const (ContainerFinalizationResponse) =>
        ContainerFinalizationResponse.fromUriMap(value) as T,
      const (ContainerSyncResult) => ContainerSyncResult.fromUriMap(value) as T,
      const (TransferQrData) => TransferQrData.fromUriMap(value) as T,
      const (UnregisterContainerResult) =>
        UnregisterContainerResult.fromUriMap(value) as T,
      const (BooleanResultValue) => BooleanResultValue.fromUriMap(value) as T,
      _ => throw UnimplementedError('PiServerResultValue.fromUriMapOfType<$T>'),
    };
  }

  static ObjectValidator<dynamic>
  getValidatorFor<T extends PiServerResultValue>() {
    return switch (T) {
      const (ContainerChallenge) => ContainerChallenge.validator,
      const (ContainerFinalizationResponse) =>
        ContainerFinalizationResponse.validator,
      const (ContainerSyncResult) => ContainerSyncResult.validator,
      const (TransferQrData) => TransferQrData.validator,
      const (UnregisterContainerResult) => UnregisterContainerResult.validator,
      const (BooleanResultValue) => BooleanResultValue.validator,
      _ => throw UnimplementedError(
        'No validator implemented for PiServerResultValue of type $T',
      ),
    };
  }

  V toResultValue();

  const PiServerResultValue();
}

class BooleanResultValue extends PiServerResultValue<bool> {
  static const String KEY_VALUE = 'value';
  static const String KEY_STATUS = 'status';

  @override
  final bool status;
  final bool value;

  static const validator = ObjectValidator<Map<String, dynamic>>();

  factory BooleanResultValue.fromUriMap(Map<String, dynamic> uriMap) {
    final map = validateMap(
      map: uriMap,
      validators: {
        KEY_VALUE: const ObjectValidator<bool>(),
        KEY_STATUS: const ObjectValidator<bool>(),
      },
      name: 'BooleanResultValue#fromUriMap',
    );
    return BooleanResultValue(
      value: map[KEY_VALUE] as bool,
      status: map[KEY_STATUS] as bool,
    );
  }
  const BooleanResultValue({required this.value, required this.status});

  @override
  bool toResultValue() {
    return value;
  }
}

class ContainerChallenge extends PiServerResultValue<Map<String, dynamic>> {
  // Container challenge:
  static const String KEY_ALGORITHM = 'enc_key_algorithm';
  static const String NONCE = 'nonce';
  static const String TIMESTAMP = 'time_stamp';
  static const String SIGNATURE = 'signature';

  final String keyAlgorithm;
  final String nonce;
  final String timeStamp;

  DateTime get timeAsDatetime => DateTime.parse(timeStamp);

  static const validator = ObjectValidator<Map<String, dynamic>>();

  const ContainerChallenge({
    required this.keyAlgorithm,
    required this.nonce,
    required this.timeStamp,
  });

  factory ContainerChallenge.fromUriMap(Map<String, dynamic> uriMap) {
    final map = validateMap(
      map: uriMap,
      validators: {
        KEY_ALGORITHM: const ObjectValidator<String>(),
        NONCE: const ObjectValidator<String>(),
        TIMESTAMP: const ObjectValidator<String>(),
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
  Map<String, dynamic> toResultValue() {
    return {KEY_ALGORITHM: keyAlgorithm, NONCE: nonce, TIMESTAMP: timeStamp};
  }
}

class ContainerFinalizationResponse
    extends PiServerResultValue<Map<String, dynamic>> {
  final ContainerPolicies policies;

  static const validator = ObjectValidator<Map<String, dynamic>>();

  const ContainerFinalizationResponse({required this.policies});

  static ContainerFinalizationResponse fromUriMap(Map<String, dynamic> uriMap) {
    final map = validateMap(
      map: uriMap,
      validators: {
        TokenContainer.SYNC_POLICIES: ObjectValidator<ContainerPolicies>(
          transformer: (v) => ContainerPolicies.fromUriMap(v),
        ),
      },
      name: 'ContainerFinalizationResponse#fromUriMap',
    );
    return ContainerFinalizationResponse(
      policies: map[TokenContainer.SYNC_POLICIES] as ContainerPolicies,
    );
  }

  @override
  Map<String, dynamic> toResultValue() {
    return {TokenContainer.SYNC_POLICIES: policies.toJson()};
  }
}

class ContainerSyncResult extends PiServerResultValue<Map<String, dynamic>> {
  final String containerDictEncrypted;
  final String encryptionAlgorithm;
  final EncryptionParams encryptionParams;
  final ContainerPolicies policies;
  final String publicServerKey;

  static const validator = ObjectValidator<Map<String, dynamic>>();

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
        TokenContainer.SYNC_DICT_SERVER: const ObjectValidator<String>(),
        TokenContainer.SYNC_ENC_ALGORITHM: const ObjectValidator<String>(),
        TokenContainer.SYNC_ENC_PARAMS: ObjectValidator<EncryptionParams>(
          transformer: (v) => EncryptionParams.fromUriMap(v),
        ),
        TokenContainer.SYNC_POLICIES: ObjectValidator<ContainerPolicies>(
          transformer: (v) => ContainerPolicies.fromUriMap(v),
        ),
        TokenContainer.SYNC_PUBLIC_SERVER_KEY: const ObjectValidator<String>(),
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
  Map<String, dynamic> toResultValue() {
    return {
      TokenContainer.SYNC_DICT_SERVER: containerDictEncrypted,
      TokenContainer.SYNC_ENC_ALGORITHM: encryptionAlgorithm,
      TokenContainer.SYNC_ENC_PARAMS: encryptionParams.toUriMap(),
      TokenContainer.SYNC_POLICIES: policies.toUriMap(),
      TokenContainer.SYNC_PUBLIC_SERVER_KEY: publicServerKey,
    };
  }
}

class TransferQrData extends PiServerResultValue<Map<String, dynamic>> {
  final String description;
  final String value;

  static const validator = ObjectValidator<Map<String, dynamic>>();

  const TransferQrData({required this.description, required this.value});

  factory TransferQrData.fromUriMap(Map<String, dynamic> uriMap) {
    final map = validateMap<String>(
      map: uriMap['container_url'] as Map<String, dynamic>,
      validators: {
        'description': const ObjectValidator<String>(),
        'value': const ObjectValidator<String>(),
      },
      name: 'TransferQrData',
    );
    return TransferQrData(
      description: map['description'] as String,
      value: map['value'] as String,
    );
  }

  @override
  Map<String, dynamic> toResultValue() {
    return {
      'container_url': {'description': description, 'value': value},
    };
  }
}

class UnregisterContainerResult
    extends PiServerResultValue<Map<String, dynamic>> {
  static const String CONTAINER_UNREGISTER_SUCCESS = 'success';

  static const validator = ObjectValidator<Map<String, dynamic>>();

  final bool success;

  const UnregisterContainerResult({required this.success});

  factory UnregisterContainerResult.fromUriMap(Map<String, dynamic> uriMap) {
    final map = validateMap(
      map: uriMap,
      validators: {CONTAINER_UNREGISTER_SUCCESS: const ObjectValidator<bool>()},
      name: 'UnregisterContainerResultValue#fromUriMap',
    );
    return UnregisterContainerResult(
      success: map[CONTAINER_UNREGISTER_SUCCESS] as bool,
    );
  }

  @override
  Map<String, dynamic> toResultValue() {
    return {CONTAINER_UNREGISTER_SUCCESS: success};
  }
}
