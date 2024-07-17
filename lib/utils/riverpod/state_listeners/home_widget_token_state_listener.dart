import '../../../interfaces/riverpod/state_listeners/state_notifier_provider_listeners/token_state_listener.dart';
import '../../../model/states/token_state.dart';
import '../../home_widget_utils.dart';

class HomeWidgetTokenStateListener extends TokenStateListener {
  const HomeWidgetTokenStateListener({required super.tokenProvider}) : super(onNewState: _onNewState);

  static void _onNewState(TokenState? previous, TokenState next) {
    HomeWidgetUtils().updateTokensIfLinked(next.lastlyUpdatedTokens);
  }
}
