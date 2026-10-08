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
import 'package:privacyidea_authenticator/model/push_request/decline_reason.dart';
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart';

final _expirationDate = DateTime.utc(2026, 1, 1, 12);

PushDefaultRequest defaultRequest() => PushDefaultRequest(
  title: 'Login',
  question: 'Do you want to login?',
  nonce: 'nonce-1',
  serial: 'PIPU0001',
  signature: 'MZXW6YTB',
  expirationDate: _expirationDate,
  uri: Uri.parse('https://example.com/ttype/push'),
  sslVerify: true,
);

PushChoiceRequest choiceRequest() => PushChoiceRequest(
  title: 'Login',
  question: 'Do you want to login?',
  nonce: 'nonce-1',
  serial: 'PIPU0001',
  signature: 'MZXW6YTB',
  expirationDate: _expirationDate,
  uri: Uri.parse('https://example.com/ttype/push'),
  sslVerify: true,
  possibleAnswers: const ['1', '2', '3'],
);

void main() {
  group('DeclineReason', () {
    test('the values sent to the server are pinned', () {
      expect(DeclineReason.unknownTrigger.value, 'unknown_trigger');
      expect(DeclineReason.cancelled.value, 'cancelled');
    });

    test('there are exactly two reasons, each with a distinct value', () {
      expect(DeclineReason.values, hasLength(2));
      expect(DeclineReason.values.map((r) => r.value).toSet(), {
        'unknown_trigger',
        'cancelled',
      });
    });

    test(
      'the json of a request uses the enum name, not the value sent to the server',
      () {
        // The stored state and the wire format are two different things.
        final unknownTrigger = defaultRequest().copyWith(
          accepted: () => false,
          declineReason: () => DeclineReason.unknownTrigger,
        );
        final cancelled = defaultRequest().copyWith(
          accepted: () => false,
          declineReason: () => DeclineReason.cancelled,
        );

        expect(unknownTrigger.toJson()['declineReason'], 'unknownTrigger');
        expect(cancelled.toJson()['declineReason'], 'cancelled');
        expect(defaultRequest().toJson()['declineReason'], isNull);
      },
    );

    test('the decline reason survives a json round trip', () {
      for (final reason in DeclineReason.values) {
        final request = choiceRequest().copyWith(
          accepted: () => false,
          declineReason: () => reason,
        );

        final restored = PushRequestFactory.fromJson(request.toJson());

        expect(restored.declineReason, reason);
        expect(restored.accepted, isFalse);
      }
    });

    test(
      'the wire value of a decline reason is not accepted in the stored json',
      () {
        final json = defaultRequest().toJson()
          ..['declineReason'] = 'unknown_trigger';

        // The wire value is not the stored value, so it is not accepted here.
        expect(() => PushRequestFactory.fromJson(json), throwsArgumentError);
      },
    );
  });
}
