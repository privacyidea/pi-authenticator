import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/states/push_request_state.dart';
import '../../state_notifiers/push_request_notifier.dart';
import '../../../logger.dart';
import '../../../push_provider.dart';
import 'settings_provider.dart';
import 'token_provider.dart';

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
