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
import 'package:privacyidea_authenticator/model/push_request/push_choice_request.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';

void main() {
  group('PushChoiceRequest Tests with Short Answers', () {
    final testDate = DateTime(2026, 2, 20);
    final baseUri = Uri.parse('https://example.com');

    final testToken = PushToken(serial: 'PIPU123', id: "123456");

    test('signedData with numeric possibleAnswers', () {
      final request = PushChoiceRequest(
        title: 'Selection',
        question: 'Choose a number',
        nonce: 'N1',
        serial: 'S1',
        signature: 'Sig1',
        expirationDate: testDate,
        uri: baseUri,
        sslVerify: true,
        possibleAnswers: ['1', '2', '3'],
      );

      // Verifies that numbers are joined correctly: nonce|uri|serial|question|title|ssl|1,2,3
      expect(
        request.signedData,
        'N1|https://example.com|S1|Choose a number|Selection|1|1,2,3',
      );
    });

    test('signedData with letter possibleAnswers', () {
      final request = PushChoiceRequest(
        title: 'Poll',
        question: 'Select A or B',
        nonce: 'N2',
        serial: 'S2',
        signature: 'Sig2',
        expirationDate: testDate,
        uri: baseUri,
        sslVerify: false,
        possibleAnswers: ['A', 'B'],
      );

      expect(
        request.signedData,
        'N2|https://example.com|S2|Select A or B|Poll|0|A,B',
      );
    });

    test('getResponseSignMsg appends numeric selectedAnswer', () {
      final request = PushChoiceRequest(
        title: 'T',
        question: 'Q',
        nonce: 'N',
        serial: 'S',
        signature: 'Sig',
        expirationDate: testDate,
        uri: baseUri,
        sslVerify: true,
        possibleAnswers: ['1', '2'],
        selectedAnswer: '2',
      );

      final responseMsg = request.getResponseSignMsg(testToken);

      expect(responseMsg, endsWith('|2'));
      expect(request.accepted, isTrue);
    });

    test('fromMessageData handles comma separated numbers', () {
      final data = {
        'title': 'Numbers',
        'question': 'Pick?',
        'url': 'https://pi.com',
        'nonce': 'nonce123',
        'sslverify': '1',
        'serial': 'S123',
        'signature': 'SIG',
        'require_presence':
            '1,2,3,4', // The server sends choices as a comma-separated string
      };

      final request = PushChoiceRequest.fromMessageData(data);

      expect(request.possibleAnswers, ['1', '2', '3', '4']);
      expect(request.possibleAnswers.length, 4);
      expect(request.possibleAnswers.first, '1');
    });

    test('equality and hashing with numeric IDs', () {
      final req1 = PushChoiceRequest(
        title: 'T',
        question: 'Q',
        nonce: '100',
        serial: 'S',
        signature: 'Sig',
        expirationDate: testDate,
        uri: baseUri,
        sslVerify: true,
        possibleAnswers: ['1'],
      );
      final req2 = PushChoiceRequest(
        title: 'Other',
        question: 'Other',
        nonce: '100',
        serial: 'Other',
        signature: 'Other',
        expirationDate: testDate,
        uri: baseUri,
        sslVerify: false,
        possibleAnswers: ['2'],
      );

      // Both have the same nonce '100', so their id (nonce.hashCode) is identical
      expect(req1, req2);
      expect(req1.hashCode, req2.hashCode);
    });
  });
}
