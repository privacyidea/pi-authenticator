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

class DefaultObjectValidator<T extends Object> extends BaseValidator<T> {
  T defaultValue;

  DefaultObjectValidator({
    required this.defaultValue,
    super.transformer,
    super.allowedValues,
  });

  @override
  T transform(value, name) {
    if (value == null) return defaultValue;
    try {
      return _executeTransform(value, name);
    } catch (e) {
      return defaultValue;
    }
  }

  @override
  OptionalObjectValidator<T> optional() => OptionalObjectValidator<T>(
    transformer: transformer,
    allowedValues: (v) => v == null ? true : (allowedValues?.call(v) ?? true),
  );

  @override
  DefaultObjectValidator<T> withDefault(T defaultValue) =>
      DefaultObjectValidator<T>(
        defaultValue: defaultValue,
        transformer: transformer,
        allowedValues: allowedValues,
      );

  @override
  bool isTypeOf(value) => value == null || value is T || transformer != null;

  @override
  bool valueIsAllowed(value, name) =>
      allowedValues?.call(transform(value, name)) ?? true;
}
