import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/api/interfaces/container_api.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_container_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/model/enums/sync_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/has_firebase_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/views/container_view/container_widgets/buttons/sync_container_button.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';

import '../../../../../tests_app_wrapper.dart';
import '../../../../../tests_app_wrapper.mocks.dart';

class FakeTokenNotifier extends TokenNotifier {
  @override
  Future<TokenState> build({
    required FirebaseUtils firebaseUtils,
    required PrivacyideaIOClient ioClient,
    required TokenRepository repo,
    required RsaUtils rsaUtils,
  }) async => TokenState(tokens: []);
}

class FakeTokenContainerNotifier extends TokenContainerNotifier {
  final MockTokenContainerNotifier mock;
  FakeTokenContainerNotifier(this.mock);

  @override
  Future<TokenContainerState> build({
    required TokenContainerApi containerApi,
    required EccUtils eccUtils,
    required TokenContainerRepository repo,
  }) async => TokenContainerState(containerList: []);

  @override
  Future<Map<int, TokenContainerFinalized>> syncContainers({
    List<TokenContainerFinalized>? containersToSync,
    bool? isInitSync,
    required bool isManually,
    required TokenState tokenState,
  }) => mock.syncContainers(
    containersToSync: containersToSync,
    isInitSync: isInitSync,
    isManually: isManually,
    tokenState: tokenState,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTokenContainerFinalized mockContainer;
  late MockTokenContainerNotifier mockInternalNotifier;

  setUp(() {
    mockContainer = MockTokenContainerFinalized();
    mockInternalNotifier = MockTokenContainerNotifier();
  });

  Future<void> pumpButton(
    WidgetTester tester, {
    required SyncState state,
    bool isPreview = false,
  }) async {
    when(mockContainer.syncState).thenReturn(state);

    await tester.pumpWidget(
      TestsAppWrapper(
        overrides: [
          tokenProvider.overrideWith(() => FakeTokenNotifier()),
          tokenContainerProvider.overrideWith(
            () => FakeTokenContainerNotifier(mockInternalNotifier),
          ),
          hasFirebaseProvider.overrideWith((ref) => Future.value(true)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: Center(
                child: SyncContainerButton(
                  isPreview: isPreview,
                  container: mockContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    debugPrint('Pump complete for state: $state, isPreview: $isPreview');

    debugPrint(tester.allWidgets.toString());

    debugPrint('Looking for IntentButton: ${find.byType(IntentButton)}');
    // Warte kurz auf das Layout
    await tester.pumpAndSettle();
  }

  group('SyncContainerButton - Logic and States', () {
    testWidgets('should only show Icon without button when isPreview is true', (
      tester,
    ) async {
      await pumpButton(tester, state: SyncState.notStarted, isPreview: true);

      await tester.pumpAndSettle();

      expect(find.byType(IntentButton), findsNothing);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('should be enabled when SyncState is notStarted', (
      tester,
    ) async {
      await pumpButton(tester, state: SyncState.notStarted);

      final button = tester.widget<IntentButton>(find.byType(IntentButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should be disabled when SyncState is syncing', (tester) async {
      await pumpButton(tester, state: SyncState.syncing);

      final button = tester.widget<IntentButton>(find.byType(IntentButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should be enabled when SyncState is failed', (tester) async {
      await pumpButton(tester, state: SyncState.failed);

      final button = tester.widget<IntentButton>(find.byType(IntentButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should call syncContainers when pressed', (tester) async {
      await pumpButton(tester, state: SyncState.notStarted);

      when(
        mockInternalNotifier.syncContainers(
          tokenState: anyNamed('tokenState'),
          containersToSync: anyNamed('containersToSync'),
          isManually: anyNamed('isManually'),
          isInitSync: anyNamed('isInitSync'),
        ),
      ).thenAnswer((_) async => <int, TokenContainerFinalized>{});

      await tester.tap(find.byType(IntentButton));
      await tester.pump();

      verify(
        mockInternalNotifier.syncContainers(
          tokenState: anyNamed('tokenState'),
          containersToSync: [mockContainer],
          isManually: true,
          isInitSync: anyNamed('isInitSync'),
        ),
      ).called(1);
    });
  });
}
