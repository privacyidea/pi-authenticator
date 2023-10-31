import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/mixins/sortable_mixin.dart';
import '../model/push_request.dart';
import '../model/states/app_state.dart';
import '../model/states/settings_state.dart';
import '../model/states/token_folder_state.dart';
import '../model/states/token_state.dart';
import '../repo/preference_settings_repository.dart';
import '../repo/preference_token_folder_repository.dart';
import '../state_notifiers/app_state_notifier.dart';
import '../state_notifiers/deeplink_notifier.dart';
import '../state_notifiers/push_request_notifier.dart';
import '../state_notifiers/settings_notifier.dart';
import '../state_notifiers/token_folder_notifier.dart';
import '../state_notifiers/token_notifier.dart';
import 'app_customizer.dart';
import 'logger.dart';
import 'push_provider.dart';

// Never use globalRef to .watch() a provider. only use it to .read() a provider
// Otherwise the whole app will rebuild on every state change of the provider
WidgetRef? globalRef;

final tokenProvider = StateNotifierProvider<TokenNotifier, TokenState>((ref) {
  Logger.info("New TokenNotifier created");
  final tokenNotifier = TokenNotifier();

  ref.listen(deeplinkProvider, (previous, newLink) {
    if (newLink == null) {
      Logger.info("tokenProvider received null deeplink");
      return;
    }
    Logger.info("tokenProvider received new deeplink");
    tokenNotifier.handleLink(newLink);
  });

  ref.listen(pushRequestProvider, (previous, newPushRequest) {
    if (newPushRequest == null) {
      Logger.info("tokenProvider received null pushRequest");
      return;
    }
    if (newPushRequest.accepted == null) {
      Logger.info("tokenProvider received new pushRequest");
      tokenNotifier.addPushRequestToToken(newPushRequest);
    }
    if (newPushRequest.accepted != null) {
      Logger.info("tokenProvider received pushRequest with accepted=${newPushRequest.accepted}... removing it from state.");
      tokenNotifier.removePushRequest(newPushRequest);
      FlutterLocalNotificationsPlugin().cancelAll();
    }
  });

  ref.listen(
    appStateProvider,
    (previous, next) {
      Logger.info('tokenProvider reviced new AppState. Changed from $previous to $next');
      if (previous == AppState.pause && next == AppState.resume) {
        Logger.info('Refreshing tokens on resume');
        tokenNotifier.refreshRolledOutPushTokens();
      }
    },
  );
  return tokenNotifier;
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    // Using Logger here will cause a circular dependency because Logger uses settingsProvider (logging verbosity)
    return SettingsNotifier(repository: PreferenceSettingsRepository());
  },
);

final pushRequestProvider = StateNotifierProvider<PushRequestNotifier, PushRequest?>(
  (ref) {
    Logger.info("New PushRequestNotifier created");
    ref.listen(settingsProvider, (previous, next) {
      if (previous?.enablePolling != next.enablePolling) {
        Logger.info("Polling enabled changed from ${previous?.enablePolling} to ${next.enablePolling}");
        PushProvider.instance?.setPollingEnabled(next.enablePolling);
      }
    });

    final pushProvider = PushProvider(pollingEnabled: false);
    final pushRequestNotifier = PushRequestNotifier(
      pushProvider: pushProvider,
    );

    ref.listen(appStateProvider, (previous, next) {
      if (previous == AppState.pause && next == AppState.resume) {
        Logger.info('Polling for challenges on resume');
        pushProvider.pollForChallenges();
      }
    });

    return pushRequestNotifier;
  },
);

final deeplinkProvider = StateNotifierProvider<DeeplinkNotifier, Uri?>((ref) {
  Logger.info("New DeeplinkNotifier created");
  return DeeplinkNotifier();
});

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) {
    Logger.info("New AppStateNotifier created");
    return AppStateNotifier();
  },
);

final tokenFolderProvider = StateNotifierProvider.autoDispose<TokenFolderNotifier, TokenFolderState>(
  (ref) {
    Logger.info("New TokenFolderNotifier created");
    return TokenFolderNotifier(
      repository: PreferenceTokenFolderRepository(),
    );
  },
);

final draggingSortableProvider = StateProvider<SortableMixin?>((ref) {
  Logger.info("New draggingSortableProvider created");
  return null;
});

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  Logger.info("New connectivityProvider created");
  return Connectivity().onConnectivityChanged;
});

final statusMessageProvider = StateProvider<(String, String?)?>((ref) {
  Logger.info("New connectionStateProvider created");
  final next = ref.watch(connectivityProvider).asData?.value;
  if (next == null || next == ConnectivityResult.none) {
    log("ConnectionState is $next");
    return ('No Connection', null);
  }
  log("ConnectionState is $next");
  return null;
});

/// Only used for the app customizer
final applicationCustomizerProvider = StateProvider<ApplicationCustomization>((ref) => ApplicationCustomization.defaultCustomization);
