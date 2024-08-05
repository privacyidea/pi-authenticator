import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/riverpod_states/settings_state.dart';
import '../../../../repo/preference_settings_repository.dart';
import '../../state_notifiers/settings_notifier.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    // Using Logger here will cause a circular dependency because Logger uses settingsProvider (logging verbosity)
    return SettingsNotifier(repository: PreferenceSettingsRepository());
  },
  name: 'settingsProvider',
);
