/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

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

import 'package:flutter/material.dart';

var lightPrim = Colors.blue.shade300;
var darkPrim = Colors.blue.shade900;

var lightThemeData = new ThemeData(
  primaryColor: lightPrim,
  textTheme: new TextTheme(button: TextStyle(color: Colors.white70)),
  brightness: Brightness.light,
  accentColor: lightPrim,
  toggleableActiveColor: lightPrim,
  colorScheme: ColorScheme.light(
    primary: lightPrim,
    primaryVariant: lightPrim,
    background: lightPrim.withOpacity(0.5),
    secondary: lightPrim,
    secondaryVariant: lightPrim,
  ),
);

var darkThemeData = ThemeData(
  primaryColor: darkPrim,
  textTheme: new TextTheme(button: TextStyle(color: Colors.black54)),
  brightness: Brightness.dark,
  accentColor: darkPrim,
  toggleableActiveColor: darkPrim,
  colorScheme: ColorScheme.dark(
    primary: darkPrim,
    primaryVariant: darkPrim,
    background: darkPrim.withOpacity(0.5),
    secondary: darkPrim,
    secondaryVariant: darkPrim,
  ),
);
