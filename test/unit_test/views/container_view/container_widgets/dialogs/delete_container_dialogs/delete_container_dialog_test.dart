import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/api/interfaces/container_api.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_container_repository.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/views/container_view/container_widgets/dialogs/delete_container_dialogs.dart/delete_container_dialog.dart';

import '../../../../../../tests_app_wrapper.dart';
import '../../../../../../tests_app_wrapper.mocks.dart';

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
  late MockTokenContainerNotifier mockContainerInternal;

  setUp(() {
    mockFinalizedContainer = MockTokenContainerFinalized();
    mockContainerInternal = MockTokenContainerNotifier();

    when(mockFinalizedContainer.serial).thenReturn('finalized-serial');
  });

  Future<void> pumpDialog(WidgetTester tester, TokenContainer container) async {
    await tester.pumpWidget(
      TestsAppWrapper(
        overrides: [
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
    testWidgets('should unregister without asking what to do with tokens', (
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
      expect(find.text('Only container'), findsNothing);
      expect(find.text('Delete all'), findsNothing);
    });
  });
}
