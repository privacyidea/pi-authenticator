/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
import 'package:http/http.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result_detail.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result_value.dart';
import 'package:privacyidea_authenticator/model/exception_errors/error_codes.dart';
import 'package:privacyidea_authenticator/model/pi_server_response.dart';

PiServerResponse<ContainerChallenge, EmptyResultDetail> _parse(
  String body,
  int status,
) => PiServerResponse.fromResponse<ContainerChallenge, EmptyResultDetail>(
  Response(body, status),
);

void _expectError(
  PiServerResponse response, {
  required int status,
  required String message,
}) {
  expect(response.isError, isTrue);
  final error = response.asError!;
  expect(error.statusCode, status);
  expect(error.piServerResultError.code, InAppErrorCodes.jsonParseError);
  expect(error.piServerResultError.message, message);
}

void main() {
  group('PiServerResponse.fromResponse with non-JSON body', () {
    test('empty body yields "Empty response body"', () {
      _expectError(
        _parse('', 502),
        status: 502,
        message: 'Empty response body (HTTP 502)',
      );
    });

    test('whitespace-only body yields "Empty response body"', () {
      _expectError(
        _parse('  \n\t ', 503),
        status: 503,
        message: 'Empty response body (HTTP 503)',
      );
    });

    test('HTML body yields generic message', () {
      _expectError(
        _parse('<html><body>Bad Gateway</body></html>', 502),
        status: 502,
        message: 'Invalid server response (HTTP 502)',
      );
    });

    test('doctype body yields generic message', () {
      _expectError(
        _parse('<!DOCTYPE html>', 500),
        status: 500,
        message: 'Invalid server response (HTTP 500)',
      );
    });

    test('body starting with a brace (broken JSON) yields generic message', () {
      _expectError(
        _parse('  {"broken": ', 200),
        status: 200,
        message: 'Invalid server response (HTTP 200)',
      );
    });

    test('plain proxy message is returned trimmed', () {
      _expectError(
        _parse('  Bad Gateway\n', 502),
        status: 502,
        message: 'Bad Gateway',
      );
    });

    test('body of exactly 200 chars is returned as raw text', () {
      final body = 'a' * 200;
      _expectError(_parse(body, 500), status: 500, message: body);
    });

    test('body of 201 chars yields generic message', () {
      _expectError(
        _parse('a' * 201, 500),
        status: 500,
        message: 'Invalid server response (HTTP 500)',
      );
    });

    test('length boundary is measured on the trimmed body', () {
      final body = 'a' * 200;
      _expectError(_parse('  $body  ', 500), status: 500, message: body);
    });
  });
}
