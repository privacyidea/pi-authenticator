/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2020 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'package:catcher/catcher.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:privacyidea_authenticator/screens/main_screen.dart';
import 'package:privacyidea_authenticator/screens/settings_screen.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/customizations.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/widgets/CustomPageReportMode.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'widgets/CustomEmailManualHandler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  CatcherOptions debugOptions = CatcherOptions(SilentReportMode(), [
    ConsoleHandler(
        enableApplicationParameters: false,
        enableDeviceParameters: false,
        enableCustomParameters: false,
        enableStackTrace: true)
  ]);

  CatcherOptions releaseOptions = CatcherOptions(CustomPageReportMode(), [
    CustomEmailManualHandler([defaultCrashReportRecipient],
        enableCustomParameters: false)
  ]);

  Catcher(
    rootWidget: PrivacyIDEAAuthenticator(
        preferences: await StreamingSharedPreferences.instance),
    debugConfig: debugOptions,
    releaseConfig: releaseOptions,
  );
}

class PrivacyIDEAAuthenticator extends StatelessWidget {
  final StreamingSharedPreferences _preferences;

  const PrivacyIDEAAuthenticator({StreamingSharedPreferences preferences})
      : this._preferences = preferences;

  static List<Locale> _supportedLocales = [
    const Locale('en', ''),
    const Locale('de', ''),
    const Locale('fr', '')
  ];

  static set supportedLocales(List<Locale> supportedLocales) {
    _supportedLocales = supportedLocales;
  }

  @override
  Widget build(BuildContext context) {
    return AppSettings(
      preferences: this._preferences,
      child: DynamicTheme(
          defaultBrightness: Brightness.light,
          data: (brightness) => getApplicationTheme(brightness),
          themedWidgetBuilder: (context, theme) {
            var crashReportRecipients =
                AppSettings.of(context).crashReportRecipients;

            // Override release config to use custom e-mail recipients
            Catcher.instance.updateConfig(
              releaseConfig: CatcherOptions(CustomPageReportMode(), [
                CustomEmailManualHandler(crashReportRecipients,
                    enableCustomParameters: false)
              ]),
            );

            return MaterialApp(
              navigatorKey: Catcher.navigatorKey,
              // Needed to display dialogs etc.
              localizationsDelegates: [
                const MyLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                DefaultCupertinoLocalizations.delegate,
              ],
              supportedLocales: _supportedLocales,
              title: applicationName,
              theme: theme,
              darkTheme: getApplicationTheme(Brightness.dark),
              home: MainScreen(title: applicationName),
            );
          }),
    );
  }
}
