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

final stringToIntValidatorOptional = stringToIntvalidator.optional();
final stringToIntvalidator = TypeValidatorRequired<int>(transformer: (v) => int.parse(v));

final intToStringValidator = TypeValidatorRequired<String>(transformer: (v) => (v as int).toString());
final intToStringValidatorOptional = intToStringValidator.optional();

final stringSecondsToDurationvalidatorOptional = stringSecondsToDurationvalidator.optional();
final stringSecondsToDurationvalidator = TypeValidatorRequired<Duration>(transformer: (v) => Duration(seconds: int.parse(v)));

final stringToUriValidatorOptional = stringToUrivalidator.optional();
final stringToUrivalidator = TypeValidatorRequired<Uri>(transformer: (v) => Uri.parse(v));

final stringToBoolValidatorOptional = stringToBoolValidator.optional();
final stringToBoolValidator = TypeValidatorRequired<bool>(
    transformer: (v) => switch ((v as String).toLowerCase()) {
          'true' => true,
          '1' => true,
          'false' => false,
          '0' => false,
          _ => throw ArgumentError('Invalid boolean value: $v'),
        });

final stringToAlgorithmsValidator = TypeValidatorRequired<Algorithms>(
  transformer: (v) => Algorithms.values.byName((v as String).toUpperCase()),
);
final stringToAlgorithmsValidatorOptional = stringToAlgorithmsValidator.optional();

/// When value is given, it checks if the value is a base32 encoded string.
final base32SecretValidatorOptional = base32Secretvalidator.optional();

/// Checks if the value is a base32 encoded string.
final base32Secretvalidator = TypeValidatorRequired<String>(transformer: (v) {
  if (v is String) v = Encodings.base32.decode(v);
  return Encodings.base32.encode(v);
});
