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

import '../../../../../../../model/extensions/enums/encodings_extension.dart';
import '../model/enums/algorithms.dart';
import '../model/enums/encodings.dart';
import '../model/exception_errors/localized_argument_error.dart';
import 'logger.dart';

final durationValidatorNullable = durationValidator.nullable();
final durationValidator = ObjectValidator<Duration>(
  transformer: (v) => Duration(seconds: v is int ? v : int.parse(v)),
  allowedValues: (v) => v.inSeconds > 0,
);

final otpAutjPeriodSecondsValidatorNullable = otpAuthPeriodSecondsValidator.nullable();
final otpAuthPeriodSecondsValidator = ObjectValidator<int>(
  transformer: (v) {
    if (v is int) return v;
    return int.parse(v);
  },
  defaultValue: 30,
  allowedValues: (v) => v > 0,
);

final otpAuthDigitsValidatorNullable = otpAuthDigitsValidator.nullable();
final otpAuthDigitsValidator = ObjectValidator<int>(
  transformer: (v) {
    if (v is int) return v;
    return int.parse(v);
  },
  defaultValue: 6,
  allowedValues: (p0) => p0 > 0,
);

final otpAuthCounterValidator = ObjectValidator<int>(
  transformer: (v) {
    if (v is int) return v;
    return int.parse(v);
  },
  allowedValues: (v) => v >= 0,
);

final intValidatorNullable = intValidator.nullable();
final intValidator = ObjectValidator<int>(transformer: (v) {
  if (v is int) return v;
  return int.parse(v);
});

final intToStringValidator = ObjectValidator<String>(transformer: (v) => (v as int).toString());
final intToStringValidatorNullable = intToStringValidator.nullable();

final stringSecondsToDurationValidatorNullable = stringSecondsToDurationValidator.nullable();
final stringSecondsToDurationValidator = ObjectValidator<Duration>(
  transformer: (v) => Duration(seconds: int.parse(v)),
  allowedValues: (v) => v.inSeconds > 0,
);

final stringToUriValidatorNullable = stringToUrivalidator.nullable();
final stringToUrivalidator = ObjectValidator<Uri>(transformer: (v) => Uri.parse(v));

