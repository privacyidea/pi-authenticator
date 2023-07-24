import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/platform_info/platform_info_imp/dummy_platform_info.dart';
import 'package:privacyidea_authenticator/model/platform_info/platform_info.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/states/app_state.dart';
import 'package:privacyidea_authenticator/state_notifiers/app_state_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/push_request_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/settings_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_notifier.dart';
import 'package:privacyidea_authenticator/model/states/settings_state.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logger.dart';

// Never use globalRef to .watch() a provider. only use it to .read() a provider
// Otherwise the whole app will rebuild on every state change of the provider
WidgetRef? globalRef;

final tokenProvider = StateNotifierProvider<TokenNotifier, List<Token>>((ref) {
  final tokenNotifier = TokenNotifier();

  appStateProvider.addListener(
    ref.container,
    (previous, next) {
      switch (next) {
        case AppState.resume:
          //startPolling();
          Logger.warning('resume');
          tokenNotifier.refreshTokens();
          ref.read(appStateProvider.notifier).setAppState(AppState.running);
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
      if (next.accepted == null) {
        tokenNotifier.addPushRequest(next);
        return;
      }
      if (next.accepted != null) {
        tokenNotifier.removePushRequest(next);
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

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  print('settingsProvider: ${ref.watch(sharedPreferencesProvider)}');
  return SettingsNotifier(ref.watch(sharedPreferencesProvider));
});

final sharedPreferencesProvider = StateProvider<SharedPreferences?>((ref) => null);

final platformInfoProvider = StateProvider<PlatformInfo>((ref) => DummyPlatformInfo());

final pushRequestProvider = StateNotifierProvider<PushRequestNotifier, PushRequest?>(
  (ref) => PushRequestNotifier(null, pollingEnabled: ref.watch(settingsProvider).pollingEnabled),
);

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) => AppStateNotifier());
