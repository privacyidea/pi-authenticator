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
import '../logger.dart';
import 'base_validator.dart';

class OptionalObjectValidator<T extends Object> extends BaseValidator<T> {
  const OptionalObjectValidator({
    super.transformer,
    super.defaultValue,
    super.allowedValues,
  });

  @override
  T? transform(Object? value) {
    if (value == null) return defaultValue;
    return executeTransform(value);
  }

  @override
  OptionalObjectValidator<T> withDefault(T? defaultValue) {
    return OptionalObjectValidator<T>(
      transformer: transformer,
      defaultValue: defaultValue,
      allowedValues: allowedValues,
    );
  }

  @override
  bool isTypeOf(Object? value) {
    if (value == null) return true;

    if (transformer != null) {
      try {
        transformer!(value);
        return true;
      } catch (e, stackTrace) {
        Logger.warning(
          'Validation failed for <$T?>. Optional Value: "$value" (Type: ${value.runtimeType})',
          error: e,
          stackTrace: stackTrace,
          name: 'OptionalObjectValidator<$T>',
        );
        return false;
      }
    }

    return value is T;
  }

  @override
  bool valueIsAllowed(Object? value) {
    if (value == null) return true;
    final val = transform(value);
    return val == null || (allowedValues?.call(val) ?? true);
  }
}
