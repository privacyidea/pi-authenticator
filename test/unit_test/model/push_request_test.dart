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

/// The identity of a push request: `id == nonce.hashCode` and `==` compares
/// the runtime type and the id only. Neither the serial (the token the request
/// belongs to) nor the nonce itself takes part.
///
/// The consequences are visible in [PushRequestState], which uses the id to
/// decide whether a request is already known and to replace requests.
library;

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/push_request/decline_reason.dart';
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';

/// Run the tests of suspected bugs for real:
/// `flutter test --dart-define=RUN_BUG_TESTS=true <this file>`
const _runBugTests = bool.fromEnvironment('RUN_BUG_TESTS');

final _expirationDate = DateTime.utc(2026, 1, 1, 12);

PushDefaultRequest defaultRequest({
  String nonce = 'nonce-1',
  String serial = 'PIPU0001',
  String title = 'Login',
  String uri = 'https://example.com/ttype/push',
}) => PushDefaultRequest(
  title: title,
  question: 'Do you want to login?',
  nonce: nonce,
  serial: serial,
  signature: 'MZXW6YTB',
  expirationDate: _expirationDate,
  uri: Uri.parse(uri),
  sslVerify: true,
);

PushChoiceRequest choiceRequest({
  String nonce = 'nonce-1',
  String serial = 'PIPU0001',
}) => PushChoiceRequest(
  title: 'Login',
  question: 'Do you want to login?',
  nonce: nonce,
  serial: serial,
  signature: 'MZXW6YTB',
  expirationDate: _expirationDate,
  uri: Uri.parse('https://example.com/ttype/push'),
  sslVerify: true,
  possibleAnswers: const ['1', '2', '3'],
);

PushCodeToPhoneRequest codeRequest({
  String nonce = 'nonce-1',
  String serial = 'PIPU0001',
}) => PushCodeToPhoneRequest(
  title: 'Login',
  question: 'Do you want to login?',
  nonce: nonce,
  serial: serial,
  signature: 'MZXW6YTB',
  expirationDate: _expirationDate,
  uri: Uri.parse('https://example.com/ttype/push'),
  sslVerify: true,
  displayCode: '123456',
);

/// Two different nonces with the same `hashCode`. Found by searching, because
/// the hash of a String is only an int.
({String a, String b}) findCollidingNonces() {
  final seen = <int, String>{};
  for (var i = 0; i < 2000000; i++) {
    final nonce = 'nonce$i';
    final previous = seen[nonce.hashCode];
    if (previous != null) return (a: previous, b: nonce);
    seen[nonce.hashCode] = nonce;
  }
  throw StateError('No colliding nonces found.');
}

