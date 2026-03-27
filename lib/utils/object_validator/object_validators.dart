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
part 'default_object_validator.dart';
part 'optional_object_validator.dart';
part 'required_object_validator.dart';

final _base32Regex = RegExp(r'^[A-Z2-7]+=*$');

abstract class Validators {
  // --- Core Types ---
  static final string = RequiredObjectValidator<String>();
  static final stringOptional = string.optional();
  static final stringSafe = string.withDefault('');

  static final intType = RequiredObjectValidator<int>(
    transformer: (v) => v is String ? int.parse(v) : (v as int),
  );
  static final intOptional = intType.optional();

  static final boolType = RequiredObjectValidator<bool>(
    transformer: (v) {
      if (v is bool) return v;
      if (v is int) return v == 1;
      if (v is String) {
        return switch (v.toLowerCase()) {
          'true' || '1' => true,
          'false' || '0' => false,
          _ => throw ArgumentError('Invalid boolean: $v'),
        };
      }
      throw ArgumentError('Invalid type for bool: ${v.runtimeType}');
    },
  );
  static final boolOptional = boolType.optional();
  static final boolSafeTrue = boolType.withDefault(true);
  static final boolSafeFalse = boolType.withDefault(false);

  // --- OTP / Token Specific ---
  static final otpPeriod = RequiredObjectValidator<int>(
    transformer: (v) => v is String ? int.parse(v) : (v as int),
    allowedValues: (v) => v > 0,
  );
  static final otpPeriodSafe = otpPeriod.withDefault(30);

  static final otpDigits = RequiredObjectValidator<int>(
    transformer: (v) => v is String ? int.parse(v) : (v as int),
    allowedValues: (v) => v > 0,
  );
  static final otpDigitsSafe = otpDigits.withDefault(6);

  static final otpCounter = RequiredObjectValidator<int>(
    transformer: (v) => v is String ? int.parse(v) : (v as int),
    allowedValues: (v) => v >= 0,
  );
  static final otpCounterSafe = otpCounter.withDefault(0);

  static final algorithms = RequiredObjectValidator<Algorithms>(
    transformer: (v) => v is String
        ? Algorithms.values.byName(v.toUpperCase())
        : (v as Algorithms),
  );
  static final algorithmOptional = algorithms.optional();

  // --- Conversions ---
  static final intToString = RequiredObjectValidator<String>(
    transformer: (v) {
      if (v is int) return v.toString();
      if (v is String) return int.parse(v).toString();
      if (v is num) return v.toInt().toString();
      throw ArgumentError('Invalid type for int to string: ${v.runtimeType}');
    },
  );
  static final intToStringOptional = intToString.optional();

  static final base32String = RequiredObjectValidator<String>(
    transformer: (v) {
      if (v is Uint8List) return Encodings.base32.encode(v);
      final s = (v as String).replaceAll(' ', '').toUpperCase();
      if (!_base32Regex.hasMatch(s)) throw ArgumentError('Invalid base32');
      return s;
    },
  );
  static final base32StringOptional = base32String.optional();

  static final base32ToBytes = RequiredObjectValidator<Uint8List>(
    transformer: (v) {
      if (v is Uint8List) return v;
      return Encodings.base32.decode(
        (v as String).replaceAll(' ', '').toUpperCase(),
      );
    },
  );
  static final base32ToBytesOptional = base32ToBytes.optional();

  // --- Durations & URI ---
  static final secondsDuration = RequiredObjectValidator<Duration>(
    transformer: (v) {
      if (v is Duration) return v;
      final sec = v is String ? int.parse(v) : (v as int);
      return Duration(seconds: sec);
    },
    allowedValues: (v) => v.inSeconds > 0,
  );
  static final secondsDurationOptional = secondsDuration.optional();

  static final minutesDuration = RequiredObjectValidator<Duration>(
    transformer: (v) {
      if (v is Duration) return v;
      final min = v is String ? int.parse(v) : (v as int);
      return Duration(minutes: min);
    },
    allowedValues: (v) => v.inMinutes > 0,
  );
  static final minutesDurationOptional = minutesDuration.optional();

  static final uri = RequiredObjectValidator<Uri>(
    transformer: (v) => v is String ? Uri.parse(v) : (v as Uri),
  );
  static final uriOptional = uri.optional();
}

T validate<T extends Object?>({
  required Object? value,
  required BaseValidator<T> validator,
  required String name,
}) {
  final result = validator.transform(value, name);
  if (!validator.valueIsAllowed(value, name)) {
    throw (validator as dynamic)._error(value, name);
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
    final newValue = validate<T>(
      value: map[key],
      validator: validators[key]!,
      name: key,
    );

    if (newValue != null) {
      validatedMap[key] = newValue;
    }
  }
  return validatedMap;
}
