import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/states/token_state.dart';
import '../../state_notifiers/token_notifier.dart';
import '../../../logger.dart';
import 'deeplink_provider.dart';

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
      newTokenNotifier.handleLink(newLink.uri);
    });

    return newTokenNotifier;
  },
  name: 'tokenProvider',
);
