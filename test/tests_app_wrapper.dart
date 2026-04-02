import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:privacyidea_authenticator/api/interfaces/container_api.dart';
import 'package:privacyidea_authenticator/interfaces/repo/introduction_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/push_request_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/settings_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_container_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_folder_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/repo/secure_storage.dart';
import 'package:privacyidea_authenticator/utils/allow_screenshot_utils.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/action_theme.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/push_request_theme.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/status_colors.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
])
class TestsAppWrapper extends StatelessWidget {
  final Widget child;
  final List<Override> overrides;

  const TestsAppWrapper({
    super.key,
    required this.child,
    this.overrides = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        navigatorKey: globalNavigatorKey,
        theme: ThemeData(
          extensions: [
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
        home: Scaffold(body: child),
      ),
    );
  }
}

Future<void> pumpUntilFindNWidgets(
  WidgetTester tester,
  Finder finder,
  int n, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final end = tester.binding.clock.now().add(timeout);
  while (tester.binding.clock.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 50));
    if (tester.widgetList(finder).length == n) {
      return;
    }
  }
  throw TestFailure("Could not find $n widgets for $finder within $timeout");
}
