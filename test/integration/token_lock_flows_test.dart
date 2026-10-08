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
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/totp_token_widgets/totp_token_widget_tile.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/push_request_dialog.dart';

import 'harness/app_harness.dart';
import 'harness/fake_push_endpoint.dart';
import 'harness/reference_otp.dart';

final _secret = utf8.encode('locked-token-secret-01');
final _digits = RegExp(r'\d{3} \d{3}');

Iterable<String> _codesIn(Finder tile) => find
    .descendant(
      of: tile,
      matching: find.byWidgetPredicate(
        (w) => w is Text && _digits.hasMatch(w.data ?? ''),
      ),
    )
    .evaluate()
    .map((e) => (e.widget as Text).data!.replaceAll(' ', ''));

void main() {
  appTest('a locked token shows its code only after the device authentication '
      'succeeded and hides it again once the next period is over', (app) async {
    app.storage.putToken(
      TOTPToken(
        id: 'locked-1',
        label: 'Bank',
        issuer: 'Example',
        algorithm: Algorithms.SHA1,
        digits: 6,
        period: 30,
        secret: base32(_secret),
        isLocked: true,
      ),
    );
    await app.start();
    final tile = find.byType(TOTPTokenWidgetTile);
    await app.pumpUntilFound(tile);
    expect(_codesIn(tile), isEmpty, reason: 'hidden on start');

    app.platform.localAuth.nextResult = false;
    await app.tap(find.byIcon(Icons.remove_red_eye_outlined));
    expect(app.platform.localAuth.prompts, [l10n.authenticateToShowOtp]);
    expect(_codesIn(tile), isEmpty, reason: 'a failed prompt shows nothing');

    app.platform.localAuth.nextResult = true;
    await app.tap(find.byIcon(Icons.remove_red_eye_outlined));
    expect(app.platform.localAuth.prompts, hasLength(2));
    final before = referenceTotp(_secret, DateTime.now());
    final shown = _codesIn(tile).toSet();
    final after = referenceTotp(_secret, DateTime.now());
    expect(shown, anyOf({before}, {after}));

    final remaining = 30 - DateTime.now().millisecondsSinceEpoch ~/ 1000 % 30;
    await app.settle(Duration(seconds: remaining + 28));
    expect(_codesIn(tile), isNotEmpty, reason: 'shown for the next period');
    await app.settle(const Duration(seconds: 3));
    expect(_codesIn(tile), isEmpty, reason: 'hidden after the next period');
    app.expectNoErrorLogs();
  });

  appTest('accepting a request of a locked push token needs the device '
      'authentication, a cancelled prompt sends nothing', (app) async {
    final push = FakePushEndpoint(FakePushServer.advertising(), app.backend);
    app.storage.putToken(push.enrolledToken().copyWith(isLocked: true));
    final challenge = push.queueChallenge();
    await app.start();
    await app.pumpUntilFound(find.byType(PushDefaultDialog));
    final accept = find.descendant(
      of: find.byType(PushDefaultDialog),
      matching: find.text(l10n.accept),
    );

    app.platform.localAuth.nextResult = false;
    await app.tap(accept);
    expect(app.platform.localAuth.prompts, [l10n.authToAcceptPushRequest]);
    expect(app.backend.posts, isEmpty);
    expect(find.byType(PushDefaultDialog), findsOneWidget);

    app.platform.localAuth.nextResult = true;
    await app.settle();
    await app.tap(accept);
    await app.pumpUntilGone(find.byType(PushDefaultDialog));
    expect(
      push.server.sessionOf(challenge['nonce'] as String),
      ChallengeSession.answered,
    );
    app.expectNoErrorLogs();
  });
}
