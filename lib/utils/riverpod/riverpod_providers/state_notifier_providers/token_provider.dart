import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/riverpod_states/token_state.dart';
import '../../state_notifiers/token_notifier.dart';
import '../../../logger.dart';
import '../generated_providers/deeplink_notifier.dart';

final tokenProvider = StateNotifierProvider<TokenNotifier, TokenState>(
  (ref) {
    Logger.info("New TokenNotifier created");
    final newTokenNotifier = TokenNotifier(ref: ref);

    ref.listen(deeplinkNotifierProvider, (previous, newLink) {
      newLink.whenData(
        (data) {
          Logger.info("Received new deeplink with data: $data", name: 'tokenProvider#deeplinkProvider');
          newTokenNotifier.handleLink(data.uri);
        },
      );

    });

    return newTokenNotifier;
  },
  name: 'tokenProvider',
);
