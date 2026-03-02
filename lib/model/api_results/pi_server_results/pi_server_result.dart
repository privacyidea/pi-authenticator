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

import '../../../utils/object_validator.dart';
import '../../exception_errors/pi_server_result_error.dart';
import 'pi_server_result_value.dart';

class PiServerResult<V extends PiServerResultValue> {
  static const RESULT_STATUS = 'status';
  static const RESULT_VALUE = 'value';
  static const RESULT_ERROR = 'error';

  final bool status;
  final V? value;
  bool get hasValue => value != null;
  final PiServerResultError? error;
  bool get hasError => error != null;

  factory PiServerResult.fromResultMap(Map<String, dynamic> json) {
    final map = validateMap(
      map: json,
      validators: {
        RESULT_STATUS: const ObjectValidator<bool>(),
        RESULT_VALUE: const ObjectValidatorNullable<dynamic>(),
        RESULT_ERROR: const ObjectValidatorNullable<Map<String, dynamic>>(),
      },
      name: 'PiServerResult#fromJson',
    );
    return PiServerResult(
      status: map[RESULT_STATUS],
      value: map[RESULT_VALUE] != null
          ? PiServerResultValue.fromResultValue<V>(map[RESULT_VALUE])
          : null,
      error: map[RESULT_ERROR] != null
          ? PiServerResultError.fromResultError(map[RESULT_ERROR])
          : null,
    );
  }

  const PiServerResult({required this.status, this.value, this.error})
    : assert(
        (value != null && error == null) || (value == null && error != null),
        'Either value or error must be provided, but not both.',
      );
}
