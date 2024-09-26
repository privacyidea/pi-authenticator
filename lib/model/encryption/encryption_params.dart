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
import '../../utils/object_validator.dart';

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

  static EncryptionParams fromParams(Map<String, dynamic> json) {
    final map = validateMap(
      map: json,
      validators: {
        'algorithm': const ObjectValidator<String>(),
        'init_vector': const ObjectValidator<String>(),
        'mode': const ObjectValidator<String>(),
        'tag': const ObjectValidator<String>(),
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
