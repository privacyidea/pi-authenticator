import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/api/interfaces/container_api.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_container_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
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
  });
}