void main() {
  final factories =
      <String, PushRequest Function({String nonce, String serial})>{
        'PushDefaultRequest': ({nonce = 'nonce-1', serial = 'PIPU0001'}) =>
            defaultRequest(nonce: nonce, serial: serial),
        'PushChoiceRequest': ({nonce = 'nonce-1', serial = 'PIPU0001'}) =>
            choiceRequest(nonce: nonce, serial: serial),
        'PushCodeToPhoneRequest': ({nonce = 'nonce-1', serial = 'PIPU0001'}) =>
            codeRequest(nonce: nonce, serial: serial),
      };

  group('id', () {
    for (final entry in factories.entries) {
      test('${entry.key}.id is the hashCode of the nonce', () {
        final request = entry.value(nonce: 'a-nonce');

        expect(request.id, 'a-nonce'.hashCode);
      });

      test('${entry.key}.id does not depend on anything but the nonce', () {
        final a = entry.value(nonce: 'a-nonce', serial: 'PIPU0001');
        final b = entry.value(nonce: 'a-nonce', serial: 'PIPU0002');

        expect(a.id, b.id);
        expect(a.copyWith(title: 'other', sslVerify: false).id, a.id);
      });

      test('${entry.key}.id changes with the nonce', () {
        expect(
          entry.value(nonce: 'nonce-1').id,
          isNot(entry.value(nonce: 'nonce-2').id),
        );
      });
    }

    test('a request created from message data has the nonce hash as id', () {
      // The request is created from message data in the same way as in the app.
      final request = PushRequestFactory.fromMessageData({
        'title': 'Login',
        'question': 'Do you want to login?',
        'url': 'https://example.com/ttype/push',
        'nonce': 'from-message',
        'sslverify': '1',
        'serial': 'PIPU0001',
        'signature': 'MZXW6YTB',
      });

      expect(request.id, 'from-message'.hashCode);
    });
  });

  group('equality', () {
    for (final entry in factories.entries) {
      test('${entry.key}: same nonce is equal, with equal hashCode', () {
        final a = entry.value(nonce: 'same');
        final b = entry.value(nonce: 'same');

        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
        expect({a, b}, hasLength(1));
      });

      test('${entry.key}: different nonces are not equal', () {
        final a = entry.value(nonce: 'nonce-1');
        final b = entry.value(nonce: 'nonce-2');

        expect(a, isNot(equals(b)));
        expect({a, b}, hasLength(2));
      });

      test(
        '${entry.key}: the state of the request (answer, decline reason) is ignored',
        () {
          final a = entry.value(nonce: 'same');
          final answered = a.copyWith(
            accepted: () => false,
            declineReason: () => DeclineReason.cancelled,
            title: 'Other title',
          );

          expect(answered, equals(a));
          expect(answered.accepted, isFalse);
          expect(a.accepted, isNull);
        },
      );

      test(
        '${entry.key}: is not equal to something that is not a push request',
        () {
          // ignore: unrelated_type_equality_checks
          expect(entry.value() == 'nonce-1', isFalse);
          // ignore: unrelated_type_equality_checks
          expect(entry.value() == entry.value().id, isFalse);
        },
      );
    }

    test(
      'requests of different types with the same nonce share the id but are not equal',
      () {
        final all = [for (final f in factories.values) f(nonce: 'same')];

        for (final a in all) {
          for (final b in all) {
            if (identical(a, b)) continue;
            expect(a.id, b.id);
            expect(
              a == b,
              isFalse,
              reason: '${a.runtimeType} == ${b.runtimeType}',
            );
          }
        }
      },
    );

    test(
      'a PushChoiceRequest is not equal to a PushDefaultRequest with the same nonce, in both directions',
      () {
        final choice = choiceRequest(nonce: 'same');
        final plain = defaultRequest(nonce: 'same');

        // PushChoiceRequest extends PushDefaultRequest, so the runtimeType check
        // is what separates them.
        expect(choice, isA<PushDefaultRequest>());
        expect(choice == plain, isFalse);
        expect(plain == choice, isFalse);
      },
    );
  });

  group('requests of different tokens with the same nonce', () {
    // Two serials: two tokens, e.g. of two servers. The nonce is chosen by the
    // server, the app has no influence on it.
    final tokenA = defaultRequest(
      nonce: 'shared',
      uri: 'https://server-a.example/ttype/push',
    );
    final tokenB = defaultRequest(
      nonce: 'shared',
      serial: 'PIPU0002',
      uri: 'https://server-b.example/ttype/push',
    );

    test(
      'they are the same request for ==, hashCode and id (DESIGN ISSUE: the serial is ignored)',
      () {
        expect(tokenA.serial, isNot(tokenB.serial));
        expect(tokenA.uri, isNot(tokenB.uri));

        expect(tokenA == tokenB, isTrue);
        expect(tokenA.hashCode, tokenB.hashCode);
        expect(tokenA.id, tokenB.id);
        expect({tokenA, tokenB}, hasLength(1));
      },
    );

    test(
      'the state treats the second one as already known, so it is dropped (DESIGN ISSUE)',
      () {
        final state = PushRequestState.empty().withRequest(tokenA);

        // PushRequestNotifier.add and SecurePushRequestRepository.addRequest
        // drop a request for which this is true.
        expect(state.knowsRequest(tokenB), isTrue);
        expect(state.knowsRequestId(tokenB.id), isTrue);
      },
    );

    test(
      'addOrReplace replaces the request of the first token with the one of the second (DESIGN ISSUE)',
      () {
        final state = PushRequestState.empty()
            .withRequest(tokenA)
            .addOrReplace(tokenB);

        expect(state.pushRequests, hasLength(1));
        expect(state.pushRequests.single.serial, 'PIPU0002');
        expect(state.pushRequests.single.uri, tokenB.uri);
      },
    );

    test(
      'currentOf returns the stored request of the other token (DESIGN ISSUE)',
      () {
        final state = PushRequestState.empty().withRequest(tokenA);

        expect(state.currentOf(tokenB)?.serial, 'PIPU0001');
      },
    );

    test(
      'replaceRequest overwrites the request of the other token (DESIGN ISSUE)',
      () {
        final state = PushRequestState.empty().withRequest(tokenA);

        final (replaced, success) = state.replaceRequest(tokenB);

        expect(success, isTrue);
        expect(replaced.pushRequests.single.serial, 'PIPU0002');
      },
    );

    test(
      'withoutRequest removes the request of the other token (DESIGN ISSUE)',
      () {
        final state = PushRequestState.empty().withRequest(tokenA);

        expect(state.withoutRequest(tokenB).pushRequests, isEmpty);
      },
    );

    test(
      'control: requests with different nonces of different tokens live side by side',
      () {
        final other = defaultRequest(nonce: 'other', serial: 'PIPU0002');
        final state = PushRequestState.empty().withRequest(tokenA);

        expect(state.knowsRequest(other), isFalse);
        final both = state.withRequest(other);
        expect(both.pushRequests.map((r) => r.serial), [
          'PIPU0001',
          'PIPU0002',
        ]);
        expect(both.currentOf(other)?.serial, 'PIPU0002');
      },
    );

    group(
      'SUSPECTED BUG',
      () {
        test('the requests of two tokens are different requests', () {
          expect(tokenA == tokenB, isFalse);
        });

        test(
          'the second request is not known after only the first one was added',
          () {
            final state = PushRequestState.empty().withRequest(tokenA);

            expect(state.knowsRequest(tokenB), isFalse);
          },
        );
      },
      skip: _runBugTests
          ? null
          : 'BUG: push_request.dart:229 == and id (nonce.hashCode) ignore the serial, so a request of another token with the same nonce is dropped as known',
    );
  });

  group('requests with different nonces but the same nonce hashCode', () {
    late ({String a, String b}) colliding;

    setUpAll(() => colliding = findCollidingNonces());

    test(
      'premise: such nonces exist, because the id is only the 32 bit hash',
      () {
        expect(colliding.a, isNot(colliding.b));
        expect(colliding.a.hashCode, colliding.b.hashCode);

        final a = defaultRequest(nonce: colliding.a);
        final b = defaultRequest(nonce: colliding.b);

        expect(a.id, b.id);
        expect(a.nonce, isNot(b.nonce));
      },
    );

    test(
      'they are the same request for ==, and the second one is dropped as known (DESIGN ISSUE)',
      () {
        final a = defaultRequest(nonce: colliding.a);
        final b = defaultRequest(nonce: colliding.b);

        expect(a == b, isTrue);
        expect(PushRequestState.empty().withRequest(a).knowsRequest(b), isTrue);
      },
    );

    test(
      'control: the buffer of known ids is what makes the replay protection',
      () {
        final a = defaultRequest(nonce: 'replayed');
        final state = PushRequestState.empty().withRequest(a);
        // Removing the request does not make it unknown again.
        final removed = state.withoutRequest(a);

        expect(removed.pushRequests, isEmpty);
        expect(removed.knowsRequest(a), isTrue);
        expect(
          const ListEquality<int>().equals(removed.knownPushRequests.list, [
            a.id,
          ]),
          isTrue,
        );
      },
    );

    test(
      'SUSPECTED BUG: requests with different nonces are different requests',
      () {
        final a = defaultRequest(nonce: colliding.a);
        final b = defaultRequest(nonce: colliding.b);

        expect(a == b, isFalse);
        expect(
          PushRequestState.empty().withRequest(a).knowsRequest(b),
          isFalse,
        );
      },
      skip: _runBugTests
          ? null
          : 'BUG: push_request.dart:106 id is nonce.hashCode, two different nonces with a colliding hash are the same request',
    );
  });
}
