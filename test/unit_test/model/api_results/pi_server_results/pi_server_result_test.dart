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

import 'dart:convert';

import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result_value.dart';
import 'package:test/test.dart';

void main() {
  _testPiServerResult();
}

void _testPiServerResult() {
  group('PiServerResult.fromResultMap', () {
    // jsonDecode returns _Map<String, dynamic> at runtime, which must be
    // accepted by the error field validator (was broken with Map<String, Object>).
    test('parses error from JSON-decoded map (_Map<String, dynamic>)', () {
      final json = jsonDecode(
        '{"status": false, "error": {"code": 3002, "message": "ERR3002: Could not verify signature!"}}',
      ) as Map<String, dynamic>;

      final result =
          PiServerResult<ContainerFinalizationResponse>.fromResultMap(json);

      expect(result.status, false);
      expect(result.error, isNotNull);
      expect(result.error!.code, 3002);
      expect(result.error!.message, contains('Could not verify signature'));
      expect(result.value, isNull);
    });

    test('error is null when status is false and no error field present', () {
      final json = jsonDecode('{"status": false}') as Map<String, dynamic>;

      final result =
          PiServerResult<ContainerFinalizationResponse>.fromResultMap(json);

      expect(result.status, false);
      expect(result.error, isNull);
      expect(result.value, isNull);
    });

    test('parses containerNotFound error code 601', () {
      final json = jsonDecode(
        '{"status": false, "error": {"code": 601, "message": "Unable to find container with serial SMPH001."}}',
      ) as Map<String, dynamic>;

      final result =
          PiServerResult<ContainerFinalizationResponse>.fromResultMap(json);

      expect(result.status, false);
      expect(result.error, isNotNull);
      expect(result.error!.code, 601);
    });

    test('parses containerNotRegistered error code 3001', () {
      final json = jsonDecode(
        '{"status": false, "error": {"code": 3001, "message": "Container is not registered."}}',
      ) as Map<String, dynamic>;

      final result =
          PiServerResult<ContainerFinalizationResponse>.fromResultMap(json);

      expect(result.status, false);
      expect(result.error, isNotNull);
      expect(result.error!.code, 3001);
    });
  });
}
