import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../../../interfaces/riverpod/state_listeners/state_notifier_provider_listeners/token_state_listener.dart';
import '../../../model/states/token_state.dart';
import '../riverpod_providers/state_notifier_providers/token_container_state_provider.dart';

class ContainerListensToTokenState extends TokenStateListener {
  ContainerListensToTokenState({
    required super.tokenProvider,
    required WidgetRef ref,
  }) : super(onNewState: (TokenState? previous, TokenState next) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onNewState(previous, next, ref);
          });
        });

  static Future<void> _onNewState(TokenState? previousState, TokenState nextState, WidgetRef ref) async {
    Logger.warning('New token state', name: 'TokenContainerTokenStateListener');
    final maybePiTokenTemplates = nextState.lastlyUpdatedTokens.maybePiTokens.toTemplates();
    final credentials = ref.read(credentialsProvider).value?.credentials ?? [];
    if (maybePiTokenTemplates.isEmpty) return;
    for (var credential in credentials) {
      ref.read(tokenContainerProviderOf(containerSerial: credential.serial).notifier).addLocalTemplates(maybePiTokenTemplates);
    }
  }
}
