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
import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';

import '../model/enums/algorithms.dart';
import '../model/enums/encodings.dart';
import 'identifiers.dart';

final otpAutjPeriodSecondsValidatorNullable = otpAutjPeriodSecondsValidator.nullable();
final otpAutjPeriodSecondsValidator = ObjectValidator<int>(
  transformer: (v) => int.parse(v),
  allowedValues: (v) => v > 0,
);

final otpAuthDigitsValidatorNullable = otpAuthDigitsValidator.nullable();
final otpAuthDigitsValidator = ObjectValidator<int>(
  transformer: (v) => int.parse(v),
  defaultValue: 6,
  allowedValues: (p0) => p0 > 0,
);
final otpAuthCounterValidator = ObjectValidator<int>(
  transformer: (v) => int.parse(v),
  allowedValues: (v) => v >= 0,
);

final stringToIntValidatorNullable = stringToIntvalidator.nullable();
final stringToIntvalidator = ObjectValidator<int>(transformer: (v) => int.parse(v));

final intToStringValidator = ObjectValidator<String>(transformer: (v) => (v as int).toString());
final intToStringValidatorNullable = intToStringValidator.nullable();

final stringSecondsToDurationValidatorNullable = stringSecondsToDurationValidator.nullable();
final stringSecondsToDurationValidator = ObjectValidator<Duration>(
  transformer: (v) => Duration(seconds: int.parse(v)),
  allowedValues: (v) => v.inSeconds > 0,
);

final stringToUriValidatorNullable = stringToUrivalidator.nullable();
final stringToUrivalidator = ObjectValidator<Uri>(transformer: (v) => Uri.parse(v));

final stringToBoolValidatorNullable = stringToBoolValidator.nullable();
final stringToBoolValidator = ObjectValidator<bool>(
    transformer: (v) => switch ((v as String).toLowerCase()) {
          'true' => true,
          '1' => true,
          'false' => false,
          '0' => false,
          _ => throw ArgumentError('Invalid boolean value: $v'),
        });

final stringToAlgorithmsValidator = ObjectValidator<Algorithms>(
  transformer: (v) {
    return Algorithms.values.byName((v as String).toUpperCase());
  },
);
final stringToAlgorithmsValidatorNullable = stringToAlgorithmsValidator.nullable();

/// When value is given, it checks if the value is a base32 encoded string.
final base32SecretValidatorNullable = base32Secretvalidator.nullable();

/// Checks if the value is a base32 encoded string.
final base32Secretvalidator = ObjectValidator<String>(transformer: (v) {
  if (v is String) v = Encodings.base32.decode(v);
  return Encodings.base32.encode(v);
});
