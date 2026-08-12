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
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/enums/push_token_rollout_state.dart';
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/helpers/base32_helper.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  group('PushRequest verifySignature', () {
    final expirationDate = DateTime(2026);
    const serial = 'PIPU0001';
    const signature = 'MZXW6YTB';
    const publicServerKeyString =
        'MIICCgKCAgEAomCYODF47vz/axztjlmEcepqZPC8NNhXTlPu/FPGJ+qIOq+swTiEYgmv8DYIAslqLy3EHa7JUouSlE3f1l4OUcqZvPGgEP5Cpbjnaddy6u4Pt37YLDtlhX7nnd+VZnDLxXxqQ62e1CEOJVjKWq1x2Bq2GPcQz0fwWfGjNH7PtN+F00i3NiN0FPigOD4p7Bcru1ihWToQMobzf/p1945Yu0fwfpwUhHn0cfG5uKUrXl4T24s0b92MA8CmxYKKlenEQu9EezljeH2PJ0h1kfv58xjAEVEdwjCb8jzHwXomzJWUqZHt0BexavR+sUQNyk8r5OdX0fgOo+4W3/H+b/0Ktn47Frn827pYB8c2AX8lqxFocP6lj62hjCfKWss0rgqQBegTd9trCuN2iiw/Dj1HLFzK2Z8JwGDrQni1F8nyevaaZOuZI3I4DAFJzYKcP/zDvkNs6qpa+P1kzg50ml3m0RONGIHrzcSeo3aVeaMMdHXKhB5dqrig6Sjblqt2hwdPAWQPOiq9pTAXZIJmXI0UJb3bfWKlPIUmiZPRs+xYom+aZ9VEBTLdcxGC6puAJyUsjoXBJTJqH7O8g/pWA02UfPALEcuDAVQOSJbahodkWmrBg8jIMnjNOkN1t9hxHbg5XSWidgei4D/MJp4xH9w0eHyVZSnVTY5Iah0GkCVQFVsCAwEAAQ==';

    /// A push token that never finished its rollout, so the server key of a
    /// previous rollout is gone.
    final notRolledOutToken = PushToken(
      serial: serial,
      id: 'push-id',
      label: 'Push',
      issuer: 'privacyIDEA',
      url: Uri.parse('https://example.com/ttype/push'),
      isRolledOut: false,
      rolloutState: PushTokenRollOutState.rolloutNotStarted,
    );
    final rolledOutToken = notRolledOutToken.copyWith(
      isRolledOut: true,
      rolloutState: PushTokenRollOutState.rolloutComplete,
      publicServerKey: publicServerKeyString,
    );

    final requests = <String, PushRequest>{
      'PushDefaultRequest': PushDefaultRequest(
        title: 'Title',
        question: 'Question',
        nonce: 'nonce',
        serial: serial,
        signature: signature,
        expirationDate: expirationDate,
        uri: Uri.parse('https://example.com/validate/check'),
        sslVerify: true,
      ),
      'PushChoiceRequest': PushChoiceRequest(
        title: 'Title',
        question: 'Question',
        nonce: 'nonce',
        serial: serial,
        signature: signature,
        expirationDate: expirationDate,
        uri: Uri.parse('https://example.com/validate/check'),
        sslVerify: true,
        possibleAnswers: const ['yes', 'no'],
      ),
      'PushCodeToPhoneRequest': PushCodeToPhoneRequest(
        title: 'Title',
        question: 'Question',
        nonce: 'nonce',
        serial: serial,
        signature: signature,
        expirationDate: expirationDate,
        uri: Uri.parse('https://example.com/validate/check'),
        sslVerify: true,
        displayCode: '123456',
      ),
    };

    for (final entry in requests.entries) {
      final request = entry.value;

      test('${entry.key} is rejected if the token is not rolled out', () {
        final mockRsaUtils = MockRsaUtils();

        expect(
          request.verifySignature(notRolledOutToken, rsaUtils: mockRsaUtils),
          isFalse,
        );
        verifyNever(mockRsaUtils.verifyRSASignature(any, any, any));
      });

      test('${entry.key} is accepted if the signature matches', () {
        final mockRsaUtils = MockRsaUtils();
        when(mockRsaUtils.verifyRSASignature(any, any, any)).thenReturn(true);

        expect(
          request.verifySignature(rolledOutToken, rsaUtils: mockRsaUtils),
          isTrue,
        );
        verify(
          mockRsaUtils.verifyRSASignature(
            any,
            argThat(equals(utf8.encode(request.signedData))),
            argThat(equals(base32Decode(signature))),
          ),
        ).called(1);
      });

      test('${entry.key} is rejected if the signature does not match', () {
        final mockRsaUtils = MockRsaUtils();
        when(mockRsaUtils.verifyRSASignature(any, any, any)).thenReturn(false);

        expect(
          request.verifySignature(rolledOutToken, rsaUtils: mockRsaUtils),
          isFalse,
        );
      });
    }
  });
}
