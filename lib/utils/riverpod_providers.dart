import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/app_customizer.dart';
import 'package:privacyidea_authenticator/state_notifiers/deeplink_notifier.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';

import '../model/mixins/sortable_mixin.dart';
import '../model/platform_info/platform_info.dart';
import '../model/platform_info/platform_info_imp/dummy_platform_info.dart';
import '../model/push_request.dart';
import '../model/states/app_state.dart';
import '../model/states/settings_state.dart';
import '../model/states/token_folder_state.dart';
import '../model/states/token_state.dart';
import '../repo/preference_settings_repository.dart';
import '../repo/preference_token_folder_repository.dart';
import '../state_notifiers/app_state_notifier.dart';
import '../state_notifiers/push_request_notifier.dart';
import '../state_notifiers/settings_notifier.dart';
import '../state_notifiers/token_folder_notifier.dart';
import '../state_notifiers/token_notifier.dart';
import 'logger.dart';

// Never use globalRef to .watch() a provider. only use it to .read() a provider
// Otherwise the whole app will rebuild on every state change of the provider
WidgetRef? globalRef;

final tokenProvider = StateNotifierProvider.autoDispose<TokenNotifier, TokenState>((ref) {
  final tokenNotifier = TokenNotifier();

  deeplinkProvider.addListener(
    ref.container,
    (previous, next) {
      if (next == null) return;
      Logger.info("tokenProvider received new deeplink");
      tokenNotifier.handleLink(next);
    },
    onError: (err, _) => throw err,
    onDependencyMayHaveChanged: () {},
    fireImmediately: false,
  );

  appStateProvider.addListener(
    ref.container,
    (previous, next) {
      if (previous == AppState.pause && next == AppState.resume) {
        Logger.info('Refreshing tokens on resume');
        tokenNotifier.refreshRolledOutPushTokens();
      }
    },
    onError: (err, stack) {
      throw err;
    },
    onDependencyMayHaveChanged: () {},
    fireImmediately: true,
  );

  pushRequestProvider.addListener(
    ref.container,
    (previous, next) {
      if (next == null) return;
      if (next.accepted == null) {
        Logger.info("tokenProvider received new pushRequest");
        tokenNotifier.addPushRequestToToken(next);
        return;
      }
      if (next.accepted != null) {
        Logger.info("tokenProvider received pushRequest with accepted=${next.accepted}... removing it from state.");
        tokenNotifier.removePushRequest(next);
        FlutterLocalNotificationsPlugin().cancelAll();
        return;
      }
    },
    onError: (err, stack) {
      throw err;
    },
    onDependencyMayHaveChanged: () {},
    fireImmediately: true,
  );
  return tokenNotifier;
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(
    repository: PreferenceSettingsRepository(),
    initialState: SettingsState(),
  ),
);

final platformInfoProvider = StateProvider<PlatformInfo>(
  (ref) => DummyPlatformInfo(),
);

final pushRequestProvider = StateNotifierProvider<PushRequestNotifier, PushRequest?>(
  (ref) {
    final pushProvider = PushProvider(pollingEnabled: ref.watch(settingsProvider).enablePolling);
    final pushRequestNotifier = PushRequestNotifier(
      pushProvider: pushProvider,
    );
    appStateProvider.addListener(
      ref.container,
      (previous, next) {
        if (previous == AppState.pause && next == AppState.resume) {
          Logger.info('Polling for challenges on resume');
          pushProvider.pollForChallenges();
        }
      },
      onError: (_, __) {},
      onDependencyMayHaveChanged: () {},
      fireImmediately: false,
    );
    return pushRequestNotifier;
  },
);

final deeplinkProvider = StateNotifierProvider<DeeplinkNotifier, Uri?>((ref) => DeeplinkNotifier());

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

final tokenFolderProvider = StateNotifierProvider.autoDispose<TokenFolderNotifier, TokenFolderState>(
  (ref) => TokenFolderNotifier(
    repository: PreferenceTokenFolderRepository(),
  ),
);

final draggingSortableProvider = StateProvider<SortableMixin?>((ref) => null);

final applicationCustomizerProvider = StateProvider<ApplicationCustomizer>((ref) => ApplicationCustomizer());
