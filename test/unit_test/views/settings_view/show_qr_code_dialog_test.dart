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
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_groups/import_export_tokens_widgets/dialogs/show_qr_code_dialog.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../tests_app_wrapper.dart';
import '../../utils/encryption/token_export_fixtures.dart';
import '../dialog_layout_helpers.dart';

final _l10n = AppLocalizationsEn();

TOTPToken _token() => TOTPToken(
  id: 'qr-token',
  label: 'account',
  issuer: 'issuer',
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'GEZDGNBVGY3TQOJQ',
  period: 30,
);

void main() {
  setUpAll(() async {
    await setupMocks();
  });

  group('ShowQrCodeDialog layout', () {
    for (final entry in dialogLayoutSizes.entries) {
      testWidgets('has no overflow and a square QR code at ${entry.key}', (
        tester,
      ) async {
        setScreen(tester, entry.value);
        await showDialogOf<bool>(tester, ShowQrCodeDialog(token: _token()));

        expect(tester.takeException(), isNull);
        expectSquare(tester, qrOf(ShowQrCodeDialog));
        expectOnScreen(tester, qrOf(ShowQrCodeDialog));
        expectOnScreen(tester, find.text(_l10n.asQrCode));
        expectOnScreen(tester, find.text(_l10n.scanThisQrWithNewDevice));
        expectOnScreen(
          tester,
          find.widgetWithText(IntentButton, _l10n.exportOneMore),
        );
        expectOnScreen(tester, find.widgetWithText(IntentButton, _l10n.done));
      });
    }

    testWidgets('the dialog surface stays on screen and contains the QR code', (
      tester,
    ) async {
      setScreen(tester, const Size(480, 320));
      await showDialogOf<bool>(tester, ShowQrCodeDialog(token: _token()));

      final surface = surfaceOf();
      expectOnScreen(tester, surface);
      expectInsideSurface(tester, surface, qrOf(ShowQrCodeDialog));
      expectInsideSurface(
        tester,
        surface,
        find.widgetWithText(IntentButton, _l10n.done),
      );
      expectInsideSurface(tester, surface, find.text(_l10n.asQrCode));
    });

    testWidgets('the QR code is bigger in portrait than in a short landscape', (
      tester,
    ) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf<bool>(tester, ShowQrCodeDialog(token: _token()));
      final portrait = tester.getSize(qrOf(ShowQrCodeDialog)).width;

      setScreen(tester, const Size(568, 320));
      await tester.pumpAndSettle();
      final landscape = tester.getSize(qrOf(ShowQrCodeDialog)).width;

      expect(tester.takeException(), isNull);
      expect(portrait, greaterThan(landscape));
      expectSquare(tester, qrOf(ShowQrCodeDialog));
    });

    testWidgets('does not scroll its content', (tester) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf<bool>(tester, ShowQrCodeDialog(token: _token()));

      expect(
        tester
            .widget<DefaultDialog>(find.byType(DefaultDialog))
            .scrollableContent,
        isFalse,
      );
      expect(
        find.descendant(
          of: find.byType(ShowQrCodeDialog),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );
    });

    testWidgets('tapping the QR code shows it maximized and square', (
      tester,
    ) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf<bool>(tester, ShowQrCodeDialog(token: _token()));
      final smallSize = tester.getSize(qrOf(ShowQrCodeDialog)).width;

      await tester.tap(qrOf(ShowQrCodeDialog));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final images = find.byType(Image);
      expect(images, findsNWidgets(2));
      final maximized = images.last;
      expectSquare(tester, maximized);
      expectOnScreen(tester, maximized);
      expect(tester.getSize(maximized).width, greaterThan(smallSize));
      expect(tester.getSize(maximized).width, lessThanOrEqualTo(320 - 32));

      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(ShowQrCodeDialog), findsOneWidget);
    });

    testWidgets('the maximized QR code fits a short landscape screen', (
      tester,
    ) async {
      setScreen(tester, const Size(480, 320));
      await showDialogOf<bool>(tester, ShowQrCodeDialog(token: _token()));

      await tester.tap(qrOf(ShowQrCodeDialog));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final maximized = find.byType(Image).last;
      expectSquare(tester, maximized);
      expectOnScreen(tester, maximized);
      expect(tester.getSize(maximized).height, lessThanOrEqualTo(320 - 32));
    });

    testWidgets('done closes the dialog with true', (tester) async {
      setScreen(tester, const Size(320, 480));
      bool? result;
      var closed = false;
      await showDialogOf<bool>(
        tester,
        ShowQrCodeDialog(token: _token()),
        onResult: (value) {
          result = value;
          closed = true;
        },
      );

      await tester.tap(find.widgetWithText(IntentButton, _l10n.done));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(result, isTrue);
      expect(find.byType(ShowQrCodeDialog), findsNothing);
    });

    testWidgets('export one more closes the dialog without a result', (
      tester,
    ) async {
      setScreen(tester, const Size(320, 480));
      bool? result = true;
      var closed = false;
      await showDialogOf<bool>(
        tester,
        ShowQrCodeDialog(token: _token()),
        onResult: (value) {
          result = value;
          closed = true;
        },
      );

      await tester.tap(find.widgetWithText(IntentButton, _l10n.exportOneMore));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(result, isNull);
      expect(find.byType(ShowQrCodeDialog), findsNothing);
    });
  });

  group('ShowQrCodeDialog build', () {
    testWidgets('ShowQrCodeDialog shows a QR image for a normal token', (tester) async {
      await tester.pumpWidget(TestsAppWrapper(child: Scaffold(body: ShowQrCodeDialog(token: exportUriTotp()))));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('a token above the QR capacity shows a message instead of crashing', (tester) async {
      // generateQrCodeImage throws a WriterException past QR version 40; the
      // dialog used to end in the framework's error widget.
      await tester.pumpWidget(TestsAppWrapper(child: Scaffold(body: ShowQrCodeDialog(token: exportUriMinimalTotp(label: 'x' * 3000)))));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text(_l10n.qrCodeTooMuchData), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    test('the message for a token above the QR capacity is translated into every app language', () {
      final untranslated = [
        for (final locale in AppLocalizations.supportedLocales)
          if (locale.languageCode != 'en' &&
              lookupAppLocalizations(locale).qrCodeTooMuchData == _l10n.qrCodeTooMuchData)
            locale.languageCode,
      ];

      expect(untranslated, isEmpty);
    });
  });
}
