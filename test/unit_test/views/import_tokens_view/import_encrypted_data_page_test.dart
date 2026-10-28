import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/token_import_type.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/processors/mixins/token_import_processor.dart';
import 'package:privacyidea_authenticator/views/import_tokens_view/pages/import_encrypted_data_page.dart';

import '../../../tests_app_wrapper.dart';

/// Fails the way a broken file does, not with a wrong password.
class _BrokenFileProcessor with TokenImportProcessor<String, String?> {
  @override
  Future<List<ProcessorResult<Token>>?> processTokenMigrate(
    String data, {
    String? args,
  }) async => throw const FormatException('unexpected end of input');
}

void main() {
  testWidgets('a failure other than a wrong password ends the spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestsAppWrapper(
        child: ImportEncryptedDataPage<String, String?>(
          appName: 'App',
          data: 'encrypted',
          selectedType: TokenImportType.backupFile,
          processor: _BrokenFileProcessor(),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'password');
    await tester.pump();

    await tester.tap(find.text(AppLocalizationsEn().decrypt));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(AppLocalizationsEn().decrypt), findsOneWidget);
  });
}
