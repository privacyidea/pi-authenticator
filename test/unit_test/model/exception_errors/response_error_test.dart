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
import 'package:http/http.dart';
import 'package:privacyidea_authenticator/model/exception_errors/response_error.dart';

void main() {
  group('ResponseError', () {
    test('parses status code from HTML title', () {
      final response = Response(
        '<html><head><title>405 Method Not Allowed</title></head></html>',
        405,
      );
      final error = ResponseError(response);
      expect(error.statusCode, 405);
      expect(error.message, 'Method Not Allowed');
    });

    test('falls back to response statusCode when no title', () {
      final response = Response('plain error text', 500);
      final error = ResponseError(response);
      expect(error.statusCode, 500);
    });

    test('message truncates to 100 characters', () {
      final longBody = 'A' * 200;
      final response = Response(longBody, 400);
      final error = ResponseError(response);
      expect(error.message.length, 100);
      expect(error.fullMessage.length, 200);
    });

    test('message returns full message when under 100 chars', () {
      final response = Response('<title>404 Not Found</title>', 404);
      final error = ResponseError(response);
      expect(error.message, error.fullMessage);
    });

    test('toString returns statusCode: message', () {
      final response = Response('<title>403 Forbidden</title>', 403);
      final error = ResponseError(response);
      expect(error.toString(), contains('403'));
      expect(error.toString(), contains('Forbidden'));
    });

    test('parses title without status code in title', () {
      final response = Response('<title>Bad Gateway</title>', 502);
      final error = ResponseError(response);
      expect(error.statusCode, 502);
    });
  });
}
