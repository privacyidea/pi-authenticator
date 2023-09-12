/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>

  Copyright (c) 2017-2023 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/app_customizer.dart';
import 'package:privacyidea_authenticator/utils/customizations.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/views/add_token_manually_view/add_token_manually_view.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view.dart';
import 'package:privacyidea_authenticator/views/onboarding_view/onboarding_view.dart';
import 'package:privacyidea_authenticator/views/qr_scanner_view/scanner_view.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view.dart';
import 'package:privacyidea_authenticator/views/splash_screen/splash_screen.dart';
import 'package:privacyidea_authenticator/widgets/app_wrapper.dart';

void main() async {
  Logger.init(
      navigatorKey: globalNavigatorKey,
      appRunner: () async {
        WidgetsFlutterBinding.ensureInitialized();
        if (!kIsWeb) await Firebase.initializeApp();
        runApp(const AppWrapper(child: PrivacyIDEAAuthenticator()));
      });
}

class PrivacyIDEAAuthenticator extends ConsumerWidget {
  const PrivacyIDEAAuthenticator({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsFlutterBinding.ensureInitialized();
    globalRef = ref;
    final state = ref.watch(settingsProvider);
    final locale = state.currentLocale;
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      navigatorKey: globalNavigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      title: applicationCustomizer.appName,
      theme: applicationCustomizer.generateLightTheme(),
      darkTheme: applicationCustomizer.generateDarkTheme(),
      scaffoldMessengerKey: globalSnackbarKey, // <= this
      themeMode: EasyDynamicTheme.of(context).themeMode,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        OnboardingView.routeName: (context) => const OnboardingView(),
        MainView.routeName: (context) => MainView(title: applicationCustomizer.appName, appLogo: applicationCustomizer.appIcon),
        SettingsView.routeName: (context) => const SettingsView(),
        AddTokenManuallyView.routeName: (context) => const AddTokenManuallyView(),
        QRScannerView.routeName: (context) => QRScannerView(),
      },
    );
  }
}
