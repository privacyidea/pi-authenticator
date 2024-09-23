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
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../interfaces/repo/introduction_repository.dart';
// import '../../../model/enums/introduction.dart';
// import '../../../model/riverpod_states/introduction_state.dart';
// import '../../logger.dart';

// class IntroductionNotifier extends StateNotifier<IntroductionState> {
//   late Future<IntroductionState> loadingRepo;

//   final IntroductionRepository _repo;
//   IntroductionNotifier({required IntroductionRepository repository})
//       : _repo = repository,
//         super(const IntroductionState()) {
//     _init();
//   }

//   Future<void> _init() async {
//     loadingRepo = Future(() async {
//       await loadFromRepo();
//       return state;
//     });
//     await loadingRepo;
//   }

//   Future<void> loadFromRepo() async {
//     loadingRepo = Future<IntroductionState>(() async {
//       final newState = await _repo.loadCompletedIntroductions();
//       state = newState;
//       Logger.info('Loading completed introductions from repo: $state');
//       return newState;
//     });
//     await loadingRepo;
//   }

//   Future<void> _saveToRepo() async {
//     loadingRepo = Future<IntroductionState>(() async {
//       final success = await _repo.saveCompletedIntroductions(state);
//       if (success) {
//         Logger.info('Saving completed introductions to repo: $state');
//       } else {
//         Logger.warning('Failed to save completed introductions to repo: $state');
//       }
//       return state;
//     });
//     await loadingRepo;
//   }

//   Future<void> complete(Introduction introduction) async {
//     state = state.withCompletedIntroduction(introduction);
//     await _saveToRepo();
//   }

//   Future<void> uncomplete(Introduction introduction) async {
//     state = state.withoutCompletedIntroduction(introduction);
//     await _saveToRepo();
//   }

//   bool isCompleted(Introduction introduction) => state.isCompleted(introduction);
//   bool isUncompleted(Introduction introduction) => state.isUncompleted(introduction);

//   Future<void> completeAll() async {
//     state = state.withAllCompleted();
//     await _saveToRepo();
//   }
// }
