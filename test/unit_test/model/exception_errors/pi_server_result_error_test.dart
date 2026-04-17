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
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/exception_errors/pi_server_result_error.dart';

void main() {
  group('PiServerResultError', () {
    test('constructs with code and message', () {
      final error = PiServerResultError(code: 401, message: 'Unauthorized');
      expect(error.code, 401);
      expect(error.message, 'Unauthorized');
      expect(error.stackTrace, isNotNull);
    });

    test('implements Error', () {
      final error = PiServerResultError(code: 500, message: 'Internal');
      expect(error, isA<Error>());
    });

    test('toString returns formatted string', () {
      final error = PiServerResultError(code: 403, message: 'Forbidden');
      expect(error.toString(), 'PiError(code: 403, message: Forbidden)');
    });

    test('fromResultError parses JSON', () {
      final json = {'code': 904, 'message': 'Token not found'};
      final error = PiServerResultError.fromResultError(json);
      expect(error.code, 904);
      expect(error.message, 'Token not found');
    });

    test('fromResultError parses string code', () {
      final json = {'code': '123', 'message': 'Some error'};
      final error = PiServerResultError.fromResultError(json);
      expect(error.code, 123);
      expect(error.message, 'Some error');
    });

    test('fromResultError throws on missing code', () {
      final json = {'message': 'No code'};
      expect(
        () => PiServerResultError.fromResultError(json),
        throwsA(anything),
      );
    });

    test('fromResultError throws on missing message', () {
      final json = {'code': 1};
      expect(
        () => PiServerResultError.fromResultError(json),
        throwsA(anything),
      );
    });
  });
}
