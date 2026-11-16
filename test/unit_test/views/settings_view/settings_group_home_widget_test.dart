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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/home_widget_utils.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_groups/settings_group_home_widget.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view_widgets/settings_group.dart';

class _FakeTokenNotifier extends TokenNotifier {
  final List<Token> tokens;
  _FakeTokenNotifier(this.tokens);

  @override
  Future<TokenState> build({
    required TokenRepository repo,
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required FirebaseUtils firebaseUtils,
  }) async => TokenState(tokens: tokens);
}

final _otpToken = HOTPToken(
  id: 'live-check-hotp',
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'JBSWY3DPEHPK3PXP',
);

void main() {
  const channel = MethodChannel('home_widget');
  final l10n = AppLocalizationsEn();

  late bool pinSupported;
  late int pinRequests;
  late List<Token> tokens;

  setUp(() {
    pinSupported = true;
    pinRequests = 0;
    tokens = [_otpToken];
    SettingsGroupHomeWidget.debugLinkViewBuilder = () =>
        const Scaffold(body: Text('live-check-token-list'));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'isRequestPinWidgetSupported':
              return pinSupported;
            case 'requestPinWidget':
              pinRequests++;
              return null;
          }
          return null;
        });
  });

  tearDown(() {
    SettingsGroupHomeWidget.debugLinkViewBuilder = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> pumpGroup(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenProvider.overrideWith(() => _FakeTokenNotifier(tokens)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SettingsGroupHomeWidget(
              utils: HomeWidgetUtils.debugInstance(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool entryIsActive(WidgetTester tester) =>
      tester.widget<SettingsGroup>(find.byType(SettingsGroup)).isActive;

  testWidgets('the entry is shown when the launcher can add widgets', (
    tester,
  ) async {
    await pumpGroup(tester);

    expect(find.text(l10n.homeWidget), findsOneWidget);
  });

  testWidgets('the entry is hidden when the launcher cannot add widgets', (
    tester,
  ) async {
    pinSupported = false;

    await pumpGroup(tester);

    expect(find.text(l10n.homeWidget), findsNothing);
  });

  testWidgets('a tap opens the token list and asks the launcher nothing yet', (
    tester,
  ) async {
    await pumpGroup(tester);

    await tester.tap(find.text(l10n.homeWidget));
    await tester.pumpAndSettle();

    expect(find.text('live-check-token-list'), findsOneWidget);
    expect(pinRequests, 0);
  });

  testWidgets('the entry is active while a token can get a widget', (
    tester,
  ) async {
    await pumpGroup(tester);

    expect(entryIsActive(tester), true);
  });

  testWidgets('the entry is disabled when no token can get a widget', (
    tester,
  ) async {
    tokens = [];

    await pumpGroup(tester);
    await tester.tap(find.text(l10n.homeWidget));
    await tester.pumpAndSettle();

    expect(entryIsActive(tester), false);
    expect(find.text('live-check-token-list'), findsNothing);
  });
}
