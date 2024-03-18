import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_links/uni_links.dart';

import '../l10n/app_localizations.dart';
import '../model/mixins/sortable_mixin.dart';
import '../model/states/introduction_state.dart';
import '../model/states/push_request_state.dart';
import '../model/states/settings_state.dart';
import '../model/states/token_filter.dart';
import '../model/states/token_folder_state.dart';
import '../model/states/token_state.dart';
import '../model/tokens/otp_token.dart';
import '../repo/preference_introduction_repository.dart';
import '../repo/preference_settings_repository.dart';
import '../repo/preference_token_folder_repository.dart';
import '../state_notifiers/completed_introduction_notifier.dart';
import '../state_notifiers/deeplink_notifier.dart';
import '../state_notifiers/push_request_notifier.dart';
import '../state_notifiers/settings_notifier.dart';
import '../state_notifiers/token_folder_notifier.dart';
import '../state_notifiers/token_notifier.dart';
import 'app_customizer.dart';
import 'firebase_utils.dart';
import 'globals.dart';
import 'home_widget_utils.dart';
import 'logger.dart';
import 'push_provider.dart';
import 'riverpod_state_listener.dart';

// Never use globalRef to .watch() a provider. only use it to .read() a provider
// Otherwise the whole app will rebuild on every state change of the provider
WidgetRef? globalRef;

final tokenProvider = StateNotifierProvider<TokenNotifier, TokenState>(
  (ref) {
    Logger.info("New TokenNotifier created");
    final newTokenNotifier = TokenNotifier();

    ref.listen(deeplinkProvider, (previous, newLink) {
      if (newLink == null) {
        Logger.info("Received null deeplink", name: 'tokenProvider#deeplinkProvider');
        return;
      }
      Logger.info("Received new deeplink", name: 'tokenProvider#deeplinkProvider');
      newTokenNotifier.handleLink(newLink.uri);
    });

    ref.listen(
      appStateProvider,
      (previous, next) {
        Logger.info('tokenProvider reviced new AppState. Changed from $previous to $next');
        if (previous == AppLifecycleState.paused && next == AppLifecycleState.resumed) {
          Logger.info('Refreshing tokens on resume', name: 'tokenProvider#appStateProvider');
          newTokenNotifier.loadStateFromRepo();
        }
        if (previous == AppLifecycleState.resumed && next == AppLifecycleState.paused) {
          Logger.info('Saving tokens and cancelling all notifications on pause', name: 'tokenProvider#appStateProvider');
          FlutterLocalNotificationsPlugin().cancelAll();
          newTokenNotifier.saveStateOnMinimizeApp();
        }
      },
    );
    return newTokenNotifier;
  },
  name: 'tokenProvider',
);

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    // Using Logger here will cause a circular dependency because Logger uses settingsProvider (logging verbosity)
    return SettingsNotifier(repository: PreferenceSettingsRepository());
  },
  name: 'settingsProvider',
);

final pushRequestProvider = StateNotifierProvider<PushRequestNotifier, PushRequestState>(
  (ref) {
    Logger.info("New PushRequestNotifier created", name: 'pushRequestProvider');
    final tokenState = ref.read(tokenProvider);
    PushProvider pushProvider = tokenState.hasPushTokens ? PushProvider() : PlaceholderPushProvider(); // Until the state is loaded from the repo
    final pushRequestNotifier = PushRequestNotifier(
      pushProvider: pushProvider,
    );

    ref.listen(tokenProvider, (previous, next) {
      if (previous?.hasPushTokens == true && next.hasPushTokens == false) {
        /// Last push token was deleted
        Logger.info('Last push token was deleted. Deactivating push provider and deleting firebase token.', name: 'pushRequestProvider#tokenProvider');
        pushRequestNotifier.swapPushProvider(PlaceholderPushProvider());
        FirebaseUtils().deleteFirebaseToken();
      }
      Logger.info('Activating push provider: ${previous?.hasPushTokens != true} -> ${next.hasPushTokens == true}', name: 'pushRequestProvider#tokenProvider');
      if (previous?.hasPushTokens != true && next.hasPushTokens == true) {
        /// First push token was added
        Logger.info('First push token was added. Activating push provider.', name: 'pushRequestProvider#tokenProvider');
        pushRequestNotifier.swapPushProvider(PushProvider());
      }
    });

    ref.listen(settingsProvider, (previous, next) {
      if (previous?.enablePolling != next.enablePolling) {
        Logger.info("Polling enabled changed from ${previous?.enablePolling} to ${next.enablePolling}", name: 'pushRequestProvider#settingsProvider');
        pushRequestNotifier.pushProvider.setPollingEnabled(next.enablePolling);
      }
    });

    ref.listen(appStateProvider, (previous, next) {
      if (previous == AppLifecycleState.paused && next == AppLifecycleState.resumed) {
        Logger.info('Polling for challenges on resume', name: 'pushRequestProvider#appStateProvider');
        pushRequestNotifier.loadStateFromRepo();
        pushProvider.pollForChallenges(isManually: false);
      }
    });

    return pushRequestNotifier;
  },
  name: 'pushRequestProvider',
);

