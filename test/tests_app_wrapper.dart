import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:privacyidea_authenticator/api/interfaces/container_api.dart';
import 'package:privacyidea_authenticator/interfaces/repo/introduction_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/push_request_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/settings_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_container_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_folder_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/repo/secure_storage.dart';
import 'package:privacyidea_authenticator/utils/allow_screenshot_utils.dart';
import 'package:privacyidea_authenticator/utils/app_info_utils.dart';
import 'package:privacyidea_authenticator/utils/custom_int_buffer.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/action_theme.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/app_dimensions.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/push_request_theme.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/status_colors.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/home_widget_utils.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateNiceMocks([
  MockSpec<TokenRepository>(),
  MockSpec<SettingsRepository>(),
  MockSpec<TokenFolderRepository>(),
  MockSpec<IntroductionRepository>(),
  MockSpec<PushRequestRepository>(),
  MockSpec<TokenContainerRepository>(),
  MockSpec<TokenContainerApi>(),
  MockSpec<PrivacyideaIOClient>(),
  MockSpec<RsaUtils>(),
  MockSpec<EccUtils>(),
  MockSpec<FirebaseUtils>(),
  MockSpec<PushProvider>(),
  MockSpec<AllowScreenshotUtils>(),
  MockSpec<FlutterSecureStorage>(),
  MockSpec<SecureStorage>(),
  MockSpec<TokenContainerNotifier>(),
  MockSpec<TokenContainerFinalized>(),
  MockSpec<TokenNotifier>(),
  MockSpec<LocalAuthentication>(),
  MockSpec<PushRequestNotifier>(),
  MockSpec<HomeWidgetUtils>(),
  MockSpec<IntroductionNotifier>(),
  MockSpec<Token>(),
  MockSpec<DeeplinkNotifier>(),
  MockSpec<TokenFolderNotifier>(),
])
class TestsAppWrapper extends StatelessWidget {
  final Widget child;
  final List<Override> overrides;
  final bool wrapInMaterialApp;

  const TestsAppWrapper({
    super.key,
    required this.child,
    this.overrides = const [],
    this.wrapInMaterialApp = true,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: Consumer(
        builder: (context, ref, _) {
          globalRef = ref;
          if (!wrapInMaterialApp) {
            return EasyDynamicThemeWidget(
              initialThemeMode: ThemeMode.system,
              child: child,
            );
          }
          return MaterialApp(
            navigatorKey: globalNavigatorKey,
            theme: ThemeData(
              extensions: [
                const AppDimensions(),
                StatusColors(
                  success: const Color(0xFF4CAF50),
                  warning: const Color(0xFFFF9800),
                  error: const Color(0xFFF44336),
                ),
                TokenTileTheme(
                  deleteColor: Colors.red,
                  editColor: Colors.blue,
                  lockColor: Colors.grey,
                  transferColor: Colors.green,
                  actionDisabledColor: Colors.blueGrey,
                  actionForegroundColor: Colors.white,
                  defaultOtpColor: Colors.black,
                  warningOtpColor: const Color(0xFFFF9800),
                  criticalOtpColor: const Color(0xFFF44336),
                  defaultCountdownColor: Colors.grey,
                  warningCountdownColor: const Color(0xFFFF9800),
                  criticalCountdownColor: const Color(0xFFF44336),
                  tileSubtitleColor: Colors.black54,
                  tileIconColor: Colors.black87,
                ),
                PushRequestTheme(
                  acceptColor: const Color(0xFF4CAF50),
                  declineColor: const Color(0xFFF44336),
                ),
              ],
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: Scaffold(body: EasyDynamicThemeWidget(child: child)),
          );
        },
      ),
    );
  }
}

Future<void> setupMocks() async {
  provideDummy(const IntroductionState());
  provideDummy(const TokenContainerState(containerList: []));
  provideDummy(const TokenFolderState(folders: []));
  provideDummy(PushRequestState(pushRequests: [], knownPushRequests: CustomIntBuffer(list: [])));
  SharedPreferences.setMockInitialValues({});
  PackageInfo.setMockInitialValues(
    appName: 'privacyIDEA',
    packageName: 'it.netknights.pi',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  await AppInfoUtils.init();
}

/// Pumps multiple frames over a duration, simulating real-time frame rendering.
/// Use this instead of `tester.pump(duration)` when animations/transitions need multiple frames.
Future<void> pumpForDuration(
  WidgetTester tester,
  Duration duration, {
  Duration frameInterval = const Duration(milliseconds: 50),
}) async {
  final frames = (duration.inMilliseconds / frameInterval.inMilliseconds).ceil();
  for (var i = 0; i < frames; i++) {
    await tester.pump(frameInterval);
  }
}

Future<void> pumpUntilFindNWidgets(
  WidgetTester tester,
  Finder finder,
  int n, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 50));
    if (tester.widgetList(finder).length == n) {
      return;
    }
  }
  throw TestFailure("Could not find $n widgets for $finder within $timeout");
}
