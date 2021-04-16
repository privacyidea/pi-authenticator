import 'package:flutter/material.dart';

var lightThemeData = new ThemeData(
    primaryColor: Colors.blue,
    textTheme: new TextTheme(button: TextStyle(color: Colors.white70)),
    brightness: Brightness.light,
    accentColor: Colors.blue);

var darkThemeData = ThemeData(
    primaryColor: Colors.blue,
    textTheme: new TextTheme(button: TextStyle(color: Colors.black54)),
    brightness: Brightness.dark,
    accentColor: Colors.blue);