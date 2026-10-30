import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/api/interfaces/container_api.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_container_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/views/container_view/container_widgets/dialogs/delete_container_dialogs.dart/delete_container_dialog.dart';

import '../../../../../../tests_app_wrapper.dart';
import '../../../../../../tests_app_wrapper.mocks.dart';

class FakeTokenNotifier extends TokenNotifier {
  final MockTokenNotifier mock;
  FakeTokenNotifier(this.mock);

  @override
  Future<TokenState> build({
    required FirebaseUtils firebaseUtils,
    required PrivacyideaIOClient ioClient,
    required TokenRepository repo,
    required RsaUtils rsaUtils,
  }) async => const TokenState(tokens: []);

  /// What a container sync does while another call is still running.
  void addFromSync(Token token) => state = AsyncValue.data(
    TokenState(tokens: [...?state.value?.tokens, token]),
  );

  @override
  Future<void> removeTokens(List<Token> tokens) => mock.removeTokens(tokens);

  @override
  Future<List<T>> updateTokens<T extends Token>(
    List<T> tokens,
    T Function(T) update,
  ) => mock.updateTokens(tokens, update);
}

class FakeTokenContainerNotifier extends TokenContainerNotifier {
  final MockTokenContainerNotifier mock;
  FakeTokenContainerNotifier(this.mock);

  @override
  Future<TokenContainerState> build({
    required TokenContainerApi containerApi,
    required EccUtils eccUtils,
    required TokenContainerRepository repo,
  }) async => const TokenContainerState(containerList: []);

  @override
  Future<bool> unregisterDelete(TokenContainerFinalized container) =>
      mock.unregisterDelete(container);

  @override
  Future<bool> deleteContainer(TokenContainer container) =>
      mock.deleteContainer(container);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTokenContainerFinalized mockFinalizedContainer;
  late MockTokenNotifier mockTokenInternal;
  late MockTokenContainerNotifier mockContainerInternal;

  setUp(() {
    mockFinalizedContainer = MockTokenContainerFinalized();
    mockTokenInternal = MockTokenNotifier();
    mockContainerInternal = MockTokenContainerNotifier();

    when(mockFinalizedContainer.serial).thenReturn('finalized-serial');

    when(mockTokenInternal.updateTokens<Token>(any, any)).thenAnswer((
      invocation,
    ) async {
      return invocation.positionalArguments[0] as List<Token>;
    });
  });

  Future<void> pumpDialog(WidgetTester tester, TokenContainer container) async {
    await tester.pumpWidget(
      TestsAppWrapper(
        overrides: [
          tokenProvider.overrideWith(
            () => FakeTokenNotifier(mockTokenInternal),
          ),
          tokenContainerProvider.overrideWith(
            () => FakeTokenContainerNotifier(mockContainerInternal),
          ),
        ],
        child: DeleteContainerDialog(container),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('DeleteContainerDialog - UI Tests', () {
    testWidgets('should show serial in title', (tester) async {
      await pumpDialog(tester, mockFinalizedContainer);
      expect(find.textContaining('finalized-serial'), findsOneWidget);
    });

    testWidgets('should have cancel and delete buttons', (tester) async {
      await pumpDialog(tester, mockFinalizedContainer);

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });

  group('DeleteContainerDialog - Logic Tests', () {
    testWidgets('should call unregisterDelete and update tokens', (
      tester,
    ) async {
      await pumpDialog(tester, mockFinalizedContainer);

      when(
        mockContainerInternal.unregisterDelete(any),
      ).thenAnswer((_) async => true);

      final deleteButton = find.text('Delete');
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      verify(
        mockContainerInternal.unregisterDelete(mockFinalizedContainer),
      ).called(1);
      verify(mockTokenInternal.updateTokens<Token>(any, any)).called(1);
    });

    testWidgets(
      'keeping the tokens lists the container serial in checkedContainer once',
      (tester) async {
        await pumpDialog(tester, mockFinalizedContainer);
        when(
          mockContainerInternal.unregisterDelete(any),
        ).thenAnswer((_) async => true);

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        final update =
            verify(
                  mockTokenInternal.updateTokens<Token>(any, captureAny),
                ).captured.single
                as Token Function(Token);
        final assignedAtSync = HOTPToken(
          id: 'assigned-at-sync',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'GEZDGNBVGY3TQOJQ',
          containerSerial: 'finalized-serial',
          checkedContainer: ['finalized-serial'],
        );
        final neverChecked = assignedAtSync.copyWith(
          id: 'never-checked',
          checkedContainer: [],
        );

        final updatedAssigned = update(assignedAtSync);
        expect(updatedAssigned.checkedContainer, ['finalized-serial']);
        expect(updatedAssigned.containerSerial, isNull);
        expect(update(neverChecked).checkedContainer, ['finalized-serial']);
      },
    );

    testWidgets(
      'a dialog closed during the server call still unlinks the tokens',
      (tester) async {
        final unregister = Completer<bool>();
        when(
          mockContainerInternal.unregisterDelete(any),
        ).thenAnswer((_) => unregister.future);
        final dialogShown = ValueNotifier(true);
        await tester.pumpWidget(
          TestsAppWrapper(
            overrides: [
              tokenProvider.overrideWith(
                () => FakeTokenNotifier(mockTokenInternal),
              ),
              tokenContainerProvider.overrideWith(
                () => FakeTokenContainerNotifier(mockContainerInternal),
              ),
            ],
            child: ValueListenableBuilder<bool>(
              valueListenable: dialogShown,
              builder: (_, shown, _) => shown
                  ? DeleteContainerDialog(mockFinalizedContainer)
                  : const SizedBox(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pump();
        // A tap outside closes the dialog while the server answers.
        dialogShown.value = false;
        await tester.pump();
        unregister.complete(true);
        await tester.pumpAndSettle();

        verify(mockTokenInternal.updateTokens<Token>(any, any)).called(1);
      },
    );

    testWidgets('unlinks a token that a sync adds during the server call', (
      tester,
    ) async {
      final unregister = Completer<bool>();
      when(
        mockContainerInternal.unregisterDelete(any),
      ).thenAnswer((_) => unregister.future);
      final tokenNotifier = FakeTokenNotifier(mockTokenInternal);
      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            tokenProvider.overrideWith(() => tokenNotifier),
            tokenContainerProvider.overrideWith(
              () => FakeTokenContainerNotifier(mockContainerInternal),
            ),
          ],
          child: DeleteContainerDialog(mockFinalizedContainer),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pump();
      tokenNotifier.addFromSync(
        HOTPToken(
          id: 'added-by-sync',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'GEZDGNBVGY3TQOJQ',
          containerSerial: 'finalized-serial',
          origin: TokenOriginSourceType.container.toTokenOrigin(
            isPrivacyIdeaToken: true,
          ),
        ),
      );
      unregister.complete(true);
      await tester.pumpAndSettle();

      final unlinked =
          verify(
                mockTokenInternal.updateTokens<Token>(captureAny, any),
              ).captured.single
              as List<Token>;
      expect(unlinked.map((t) => t.id), ['added-by-sync']);
    });
  });
}
