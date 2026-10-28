import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/token_import_type.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/token_import/token_import_source.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/token_import_scheme_processor_interface.dart';
import 'package:privacyidea_authenticator/views/import_tokens_view/pages/import_start_page.dart';

import '../../../tests_app_wrapper.dart';

/// A processor that breaks the way a bad payload breaks a real one.
class _ThrowingProcessor extends TokenImportSchemeProcessor {
  const _ThrowingProcessor();

  @override
  Set<String> get supportedSchemes => {'otpauth'};

  @override
  Future<List<ProcessorResult<Token>>?> processUri(
    Uri uri, {
    bool fromInit = false,
  }) async => throw const FormatException('bad payload');
}

final _l = AppLocalizationsEn();

void main() {
  testWidgets('a processor that throws ends the spinner with a message', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestsAppWrapper(
        child: ImportStartPage(
          appName: 'App',
          selectedSource: TokenImportSource(
            type: TokenImportType.link,
            processor: const _ThrowingProcessor(),
            importHint: (_) => 'hint',
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'otpauth://totp/x?secret=A');

    await tester.tap(find.text(_l.enterLink));
    // The import runs in a Future of its own; let it start, fail and rebuild.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(_l.invalidLink('App')), findsOneWidget);
  });
}
