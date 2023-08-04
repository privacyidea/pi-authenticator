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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/utils/app_customizer.dart';

//TODO Use this when customizing
Color primarySwatch = ApplicationCustomizer.primaryColor;
Color onPrimary = isColorBright(primarySwatch) ? ApplicationCustomizer.themeColorDark : ApplicationCustomizer.themeColorLight;

var lightThemeData = ThemeData(
  scaffoldBackgroundColor: ApplicationCustomizer.backgroundColorLight,
  brightness: Brightness.light,
  primaryColorLight: primarySwatch,
  primaryColorDark: primarySwatch,
  appBarTheme: const AppBarTheme().copyWith(backgroundColor: Colors.transparent, elevation: 0),
  listTileTheme: ListTileThemeData(
    tileColor: ApplicationCustomizer.backgroundColorLight,
    titleTextStyle: TextStyle(color: primarySwatch),
    subtitleTextStyle: const TextStyle(color: ApplicationCustomizer.tileSubtitleColorLight),
    iconColor: ApplicationCustomizer.tileIconColorLight,
  ),
  colorScheme: ColorScheme.light(
    primary: primarySwatch,
    secondary: primarySwatch,
    onPrimary: onPrimary,
    onSecondary: onPrimary,
  ),
  iconTheme: const IconThemeData(color: Colors.black),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return primarySwatch;
      }
      return null;
    }),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return primarySwatch;
      }
      return null;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return primarySwatch;
      }
      return null;
    }),
    trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return primarySwatch;
      }
      return null;
    }),
  ),
);

var darkThemeData = ThemeData(
  scaffoldBackgroundColor: ApplicationCustomizer.backgroundColorDark,
  brightness: Brightness.dark,
  primaryColorLight: primarySwatch,
  primaryColorDark: primarySwatch,
  appBarTheme: const AppBarTheme().copyWith(backgroundColor: Colors.transparent, elevation: 0),
  listTileTheme: ListTileThemeData(
    tileColor: ApplicationCustomizer.backgroundColorDark,
    titleTextStyle: TextStyle(color: primarySwatch),
    subtitleTextStyle: const TextStyle(color: ApplicationCustomizer.tileSubtitleColorDark),
    iconColor: ApplicationCustomizer.tileIconColorDark,
  ),
  colorScheme: ColorScheme.dark(
    primary: primarySwatch,
    secondary: primarySwatch,
    onPrimary: onPrimary,
    onSecondary: onPrimary,
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return primarySwatch;
      }
      return null;
    }),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return primarySwatch;
      }
      return null;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return primarySwatch;
      }
      return null;
    }),
    trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return primarySwatch;
      }
      return null;
    }),
  ),
);

/// Calculate HSP and check if the primary color is bright or dark
/// brightness  =  sqrt( .299 R^2 + .587 G^2 + .114 B^2 )
/// c.f., http://alienryderflex.com/hsp.html
bool isColorBright(Color color) {
  return math.sqrt(0.299 * math.pow(color.red, 2) + 0.587 * math.pow(color.green, 2) + 0.114 * math.pow(color.blue, 2)) > 150;
}
