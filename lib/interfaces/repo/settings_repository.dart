import '../../model/states/settings_state.dart';

abstract class SettingsRepository {
  Future<SettingsState> loadSettings();
  Future<bool> saveSettings(SettingsState settings);
}
