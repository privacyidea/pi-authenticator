/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

class RequiredObjectValidator<T extends Object> extends BaseValidator<T> {
  const RequiredObjectValidator({
    super.transformer,
    super.defaultValue,
    super.allowedValues,
  });

  @override
  T transform(Object? value) {
    if (value == null) {
      if (defaultValue != null) {
        return defaultValue as T;
      }
      Logger.warning(
        'Validation failed for <$T>. Value is required but was null.',
        name: 'RequiredObjectValidator<$T>',
      );
      throw ArgumentError('Value is required but was null.');
    }
    try {
      return _executeTransform(value);
    } catch (e, stackTrace) {
      Logger.warning(
        'Validation failed for <$T>. Value: "$value" (Type: ${value.runtimeType})',
        error: e,
        stackTrace: stackTrace,
        name: 'RequiredObjectValidator<$T>',
      );
      rethrow;
    }
  }

  @override
  RequiredObjectValidator<T> withDefault(T? defaultValue) {
    return RequiredObjectValidator<T>(
      transformer: transformer,
      defaultValue: defaultValue,
      allowedValues: allowedValues,
    );
  }

  OptionalObjectValidator<T> optional() => OptionalObjectValidator<T>(
    transformer: transformer,
    defaultValue: defaultValue,
    allowedValues: (v) {
      if (allowedValues == null) return true;
      if (v == null) return true;
      return allowedValues!(v);
    },
  );

  @override
  bool isTypeOf(Object? value) {
    if (value == null) return false;

    if (transformer != null) {
      try {
        transformer!(value);
        return true;
      } catch (e, stackTrace) {
        Logger.warning(
          'Validation failed for <$T>. Required Value: "$value" (Type: ${value.runtimeType})',
          error: e,
          stackTrace: stackTrace,
          name: 'RequiredObjectValidator<$T>',
        );
        return false;
      }
    }

    return value is T;
  }

  @override
  bool valueIsAllowed(Object? value) {
    if (!isTypeOf(value)) {
      if (defaultValue != null) {
        return allowedValues?.call(defaultValue as T) ?? true;
      }
      return false;
    }
    return allowedValues?.call(transform(value)) ?? true;
  }
}
