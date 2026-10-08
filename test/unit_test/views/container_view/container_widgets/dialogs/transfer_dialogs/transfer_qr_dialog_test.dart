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
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/views/container_view/container_widgets/dialogs/transfer_dialogs/transfer_qr_dialog.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../../../../tests_app_wrapper.dart';
import '../../../../../../tests_app_wrapper.mocks.dart';
import '../../../../dialog_layout_helpers.dart';

final _l10n = AppLocalizationsEn();

void main() {
  setUpAll(() async {
    await setupMocks();
  });

  group('TransferQrDialog layout', () {
    final qrData = 'otpauth://container/transfer?data=${'x' * 300}';

    Widget dialog([String? data]) => TransferQrDialog(
      qrData: data ?? qrData,
      container: MockTokenContainerFinalized(),
    );

    for (final entry in dialogLayoutSizes.entries) {
      testWidgets('has no overflow and a square QR code at ${entry.key}', (
        tester,
      ) async {
        setScreen(tester, entry.value);
        await showDialogOf<void>(tester, dialog());

        expect(tester.takeException(), isNull);
        expectSquare(tester, qrOf(TransferQrDialog));
        expectOnScreen(tester, qrOf(TransferQrDialog));
        expectOnScreen(tester, find.text(_l10n.transferContainerDialogTitle));
        expectOnScreen(tester, find.text(_l10n.transferContainerScanQrCode));
        expectOnScreen(tester, find.widgetWithText(IntentButton, _l10n.done));
      });
    }

    testWidgets('a very long payload still fits a small screen', (
      tester,
    ) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf<void>(tester, dialog('y' * 1200));

      expect(tester.takeException(), isNull);
      expectSquare(tester, qrOf(TransferQrDialog));
      expectOnScreen(tester, qrOf(TransferQrDialog));
    });

    testWidgets('places the centered QR code between the text and the action', (
      tester,
    ) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf<void>(tester, dialog());

      final qr = tester.getRect(qrOf(TransferQrDialog));
      final text = tester.getRect(find.text(_l10n.transferContainerScanQrCode));
      final done = tester.getRect(
        find.widgetWithText(IntentButton, _l10n.done),
      );
      final surface = surfaceOf();

      expect(qr.top, greaterThanOrEqualTo(text.bottom));
      expect(qr.bottom, lessThanOrEqualTo(done.top));
      expect(qr.center.dx, closeTo(tester.getRect(surface).center.dx, 1));
      expectInsideSurface(tester, surface, qrOf(TransferQrDialog));
      expectInsideSurface(tester, surface, find.byType(IntentButton));
    });

    testWidgets('does not scroll its content', (tester) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf<void>(tester, dialog());

      expect(
        tester
            .widget<DefaultDialog>(find.byType(DefaultDialog))
            .scrollableContent,
        isFalse,
      );
    });

    testWidgets('has a single confirm action', (tester) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf<void>(tester, dialog());

      expect(
        find.descendant(
          of: find.byType(TransferQrDialog),
          matching: find.byType(IntentButton),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<IntentButton>(find.widgetWithText(IntentButton, _l10n.done))
            .intent,
        ActionIntent.confirm,
      );
    });
  });
}
