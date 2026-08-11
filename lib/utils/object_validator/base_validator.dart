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

part of 'object_validators.dart';

/// Builds a message for the user from the invalid [value] of the field [name].
typedef ValidatorMessage =
    String Function(
      AppLocalizations localizations,
      String value,
      String name,
    );

abstract class BaseValidator<T extends Object?> {
  final T Function(Object? value)? transformer;
  final bool Function(T)? allowedValues;

  /// Shown to the user when the value could not be transformed,
  /// instead of the generic “invalid value“ text.
  final ValidatorMessage? invalidMessage;

  /// Shown to the user when [allowedValues] rejected the transformed value,
  /// instead of the generic “invalid value“ text.
  final ValidatorMessage? unallowedMessage;

  const BaseValidator({
    this.transformer,
    this.allowedValues,
    this.invalidMessage,
    this.unallowedMessage,
  });

  // Rückgabetyp auf T (bzw. die Non-Nullable Variante) angepasst
  BaseValidator<Object?> optional();
  BaseValidator<Object> withDefault(covariant Object defaultValue);

  bool isTypeOf(Object? value);
  bool valueIsAllowed(Object? value, String name);
  T transform(Object? value, String name);

  T _executeTransform(Object? value, String name) {
    if (transformer != null) {
      return transformer!(value);
    }
    if (value is T) return value;
    throw _invalidError(value, name);
  }

  Exception _invalidError(Object? value, String name) =>
      _error(value, name, invalidMessage);

  Exception _unallowedError(Object? value, String name) =>
      _error(value, name, unallowedMessage);

  Exception _error(Object? value, String name, ValidatorMessage? message) {
    final error = LocalizedArgumentError(
      localizedMessage:
          message ??
          (localizations, v, name) =>
              localizations.invalidValue(name, value.runtimeType.toString(), v),
      unlocalizedMessage:
          'The ${value.runtimeType} “$value“ is not valid for “$name“',
      invalidValue: value.toString(),
      name: name,
    );
    Logger.warning(
      'Validation failed for <$T>. Value: "$value" (Type: ${value.runtimeType})',
      error: error,
      stackTrace: StackTrace.current,
      name: runtimeType.toString(),
    );
    return error;
  }
}
