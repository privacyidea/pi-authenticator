/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

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

// var primarySwatch = PRIMARY_COLOR; // TODO Use this when customizing
Color primarySwatch = Colors.lightBlue;
Color onPrimary = isColorBright(primarySwatch) ? Colors.black : Colors.white;

var lightThemeData = new ThemeData(
  toggleableActiveColor: primarySwatch,
  brightness: Brightness.light,
  primaryColorLight: primarySwatch,
  primaryColorDark: primarySwatch,
  appBarTheme:
      AppBarTheme().copyWith(backgroundColor: Colors.transparent, elevation: 0),
  colorScheme: ColorScheme.light(
    primary: primarySwatch,
    secondary: primarySwatch,
    onPrimary: onPrimary,
    onSecondary: onPrimary,
  ),
  iconTheme: IconThemeData(color: Colors.black),
);

var darkThemeData = ThemeData(
  scaffoldBackgroundColor: Color(0xFF303030),
  toggleableActiveColor: primarySwatch,
  brightness: Brightness.dark,
  primaryColorLight: primarySwatch,
  primaryColorDark: primarySwatch,
  appBarTheme:
      AppBarTheme().copyWith(backgroundColor: Colors.transparent, elevation: 0),
  colorScheme: ColorScheme.dark(
    primary: primarySwatch,
    secondary: primarySwatch,
    onPrimary: onPrimary,
    onSecondary: onPrimary,
  ),
  iconTheme: IconThemeData(color: Colors.white),
);

/// Calculate HSP and check if the primary color is bright or dark
/// brightness  =  sqrt( .299 R^2 + .587 G^2 + .114 B^2 )
/// c.f., http://alienryderflex.com/hsp.html
bool isColorBright(Color color) {
  return math.sqrt(0.299 * math.pow(color.red, 2) +
          0.587 * math.pow(color.green, 2) +
          0.114 * math.pow(color.blue, 2)) >
      150;
}
