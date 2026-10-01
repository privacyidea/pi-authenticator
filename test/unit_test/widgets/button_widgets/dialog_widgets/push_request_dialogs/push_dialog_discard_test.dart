import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/interfaces/repo/push_request_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result_detail.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result_value.dart';
import 'package:privacyidea_authenticator/model/pi_server_response.dart';
import 'package:privacyidea_authenticator/model/push_request/push_code_to_phone_request.dart';
import 'package:privacyidea_authenticator/model/push_request/push_default_request.dart';
import 'package:privacyidea_authenticator/model/push_request/push_request.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/push_request_dialog.dart';

import '../../../../../tests_app_wrapper.mocks.dart';

/// Hand-written fake: records calls, never talks to a server.
class _FakeNotifier extends PushRequestNotifier {
  final removed = <PushRequest>[];
  final cancelled = <PushRequest>[];
  int declineCalls = 0;
  int acceptCalls = 0;
  PiSuccessResponse<PiServerResultValue, PiServerResultDetail>? cancelResponse;

  @override
  Future<PushRequestState> build({
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required PushProvider pushProvider,
    required PushRequestRepository pushRepo,
  }) async => PushRequestState.empty();

  @override
  Future<bool> remove(PushRequest pushRequest) async {
    removed.add(pushRequest);
    return true;
  }

  @override
  Future<PiSuccessResponse<T, D>?> cancel<
    T extends PiServerResultValue,
    D extends PiServerResultDetail
  >(PushToken token, PushRequest request) async {
    cancelled.add(request);
    return cancelResponse as PiSuccessResponse<T, D>?;
  }

  @override
  Future<PiSuccessResponse<T, D>?> decline<
    T extends PiServerResultValue,
    D extends PiServerResultDetail
  >(PushToken token, PushRequest request) async {
    declineCalls++;
    return null;
  }

  @override
  Future<PiSuccessResponse<T, D>?> accept<
    T extends PiServerResultValue,
    D extends PiServerResultDetail
  >(PushToken token, PushRequest request, {String? selectedAnswer}) async {
    acceptCalls++;
    return null;
  }
}

/// Minimal host exposing [PushDialogMixin.handleDiscard] via a button.
class _DiscardHost extends ConsumerWidget with PushDialogMixin {
  @override
  final PushDefaultRequest pushRequest;
  @override
  final PushToken token;

  const _DiscardHost({required this.pushRequest, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: TextButton(
      onPressed: () => handleDiscard(context, ref),
      child: const Text('discard'),
    ),
  );
}

void main() {
  late PushDefaultRequest defaultRequest;
  late PushCodeToPhoneRequest codeRequest;
  late PushToken token;
  late _FakeNotifier notifier;
  late MockLocalAuthentication localAuth;

  setUp(() {
    defaultRequest = PushDefaultRequest(
      title: 't',
      question: 'q',
      nonce: 'n',
      serial: 's',
      signature: 'sig',
      expirationDate: DateTime(2099),
      uri: Uri.parse('https://example.com'),
      sslVerify: true,
    );
    codeRequest = PushCodeToPhoneRequest(
      title: 't',
      serial: 's',
      question: 'q',
      nonce: 'n',
      signature: 'sig',
      uri: Uri.parse('https://example.com'),
      sslVerify: true,
      displayCode: '123 456',
      expirationDate: DateTime(2099),
    );
    token = PushToken(serial: 's', id: 'id');
    notifier = _FakeNotifier();
    localAuth = MockLocalAuthentication();
    localAuthInstance = localAuth;
    resetAuthMutex();
  });

  tearDown(() {
    localAuthInstance = LocalAuthentication();
    resetAuthMutex();
  });

  void verifyNoAuthPrompt() {
    verifyNever(localAuth.isDeviceSupported());
    verifyNever(
      localAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        biometricOnly: anyNamed('biometricOnly'),
        authMessages: anyNamed('authMessages'),
      ),
    );
  }

  /// Pumps a home page whose button pushes [dialog] as a new route.
  Future<void> openDialog(WidgetTester tester, Widget dialog) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pushRequestProvider.overrideWith(() => notifier)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => Scaffold(body: dialog)),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('handleDone (PushCodeToPhoneDialog)', () {
    testWidgets('Done only removes locally, never cancels or declines', (
      tester,
    ) async {
      await openDialog(
        tester,
        PushCodeToPhoneDialog(pushRequest: codeRequest, token: token),
      );
      expect(find.byType(PushCodeToPhoneDialog), findsOneWidget);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(PushCodeToPhoneDialog)),
      )!;

      await tester.tap(find.text(l10n.done));
      await tester.pumpAndSettle();

      expect(notifier.removed, [codeRequest]);
      expect(notifier.cancelled, isEmpty);
      expect(notifier.declineCalls, 0);
      expect(notifier.acceptCalls, 0);
      verifyNoAuthPrompt();
      expect(find.byType(PushCodeToPhoneDialog), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });

  group('handleDiscard', () {
    testWidgets('cancel returns null (offline): also removes locally', (
      tester,
    ) async {
      notifier.cancelResponse = null;
      await openDialog(
        tester,
        _DiscardHost(pushRequest: defaultRequest, token: token),
      );

      await tester.tap(find.text('discard'));
      await tester.pumpAndSettle();

      expect(notifier.cancelled, [defaultRequest]);
      expect(notifier.removed, [defaultRequest]);
      verifyNoAuthPrompt();
      expect(find.text('discard'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('cancel succeeds: dialog does not call remove additionally', (
      tester,
    ) async {
      notifier.cancelResponse =
          PiSuccessResponse<PiServerResultValue, PiServerResultDetail>(
            statusCode: 200,
            result: const PiServerResult(
              status: true,
              value: PushResultValue(true),
            ),
          );
      await openDialog(
        tester,
        _DiscardHost(pushRequest: defaultRequest, token: token),
      );

      await tester.tap(find.text('discard'));
      await tester.pumpAndSettle();

      expect(notifier.cancelled, [defaultRequest]);
      expect(notifier.removed, isEmpty);
      verifyNoAuthPrompt();
      expect(find.text('discard'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });
}
