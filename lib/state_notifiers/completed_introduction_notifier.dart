import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/states/Introductions_state.dart';
import '../utils/logger.dart';

import '../interfaces/repo/introduction_repository.dart';
import '../model/enums/introduction_enum.dart';

class CompletedInrtroductionNotifier extends StateNotifier<IntroductionsState> {
  Future<void>? isLoading;

  final IntroductionRepository _repo;
  CompletedInrtroductionNotifier({required IntroductionRepository repository})
      : _repo = repository,
        super(IntroductionsState()) {
    _loadFromRepo();
  }

  void _loadFromRepo() async {
    isLoading = Future<void>(() async {
      state = await _repo.loadCompletedIntroductions();
      Logger.info('Loading completed introductions from repo: $state', name: 'settings_notifier.dart#_loadFromRepo');
    });
  }

  void _saveToRepo() async {
    isLoading = Future<void>(() async {
      final success = await _repo.saveCompletedIntroductions(state);
      if (success) {
        Logger.info('Saving completed introductions to repo: $state', name: 'settings_notifier.dart#_saveToRepo');
      } else {
        Logger.warning('Failed to save completed introductions to repo: $state', name: 'settings_notifier.dart#_saveToRepo');
      }
    });
  }

  void complete(Introduction introduction) {
    state = state.withCompletedIntroduction(introduction);
    _saveToRepo();
  }

  void uncomplete(Introduction introduction) {
    state = state.withoutCompletedIntroduction(introduction);
    _saveToRepo();
  }
}
