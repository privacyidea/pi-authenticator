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
import 'dart:developer';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/utils/app_customizer.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/views/add_token_manually_view/add_token_manually_view.dart';
import 'package:privacyidea_authenticator/views/license_view/license_view.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view.dart';
import 'package:privacyidea_authenticator/views/onboarding_view/onboarding_view.dart';
import 'package:privacyidea_authenticator/views/push_token_view/push_tokens_view.dart';
import 'package:privacyidea_authenticator/views/qr_scanner_view/qr_scanner_view.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view.dart';
import 'package:privacyidea_authenticator/views/splash_screen/splash_screen.dart';
import 'package:privacyidea_authenticator/widgets/app_wrapper.dart';

import 'utils/home_widget_utils.dart';

void main() async {
  Logger.init(
      navigatorKey: globalNavigatorKey,
      appRunner: () async {
        WidgetsFlutterBinding.ensureInitialized();
        await HomeWidget.setAppGroupId(appGroupId);
        if (await HomeWidgetUtils.isHomeWidgetSupported) {
          await HomeWidget.registerBackgroundCallback(homeWidgetBackgroundCallback);
        }

        runApp(AppWrapper(child: PrivacyIDEAAuthenticator(customization: ApplicationCustomization.defaultCustomization)));
      });
}

class PrivacyIDEAAuthenticator extends ConsumerWidget {
  static ApplicationCustomization? customization;
  final ApplicationCustomization _customization;
  PrivacyIDEAAuthenticator({required ApplicationCustomization customization, super.key}) : _customization = customization {
    // ignore: prefer_initializing_formals
    PrivacyIDEAAuthenticator.customization = customization;
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsFlutterBinding.ensureInitialized();
    globalRef = ref;
    final locale = ref.watch(settingsProvider).currentLocale;
    log('Current Locale: $locale');
    return LayoutBuilder(builder: (context, constraints) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(appConstraintsProvider.notifier).state = constraints;
      });
      return MaterialApp(
        debugShowCheckedModeBanner: true,
        navigatorKey: globalNavigatorKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        title: _customization.appName,
        theme: _customization.generateLightTheme(),
        darkTheme: _customization.generateDarkTheme(),
        scaffoldMessengerKey: globalSnackbarKey, // <= this
        themeMode: EasyDynamicTheme.of(context).themeMode,
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (context) => SplashScreen(
                appImage: _customization.appImage,
                appIcon: _customization.appIcon,
                appName: _customization.appName,
              ),
          OnboardingView.routeName: (context) => OnboardingView(
                appName: _customization.appName,
              ),
          MainView.routeName: (context) => MainView(
                appIcon: _customization.appIcon,
                appName: _customization.appName,
              ),
          SettingsView.routeName: (context) => const SettingsView(),
          AddTokenManuallyView.routeName: (context) => const AddTokenManuallyView(),
          QRScannerView.routeName: (context) => const QRScannerView(),
          LicenseView.routeName: (context) => LicenseView(
                appImage: _customization.appImage,
                appName: _customization.appName,
                websiteLink: _customization.websiteLink,
              ),
          PushTokensView.routeName: (context) => const PushTokensView(),
        },
      );
    });
  }
}
