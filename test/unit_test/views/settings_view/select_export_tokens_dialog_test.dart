import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_groups/import_export_tokens_widgets/dialogs/export_tokens_to_file_dialog.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_groups/import_export_tokens_widgets/dialogs/select_tokens_dialog.dart';

import '../../../tests_app_wrapper.dart';
import '../../../tests_app_wrapper.mocks.dart';
import '../../utils/encryption/token_export_fixtures.dart';

Future<void> _pumpDialog(
  WidgetTester tester,
  Token token, {
  required Future<bool> Function(Set<Token> tokens) authorize,
}) async {
  final repo = MockTokenRepository();
  when(repo.loadTokens()).thenAnswer((_) async => [token]);
  await tester.pumpWidget(
    TestsAppWrapper(
      overrides: [
        tokenProvider.overrideWith(() => TokenNotifier(repoOverride: repo)),
      ],
      child: SelectExportTokensDialog(
        multiSelect: false,
        authorize: authorize,
        dialogBuilder: (tokens) => Text('exported ${tokens.single.label}'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('SelectExportTokensDialog authorize', () {
    testWidgets('runs for the picked token and blocks the export when refused', (
      tester,
    ) async {
      final token = exportUriTotp();
      Set<Token>? asked;
      await _pumpDialog(
        tester,
        token,
        authorize: (tokens) async {
          asked = tokens;
          return false;
        },
      );

      await tester.tap(find.text(token.label));
      await tester.pumpAndSettle();

      expect(asked?.single.id, token.id);
      expect(find.text('exported ${token.label}'), findsNothing);
    });

    testWidgets('shows the export once it is granted', (tester) async {
      final token = exportUriTotp();
      await _pumpDialog(tester, token, authorize: (_) async => true);

      await tester.tap(find.text(token.label));
      await tester.pumpAndSettle();

      expect(find.text('exported ${token.label}'), findsOneWidget);
    });
  });

  group('exportForceBiometricOption', () {
    TOTPToken withOption(ForceBiometricOption option) =>
        exportUriTotp().copyWith(forceBiometricOption: option);

    test('forces biometric when one token asks for it', () {
      expect(
        exportForceBiometricOption([
          withOption(ForceBiometricOption.pin),
          withOption(ForceBiometricOption.biometric),
        ]),
        ForceBiometricOption.biometric,
      );
    });

    test('forces nothing when no token asks for biometric', () {
      expect(
        exportForceBiometricOption([
          withOption(ForceBiometricOption.pin),
          withOption(ForceBiometricOption.none),
        ]),
        isNull,
      );
    });
  });
}
