import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:uni_links/uni_links.dart';

import '../l10n/app_localizations.dart';
import '../model/mixins/sortable_mixin.dart';
import '../model/push_request.dart';
import '../model/states/introduction_state.dart';
import '../model/states/settings_state.dart';
import '../model/states/token_filter.dart';
import '../model/states/token_folder_state.dart';
import '../model/states/token_state.dart';
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
    final tokenNotifier = TokenNotifier();

    ref.listen(deeplinkProvider, (previous, newLink) {
      if (newLink == null) {
        Logger.info("tokenProvider received null deeplink");
        return;
      }
      Logger.info("tokenProvider received new deeplink");
      tokenNotifier.handleLink(newLink.uri);
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
        if (previous == AppLifecycleState.paused && next == AppLifecycleState.resumed) {
          Logger.info('Refreshing tokens on resume');
          tokenNotifier.refreshTokens();
        }
        if (previous == AppLifecycleState.resumed && next == AppLifecycleState.paused) {
          Logger.info('Cancelling all notifications on pause');
          tokenNotifier.saveTokens();
        }
      },
    );
    return tokenNotifier;
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

final pushRequestProvider = StateNotifierProvider<PushRequestNotifier, PushRequest?>(
  (ref) {
    Logger.info("New PushRequestNotifier created");
    final pushProvider = PushProvider();
    ref.listen(settingsProvider, (previous, next) {
      Logger.warning("settingsProvider changed from $previous to $next");
      if (previous?.enablePolling != next.enablePolling) {
        Logger.info("Polling enabled changed from ${previous?.enablePolling} to ${next.enablePolling}");
        pushProvider.setPollingEnabled(next.enablePolling);
      }
    });

    final pushRequestNotifier = PushRequestNotifier(
      pushProvider: pushProvider,
    );

    ref.listen(appStateProvider, (previous, next) {
      if (previous == AppLifecycleState.paused && next == AppLifecycleState.resumed) {
        Logger.info('Polling for challenges on resume');
        pushProvider.pollForChallenges(isManually: false);
      }
    });

    return pushRequestNotifier;
  },
  name: 'pushRequestProvider',
);

final deeplinkProvider = StateNotifierProvider<DeeplinkNotifier, DeepLink?>(
  (ref) {
    Logger.info("New DeeplinkNotifier created");
    return DeeplinkNotifier(sources: [
      DeeplinkSource(name: 'uni_links', stream: uriLinkStream, initialUri: getInitialUri()),
      DeeplinkSource(
        name: 'home_widget',
        stream: HomeWidget.widgetClicked,
        initialUri: HomeWidget.initiallyLaunchedFromHomeWidget(),
        isSupported: HomeWidgetUtils.isHomeWidgetSupported,
      ),
    ]);
  },
  name: 'deeplinkProvider',
);

final appStateProvider = StateProvider<AppLifecycleState?>(
  (ref) {
    Logger.info("New AppStateNotifier created");
    return null;
  },
  name: 'appStateProvider',
);

final tokenFolderProvider = StateNotifierProvider<TokenFolderNotifier, TokenFolderState>(
  (ref) {
    Logger.info("New TokenFolderNotifier created");
    return TokenFolderNotifier(
      repository: PreferenceTokenFolderRepository(),
    );
  },
  name: 'tokenFolderProvider',
);

final draggingSortableProvider = StateProvider<SortableMixin?>(
  (ref) {
    Logger.info("New draggingSortableProvider created");
    return null;
  },
  name: 'draggingSortableProvider',
);

final tokenFilterProvider = StateProvider<TokenFilter?>((ref) => null);

final connectivityProvider = StreamProvider<ConnectivityResult>(
  (ref) {
    Logger.info("New connectivityProvider created");
    ref.read(tokenProvider.notifier).loadingRepo.then(
      (newState) {
        Connectivity().checkConnectivity().then((connectivity) {
          Logger.info("First connectivity check: $connectivity");
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
    Logger.info("New statusMessageProvider created");
    return null;
  },
);

final introductionProvider = StateNotifierProvider<InrtroductionNotifier, IntroductionState>(
  (ref) {
    Logger.info("New introductionProvider created");
    return InrtroductionNotifier(repository: PreferenceIntroductionRepository());
  },
);

final appConstraintsProvider = StateProvider<BoxConstraints?>(
  (ref) {
    Logger.info("New constraintsProvider created");
    return null;
  },
);

/// Only used for the app customizer
final applicationCustomizerProvider = StateProvider<ApplicationCustomization>((ref) => ApplicationCustomization.defaultCustomization);
