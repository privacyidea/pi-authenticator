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
import '../../utils/object_validator/base_validator.dart';
import '../../utils/object_validator/object_validators.dart';
import '../../utils/object_validator/required_object_validator.dart';

class PiServerResultError implements Error {
  static const CODE = 'code';
  static const MESSAGE = 'message';

  final int code;
  final String message;
  @override
  final StackTrace stackTrace;

  const PiServerResultError._({
    required this.code,
    required this.message,
    required this.stackTrace,
  });

  factory PiServerResultError({required int code, required String message}) =>
      PiServerResultError._(
        code: code,
        message: message,
        stackTrace: StackTrace.current,
      );

  factory PiServerResultError.fromResultError(Map<String, dynamic> json) {
    final map = validateMap(
      map: json,
      validators: <String, BaseValidator>{
        CODE: const RequiredObjectValidator<int>(),
        MESSAGE: stringValidator,
      },
      name: 'PiServerResultError#fromJson',
    );
    return PiServerResultError(
      code: map[CODE] as int,
      message: map[MESSAGE] as String,
    );
  }
  @override
  String toString() => 'PiError(code: $code, message: $message)';
}
