import 'dart:math';

import 'package:flutter/material.dart';

final applicationCustomizer = ApplicationCustomizer();

class ApplicationCustomizer {
  // Edit in android/app/src/main/AndroidManifest.xml file
  // <application android:label="app name">

  // Edit in ios/Runner/Info.plist file
  // <key>CFBundleName</key>
  // <string>app name</string>
  // <string>app name</string>

  // CHANGE PACKAGE NAME
  // Type in terminal
  // flutter pub run change_app_package_name:main new.package.name

  // CHANGE LAUNCHER ICONS
  // Edit in pubspec.yaml file
  // flutter_icons:
  // android: true
  // ios: true
  // image_path: appIcon as string

  // Terminal
  // flutter pub run flutter_launcher_icons:main

  // ----- CHANGE GOOGLE-SERVICES -----
  // Insert the new google-services.json with the package name of the new app
  // 1. Android: google-services.json is the file name
  // - /android/app/src/debug (add ".debug" to package_name)
  // - /android/app/src/release
  // 2. iOS: in /ios/ add the GoogleService-Info.plist

  final String appName = "privacyIDEA Authenticator";
  final String websiteLink = 'https://netknights.it/';
  final String appIcon = 'res/logo/app_logo_light.png';

  final Color primaryColor = Colors.lightBlue;
  final Color themeColorDark = const Color(0xFF282828);
  final Color themeColorLight = Colors.white;

  final Color backgroundColorDark = const Color(0xFF303030);
  final Color backgroundColorLight = const Color(0xFFEFEFEF);

  // Slide action
  final Color deleteColorDark = const Color(0xffCD3C14);
  final Color deleteColorLight = const Color(0xffE04D2D);
  final Color renameColorDark = const Color(0xff527EDB);
  final Color renameColorLight = const Color(0xff6A8FE5);
  final Color lockColorDark = const Color(0xffFFCC00);
  final Color lockColorLight = const Color(0xffFFD633);

  Color get buttonColor => primaryColor;
  Color get textColor => primaryColor;
  Color get timerColor => primaryColor;

  // List tile
  final Color tileIconColorLight = const Color(0xff9E9E9E);
  final Color tileSubtitleColorLight = const Color(0xff757575);
  final Color tileIconColorDark = const Color(0xffF5F5F5);
  final Color tileSubtitleColorDark = const Color(0xff9E9E9E);

  ThemeData generateLightTheme() {
    Color onPrimary = _isColorBright(primaryColor) ? themeColorDark : themeColorLight;
    return ThemeData(
      scaffoldBackgroundColor: backgroundColorLight,
      brightness: Brightness.light,
      primaryColorLight: primaryColor,
      primaryColorDark: primaryColor,
      cardColor: backgroundColorLight,
      appBarTheme: const AppBarTheme().copyWith(
        backgroundColor: backgroundColorLight,
        shadowColor: themeColorDark,
        elevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData().copyWith(
        backgroundColor: themeColorLight,
        shadowColor: themeColorDark,
        elevation: 6,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: backgroundColorLight,
        titleTextStyle: TextStyle(color: primaryColor),
        subtitleTextStyle: TextStyle(color: tileSubtitleColorLight),
        iconColor: tileIconColorLight,
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        onPrimary: onPrimary,
        onSecondary: onPrimary,
        errorContainer: deleteColorLight,
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
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
            return primaryColor;
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
            return primaryColor;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return null;
        }),
      ),
    );
  }

  ThemeData generateDarkTheme() {
    Color onPrimary = _isColorBright(primaryColor) ? themeColorDark : themeColorLight;
    return ThemeData(
      scaffoldBackgroundColor: backgroundColorDark,
      brightness: Brightness.dark,
      primaryColorLight: primaryColor,
      primaryColorDark: primaryColor,
      cardColor: backgroundColorDark,
      appBarTheme: const AppBarTheme().copyWith(
        backgroundColor: backgroundColorDark,
        shadowColor: themeColorLight,
        elevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData().copyWith(
        backgroundColor: themeColorDark,
        shadowColor: themeColorLight,
        elevation: 6,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: backgroundColorDark,
        titleTextStyle: TextStyle(color: primaryColor),
        subtitleTextStyle: TextStyle(color: tileSubtitleColorDark),
        iconColor: tileIconColorDark,
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        onPrimary: onPrimary,
        onSecondary: onPrimary,
        errorContainer: deleteColorDark,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
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
            return primaryColor;
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
            return primaryColor;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return null;
        }),
      ),
    );
  }
}

/// Calculate HSP and check if the primary color is bright or dark
/// brightness  =  sqrt( .299 R^2 + .587 G^2 + .114 B^2 )
/// c.f., http://alienryderflex.com/hsp.html
bool _isColorBright(Color color) {
  return sqrt(0.299 * pow(color.red, 2) + 0.587 * pow(color.green, 2) + 0.114 * pow(color.blue, 2)) > 150;
}
