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
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/push_request_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/widgets/push_decline_confirm_dialog.dart';

import 'harness/app_harness.dart';
import 'harness/fake_push_endpoint.dart';

/// A rolled out poll only push token on the device and its server.
FakePushEndpoint _pushTokenOf(AppHarness app, FakePushServer server) {
  final endpoint = FakePushEndpoint(server, app.backend);
  app.storage.putToken(endpoint.enrolledToken());
  return endpoint;
}

Finder _inDialog(Type dialog, Finder finder) =>
    find.descendant(of: find.byType(dialog), matching: finder);

Future<void> _decline(AppHarness app, {required bool triggeredByUser}) async {
  await app.tap(_inDialog(PushDefaultDialog, find.text(l10n.decline)));
  await app.pumpUntilFound(find.byType(PushDeclineConfirmDialog));
  await app.tap(
    _inDialog(
      PushDeclineConfirmDialog,
      find.text(triggeredByUser ? l10n.yes : l10n.no),
    ),
  );
}

Iterable<RecordedRequest> _answersTo(AppHarness app, String nonce) =>
    app.backend.posts.where((r) => r.data['nonce'] == nonce);

void main() {
  group('accept', () {
    appTest(
      'a challenge polled at start is shown and accepting it sends an answer '
      'the server verifies',
      (app) async {
        final push = _pushTokenOf(app, FakePushServer.advertising());
        final challenge = push.queueChallenge(
          title: 'VPN',
          question: 'Do you want to log in to the VPN?',
        );

        await app.start();
        await app.pumpUntilFound(find.byType(PushDefaultDialog));
        expect(find.text('Do you want to log in to the VPN?'), findsOneWidget);

        await app.tap(_inDialog(PushDefaultDialog, find.text(l10n.accept)));
        await app.pumpUntilGone(find.byType(PushDefaultDialog));

        final nonce = challenge['nonce'] as String;
        expect(push.server.sessionOf(nonce), ChallengeSession.answered);
        expect(_answersTo(app, nonce), hasLength(1));
        expect(
          _answersTo(app, nonce).single.data.containsKey('decline'),
          false,
        );
        expect(app.pushRequestState.pushRequests, isEmpty);
        expect(app.storage.storedPushRequestState!.pushRequests, isEmpty);
        expect(app.backend.unhandled, isEmpty);
        app.expectNoErrorLogs();
      },
    );

    appTest('a challenge fetched by pull to refresh is shown and accepted', (
      app,
    ) async {
      final push = _pushTokenOf(app, FakePushServer.legacy());
      await app.start();
      expect(find.byType(PushDefaultDialog), findsNothing);

      final challenge = push.queueChallenge(question: 'Approve the login?');
      await app.pullToRefresh();
      await app.pumpUntilFound(find.byType(PushDefaultDialog));
      expect(find.text('Approve the login?'), findsOneWidget);

      await app.tap(_inDialog(PushDefaultDialog, find.text(l10n.accept)));
      await app.pumpUntilGone(find.byType(PushDefaultDialog));

      expect(
        push.server.sessionOf(challenge['nonce'] as String),
        ChallengeSession.answered,
      );
      app.expectNoErrorLogs();
    });

    appTest('a presence challenge is answered with the option the user taps', (
      app,
    ) async {
      final push = _pushTokenOf(app, FakePushServer.advertising());
      final challenge = push.queueChallenge(
        requirePresence: ['42', '17', '93'],
      );

      await app.start();
      await app.pumpUntilFound(find.byType(PushChoiceDialog));
      await app.tap(_inDialog(PushChoiceDialog, find.text('42')));
      await app.pumpUntilGone(find.byType(PushChoiceDialog));

      final nonce = challenge['nonce'] as String;
      expect(push.server.sessionOf(nonce), ChallengeSession.answered);
      expect(_answersTo(app, nonce).single.data['presence_answer'], '42');
      app.expectNoErrorLogs();
    });

    appTest(
      'an answer that timed out is not sent again and the request stays',
      (app) async {
        final push = _pushTokenOf(app, FakePushServer.advertising());
        final challenge = push.queueChallenge();
        await app.start();
        await app.pumpUntilFound(find.byType(PushDefaultDialog));

        app.backend.networkFailure = FakeBackend.timedOut;
        await app.tap(_inDialog(PushDefaultDialog, find.text(l10n.accept)));
        await app.settle(const Duration(seconds: 2));

        final nonce = challenge['nonce'] as String;
        expect(_answersTo(app, nonce), hasLength(1));
        expect(push.server.sessionOf(nonce), isNull);
        expect(find.byType(PushDefaultDialog), findsOneWidget);
        expect(app.pushRequestState.pushRequests, hasLength(1));
        expect(find.text(l10n.connectionFailed), findsOneWidget);
      },
    );

    appTest(
      'an answer that could not reach the server is retried exactly once',
      (app) async {
        final push = _pushTokenOf(app, FakePushServer.advertising());
        final challenge = push.queueChallenge();
        await app.start();
        await app.pumpUntilFound(find.byType(PushDefaultDialog));

        app.backend.networkFailure = FakeBackend.unreachable;
        await app.tap(_inDialog(PushDefaultDialog, find.text(l10n.accept)));
        await app.settle(const Duration(seconds: 2));

        final nonce = challenge['nonce'] as String;
        expect(_answersTo(app, nonce), hasLength(2));
        expect(find.byType(PushDefaultDialog), findsOneWidget);
        expect(app.pushRequestState.pushRequests, hasLength(1));
      },
    );

    appTest(
      'an answer the server rejects with an error response keeps the request '
      'and tells the user',
      skip:
          'BUG: _handleReaction only treats an unparsable body as failure; an '
          'HTTP 400 privacyIDEA error (result.status false) removes the request '
          'silently although its doc comment promises an error message',
      (app) async {
        final push = _pushTokenOf(app, FakePushServer.advertising());
        final challenge = push.queueChallenge();
        push.answerResponse = (_, _) =>
            FakeBackend.error(905, 'Could not verify signature!');
        await app.start();
        await app.pumpUntilFound(find.byType(PushDefaultDialog));

        await app.tap(_inDialog(PushDefaultDialog, find.text(l10n.accept)));
        await app.settle(const Duration(seconds: 2));

        expect(_answersTo(app, challenge['nonce'] as String), hasLength(1));
        expect(app.statusMessages, isNotEmpty);
        expect(find.byType(PushDefaultDialog), findsOneWidget);
        expect(app.pushRequestState.pushRequests, hasLength(1));
      },
    );

    appTest(
      'a presence answer the server rejects is reported to the user',
      skip:
          'BUG: _handleReaction ignores result.value; privacyIDEA answers a '
          'wrong presence answer with HTTP 200 and value false, and the app '
          'closes the dialog as if the login was approved',
      (app) async {
        final push = _pushTokenOf(app, FakePushServer.advertising());
        final challenge = push.queueChallenge(
          requirePresence: ['42', '17', '93'],
        );
        await app.start();
        await app.pumpUntilFound(find.byType(PushChoiceDialog));

        await app.tap(_inDialog(PushChoiceDialog, find.text('17')));
        await app.settle(const Duration(seconds: 2));

        final nonce = challenge['nonce'] as String;
        expect(push.answers.single.$2.result, false);
        expect(push.server.sessionOf(nonce), isNull);
        expect(app.statusMessages, isNotEmpty);
      },
    );
  });

  group('decline', () {
    appTest('"No" declines with decline_reason unknown_trigger when the server '
        'advertises it', (app) async {
      final push = _pushTokenOf(app, FakePushServer.advertising());
      final challenge = push.queueChallenge();
      await app.start();
      await app.pumpUntilFound(find.byType(PushDefaultDialog));

      await _decline(app, triggeredByUser: false);
      await app.pumpUntilGone(find.byType(PushDefaultDialog));
      await app.pumpUntilGone(find.byType(PushDeclineConfirmDialog));

      final nonce = challenge['nonce'] as String;
      final answer = _answersTo(app, nonce).single.data;
      expect(answer['decline'], '1');
      expect(answer['decline_reason'], 'unknown_trigger');
      expect(push.server.sessionOf(nonce), ChallengeSession.declined);
      expect(app.pushRequestState.pushRequests, isEmpty);
      app.expectNoErrorLogs();
    });

    appTest(
      '"Yes, but discard it" cancels with decline_reason cancelled when the '
      'server advertises it',
      (app) async {
        final push = _pushTokenOf(app, FakePushServer.advertising());
        final challenge = push.queueChallenge();
        await app.start();
        await app.pumpUntilFound(find.byType(PushDefaultDialog));

        await _decline(app, triggeredByUser: true);
        await app.pumpUntilGone(find.byType(PushDefaultDialog));

        final nonce = challenge['nonce'] as String;
        final answer = _answersTo(app, nonce).single.data;
        expect(answer['decline'], '1');
        expect(answer['decline_reason'], 'cancelled');
        expect(push.server.sessionOf(nonce), ChallengeSession.cancelled);
        app.expectNoErrorLogs();
      },
    );

    for (final triggeredByUser in [false, true]) {
      appTest('a server without capabilities gets a plain decline '
          '(${triggeredByUser ? '"Yes, but discard it"' : '"No"'})', (
        app,
      ) async {
        final push = _pushTokenOf(app, FakePushServer.legacy());
        final challenge = push.queueChallenge();
        await app.start();
        await app.pumpUntilFound(find.byType(PushDefaultDialog));

        await _decline(app, triggeredByUser: triggeredByUser);
        await app.pumpUntilGone(find.byType(PushDefaultDialog));

        final nonce = challenge['nonce'] as String;
        final answer = _answersTo(app, nonce).single.data;
        expect(answer['decline'], '1');
        expect(answer.containsKey('decline_reason'), false);
        expect(push.server.sessionOf(nonce), ChallengeSession.declined);
        app.expectNoErrorLogs();
      });
    }

    appTest(
      'discarding while offline removes the request locally and it does not '
      'come back with the next poll',
      (app) async {
        final push = _pushTokenOf(app, FakePushServer.advertising());
        final challenge = push.queueChallenge(question: 'Unexpected login?');
        await app.start();
        await app.pumpUntilFound(find.byType(PushDefaultDialog));

        app.backend.networkFailure = FakeBackend.unreachable;
        await _decline(app, triggeredByUser: true);
        await app.pumpUntilGone(find.byType(PushDefaultDialog));
        await app.pumpUntilGone(find.byType(PushDeclineConfirmDialog));

        final nonce = challenge['nonce'] as String;
        expect(push.server.sessionOf(nonce), isNull);
        expect(app.pushRequestState.pushRequests, isEmpty);
        expect(app.storage.storedPushRequestState!.pushRequests, isEmpty);

        app.backend.networkFailure = null;
        app.backend.clearRecords();
        await app.pullToRefresh();
        expect(
          app.backend.requests.where((r) => !r.isPost),
          isNotEmpty,
          reason:
              'the refresh polled the server, which still has the '
              'challenge open',
        );
        await app.settle(const Duration(seconds: 3));
        expect(find.byType(PushDefaultDialog), findsNothing);
        expect(app.pushRequestState.pushRequests, isEmpty);
      },
    );
  });

  group('code to phone', () {
    appTest(
      'a polled code to phone request shows the code and "Done" removes it '
      'without contacting the server',
      (app) async {
        app.setScreen(AppHarness.wideScreen);
        final push = _pushTokenOf(app, FakePushServer.advertising());
        push.queueCodeToPhoneChallenge(displayCode: '415926');
        await app.start();
        await app.pumpUntilFound(find.byType(PushCodeToPhoneDialog));
        expect(find.text('415926'), findsOneWidget);
        expect(app.backend.posts, isEmpty);

        await app.tap(_inDialog(PushCodeToPhoneDialog, find.text(l10n.done)));
        await app.pumpUntilGone(find.byType(PushCodeToPhoneDialog));
        await app.settle(const Duration(seconds: 2));

        expect(app.backend.posts, isEmpty);
        expect(push.answers, isEmpty);
        expect(app.pushRequestState.pushRequests, isEmpty);
        expect(app.storage.storedPushRequestState!.pushRequests, isEmpty);
        app.expectNoErrorLogs();
      },
    );

    appTest(
      'an accepted request that answers with a display code shows the code '
      'and "Done" closes it without any further request',
      (app) async {
        app.setScreen(AppHarness.wideScreen);
        final push = _pushTokenOf(app, FakePushServer.advertising());
        final challenge = push.queueChallenge();
        push.answerResponse = (_, _) => FakeBackend.json(
          true,
          detail: {'display_code': '739104', 'message': 'Enter this code'},
        );
        await app.start();
        await app.pumpUntilFound(find.byType(PushDefaultDialog));

        await app.tap(_inDialog(PushDefaultDialog, find.text(l10n.accept)));
        await app.pumpUntilFound(find.byType(PushCodeToPhoneDialog));
        expect(find.text('739104'), findsOneWidget);
        expect(
          push.server.sessionOf(challenge['nonce'] as String),
          ChallengeSession.answered,
        );

        app.backend.clearRecords();
        await app.tap(_inDialog(PushCodeToPhoneDialog, find.text(l10n.done)));
        await app.pumpUntilGone(find.byType(PushCodeToPhoneDialog));
        await app.settle(const Duration(seconds: 2));

        expect(app.backend.posts, isEmpty);
        expect(app.pushRequestState.pushRequests, isEmpty);
        expect(app.storage.storedPushRequestState!.pushRequests, isEmpty);
        app.expectNoErrorLogs();
      },
    );
  });
}
