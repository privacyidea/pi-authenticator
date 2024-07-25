import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/states/progress_state.dart';
import '../../state_notifiers/progress_state_notifier.dart';
import '../../../logger.dart';

final progressStateProvider = StateNotifierProvider<ProgressStateNotifier, ProgressState?>((ref) {
  Logger.info("New ProgressStateNotifier created", name: 'progressStateProvider');
  return ProgressStateNotifier();
});
