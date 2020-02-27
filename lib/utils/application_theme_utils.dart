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

ThemeData getApplicationTheme(Brightness brightness) {
  bool isDark = brightness == Brightness.dark;

//  final Color primaryColor = isDark ? Colors.black : Color(0xff03a8f4);
  final Color primaryColor = isDark ? Colors.black : Color(0xff03a8f4);
  final Color accentColor = isDark ? Color(0xff03f4c8) : primaryColor;

  final FloatingActionButtonThemeData floatingActionButtonThemeData =
      FloatingActionButtonThemeData(backgroundColor: accentColor);

  final ButtonThemeData buttonTheme = ButtonThemeData(
    textTheme: ButtonTextTheme.accent,
    colorScheme: ThemeData.dark().buttonTheme.colorScheme.copyWith(
          primary: accentColor,
          secondary: isDark ? Colors.black : Colors.white,
        ),
  );

  ThemeData thisTheme = isDark ? ThemeData.dark() : ThemeData.light();
  return thisTheme.copyWith(
    primaryColor: primaryColor,
    accentColor: accentColor,
    toggleableActiveColor: accentColor,
    floatingActionButtonTheme: floatingActionButtonThemeData,
    buttonTheme: buttonTheme,
  );
}

TextStyle getDialogTextStyle(bool isDark) =>
    TextStyle(color: isDark ? Colors.white : Colors.black);

Color getTonedColor(Color input, bool isDark) {
  double f = 0.8;

  return isDark
      ? Color.fromARGB(input.alpha, (input.red * f).round(),
          (input.green * f).round(), (input.blue * f).round())
      : input;
}

bool isDarkModeOn(BuildContext context) =>
    DynamicTheme.of(context).brightness == Brightness.dark ||
    MediaQuery.of(context).platformBrightness == Brightness.dark;

double get screenTitleScaleFactor => 0.95;
