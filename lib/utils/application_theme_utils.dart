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

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

import 'customizations.dart';

Color getHighlightColor(bool isDark) {
  return isDark ? DARK_ACCENT_COLOR : PRIMARY_COLOR;
}

/// Builds the theme of this application, the theme is dependent on the
/// brightness of the device, when brightness == dark the dark theme of this
/// app is returned, otherwise the light theme is returned.
ThemeData getApplicationTheme(Brightness brightness) {
  bool isDark = brightness == Brightness.dark;
  ThemeData thisThemeData = isDark ? ThemeData.dark() : ThemeData.light();

  final Color primaryColor = isDark ? Colors.black : PRIMARY_COLOR;
  final Color accentColor = isDark ? DARK_ACCENT_COLOR : primaryColor;

  final FloatingActionButtonThemeData floatingActionButtonThemeData =
      FloatingActionButtonThemeData(backgroundColor: accentColor);

  final ButtonThemeData buttonTheme = ButtonThemeData(
    textTheme: ButtonTextTheme.primary,
    colorScheme: thisThemeData.buttonTheme.colorScheme.copyWith(
      primary: accentColor,
    ),
  );

  return thisThemeData.copyWith(
    primaryColor: primaryColor,
    accentColor: accentColor,
    toggleableActiveColor: accentColor,
    floatingActionButtonTheme: floatingActionButtonThemeData,
    buttonTheme: buttonTheme,
  );
}

TextStyle getDialogTextStyle(bool isDark) =>
    TextStyle(color: isDark ? Colors.white : Colors.black);

/// This method returns the input color with a slightly lower alpha value if
/// isDark == true, otherwise the method returns input. This is used to make
/// colors less bright in dark mode of the app.
Color getTonedColor(Color input, bool isDark) {
  double f = 0.8;

  return isDark
      ? Color.fromARGB(input.alpha, (input.red * f).round(),
          (input.green * f).round(), (input.blue * f).round())
      : input;
}

/// Evaluates if the application is in dark mode, that is the case if the dark
/// theme is selected in the settings, or if the device enabled the system wide
/// dark mode.
bool isDarkModeOn(BuildContext context) =>
    DynamicTheme.of(context).brightness == Brightness.dark ||
    MediaQuery.of(context).platformBrightness == Brightness.dark;

/// Default scale for Text() that is used inside AppBar() as title, this
/// guarantees that the application name fits in the app bar.
double get screenTitleScaleFactor => 0.95;
