/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2020 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required b"y applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:async';

// import 'package:catcher/catcher.dart';
// import 'package:catcher/handlers/console_handler.dart';
// import 'package:catcher/mode/silent_report_mode.dart';
// import 'package:catcher/model/catcher_options.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/screens/main_screen.dart';
import 'package:privacyidea_authenticator/screens/onboarding_screen.dart';
import 'package:privacyidea_authenticator/screens/settings_screen.dart';
import 'package:privacyidea_authenticator/utils/appCustomizer.dart';
import 'package:privacyidea_authenticator/utils/customizations.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/themes.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'widgets/custom_catcher.dart';

void main() async {
  Logger.init(callback: () async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(PrivacyIDEAAuthenticator(preferences: await StreamingSharedPreferences.instance));
  });
}

class PrivacyIDEAAuthenticator extends StatelessWidget {
  final StreamingSharedPreferences _preferences;

  const PrivacyIDEAAuthenticator({required StreamingSharedPreferences preferences}) : this._preferences = preferences;

  @override
  Widget build(BuildContext context) {
    return EasyDynamicThemeWidget(
      child: AppSettings(
        preferences: this._preferences,
        child: Builder(
          builder: (context) {
            final settings = AppSettings.of(context);

            return StreamBuilder<bool>(
              stream: settings.streamUseSystemLocale(),
              builder: (context, snapshot) {
                bool useSystemLocale = true;
                if (snapshot.hasData) {
                  useSystemLocale = snapshot.data!;
                }

                return StreamBuilder<Locale>(
                  stream: settings.streamLocalePreference(),
                  builder: (context, snapshot) {
                    Locale? locale;
                    if (!useSystemLocale && snapshot.hasData) {
                      locale = snapshot.data!;
                    }

                    return MaterialApp(
                      debugShowCheckedModeBanner: true,
                      navigatorKey: Logger.navigatorKey,
                      localizationsDelegates: AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      locale: locale,
                      title: ApplicationCustomizer.appName,
                      theme: lightThemeData,
                      darkTheme: darkThemeData,
                      scaffoldMessengerKey: snackbarKey, // <= this
                      themeMode: EasyDynamicTheme.of(context).themeMode,
                      home: settings.isFirstRun ? OnboardingScreen() : MainScreen(title: ApplicationCustomizer.appName),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
