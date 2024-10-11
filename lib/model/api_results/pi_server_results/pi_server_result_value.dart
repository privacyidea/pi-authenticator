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

import 'package:pointycastle/ecc/api.dart';

import '../../../utils/ecc_utils.dart';
import '../../../utils/identifiers.dart';
import '../../../utils/object_validator.dart';
import '../../encryption/encryption_params.dart';
import 'pi_server_result.dart';

sealed class PiServerResultValue extends PiServerResult {
  @override
  bool get status => true;

  static T? fromJsonOfType<T extends PiServerResultValue>(Map<String, dynamic> json) {
    return switch (T) {
      const (ContainerFinalizationChallenge) => ContainerFinalizationChallenge.fromJson(json) as T,
      const (ContainerFinalizationResponse) => ContainerFinalizationResponse.fromJson(json) as T,
      const (ContainerSyncResult) => ContainerSyncResult.fromJson(json) as T,
      _ => null,
    };
  }

  const PiServerResultValue();
}

class ContainerFinalizationChallenge extends PiServerResultValue {
  final String finalizeSyncUrl;
  final String keyAlgorithm;
  final String nonce;
  final String timeStamp;

  get timeAsDatetime => DateTime.parse(timeStamp);

  const ContainerFinalizationChallenge({
    required this.finalizeSyncUrl,
    required this.keyAlgorithm,
    required this.nonce,
    required this.timeStamp,
  });

  factory ContainerFinalizationChallenge.fromJson(Map<String, dynamic> json) {
    final map = validateMap(
      map: json,
      validators: {
        CONTAINER_SYNC_URL: const ObjectValidator<String>(),
        CONTAINER_SYNC_KEY_ALGORITHM: const ObjectValidator<String>(),
        CONTAINER_SYNC_NONCE: const ObjectValidator<String>(),
        CONTAINER_SYNC_TIMESTAMP: const ObjectValidator<String>(),
      },
      name: 'ContainerChallenge#fromJson',
    );
    return ContainerFinalizationChallenge(
      finalizeSyncUrl: map[CONTAINER_SYNC_URL] as String,
      keyAlgorithm: map[CONTAINER_SYNC_KEY_ALGORITHM] as String,
      nonce: map[CONTAINER_SYNC_NONCE] as String,
      timeStamp: map[CONTAINER_SYNC_TIMESTAMP] as String,
    );
  }
}

class ContainerFinalizationResponse extends PiServerResultValue {
  final ECPublicKey publicServerKey;
  final Uri syncUrl;

  const ContainerFinalizationResponse({
    required this.publicServerKey,
    required this.syncUrl,
  });

  static ContainerFinalizationResponse fromJson(Map<String, dynamic> json) {
    final map = validateMap(
      map: json,
      validators: {
        CONTAINER_SYNC_PUBLIC_SERVER_KEY: ObjectValidator<ECPublicKey>(transformer: (v) => const EccUtils().deserializeECPublicKey(v)),
        CONTAINER_SYNC_URL: ObjectValidator<Uri>(transformer: (v) => Uri.parse(v)),
      },
      name: 'ContainerFinalizationResponse#fromJson',
    );
    return ContainerFinalizationResponse(
      publicServerKey: map[CONTAINER_SYNC_PUBLIC_SERVER_KEY] as ECPublicKey,
      syncUrl: map[CONTAINER_SYNC_URL] as Uri,
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
        CONTAINER_SYNC_PUBLIC_SERVER_KEY: const ObjectValidator<String>(),
        CONTAINER_SYNC_ENC_ALGORITHM: const ObjectValidator<String>(),
        CONTAINER_SYNC_ENC_PARAMS: ObjectValidator<EncryptionParams>(transformer: (v) => EncryptionParams.fromParams(v)),
        CONTAINER_SYNC_DICT_SERVER: const ObjectValidator<String>(),
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
