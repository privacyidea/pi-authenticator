/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logger.dart';

import '../../../interfaces/riverpod/state_listeners/state_notifier_provider_listeners/token_state_listener.dart';
import '../../../model/riverpod_states/token_state.dart';
import '../riverpod_providers/generated_providers/credential_notifier.dart';
import '../riverpod_providers/generated_providers/token_container_notifier.dart';

class ContainerListensToTokenState extends TokenStateListener {
  ContainerListensToTokenState({
    required super.provider,
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
    final credentials = (await ref.read(containerCredentialsProvider.future)).credentials;
    Logger.warning('Readed: $credentials', name: 'TokenContainerTokenStateListener');
    // if (maybePiTokenTemplates.isEmpty) return;
    for (var credential in credentials) {
      final deletedPiTokenTemplates = nextState.lastlyDeletedTokens.fromContainer(credential.serial).toTemplates();
      if (deletedPiTokenTemplates.isNotEmpty) {
        Logger.warning(
          'Deleted (${deletedPiTokenTemplates.length}) tokens from container "${credential.serial}"',
          name: 'TokenContainerTokenStateListener',
        );
        await ref.read(tokenContainerNotifierProviderOf(credential: credential).notifier).handleDeletedTokenTemplates(deletedPiTokenTemplates);
      }
      if (maybePiTokenTemplates.isNotEmpty) {
        Logger.warning(
          'Adding maybePiTokenTemplates (${maybePiTokenTemplates.length}) to container ${credential.serial}',
          name: 'TokenContainerTokenStateListener',
        );
        await ref.read(tokenContainerNotifierProviderOf(credential: credential).notifier).tryAddLocalTemplates(maybePiTokenTemplates);
      }
    }
  }
}
