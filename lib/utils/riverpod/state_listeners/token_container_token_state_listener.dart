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
  }) : super(
          onNewState: (TokenState? previous, TokenState next) => WidgetsBinding.instance.addPostFrameCallback((_) {
            _onNewState(previous, next, ref);
          }),
          listenerName: 'Container',
        );

  static Future<void> _onNewState(TokenState? previousState, TokenState nextState, WidgetRef ref) async {
    Logger.warning('New token state', name: 'TokenContainerTokenStateListener');
    final maybePiTokenTemplates = nextState.lastlyUpdatedTokens.maybePiTokens.toTemplates();
    final credentials = (await ref.read(credentialsProvider.future)).credentials;
    Logger.warning('Readed: $credentials', name: 'TokenContainerTokenStateListener');
    // if (maybePiTokenTemplates.isEmpty) return;
    for (var credential in credentials) {

      final deletedPiTokenTemplates = nextState.lastlyDeletedTokens.fromContainer(credential.serial).toTemplates();
      if (deletedPiTokenTemplates.isNotEmpty) {
        Logger.warning(
          'Deleted (${deletedPiTokenTemplates.length}) tokens from container "${credential.serial}"',
          name: 'TokenContainerTokenStateListener',
        );
        await ref.read(tokenContainerProviderOf(credential: credential).notifier).handleDeletedTokenTemplates(deletedPiTokenTemplates);
      }
      if (maybePiTokenTemplates.isNotEmpty) {
        Logger.warning(
          'Adding maybePiTokenTemplates (${maybePiTokenTemplates.length}) to container ${credential.serial}',
          name: 'TokenContainerTokenStateListener',
        );
        await ref.read(tokenContainerProviderOf(credential: credential).notifier).tryAddLocalTemplates(maybePiTokenTemplates);
      }
    }
  }
}