final deeplinkProvider = StateNotifierProvider<DeeplinkNotifier, DeepLink?>(
  (ref) {
    Logger.info("New DeeplinkNotifier created", name: 'deeplinkProvider');
    return DeeplinkNotifier(sources: [
      DeeplinkSource(name: 'uni_links', stream: uriLinkStream, initialUri: getInitialUri()),
      DeeplinkSource(
        name: 'home_widget',
        stream: HomeWidgetUtils().widgetClicked,
        initialUri: HomeWidgetUtils().initiallyLaunchedFromHomeWidget(),
      ),
    ]);
  },
  name: 'deeplinkProvider',
);

final appStateProvider = StateProvider<AppLifecycleState?>(
  (ref) {
    Logger.info("New AppStateNotifier created", name: 'appStateProvider');
    return null;
  },
  name: 'appStateProvider',
);

final tokenFolderProvider = StateNotifierProvider<TokenFolderNotifier, TokenFolderState>(
  (ref) {
    Logger.info("New TokenFolderNotifier created", name: 'tokenFolderProvider');
    final newTokenFolderNotifier = TokenFolderNotifier(repository: PreferenceTokenFolderRepository());
    ref.listen(appStateProvider, (previous, next) {
      if (previous == AppLifecycleState.resumed && next == AppLifecycleState.paused) {
        Logger.info('Collapsing locked folders on pause', name: 'tokenFolderProvider#appStateProvider');
        newTokenFolderNotifier.collapseLockedFolders();
      }
    });
    return newTokenFolderNotifier;
  },
  name: 'tokenFolderProvider',
);

final draggingSortableProvider = StateProvider<SortableMixin?>(
  (ref) {
    Logger.info("New draggingSortableProvider created", name: 'draggingSortableProvider');
    return null;
  },
  name: 'draggingSortableProvider',
);

final tokenFilterProvider = StateProvider<TokenFilter?>((ref) => null);

final connectivityProvider = StreamProvider<ConnectivityResult>(
  (ref) {
    Logger.info("New connectivityProvider created", name: 'connectivityProvider');
    ref.read(tokenProvider.notifier).initState.then(
      (newState) {
        Connectivity().checkConnectivity().then((connectivity) {
          Logger.info("First connectivity check: $connectivity", name: 'connectivityProvider#initialCheck');
          final hasNoConnection = connectivity == ConnectivityResult.none;
          if (hasNoConnection && newState.hasPushTokens && globalNavigatorKey.currentContext != null) {
            ref.read(statusMessageProvider.notifier).state = (AppLocalizations.of(globalNavigatorKey.currentContext!)!.noNetworkConnection, null);
          }
        });
      },
    );
    return Connectivity().onConnectivityChanged;
  },
);

final statusMessageProvider = StateProvider<(String, String?)?>(
  (ref) {
    Logger.info("New statusMessageProvider created", name: 'statusMessageProvider');
    return null;
  },
);

final introductionProvider = StateNotifierProvider<InrtroductionNotifier, IntroductionState>(
  (ref) {
    Logger.info("New introductionProvider created", name: 'introductionProvider');
    return InrtroductionNotifier(repository: PreferenceIntroductionRepository());
  },
);

final appConstraintsProvider = StateProvider<BoxConstraints?>(
  (ref) {
    Logger.info("New constraintsProvider created", name: 'appConstraintsProvider');
    return null;
  },
);

final homeWidgetProvider = StateProvider<Map<String, OTPToken>>(
  (ref) {
    Logger.info("New homeWidgetProvider created", name: 'homeWidgetProvider');
    ref.listen(tokenProvider, (previous, next) {
      HomeWidgetUtils().updateTokensIfLinked(next.lastlyUpdatedTokens);
    });
    return {};
  },
);

/// Only used for the app customizer
final applicationCustomizerProvider = StateProvider<ApplicationCustomization>((ref) => ApplicationCustomization.defaultCustomization);
