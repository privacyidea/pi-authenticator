import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/api/interfaces/container_api.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_container_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/widgets/app_wrapper.dart';

class _ResumeTokenNotifier extends TokenNotifier {
  final TokenState tokenState;

  _ResumeTokenNotifier(this.tokenState);

  @override
  Future<TokenState> build({
    required FirebaseUtils firebaseUtils,
    required PrivacyideaIOClient ioClient,
    required TokenRepository repo,
    required RsaUtils rsaUtils,
  }) async => tokenState;

  @override
  Future<TokenState?> loadStateFromRepo() async => tokenState;
}

class _ResumeTokenContainerNotifier extends TokenContainerNotifier {
  var syncCallCount = 0;
  TokenState? syncedTokenState;
  bool? syncedManually;

  @override
  Future<TokenContainerState> build({
    required TokenContainerApi containerApi,
    required EccUtils eccUtils,
    required TokenContainerRepository repo,
  }) async => const TokenContainerState(containerList: []);

  @override
  Future<Map<int, TokenContainerFinalized>> syncContainers({
    required TokenState tokenState,
    required bool isManually,
    List<TokenContainerFinalized>? containersToSync,
    bool? isInitSync,
  }) async {
    syncCallCount++;
    syncedTokenState = tokenState;
    syncedManually = isManually;
    return {};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('synchronizes containers when the app resumes', (tester) async {
    const tokenState = TokenState(tokens: []);
    final containerNotifier = _ResumeTokenContainerNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenProvider.overrideWith(() => _ResumeTokenNotifier(tokenState)),
          tokenContainerProvider.overrideWith(() => containerNotifier),
        ],
        child: const AppWrapper(child: MaterialApp(home: SizedBox.shrink())),
      ),
    );
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(containerNotifier.syncCallCount, 1);
    expect(containerNotifier.syncedTokenState, same(tokenState));
    expect(containerNotifier.syncedManually, isFalse);
  });
}
