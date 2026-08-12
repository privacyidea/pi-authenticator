import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/repo/preference_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists auto-close after accepting a push request', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = PreferenceSettingsRepository();

    final initialSettings = await repository.loadSettings();
    expect(initialSettings.autoCloseAppAfterAcceptingPushRequest, isFalse);

    final saved = await repository.saveSettings(
      initialSettings.copyWith(autoCloseAppAfterAcceptingPushRequest: true),
    );
    expect(saved, isTrue);

    final reloadedSettings = await PreferenceSettingsRepository()
        .loadSettings();
    expect(reloadedSettings.autoCloseAppAfterAcceptingPushRequest, isTrue);
  });
}
