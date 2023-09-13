import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final tokenProvider = StateNotifierProvider<TokenNotifier, TokenState>((ref) {
  final tokenNotifier = TokenNotifier();

  Logger.info("appStateProvider.addListener ${tokenNotifier.hashCode.toString()}");
  appStateProvider.addListener(
    ref.container,
    (previous, next) {
      switch (next) {
        case AppState.resume:
          //startPolling();
          if (previous == AppState.pause) {
            Logger.info('refreshing tokens on resume');
            tokenNotifier.refreshTokens();
            ref.read(appStateProvider.notifier).setAppState(AppState.running);
          }
          break;
        case AppState.pause:
          //stopPolling();
          break;
        default:
          break;
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
      Logger.warning('next: $next');
      if (next.accepted == null) {
        tokenNotifier.addPushRequestToToken(next);
        return;
      }
      if (next.accepted != null) {
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

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier(
      repository: PreferenceSettingsRepository(),
      initialState: SettingsState(),
    ));

final platformInfoProvider = StateProvider<PlatformInfo>(
  (ref) => DummyPlatformInfo(),
);

final pushRequestProvider = StateNotifierProvider<PushRequestNotifier, PushRequest?>(
  (ref) {
    final pushRequestNotifier = PushRequestNotifier(null, pollingEnabled: ref.watch(settingsProvider).enablePolling);
    appStateProvider.addListener(
      ref.container,
      (previous, next) {
        if (previous == AppState.pause && next == AppState.resume) {
          PushProvider.pollForChallenges();
        }
      },
      onError: (_, __) {},
      onDependencyMayHaveChanged: () {},
      fireImmediately: false,
    );
    return pushRequestNotifier;
  },
);

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

final tokenFolderProvider =
    StateNotifierProvider<TokenFolderNotifier, TokenFolderState>((ref) => TokenFolderNotifier(repositoy: PreferenceTokenFolderRepotisory()));

final draggingSortableProvider = StateProvider<SortableMixin?>((ref) => null);
