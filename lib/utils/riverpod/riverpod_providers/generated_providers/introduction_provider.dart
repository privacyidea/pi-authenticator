/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../interfaces/repo/introduction_repository.dart';
import '../../../../model/enums/introduction.dart';
import '../../../../model/riverpod_states/introduction_state.dart';
import '../../../../repo/preference_introduction_repository.dart';
import '../../../logger.dart';

part 'introduction_provider.g.dart';

final introductionNotifierProvider = introductionNotifierProviderOf(repo: PreferenceIntroductionRepository());

@Riverpod(keepAlive: true)
class IntroductionNotifier extends _$IntroductionNotifier {
  final IntroductionRepository? _repositoryOverride;
  late final IntroductionRepository _repo;
  IntroductionNotifier({IntroductionRepository? repoOverride})
      : _repositoryOverride = repoOverride,
        super();

  @override
  Future<IntroductionState> build({required IntroductionRepository repo}) async {
    Logger.info('New IntroductionNotifier created');
    _repo = _repositoryOverride ?? repo;
    return await _loadFromRepo();
  }

  Future<IntroductionState> _loadFromRepo() async {
    final newState = await _repo.loadCompletedIntroductions();

    Logger.info('Loading completed introductions from repo: $newState');
    return newState;
  }

  Future<void> _saveToRepo(IntroductionState state) async {
    final success = await _repo.saveCompletedIntroductions(state);
    if (success) {
      Logger.info('Saving completed introductions to repo: $state');
    } else {
      Logger.warning('Failed to save completed introductions to repo: $state');
    }
  }

  Future<void> complete(Introduction introduction) async {
    Logger.info('Completing introduction: $introduction');
    final newState = (await future).withCompletedIntroduction(introduction);
    await _saveToRepo(newState);
    state = AsyncValue.data(newState);
    Logger.debug('New saved state after completion: ${await future}');
  }

  Future<void> completeMultiple(List<Introduction> values) async {
    Logger.info('Completing multiple introductions: $values');
    final newState = (await future).withCompletedIntroductions(values);
    await _saveToRepo(newState);
    state = AsyncValue.data(newState);
  }

  Future<void> uncomplete(Introduction introduction) async {
    Logger.info('Uncompleting introduction: $introduction');
    final newState = (await future).withoutCompletedIntroduction(introduction);
    await _saveToRepo(newState);
    state = AsyncValue.data(newState);
  }

  Future<void> uncompleteMultiple(List<Introduction> values) async {
    Logger.info('Uncompleting multiple introductions: $values');
    final newState = (await future).withoutCompletedIntroductions(values);
    await _saveToRepo(newState);
    state = AsyncValue.data(newState);
  }

  Future<void> completeAll() async {
    Logger.info('Completing all introductions');
    final newState = IntroductionState.withAllCompleted();
    await _saveToRepo(newState);
    state = AsyncValue.data(newState);
  }
}
