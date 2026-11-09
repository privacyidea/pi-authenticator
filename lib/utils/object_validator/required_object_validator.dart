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

/// Whether [name] is one whose value the log masks, a 'secret' for example.
bool _namesASecret(String name) {
  final lowerName = name.toLowerCase();
  return sensitiveEntryNames.any(lowerName.contains);
}

class RequiredObjectValidator<T extends Object> extends BaseValidator<T> {
  RequiredObjectValidator({
    super.transformer,
    super.allowedValues,
    super.invalidMessage,
    super.unallowedMessage,
  });

  @override
  T transform(value, name) {
    if (value == null) throw _invalidError(value, name);
    try {
      return _executeTransform(value, name);
    } on LocalizedArgumentError {
      rethrow;
    } catch (_) {
      // That message quotes the value, which the log cannot mask in front of
      // the name: an almost valid secret would end up in it.
      if (_namesASecret(name)) rethrow;
      // The transformer's own error (a FormatException of DateTime.parse, the
      // ArgumentError of byName) would escape every caller that reports
      // invalid input; it gets the message that names the field instead.
      throw _invalidError(value, name);
    }
  }

  @override
  OptionalObjectValidator<T> optional() => OptionalObjectValidator<T>(
    transformer: transformer,
    allowedValues: (v) {
      if (v == null) return true;
      return allowedValues?.call(v) ?? true;
    },
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

  /// Like [withDefault], but a value that is present and unreadable throws
  /// instead of becoming [defaultValue].
  AbsentDefaultObjectValidator<T> withDefaultIfAbsent(T defaultValue) =>
      AbsentDefaultObjectValidator<T>(
        defaultValue: defaultValue,
        transformer: transformer,
        allowedValues: allowedValues,
        invalidMessage: invalidMessage,
        unallowedMessage: unallowedMessage,
      );

  @override
  bool isTypeOf(value) => value is T || (transformer != null && value != null);

  @override
  bool valueIsAllowed(value, name) =>
      allowedValues?.call(transform(value, name)) ?? true;
}
