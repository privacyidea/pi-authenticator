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
import 'package:privacyidea_authenticator/views/import_tokens_view/import_tokens_view.dart';
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
  static ApplicationCustomization? currentCustomization;
  final ApplicationCustomization _customization;
  PrivacyIDEAAuthenticator({required ApplicationCustomization customization, super.key}) : _customization = customization {
    // ignore: prefer_initializing_formals
    PrivacyIDEAAuthenticator.currentCustomization = customization;
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
          ImportTokensView.routeName: (context) => const ImportTokensView(),
        },
      );
    });
  }
}

final asd = {
  "services": [],
  "groups": [],
  "updatedAt": 1704707593763,
  "schemaVersion": 4,
  "appVersionCode": 5000012,
  "appVersionName": "5.2.0",
  "appOrigin": "android",
  "servicesEncrypted":
      "bYsJGv7/NtouTlW5UaJYzSqk9RYXP9Cm/5DaVM2/EAgtkG8kEhTaWd14LSNIFMC5gUDdJqVVj3+a3yCZvefqNKMaiYKVzGlH0K4hR6/4/G8oQIv1f99NSBSQOdK6off5HZvVqDF9qt7QX93A+UJD98htIriYO06BlwfTWqE/T7lwojvkjWYZpRfADNkX8LvVRaHbpuwVcqAzbYlI8IwCshuvwrFAYjc3oZwcKGWzvTD/C5jn62bME1JMusXAD9IvpR0JwBGcna8NkwljUUl6R8JRyFGufyev7BsrAp7LbLAYiwt0PzHH6QtMFz6x0T4J1sARLpmWo2d6iEnnDDGcBmtGL8W4seUm6Jfna8G+nRLNimHhjuMV0J9BZDSmkNAvbkV2EgtYxzaJxtL4a0X79b96J4yZ3P3+cCone980Mzk0nfhCm1rVtbfY77LIejE07NkPQ5FrdBv1PvDbIPLHXeuYRNIdOXeuRDIWi6FbhQEQXFxpu412a0Xct1MN1feTaEkD5/g7J6EFPVQQS66EtLO5267IAx7j+jSSI0teRHnh31uyUj0iV7714HVs+RjULRYOhOx9521vf1oo6Oqwz9tH0G/LOPEpcJ34HVwZ7ISN1izPsuecAgSBpNBJvAKM01ppNQEKVR3z1Se1y+vczUysutWTSJ02/ZdbK9wH89x89M4np3CG//QFFzFt:nOZO9zcCNezNWMlYKSPZBsszZg611F8VuExfvKDyCyUolmX3K8/JqDfkKLton+8P3M5PLkVUvE63KbXeYK6u1QjvPkBcKACpd5XHzNo6KfhQLLEG70IHaadkIIlDwtEf561yLShlA2ikdpkBek56FS/phDPWlvouVJI9UbZegA6Q+v7iISq28d9GG0H09PrpIzOIpDJf9ydpph2gpHURfetdw7NxSUhSIJkUtwRORBFVScAMNHtbynUE8YKK4wJl6YQbiZ722/hEKC+qs0Nc6DKjrK6UmoybYnAot1/fo5cYvtbclNiWTb5Rs0F8PtHx6LqpXnF9scBsiIX0qbSI0g==:DUIJGMeVRlnusjzl",
  "reference":
      "4eqmDnpv2Xhhyl7RUxSQQiHDP02vyO3Qbe1dAQDyfQTttKeLSbQI0fMiBbqEZpwqKJcyBy2OMsWAvBn3ASZcV3WRoWsLp/XL2iqr/4YsEM586Lh67RBTpnpFoYLEigxNlNLEzTQGiZ2KKzRA1RQU6Ts04dGwJCqvkRs0+0fy434Boi24LF5ycgEMlWmN2Q+PZS7gDJvc2eOxJX2KwBndfauBgp4PhtJoaTB8K37OhbCG+1YX3j3+lmUkZXX62/5l32YJ+r68ILvYteNswmVeKRXIG4t8DRD+PXX/WT0NkvAT0Lh30atcsFzP9bLNFJToeoqj2vfDdd/JMQZgJmL647JzEUq4AdzPIaCkchweMsA=:nOZO9zcCNezNWMlYKSPZBsszZg611F8VuExfvKDyCyUolmX3K8/JqDfkKLton+8P3M5PLkVUvE63KbXeYK6u1QjvPkBcKACpd5XHzNo6KfhQLLEG70IHaadkIIlDwtEf561yLShlA2ikdpkBek56FS/phDPWlvouVJI9UbZegA6Q+v7iISq28d9GG0H09PrpIzOIpDJf9ydpph2gpHURfetdw7NxSUhSIJkUtwRORBFVScAMNHtbynUE8YKK4wJl6YQbiZ722/hEKC+qs0Nc6DKjrK6UmoybYnAot1/fo5cYvtbclNiWTb5Rs0F8PtHx6LqpXnF9scBsiIX0qbSI0g==:xRDmAlDwnsQ64afI"
};
