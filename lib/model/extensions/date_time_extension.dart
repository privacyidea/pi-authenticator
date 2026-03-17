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

import '../../utils/object_validator/required_object_validator.dart';

extension DateTimeX on DateTime {
  static final validator = RequiredObjectValidator<DateTime>(
    transformer: (v) {
      if (v is DateTime) return v;
      if (v is String) {
        return DateTime.parse(v);
      }
      if (v is int) {
        // Falls der Server mal Unix-Timestamps (ms) schickt
        return DateTime.fromMillisecondsSinceEpoch(v);
      }
      throw ArgumentError(
        'Invalid type for DateTime: ${v.runtimeType}, value: $v',
      );
    },
  );
}
