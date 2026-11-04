import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_groups/import_export_tokens_widgets/dialogs/export_tokens_to_file_dialog.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';

import '../../../tests_app_wrapper.dart';

final _l = AppLocalizationsEn();

Future<IntentButton> _exportButtonAfter(
  WidgetTester tester,
  String password,
) async {
  await tester.pumpWidget(
    TestsAppWrapper(
      child: ExportTokensToFileDialog(
        tokens: [
          HOTPToken(
            id: 'a',
            algorithm: Algorithms.SHA1,
            digits: 6,
            secret: 'secret',
          ),
        ],
      ),
    ),
  );
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), password);
  await tester.enterText(fields.at(1), password);
  await tester.pump();
  return tester.widget<IntentButton>(
    find.widgetWithText(IntentButton, _l.export),
  );
}

void main() {
  group('ExportTokensToFileDialog', () {
    testWidgets('a weak password cannot be used for the export', (
      tester,
    ) async {
      // The password protects every secret in the file; the validator's rules
      // must hold for the button, not only for the error text.
      for (final weak in ['password', 'Password1', 'Sh0rt!']) {
        final button = await _exportButtonAfter(tester, weak);
        expect(button.onPressed, isNull, reason: weak);
      }
    });

    testWidgets('a strong password enables the export', (tester) async {
      final button = await _exportButtonAfter(tester, 'Str0ng!Passw');
      expect(button.onPressed, isNotNull);
    });
  });

  group('exportFileSavedMessage', () {
    setUpAll(setupMocks);
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('on iOS names the app folder in the Files app', () {
      // iOS writes the file to the app's Documents folder, not to Downloads.
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(exportFileSavedMessage(_l), _l.fileSavedToFilesApp('privacyIDEA'));
    });

    test('on Android names the Downloads folder', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(exportFileSavedMessage(_l), _l.fileSavedToDownloadsFolder);
    });
  });
}
