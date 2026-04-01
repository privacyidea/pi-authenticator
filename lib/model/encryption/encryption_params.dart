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
import '../../utils/object_validator/object_validators.dart';

class EncryptionParams {
  static const String SYNC_ENC_PARAMS_ALGORITHM = 'algorithm';
  static const String SYNC_ENC_PARAMS_IV = 'init_vector';
  static const String SYNC_ENC_PARAMS_MODE = 'mode';
  static const String SYNC_ENC_PARAMS_TAG = 'tag';

  final String algorithm;
  final String initVector;
  final String mode;
  final String tag;

  static final validator = RequiredObjectValidator<EncryptionParams>(
    transformer: (v) {
      if (v is Map<String, dynamic>) {
        return EncryptionParams.fromUriMap(v);
      }
      throw ArgumentError(
        'Invalid type for EncryptionParams: ${v.runtimeType}, value: $v',
      );
    },
  );
  const EncryptionParams({
    required this.algorithm,
    required this.mode,
    required this.initVector,
    required this.tag,
  });

  static EncryptionParams fromUriMap(Map<String, dynamic> responseBody) {
    final map = validateMap(
      map: responseBody,
      validators: <String, BaseValidator>{
        SYNC_ENC_PARAMS_ALGORITHM: Validators.string,
        SYNC_ENC_PARAMS_IV: Validators.string,
        SYNC_ENC_PARAMS_MODE: Validators.string,
        SYNC_ENC_PARAMS_TAG: Validators.string,
      },
      name: 'EncryptionParams#fromResponseBody',
    );
    return EncryptionParams(
      algorithm: map[SYNC_ENC_PARAMS_ALGORITHM] as String,
      initVector: map[SYNC_ENC_PARAMS_IV] as String,
      mode: map[SYNC_ENC_PARAMS_MODE] as String,
      tag: map[SYNC_ENC_PARAMS_TAG] as String,
    );
  }

  Map<String, dynamic> toUriMap() => {
    SYNC_ENC_PARAMS_ALGORITHM: algorithm,
    SYNC_ENC_PARAMS_IV: initVector,
    SYNC_ENC_PARAMS_MODE: mode,
    SYNC_ENC_PARAMS_TAG: tag,
  };
}
