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

import 'dart:typed_data' show Uint8List;

import '../../../../../model/extensions/enums/encodings_extension.dart';
import '../../model/enums/algorithms.dart';
import '../../model/enums/encodings.dart';
import '../../model/exception_errors/localized_argument_error.dart';
import '../logger.dart';

part 'base_validator.dart';
part 'optional_object_validator.dart';
part 'required_object_validator.dart';

final _base32Regex = RegExp(r'^[A-Z2-7]+=*$');

final stringValidator = RequiredObjectValidator<String>(
  transformer: (v) {
    if (v is String) return v;
    throw ArgumentError('Invalid type: ${v.runtimeType}, value: $v');
  },
);
final stringValidatorOptional = stringValidator.optional();

final otpAuthPeriodSecondsValidator = RequiredObjectValidator<int>(
  transformer: (v) {
    if (v is int) return v;
    if (v is String) return int.parse(v);
    throw ArgumentError('Invalid type: ${v.runtimeType}, value: $v');
  },
  defaultValue: 30,
  allowedValues: (v) => v > 0,
);
final otpAutjPeriodSecondsValidatorOptional = otpAuthPeriodSecondsValidator
    .optional();

final otpAuthDigitsValidator = RequiredObjectValidator<int>(
  transformer: (v) {
    if (v is int) return v;
    if (v is String) return int.parse(v);
    throw ArgumentError('Invalid type: ${v.runtimeType}, value: $v');
  },
  defaultValue: 6,
  allowedValues: (p0) => p0 > 0,
);
final otpAuthDigitsValidatorOptional = otpAuthDigitsValidator.optional();

final otpAuthCounterValidator = RequiredObjectValidator<int>(
  transformer: (v) {
    if (v is int) return v;
    if (v is String) return int.parse(v);
    throw ArgumentError('Invalid type: ${v.runtimeType}, value: $v');
  },
  allowedValues: (v) => v >= 0,
);

final intValidator = RequiredObjectValidator<int>(
  transformer: (v) {
    if (v is int) return v;
    if (v is String) return int.parse(v);
    throw ArgumentError('Invalid type: ${v.runtimeType}, value: $v');
  },
);
final intValidatorOptional = intValidator.optional();

final intToStringValidator = RequiredObjectValidator<String>(
  transformer: (v) {
    if (v is int) return v.toString();
    if (v is String) return v;
    throw ArgumentError('Invalid type: ${v.runtimeType}, value: $v');
  },
);
final intToStringValidatorOptional = intToStringValidator.optional();

final secondsDurationValidator = RequiredObjectValidator<Duration>(
  transformer: (v) {
    if (v is Duration) return v;
    if (v is int) return Duration(seconds: v);
    if (v is String) return Duration(seconds: int.parse(v));
    throw ArgumentError('Invalid type: ${v.runtimeType}, value: $v');
  },
  allowedValues: (v) => v.inSeconds > 0,
);
final secondsDurationValidatorOptional = secondsDurationValidator.optional();

final minutesDurationValidator = RequiredObjectValidator<Duration>(
  transformer: (v) {
    if (v is Duration) return v;
    if (v is int) return Duration(minutes: v);
    if (v is String) return Duration(minutes: int.parse(v));
    throw ArgumentError('Invalid type: ${v.runtimeType}, value: $v');
  },
  allowedValues: (v) => v.inSeconds > 0,
);
final minutesDurationValidatorOptional = minutesDurationValidator.optional();

final uriValidator = RequiredObjectValidator<Uri>(
  transformer: (v) {
    if (v is Uri) return v;
    if (v is String) return Uri.parse(v);
    throw ArgumentError('Invalid type: ${v.runtimeType}, value: $v');
  },
);
final uriValidatorOptional = uriValidator.optional();

final boolValidator = RequiredObjectValidator<bool>(
  transformer: (v) {
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) {
      return switch (v) {
        'true' || 'True' || '1' => true,
        'false' || 'False' || '0' => false,
        _ => throw ArgumentError('Invalid boolean value: $v'),
      };
    }
    throw ArgumentError('Invalid boolean value: $v');
  },
);
final boolValidatorOptional = boolValidator.optional();

final algorithmsValidator = RequiredObjectValidator<Algorithms>(
  transformer: (v) {
    if (v is Algorithms) return v;
    if (v is String) return Algorithms.values.byName(v.toUpperCase());
    throw ArgumentError('Invalid type: ${v.runtimeType}, value: $v');
  },
);
final algorithmsValidatorOptional = algorithmsValidator.optional();

final base32Stringvalidator = RequiredObjectValidator<String>(
  transformer: (v) {
    if (v is Uint8List) return Encodings.base32.encode(v);
    if (v is String) {
      final normalized = v.replaceAll(' ', '').toUpperCase();
      if (!_base32Regex.hasMatch(normalized)) {
        throw ArgumentError('Invalid base32 format: $normalized');
      }
      return normalized;
    }
    throw ArgumentError('Invalid type: ${v.runtimeType}, value: $v');
  },
);
final base32StringValidatorOptional = base32Stringvalidator.optional();

final base32ToBytesValidator = RequiredObjectValidator<Uint8List>(
  transformer: (v) {
    if (v is Uint8List) return v;
    if (v is String) {
      final normalized = v.replaceAll(' ', '').toUpperCase();
      return Encodings.base32.decode(normalized);
    }
    throw ArgumentError('Invalid type: ${v.runtimeType}');
  },
);
final base32ToBytesValidatorOptional = base32ToBytesValidator.optional();

T validate<T extends Object?>({
  required Object? value,
  required BaseValidator<T> validator,
  required String name,
}) {
  final result = validator.transform(value, name);
  if (!validator.valueIsAllowed(value, name)) {
    throw validator._error(value, name);
  }
  return result;
}

Map<String, T> validateMap<T extends Object?>({
  required Map<String, Object?> map,
  required Map<String, BaseValidator<T>> validators,
  required String? name,
}) {
  final Map<String, T> validatedMap = {};
  for (final key in validators.keys) {
    final validator = validators[key]!;
    final mapEntry = map[key];

    final newValue = validate<T>(
      value: mapEntry,
      validator: validator,
      name: key,
    );

    if (newValue != null) {
      validatedMap[key] = newValue;
    }
  }
  return validatedMap;
}
