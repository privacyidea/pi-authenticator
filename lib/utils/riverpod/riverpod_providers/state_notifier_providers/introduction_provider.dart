import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/riverpod_states/introduction_state.dart';
import '../../../../repo/preference_introduction_repository.dart';
import '../../state_notifiers/completed_introduction_notifier.dart';
import '../../../logger.dart';

final introductionProvider = StateNotifierProvider<IntroductionNotifier, IntroductionState>(
  (ref) {
    Logger.info("New introductionProvider created", name: 'introductionProvider');
    return IntroductionNotifier(repository: PreferenceIntroductionRepository());
  },
);
