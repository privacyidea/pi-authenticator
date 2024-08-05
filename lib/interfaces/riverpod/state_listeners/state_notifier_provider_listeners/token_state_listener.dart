import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/riverpod_states/token_state.dart';
import '../../../../utils/riverpod/state_notifiers/token_notifier.dart';
import '../state_notifier_provider_listener.dart';

abstract class TokenStateListener extends StateNotifierProviderListener<TokenNotifier, TokenState> {
  const TokenStateListener({
    required StateNotifierProvider<TokenNotifier, TokenState> tokenProvider,
    required super.onNewState,
    required super.listenerName,
  }) : super(provider: tokenProvider);
}
