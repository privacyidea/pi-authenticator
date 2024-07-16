import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/states/token_state.dart';
import '../../../../state_notifiers/token_notifier.dart';
import '../state_notifier_provider_listener.dart';

abstract class TokenStateListener extends StateNotifierProviderListener<TokenNotifier, TokenState> {
  const TokenStateListener({
    required StateNotifierProvider<TokenNotifier, TokenState> tokenProvider,
    required super.onNewState,
  }) : super(provider: tokenProvider);
}
