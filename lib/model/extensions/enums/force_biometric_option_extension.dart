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

import '../../../utils/logger.dart';
import '../../../utils/object_validator/object_validators.dart';
import '../../enums/force_biometric_option.dart';

extension ForceBiometricOptionX on ForceBiometricOption {
  static final validator = DefaultObjectValidator<ForceBiometricOption>(
    defaultValue: ForceBiometricOption.none,
    transformer: (v) {
      Logger.info('Transforming value to ForceBiometricOption: $v');
      if (v is ForceBiometricOption) return v;
      if (v is String) {
        return ForceBiometricOptionX.fromString(v)!;
      }
      Logger.warning(
        'Invalid type for ForceBiometricOption: ${v.runtimeType}, value: $v',
      );
      throw ArgumentError(
        'Invalid type for ForceBiometricOption: ${v.runtimeType}, value: $v',
      );
    },
  );

  static ForceBiometricOption? fromString(String? value) {
    if (value == null) return null;
    // cut "ForceBiometricOption." prefix if present
    final enumValue = value.contains('.') ? value.split('.').last : value;
    return ForceBiometricOption.values.firstWhere(
      (e) => e.name.toLowerCase() == enumValue.toLowerCase(),
      orElse: () {
        Logger.warning('Unknown ForceBiometricOption value: $value');
        throw ArgumentError('Invalid ForceBiometricOption value: $enumValue');
      },
    );
  }
}
