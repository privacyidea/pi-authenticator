import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/platform_info/platform_info_imp/dummy_platform_info.dart';
import 'package:privacyidea_authenticator/model/platform_info/platform_info.dart';
import 'package:privacyidea_authenticator/state_notifiers/settings_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_notifier.dart';
import 'package:privacyidea_authenticator/model/states/settings_state.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Never use globalRef to .watch() a provider. only use it to .read() a provider
// Otherwise the whole app will rebuild on every state change of the provider
WidgetRef? globalRef;

final tokenProvider = StateNotifierProvider<TokenNotifier, List<Token>>((ref) {
  return TokenNotifier();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  print('settingsProvider: ${ref.watch(sharedPreferencesProvider)}');
  return SettingsNotifier(ref.watch(sharedPreferencesProvider));
});

final sharedPreferencesProvider = StateProvider<SharedPreferences?>((ref) {
  return null;
});

final platformInfoProvider = StateProvider<PlatformInfo>((ref) {
  return DummyPlatformInfo();
});
