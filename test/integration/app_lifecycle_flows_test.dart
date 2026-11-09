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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/push_request_dialog.dart';

import 'harness/app_harness.dart';
import 'harness/fake_push_endpoint.dart';
import 'harness/reference_otp.dart';

/// Walks the lifecycle the way the OS reports it, one state at a time.
Future<void> _moveTo(AppHarness app, List<AppLifecycleState> states) async {
  for (final state in states) {
    app.tester.binding.handleAppLifecycleStateChanged(state);
    await app.settle(const Duration(milliseconds: 500));
  }
}

Future<void> _sendToBackground(AppHarness app) => _moveTo(app, const [
  AppLifecycleState.inactive,
  AppLifecycleState.hidden,
  AppLifecycleState.paused,
]);

Future<void> _bringToForeground(AppHarness app) => _moveTo(app, const [
  AppLifecycleState.hidden,
  AppLifecycleState.inactive,
  AppLifecycleState.resumed,
]);

void main() {
  appTest(
    'coming back to the foreground clears the notifications and polls, so a '
    'challenge that arrived meanwhile is shown',
    (app) async {
      final push = FakePushEndpoint(FakePushServer.advertising(), app.backend);
      app.storage.putToken(push.enrolledToken());
      await app.start();
      await app.settle();
      expect(find.byType(PushDefaultDialog), findsNothing);

      await _sendToBackground(app);
      push.queueChallenge(question: 'Login while in the background?');
      await _bringToForeground(app);

      await app.pumpUntilFound(find.byType(PushDefaultDialog));
      expect(find.text('Login while in the background?'), findsOneWidget);
      expect(app.platform.notifications.cancelAllCalls, 1);
      app.expectNoErrorLogs();
    },
  );

  appTest(
    'a locked token that was shown is hidden again when the app goes to the '
    'background',
    (app) async {
      final secret = utf8.encode('background-lock-secret');
      app.storage.putToken(
        TOTPToken(
          id: 'locked-2',
          label: 'Payroll',
          issuer: 'Example',
          algorithm: Algorithms.SHA1,
          digits: 6,
          period: 30,
          secret: base32(secret),
          isLocked: true,
        ),
      );
      await app.start();
      await app.tap(find.byIcon(Icons.remove_red_eye_outlined));
      expect(app.tokenState.tokens.single.isHidden, false);

      await _sendToBackground(app);
      expect(app.tokenState.tokens.single.isHidden, true);

      await _bringToForeground(app);
      expect(find.byIcon(Icons.remove_red_eye_outlined), findsOneWidget);
      app.expectNoErrorLogs();
    },
  );
}
