import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../model/mixins/sortable_mixin.dart';
import '../model/states/introduction_state.dart';
import '../model/states/progress_state.dart';
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
import '../state_notifiers/progress_state_notifier.dart';
import '../state_notifiers/push_request_notifier.dart';
import '../state_notifiers/settings_notifier.dart';
import '../state_notifiers/sortable_notifier.dart';
import '../state_notifiers/token_folder_notifier.dart';
import '../state_notifiers/token_notifier.dart';
import 'globals.dart';
import 'home_widget_utils.dart';
import 'logger.dart';
import 'push_provider.dart';
import 'riverpod_state_listener.dart';

/// Never use globalRef to .watch() a provider. only use it to .read() a provider
///
/// Otherwise the whole app will rebuild on every state change of the provider
WidgetRef? globalRef;

Future<void> _handleUri(WidgetRef? ref, Uri uri) async => ref?.read(tokenProvider.notifier).handleLink(uri);

final tokenProvider = StateNotifierProvider<TokenNotifier, TokenState>(
  (ref) {
    Logger.info("New TokenNotifier created");
    final newTokenNotifier = TokenNotifier(ref: ref);

    ref.listen(deeplinkProvider, (previous, newLink) {
      if (newLink == null) {
        Logger.info("Received null deeplink", name: 'tokenProvider#deeplinkProvider');
        return;
      }
      Logger.info("Received new deeplink", name: 'tokenProvider#deeplinkProvider');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(Duration(milliseconds: 500));
        _handleUri(globalRef, newLink.uri);
      });
    });

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
      ref: ref,
      pushProvider: pushProvider,
    );

    ref.listen(tokenProvider, (previous, next) {
      if (previous?.hasPushTokens == true && next.hasPushTokens == false) {
        /// Last push token was deleted
        Logger.info('Last push token was deleted. Deactivating push provider and deleting firebase token.', name: 'pushRequestProvider#tokenProvider');
        pushRequestNotifier.swapPushProvider(PlaceholderPushProvider());
        pushProvider.firebaseUtils.deleteFirebaseToken();
      }
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

    return pushRequestNotifier;
  },
  name: 'pushRequestProvider',
);

final deeplinkProvider = StateNotifierProvider<DeeplinkNotifier, DeepLink?>(
  (ref) {
    Logger.info("New DeeplinkNotifier created", name: 'deeplinkProvider');
    return DeeplinkNotifier(sources: [
      DeeplinkSource(
        name: 'uni_links',
        stream: AppLinks().uriLinkStream,
        initialUri: Future.value(null), // We got the initial uri from uni_links in both (initial and incoming) cases
      ),
      DeeplinkSource(
        name: 'home_widget',
        stream: HomeWidgetUtils().widgetClicked,
        initialUri: HomeWidgetUtils().initiallyLaunchedFromHomeWidget(),
      ),
    ]);
  },
  name: 'deeplinkProvider',
);

final tokenFolderProvider = StateNotifierProvider<TokenFolderNotifier, TokenFolderState>(
  (ref) {
    Logger.info("New TokenFolderNotifier created", name: 'tokenFolderProvider');
    return TokenFolderNotifier(repository: PreferenceTokenFolderRepository());
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

final connectivityProvider = StreamProvider<List<ConnectivityResult>>(
  (ref) {
    Logger.info("New connectivityProvider created", name: 'connectivityProvider');
    ref.read(tokenProvider.notifier).initState.then(
      (newState) {
        Connectivity().checkConnectivity().then((connectivity) {
          Logger.info("First connectivity check: $connectivity", name: 'connectivityProvider#initialCheck');
          final hasNoConnection = connectivity.contains(ConnectivityResult.none);
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

final introductionProvider = StateNotifierProvider<IntroductionNotifier, IntroductionState>(
  (ref) {
    Logger.info("New introductionProvider created", name: 'introductionProvider');
    return IntroductionNotifier(repository: PreferenceIntroductionRepository());
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

final sortableProvider = StateNotifierProvider<SortableNotifier, List<SortableMixin>>(
  (ref) {
    final SortableNotifier notifier = SortableNotifier(ref);
    Logger.info("New sortableProvider created", name: 'sortableProvider');
    ref.listen(tokenProvider, (previous, next) => notifier.handleNewStateList(next.tokens));
    ref.listen(tokenFolderProvider, (previous, next) => notifier.handleNewStateList(next.folders));
    Future.wait(
      [ref.read(tokenProvider.notifier).initState, ref.read(tokenFolderProvider.notifier).initState],
    ).then((values) {
      final sortables = <SortableMixin>[];
      for (final v in values) {
        if (v is TokenState) {
          sortables.addAll(v.tokens);
        } else if (v is TokenFolderState) {
          sortables.addAll(v.folders);
        }
      }
      notifier.handleNewStateList(sortables);
    });
    return notifier;
  },
);

final progressStateProvider = StateNotifierProvider<ProgressStateNotifier, ProgressState?>((ref) => ProgressStateNotifier());
