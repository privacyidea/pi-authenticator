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
import '../../model/exception_errors/localized_argument_error.dart';

abstract class BaseValidator<T extends Object> {
  final T Function(Object? value)? transformer;
  final T? defaultValue;
  final bool Function(T)? allowedValues;

  const BaseValidator({
    this.transformer,
    this.defaultValue,
    this.allowedValues,
  });

  bool isTypeOf(Object? value);
  bool valueIsAllowed(Object? value);

  T? transform(Object? value);

  BaseValidator<T> withDefault(T? defaultValue);

  T executeTransform(Object? value) {
    if (value == null) {
      if (defaultValue != null) return defaultValue!;
      throw _error(value);
    }

    if (transformer != null) {
      return transformer!(value);
    }

    if (value is T) return value;

    if (defaultValue != null) return defaultValue!;
    throw _error(value);
  }

  Exception _error(Object? value) {
    return LocalizedArgumentError(
      localizedMessage: (localizations, v, name) => localizations.invalidValue(
        v.runtimeType.toString(),
        v.toString(),
        name,
      ),
      unlocalizedMessage:
          'The type ${value.runtimeType} for value "$value" is not valid.',
      invalidValue: value.toString(),
      name: T.toString(),
    );
  }
}
