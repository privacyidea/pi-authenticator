import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../interfaces/riverpod/state_listeners/state_notifier_provider_listeners/token_state_listener.dart';
import '../../../model/states/token_state.dart';
import '../riverpod_providers/state_notifier_providers/token_container_state_provider.dart';

class TokenContainerTokenStateListener extends TokenStateListener {
  TokenContainerTokenStateListener({
    required super.tokenProvider,
    required WidgetRef ref,
  }) : super(onNewState: (TokenState? previous, TokenState next) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onNewState(previous, next, ref);
          });
        });

  static Future<void> _onNewState(TokenState? previous, TokenState next, WidgetRef ref) async {
    final templates = next.lastlyUpdatedTokens.fromContainer.toTemplates();
    if (templates.isEmpty) return;
    ref.read(tokenContainerProvider.notifier).updateTemplates(templates);
  }
}
