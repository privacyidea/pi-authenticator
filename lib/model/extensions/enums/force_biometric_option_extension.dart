/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License atHG$%
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import '../../../utils/object_validator/required_object_validator.dart';
import '../../tokens/token.dart';

extension ForceBiometricOptionX on ForceBiometricOption {
  static final validator = RequiredObjectValidator<ForceBiometricOption>(
    transformer: (v) {
      if (v is ForceBiometricOption) return v;
      if (v is String) {
        return ForceBiometricOptionX.fromString(v)!;
      }
      throw ArgumentError(
        'Invalid type for ForceBiometricOption: ${v.runtimeType}, value: $v',
      );
    },
  );

  static ForceBiometricOption? fromString(String? value) {
    if (value == null) return null;
    return ForceBiometricOption.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () =>
          throw ArgumentError('Invalid ForceBiometricOption value: $value'),
    );
  }
}
