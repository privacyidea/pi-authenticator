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
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mutex/mutex.dart';
// import 'package:privacyidea_authenticator/model/states/token_state.dart';
// import 'package:privacyidea_authenticator/model/token_container.dart';
// import 'package:privacyidea_authenticator/utils/logger.dart';
// import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_notifier_providers/token_provider.dart';

// import '../../../interfaces/repo/container_repository.dart';
// import '../../../model/states/token_container_state.dart';

// class TokenContainerNotifier extends StateNotifier<TokenContainer> {
//   final TokenContainerRepository _repository;
//   late Future<TokenContainer> initState;
//   final StateNotifierProviderRef _ref;
//   final Mutex _repoMutex = Mutex();
//   final Mutex _updateMutex = Mutex();

//   TokenContainerNotifier({
//     required StateNotifierProviderRef ref,
//     required TokenContainerRepository repository,
//     TokenContainer? initState,
//   })  : _repository = repository,
//         _ref = ref,
//         super(initState ?? TokenContainer.uninitialized([])) {
//     _init();
//   }

//   Future<void> _init() async {
//     initState = _loadFromRepo();
//     final newState = await initState;
//     if (!mounted) return;
//     state = newState;
//   }

//   Future<TokenContainer> _loadFromRepo() async {
//     Logger.warning('Loading container state from repo', name: 'TokenContainerNotifier');
//     await _repoMutex.acquire();
//     final containerState = await _repository.loadContainerState();
//     _repoMutex.release();
//     return containerState;
//   }

//   Future<TokenContainer> _saveToRepo(TokenContainer state) async {
//     await _repoMutex.acquire();
//     final newState = await _repository.saveContainerState(state);
//     _repoMutex.release();
//     return newState;
//   }

//   Future<TokenContainer> handleTokenState(TokenState tokenState) async {
//     await _updateMutex.acquire();
//     final localTokens = tokenState.tokens.maybePiTokens;
//     final containerTokens = tokenState.containerTokens(state.serial);
//     final localTokenTemplates = localTokens.toTemplates();
//     final containerTokenTemplates = containerTokens.toTemplates();
//     final newState = state.copyWith(localTokenTemplates: localTokenTemplates, syncedTokenTemplates: containerTokenTemplates);
//     final savedState = await _saveToRepo(newState);
//     _ref.read(tokenProvider.notifier).updateContainerTokens(savedState);
//     state = savedState;
//     _updateMutex.release();
//     return savedState;
//   }

//   void addLocalTemplates(List<TokenTemplate> maybePiTokenTemplates) {}

//   // Future<TokenContainer> addToken(Token token) async {
//   //   await _updateMutex.acquire();
//   //   final newState = state.copyTransformInto<TokenContainerModified>(
//   //     tokenTemplates: [...state.syncedTokenTemplates, TokenTemplate(data: token.toUriMap())],
//   //   );
//   //   final savedState = await _saveToRepo(newState);
//   //   state = savedState;
//   //   _updateMutex.release();
//   //   return savedState;
//   // }

//   // Future<TokenContainer> updateTemplates(List<TokenTemplate> updatedTemplates) async {
//   //   await _updateMutex.acquire();
//   //   final newState = state.copyTransformInto<TokenContainerSynced>(
//   //     tokenTemplates: state.syncedTokenTemplates.map((oldToken) {
//   //       final updatedToken = updatedTemplates.firstWhere(
//   //         (newToken) => newToken.id == oldToken.id,
//   //         orElse: () => oldToken,
//   //       );
//   //       return updatedToken;
//   //     }).toList(),
//   //   );
//   //   final savedState = await _saveToRepo(newState);
//   //   state = savedState;
//   //   _updateMutex.release();
//   //   return savedState;
//   // }
// }
