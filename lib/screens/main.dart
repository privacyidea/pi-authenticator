/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

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

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:privacyidea_authenticator/screens/main_screen.dart';
import 'package:privacyidea_authenticator/utils/application_theme.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static List<Locale> _supportedLocales = [
    const Locale('en', ''),
    const Locale('de', ''),
  ];

  static set supportedLocales(List<Locale> supportedLocales) {
    _supportedLocales = supportedLocales;
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => getApplicationTheme(brightness),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            localizationsDelegates: [
              const MyLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: _supportedLocales,
            title: 'privacyIDEA Authenticator',
            theme: theme,
            home: MainScreen(title: 'privacyIDEA Authenticator'),
          );
        });
  }
}
