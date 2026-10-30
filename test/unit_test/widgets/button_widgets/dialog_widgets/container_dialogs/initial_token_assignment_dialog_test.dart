import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/initial_token_assignment_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/send_otps_without_ssl_dialog.dart';
import 'package:privacyidea_authenticator/widgets/select_tokens_widget.dart';

import '../../../../../tests_app_wrapper.dart';

class RecordingTokenNotifier extends TokenNotifier {
  final List<Token> updatedTokens = [];

  @override
  Future<TokenState> build({
    required TokenRepository repo,
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required FirebaseUtils firebaseUtils,
  }) async => const TokenState(tokens: []);

  @override
  Future<List<T>> updateTokens<T extends Token>(
    List<T> tokens,
    T Function(T) updater,
  ) async {
    final updated = tokens.map(updater).toList();
    updatedTokens.addAll(updated);
    return updated;
  }
}

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
  setUpAll(() => Logger.instance);

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

    Future<void> openDialog(
      WidgetTester tester,
      RecordingTokenNotifier tokenNotifier,
      void Function(Iterable<Token>? result) onClosed,
    ) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [tokenProvider.overrideWith(() => tokenNotifier)],
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async => onClosed(
                await InitialTokenAssignmentDialog.showDialog(
                  testContainer,
                  testTokens,
                ),
              ),
              child: const Text('Trigger'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Sending no OTPs without touching the list marks every token as checked',
      (tester) async {
        final tokenNotifier = RecordingTokenNotifier();
        Iterable<Token>? result;
        await openDialog(tester, tokenNotifier, (r) => result = r);
        final l10n = AppLocalizations.of(
          tester.element(find.byType(InitialTokenAssignmentDialog)),
        )!;
        await tester.tap(
          find.text(l10n.initialTokenAssignmentDialogButtonZero),
        );
        await tester.pumpAndSettle();
        expect(result, isEmpty);
        expect(
          {
            for (final t in tokenNotifier.updatedTokens)
              t.id: t.checkedContainer,
          },
          {
            'id_Token A': ['CON_01'],
            'id_Token B': ['CON_01'],
          },
        );
      },
    );

    testWidgets(
      'Sending the selected OTPs marks only the other tokens as checked',
      (tester) async {
        final tokenNotifier = RecordingTokenNotifier();
        Iterable<Token>? result;
        await openDialog(tester, tokenNotifier, (r) => result = r);
        await tester.tap(find.text('Token A'));
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
          tester.element(find.byType(InitialTokenAssignmentDialog)),
        )!;
        await tester.tap(
          find.text(l10n.initialTokenAssignmentDialogButtonSelected),
        );
        await tester.pumpAndSettle();
        expect(result?.map((t) => t.id), ['id_Token A']);
        expect(
          {
            for (final t in tokenNotifier.updatedTokens)
              t.id: t.checkedContainer,
          },
          {
            'id_Token B': ['CON_01'],
          },
        );
      },
    );
  });
}
