import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/initial_token_assignment_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/send_otps_without_ssl_dialog.dart';
import 'package:privacyidea_authenticator/widgets/select_tokens_widget.dart';

import '../../../../../tests_app_wrapper.dart';

TOTPToken createTestToken(String label, {List<String>? checkedContainer}) {
  return TOTPToken(
    serial: 'serial_$label',
    label: label,
    id: 'id_$label',
    secret: 'BASE32SECRET3232',
    digits: 6,
    period: 30,
    algorithm: Algorithms.SHA1,
    checkedContainer: checkedContainer ?? [],
  );
}

void main() {
  final testContainer = TokenContainer.finalized(
    serial: 'CON_01',
    issuer: 'privacyIDEA',
    nonce: 'n',
    timestamp: DateTime.now(),
    serverUrl: Uri.parse('https://pi.netknights.it'),
    ecKeyAlgorithm: EcKeyAlgorithm.prime256v1,
    hashAlgorithm: Algorithms.SHA256,
    sslVerify: true,
    publicClientKey: 'pub',
    privateClientKey: 'priv',
  );
  final testTokens = [createTestToken('Token A'), createTestToken('Token B')];
  group('InitialTokenAssignmentDialog - Suite', () {
    testWidgets('Displays correct content and sync URL', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        TestsAppWrapper(
          child: InitialTokenAssignmentDialog(
            container: testContainer,
            tokens: testTokens,
          ),
        ),
      );
      await tester.pump();
      final context = tester.element(find.byType(InitialTokenAssignmentDialog));
      final l10n = AppLocalizations.of(context)!;
      expect(find.text(l10n.initialTokenAssignmentDialogTitle), findsOneWidget);
      expect(find.textContaining('https://pi.netknights.it'), findsOneWidget);
      expect(find.byType(SelectTokensWidget), findsOneWidget);
      tester.view.resetPhysicalSize();
    });

    testWidgets('Selection logic updates internal state correctly', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        TestsAppWrapper(
          child: InitialTokenAssignmentDialog(
            container: testContainer,
            tokens: testTokens,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final selectWidget = tester.widget<SelectTokensWidget>(
        find.byType(SelectTokensWidget),
      );
      selectWidget.onSelect({testTokens[0]}, {testTokens[1]});
      await tester.pump();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(InitialTokenAssignmentDialog)),
      )!;
      expect(
        find.text(l10n.initialTokenAssignmentDialogButtonSelected),
        findsOneWidget,
      );
      tester.view.resetPhysicalSize();
    });

    testWidgets('Returns selected tokens on confirm', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      Iterable<Token>? result;
      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await InitialTokenAssignmentDialog.showDialog(
                  testContainer,
                  testTokens,
                );
              },
              child: const Text('Trigger'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();
      final selectWidget = tester.widget<SelectTokensWidget>(
        find.byType(SelectTokensWidget),
      );
      selectWidget.onSelect({testTokens[0]}, {testTokens[1]});
      await tester.pump();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(InitialTokenAssignmentDialog)),
      )!;
      await tester.tap(
        find.text(l10n.initialTokenAssignmentDialogButtonSelected),
      );
      await tester.pumpAndSettle();
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result!.first.label, 'Token A');
      tester.view.resetPhysicalSize();
    });

    testWidgets('Insecure connection triggers warning dialog before confirm', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      final insecureContainer = testContainer.copyWith(sslVerify: false);
      await tester.pumpWidget(
        TestsAppWrapper(
          child: InitialTokenAssignmentDialog(
            container: insecureContainer,
            tokens: testTokens,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final selectWidget = tester.widget<SelectTokensWidget>(
        find.byType(SelectTokensWidget),
      );
      selectWidget.onSelect({testTokens[0]}, {testTokens[1]});
      await tester.pump();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(InitialTokenAssignmentDialog)),
      )!;
      await tester.tap(
        find.text(l10n.initialTokenAssignmentDialogButtonSelected),
      );
      await tester.pump();
      expect(find.byType(SendOTPsWithoutSSLDialog), findsOneWidget);
      tester.view.resetPhysicalSize();
    });
  });
}
