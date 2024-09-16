// /*
//  * privacyIDEA Authenticator
//  *
//  * Author: Frank Merkel <frank.merkel@netknights.it>
//  *
//  * Copyright (c) 2024 NetKnights GmbH
//  *
//  * Licensed under the Apache License, Version 2.0 (the 'License');
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an 'AS IS' BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
// import 'package:flutter/widgets.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../logger.dart';

// import '../../../interfaces/riverpod/state_listeners/state_notifier_provider_listeners/token_state_listener.dart';
// import '../../../model/riverpod_states/token_state.dart';
// import '../riverpod_providers/generated_providers/container_notifier.dart';
// import '../riverpod_providers/generated_providers/token_container_notifier.dart';

// class ContainerListensToTokenState extends TokenStateListener {
//   ContainerListensToTokenState({
//     required super.provider,
//     required WidgetRef ref,
//   }) : super(
//           onNewState: (TokenState? previous, TokenState next) => WidgetsBinding.instance.addPostFrameCallback((_) {
//             _onNewState(previous, next, ref);
//           }),
//           listenerName: 'Container',
//         );

//   static Future<void> _onNewState(TokenState? previousState, TokenState nextState, WidgetRef ref) async {
//     Logger.warning('New token state', name: 'TokenContainerTokenStateListener');
//     final maybePiTokenTemplates = nextState.lastlyUpdatedTokens.maybePiTokens.toTemplates();
//     final container = (await ref.read(containerCredentialsProvider.future)).container;
//     Logger.warning('Readed: $container', name: 'TokenContainerTokenStateListener');
//     // if (maybePiTokenTemplates.isEmpty) return;
//     for (var container in container) {
//       final deletedPiTokenTemplates = nextState.lastlyDeletedTokens.ofContainer(container.serial).toTemplates();
//       if (deletedPiTokenTemplates.isNotEmpty) {
//         Logger.warning(
//           'Deleted (${deletedPiTokenTemplates.length}) tokens from container "${container.serial}"',
//           name: 'TokenContainerTokenStateListener',
//         );
//         // await ref.read(tokenContainerNotifierProviderOf(container: container).notifier).handleDeletedTokenTemplates(deletedPiTokenTemplates);
//       }
//       if (maybePiTokenTemplates.isNotEmpty) {
//         Logger.warning(
//           'Adding maybePiTokenTemplates (${maybePiTokenTemplates.length}) to container ${container.serial}',
//           name: 'TokenContainerTokenStateListener',
//         );
//         // await ref.read(tokenContainerNotifierProviderOf(container: container).notifier).tryAddLocalTemplates(maybePiTokenTemplates);
//       }
//     }
//   }
// }
