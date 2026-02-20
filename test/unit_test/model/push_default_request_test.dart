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
import 'package:privacyidea_authenticator/model/push_request/push_default_request.dart';
import 'package:privacyidea_authenticator/model/push_request/push_request.dart';

void main() {
  group('PushMessageRequest Tests', () {
    final testDate = DateTime(2025, 1, 1);

    test('Constructor and basic fields', () {
      final request = PushDefaultRequest(
        title: 'Message Title',
        question: 'Confirm?',
        nonce: 'nonce123',
        serial: 'PIPU123',
        signature: 'sig123',
        expirationDate: testDate,
        uri: Uri.parse('https://example.com'),
        sslVerify: true,
      );

      expect(request.title, 'Message Title');
      expect(request.uri.toString(), 'https://example.com');
      expect(request.sslVerify, true);
    });

    test('signedData string generation (with answers)', () {
      final request = PushDefaultRequest(
        title: 'Title',
        question: 'Question',
        nonce: 'nonce',
        serial: 'serial',
        signature: 'sig',
        expirationDate: testDate,
        uri: Uri.parse('https://pi.com'),
        sslVerify: true,
      );

      // Format: nonce|uri|serial|question|title|sslVerify
      expect(
        request.signedData,
        'nonce|https://pi.com|serial|Question|Title|1',
      );
    });

    test('signedData string generation (without answers)', () {
      final request = PushDefaultRequest(
        title: 'Title',
        question: 'Question',
        nonce: 'nonce',
        serial: 'serial',
        signature: 'sig',
        expirationDate: testDate,
        uri: Uri.parse('https://pi.com'),
        sslVerify: false,
      );

      expect(
        request.signedData,
        'nonce|https://pi.com|serial|Question|Title|0',
      );
    });

    test('JSON serialization', () {
      final request = PushDefaultRequest(
        title: 'T',
        question: 'Q',
        nonce: 'N',
        serial: 'S',
        signature: 'Sig',
        expirationDate: testDate,
        uri: Uri.parse('https://test.de'),
        sslVerify: true,
        accepted: false,
      );

      final json = request.toJson();
      expect(json['title'], 'T');
      expect(json['question'], 'Q');
      expect(json['nonce'], 'N');
      expect(json['serial'], 'S');
      expect(json['signature'], 'Sig');
      expect(json['expirationDate'], testDate.toIso8601String());
      expect(json['uri'], 'https://test.de');
      expect(json['sslVerify'], true);
      expect(json['type'], PushDefaultRequest.TYPE);
      expect(json['accepted'], false);
    });

    test('Polymorphic fromJson', () {
      final json = {
        'title': 'T',
        'question': 'Q',
        'nonce': 'N',
        'serial': 'S',
        'signature': 'Sig',
        'expirationDate': testDate.toIso8601String(),
        'uri': 'http://example.com',
        'sslVerify': false,
        'type': PushDefaultRequest.TYPE,
        'accepted': true,
      };

      final result = PushRequest.fromJson(json);
      expect(result, isA<PushDefaultRequest>());
      expect(result.title, 'T');
      expect(result.question, 'Q');
      expect(result.nonce, 'N');
      expect(result.serial, 'S');
      expect(result.signature, 'Sig');
      expect(result.uri, Uri.parse('http://example.com'));
      expect(result.sslVerify, false);
      expect(result.expirationDate, testDate);
      expect(result.accepted, true);
      expect(result.type, PushDefaultRequest.TYPE);
      expect(result.id, 'N'.hashCode);
    });
  });
}
