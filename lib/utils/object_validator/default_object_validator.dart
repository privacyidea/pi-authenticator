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
    super.invalidMessage,
    super.unallowedMessage,
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
    invalidMessage: invalidMessage,
    unallowedMessage: unallowedMessage,
  );

  @override
  DefaultObjectValidator<T> withDefault(T defaultValue) =>
      DefaultObjectValidator<T>(
        defaultValue: defaultValue,
        transformer: transformer,
        allowedValues: allowedValues,
        invalidMessage: invalidMessage,
        unallowedMessage: unallowedMessage,
      );

  @override
  bool isTypeOf(value) => value == null || value is T || transformer != null;

  @override
  bool valueIsAllowed(value, name) =>
      allowedValues?.call(transform(value, name)) ?? true;
}

/// Uses [defaultValue] only for a missing value. A value that is present but
/// cannot be read is an error: for a field that decides what a token computes,
/// a silent default would make it show wrong codes.
class AbsentDefaultObjectValidator<T extends Object>
    extends DefaultObjectValidator<T> {
  AbsentDefaultObjectValidator({
    required super.defaultValue,
    super.transformer,
    super.allowedValues,
    super.invalidMessage,
    super.unallowedMessage,
  });

  @override
  T transform(value, name) {
    // An empty value, `digits=` in a uri, says as little as a missing one.
    if (value == null || value == '') return defaultValue;
    try {
      return _executeTransform(value, name);
    } catch (_) {
      throw _invalidError(value, name);
    }
  }
}
