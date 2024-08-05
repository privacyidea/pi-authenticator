import 'package:collection/collection.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';

import '../../../interfaces/riverpod/state_listeners/state_notifier_provider_listeners/token_state_listener.dart';
import '../../../model/riverpod_states/token_state.dart';
import '../../../model/tokens/token.dart';
import '../../home_widget_utils.dart';

class HomeWidgetTokenStateListener extends TokenStateListener {
  const HomeWidgetTokenStateListener({required super.tokenProvider})
      : super(
          onNewState: _onNewState,
          listenerName: 'HomeWidgetUtils().updateTokensIfLinked',
        );

  static void _onNewState(TokenState? previous, TokenState next) {
    final updateTokens = <Token>[];
    if (previous == null) {
      updateTokens.addAll(next.lastlyUpdatedTokens);
    } else {
      final previousTokens = previous.tokens;
      final nextTokens = next.lastlyUpdatedTokens;
      for (final nextToken in nextTokens) {
        final previousToken = previousTokens.firstWhereOrNull((previousToken) => previousToken.id == nextToken.id);
        if (previousToken == null) {
          updateTokens.add(nextToken);
          continue;
        }
        if (previousToken.issuer != nextToken.issuer ||
            previousToken.label != nextToken.label ||
            previousToken.isLocked != nextToken.isLocked ||
            (previousToken is HOTPToken && nextToken is HOTPToken && previousToken.counter != nextToken.counter)) {
          updateTokens.add(nextToken);
        }
      }
    }
    HomeWidgetUtils().updateTokensIfLinked(updateTokens);
  }
}