final boolValidatorNullable = boolValidator.nullable();
final boolValidator = ObjectValidator<bool>(transformer: (v) {
  if (v is bool) return v;
  if (v is int) return v == 1;
  if (v is String) {
    return switch (v) {
      'true' => true,
      'True' => true,
      '1' => true,
      'false' => false,
      'False' => false,
      '0' => false,
      _ => throw ArgumentError('Invalid boolean value: $v'),
    };
  }
  throw ArgumentError('Invalid boolean value: $v');
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

T? validateOptional<T extends Object>({required dynamic value, required ObjectValidatorNullable<T> validator, required String name}) {
  if (validator.isTypeOf(value)) {
    return validator.transform(value);
  } else {
    throw LocalizedArgumentError(
      localizedMessage: (localizations, value, name) => localizations.invalidValue(value.runtimeType.toString(), value, name),
      unlocalizedMessage: 'The ${value.runtimeType} "$value" is not valid for "$name"',
      invalidValue: '$value',
      name: name,
    );
  }
}

T validate<T extends Object>({required dynamic value, required ObjectValidator<T> validator, required String name}) {
  if (validator.isTypeOf(value)) {
    return validator.transform(value);
  } else {
    throw LocalizedArgumentError(
      localizedMessage: (localizations, value, name) => localizations.invalidValue(value.runtimeType.toString(), value, name),
      unlocalizedMessage: 'The ${value.runtimeType} "$value" is not valid for "$name"',
      invalidValue: '$value',
      name: name,
    );
  }
}

/// Validates a map by checking if it contains all required keys and if the values are of the correct type.
///
/// Throws a [LocalizedArgumentError] if the map is invalid.
/// <br />If the validator provides a transformer function, the value will be transformed before checking the type.
/// <br />The returned map will contain the transformed values.
Map<String, RV> validateMap<RV>({required Map<String, dynamic> map, required Map<String, ObjectValidatorNullable<RV>> validators, required String? name}) {
  Map<String, RV> validatedMap = {};
  for (String key in validators.keys) {
    final validator = validators[key]!;
    final mapEntry = map[key];
    if (validator.isTypeOf(mapEntry)) {
      if (validator.valueIsAllowed(mapEntry)) {
        final newValue = validator.transform(mapEntry);
        if (newValue != null) validatedMap[key] = newValue;
      } else {
        Logger.debug('All keys: ${map.keys}');
        throw LocalizedArgumentError(
          localizedMessage: name != null
              ? (localizations, value, key) => localizations.valueNotAllowedIn(name, key, value.runtimeType.toString(), value.toString())
              : (localizations, value, key) => localizations.valueNotAllowed(key, value.runtimeType.toString(), value.toString()),
          unlocalizedMessage: 'The ${mapEntry.runtimeType} "$mapEntry" is not an allowed value for "$key"',
          invalidValue: mapEntry.toString(),
          name: key,
        );
      }
    } else {
      if (mapEntry == null) {
        Logger.debug('All keys: ${map.keys}');
        throw LocalizedArgumentError(
          localizedMessage: name != null
              ? (localizations, value, key) => localizations.missingRequiredParameterIn(name, key)
              : (localizations, value, key) => localizations.missingRequiredParameter(key),
          unlocalizedMessage: 'Map does not contain required key "$key"',
          invalidValue: mapEntry.toString(),
          name: key,
        );
      }
      throw LocalizedArgumentError(
        localizedMessage: name != null
            ? (localizations, value, key) => localizations.invalidValueIn(value.runtimeType.toString(), value.toString(), key, name)
            : (localizations, value, key) => localizations.invalidValue(value.runtimeType.toString(), value.toString(), key),
        unlocalizedMessage: 'The ${mapEntry.runtimeType} "$mapEntry" is not valid for "$key"${name != null ? ' in $name' : ''}',
        invalidValue: mapEntry.toString(),
        name: key,
      );
    }
  }
  return validatedMap;
}

class ObjectValidatorNullable<T extends Object?> {
  final T Function(dynamic value)? transformer;
  final T? defaultValue;
  final bool Function(T)? allowedValues;

  const ObjectValidatorNullable({
    this.transformer,
    this.defaultValue,
    this.allowedValues,
  });

  /// Checks if the value is of the correct type, or sub-type.
  /// If the transformer is provided, the value will be transformed before checking the type.
  bool isTypeOf(dynamic value) {
    Logger.debug('Checking type (${T.runtimeType}) of nullable value "$value" and default value "$defaultValue" with transformer "$transformer".');
    if (value == null) return true;
    if (transformer == null) return value is T?;
    try {
      transformer!(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool valueIsAllowed(dynamic value) {
    if (!isTypeOf(value)) return false;
    if (allowedValues == null) return true;
    if (value == null) return true;
    final transformedValue = transform(value);
    if (transformedValue == null) return true;
    if (allowedValues!(transformedValue)) return true;
    return false;
  }

  /// Transforms the value if a transformer is provided, otherwise returns the value as is.
  /// May throw an error if the value is not of the correct type.
  /// To prevent an error, use isTypeOf before calling transform.
  T? transform(dynamic value) {
    if (value == null) return defaultValue;
    if (transformer == null) {
      return value as T;
    }
    try {
      return transformer!.call(value);
    } catch (e) {
      return defaultValue;
    }
  }

  ObjectValidatorNullable<T> nullable() => ObjectValidatorNullable<T>(transformer: transformer, defaultValue: defaultValue, allowedValues: allowedValues);
  ObjectValidatorNullable<T> withDefault(T? defaultValue) =>
      ObjectValidatorNullable<T>(transformer: transformer, defaultValue: defaultValue, allowedValues: allowedValues);

  String get type => RegExp('(?<=<).+(?=>)').firstMatch(toString())!.group(0)!;

  @override
  String toString() => runtimeType.toString();

  @override
  bool operator ==(Object other) => other is ObjectValidatorNullable<T>;

  @override
  int get hashCode => toString().hashCode;
}

class ObjectValidator<T extends Object> extends ObjectValidatorNullable<T> {
  const ObjectValidator({
    super.transformer,
    super.defaultValue,
    super.allowedValues,
  });

  /// Transforms the value if a transformer is provided, otherwise returns the value as is.
  /// May throw an error if the value is not of the correct type.
  /// To prevent an error, use isTypeOf before calling transform.
  @override
  T transform(dynamic value) {
    try {
      if (value == null) return defaultValue!;
      if (transformer == null) return value is T ? value : defaultValue!;
      return transformer!.call(value);
    } catch (e) {
      if (defaultValue != null) return defaultValue!;
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, name) => localizations.invalidValue(value.runtimeType.toString(), value, name),
        unlocalizedMessage: 'The type ${value.runtimeType} for value "$value" is not valid.',
        invalidValue: '$value',
        name: type,
      );
    }
  }

  /// Checks if the value is of the correct type, or sub-type.
  /// If the transformer is provided, the value will be transformed before checking the type.
  @override
  bool isTypeOf(dynamic value) {
    Logger.debug('Checking type (${T.runtimeType}) of value "$value" and default value "$defaultValue" with transformer "$transformer".');
    if (value == null) return defaultValue != null;
    if (transformer == null) return value is T;
    try {
      transformer!(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool valueIsAllowed(dynamic value) {
    if (!isTypeOf(value)) return false;
    value ??= defaultValue;
    if (value == null) return false;
    if (allowedValues == null) return true;
    return allowedValues!(transform(value));
  }
}
