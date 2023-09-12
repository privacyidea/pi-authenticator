import 'dart:math';

import 'package:flutter/material.dart';

var applicationCustomizer = ApplicationCustomizer();

class ThemeCustomizer {
  const ThemeCustomizer({
    required this.onPrimary,
    required this.themeColor,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.deleteColor,
    required this.renameColor,
    required this.lockColor,
    required this.tileIconColor,
    required this.tileSubtitleColor,
    required this.shadowColor,
  });

  const ThemeCustomizer.defaultLightWith({
    Color? onPrimary,
    Color? themeColor,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? deleteColor,
    Color? renameColor,
    Color? lockColor,
    Color? tileIconColor,
    Color? tileSubtitleColor,
    Color? shadowColor,
  })  : onPrimary = onPrimary ?? const Color(0xFF282828),
        themeColor = themeColor ?? Colors.white,
        backgroundColor = backgroundColor ?? const Color(0xFFEFEFEF),
        foregroundColor = foregroundColor ?? const Color(0xff282828),
        deleteColor = deleteColor ?? const Color(0xffE04D2D),
        renameColor = renameColor ?? const Color(0xff6A8FE5),
        lockColor = lockColor ?? const Color(0xffFFD633),
        tileIconColor = tileIconColor ?? const Color(0xff9E9E9E),
        tileSubtitleColor = tileSubtitleColor ?? const Color(0xff757575),
        shadowColor = shadowColor ?? const Color(0xFF303030);

  const ThemeCustomizer.defaultDarkWith({
    Color? onPrimary,
    Color? themeColor,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? deleteColor,
    Color? renameColor,
    Color? lockColor,
    Color? tileIconColor,
    Color? tileSubtitleColor,
    Color? shadowColor,
  })  : onPrimary = onPrimary ?? const Color(0xFF282828),
        themeColor = themeColor ?? const Color(0xFF282828),
        backgroundColor = backgroundColor ?? const Color(0xFF303030),
        foregroundColor = foregroundColor ?? const Color(0xffF5F5F5),
        deleteColor = deleteColor ?? const Color(0xffCD3C14),
        renameColor = renameColor ?? const Color(0xff527EDB),
        lockColor = lockColor ?? const Color(0xffFFCC00),
        tileIconColor = tileIconColor ?? const Color(0xffF5F5F5),
        tileSubtitleColor = tileSubtitleColor ?? const Color(0xff9E9E9E),
        shadowColor = shadowColor ?? const Color(0xFFEFEFEF);

  final Color onPrimary;
  final Color themeColor;

  final Color backgroundColor;
  final Color foregroundColor;

  // Slide action
  final Color deleteColor;
  final Color renameColor;
  final Color lockColor;

  // List tile
  final Color tileIconColor;
  final Color tileSubtitleColor;

  final Color shadowColor;

  ThemeCustomizer copyWith({
    Color? onPrimary,
    Color? themeColor,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? deleteColor,
    Color? renameColor,
    Color? lockColor,
    Color? tileIconColor,
    Color? tileSubtitleColor,
    Color? shadowColor,
  }) =>
      ThemeCustomizer(
        onPrimary: onPrimary ?? this.onPrimary,
        themeColor: themeColor ?? this.themeColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        foregroundColor: foregroundColor ?? this.foregroundColor,
        deleteColor: deleteColor ?? this.deleteColor,
        renameColor: renameColor ?? this.renameColor,
        lockColor: lockColor ?? this.lockColor,
        tileIconColor: tileIconColor ?? this.tileIconColor,
        tileSubtitleColor: tileSubtitleColor ?? this.tileSubtitleColor,
        shadowColor: shadowColor ?? this.shadowColor,
      );
}

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

  final String appName;
  final String websiteLink;
  final Image appIcon;
  final ThemeCustomizer lightTheme;
  final ThemeCustomizer darkTheme;
  final Color primaryColor;

  ApplicationCustomizer({
    this.appName = "privacyIDEA Authenticator",
    this.websiteLink = 'https://netknights.it/',
    this.primaryColor = Colors.lightBlue,
    Image? appIcon,
    this.lightTheme = const ThemeCustomizer.defaultLightWith(),
    this.darkTheme = const ThemeCustomizer.defaultDarkWith(),
  }) : appIcon = appIcon ?? Image.asset('res/logo/app_logo_light.png');

  ApplicationCustomizer copyWith({
    String? appName,
    String? websiteLink,
    Image? appIcon,
    ThemeCustomizer? lightTheme,
    ThemeCustomizer? darkTheme,
    Color? primaryColor,
  }) =>
      ApplicationCustomizer(
        appName: appName ?? this.appName,
        websiteLink: websiteLink ?? this.websiteLink,
        appIcon: appIcon ?? this.appIcon,
        lightTheme: lightTheme ?? this.lightTheme,
        darkTheme: darkTheme ?? this.darkTheme,
        primaryColor: primaryColor ?? this.primaryColor,
      );

  ThemeData generateLightTheme() {
    return ThemeData(
        textTheme: const TextTheme().copyWith(
          bodyLarge: TextStyle(color: lightTheme.foregroundColor),
          bodyMedium: TextStyle(color: lightTheme.foregroundColor),
          titleMedium: TextStyle(color: lightTheme.foregroundColor),
          titleSmall: TextStyle(color: lightTheme.foregroundColor),
          displayLarge: TextStyle(color: lightTheme.foregroundColor),
          displayMedium: TextStyle(color: lightTheme.foregroundColor),
          displaySmall: TextStyle(color: lightTheme.foregroundColor),
          headlineMedium: TextStyle(color: lightTheme.foregroundColor),
          headlineSmall: TextStyle(color: lightTheme.foregroundColor),
          titleLarge: TextStyle(color: lightTheme.foregroundColor),
          bodySmall: TextStyle(color: lightTheme.tileSubtitleColor),
          labelLarge: TextStyle(color: lightTheme.foregroundColor),
          labelSmall: TextStyle(color: lightTheme.foregroundColor),
        ),
        scaffoldBackgroundColor: lightTheme.backgroundColor,
        brightness: Brightness.light,
        primaryColorLight: primaryColor,
        primaryColorDark: primaryColor,
        cardColor: lightTheme.backgroundColor,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: lightTheme.backgroundColor,
          shadowColor: lightTheme.shadowColor,
          foregroundColor: lightTheme.foregroundColor,
          elevation: 0,
        ),
        navigationBarTheme: const NavigationBarThemeData().copyWith(
          backgroundColor: lightTheme.themeColor,
          shadowColor: lightTheme.shadowColor,
          iconTheme: MaterialStatePropertyAll(IconThemeData(color: lightTheme.foregroundColor)),
          elevation: 3,
        ),
        listTileTheme: ListTileThemeData(
          tileColor: lightTheme.backgroundColor,
          titleTextStyle: TextStyle(color: primaryColor),
          subtitleTextStyle: TextStyle(color: lightTheme.tileSubtitleColor),
          iconColor: lightTheme.tileIconColor,
        ),
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: primaryColor,
          onPrimary: lightTheme.onPrimary,
          onSecondary: lightTheme.onPrimary,
          errorContainer: lightTheme.deleteColor,
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
        extensions: [
          ActionTheme(
            deleteColor: lightTheme.deleteColor,
            editColor: lightTheme.renameColor,
            lockColor: lightTheme.lockColor,
            foregroundColor: lightTheme.foregroundColor,
          ),
        ]);
  }

  ThemeData generateDarkTheme() {
    return ThemeData(
        textTheme: const TextTheme().copyWith(
          bodyLarge: TextStyle(color: darkTheme.foregroundColor),
          bodyMedium: TextStyle(color: darkTheme.foregroundColor),
          titleMedium: TextStyle(color: darkTheme.foregroundColor),
          titleSmall: TextStyle(color: darkTheme.foregroundColor),
          displayLarge: TextStyle(color: darkTheme.foregroundColor),
          displayMedium: TextStyle(color: darkTheme.foregroundColor),
          displaySmall: TextStyle(color: darkTheme.foregroundColor),
          headlineMedium: TextStyle(color: darkTheme.foregroundColor),
          headlineSmall: TextStyle(color: darkTheme.foregroundColor),
          titleLarge: TextStyle(color: darkTheme.foregroundColor),
          bodySmall: TextStyle(color: darkTheme.tileSubtitleColor),
          labelLarge: TextStyle(color: darkTheme.foregroundColor),
          labelSmall: TextStyle(color: darkTheme.foregroundColor),
        ),
        scaffoldBackgroundColor: darkTheme.backgroundColor,
        brightness: Brightness.dark,
        primaryColorLight: primaryColor,
        primaryColorDark: primaryColor,
        cardColor: darkTheme.backgroundColor,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: darkTheme.backgroundColor,
          shadowColor: darkTheme.shadowColor,
          foregroundColor: darkTheme.foregroundColor,
          elevation: 0,
        ),
        navigationBarTheme: const NavigationBarThemeData().copyWith(
          backgroundColor: darkTheme.themeColor,
          shadowColor: darkTheme.shadowColor,
          iconTheme: MaterialStatePropertyAll(IconThemeData(color: darkTheme.foregroundColor)),
          elevation: 3,
        ),
        listTileTheme: ListTileThemeData(
          tileColor: darkTheme.backgroundColor,
          titleTextStyle: TextStyle(color: primaryColor),
          subtitleTextStyle: TextStyle(color: darkTheme.tileSubtitleColor),
          iconColor: darkTheme.tileIconColor,
        ),
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: primaryColor,
          onPrimary: darkTheme.onPrimary,
          onSecondary: darkTheme.onPrimary,
          errorContainer: darkTheme.deleteColor,
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
        extensions: [
          ActionTheme(
            deleteColor: darkTheme.deleteColor,
            editColor: darkTheme.renameColor,
            lockColor: darkTheme.lockColor,
            foregroundColor: darkTheme.foregroundColor,
          ),
        ]);
  }
}

class ActionTheme extends ThemeExtension<ActionTheme> {
  final Color deleteColor;
  final Color editColor;
  final Color lockColor;
  final Color foregroundColor;
  const ActionTheme({
    required this.deleteColor,
    required this.editColor,
    required this.lockColor,
    required this.foregroundColor,
  });

  @override
  ThemeExtension<ActionTheme> lerp(covariant ActionTheme? other, double t) => ActionTheme(
        deleteColor: Color.lerp(deleteColor, other?.deleteColor, t) ?? deleteColor,
        editColor: Color.lerp(editColor, other?.editColor, t) ?? editColor,
        lockColor: Color.lerp(lockColor, other?.lockColor, t) ?? lockColor,
        foregroundColor: Color.lerp(foregroundColor, other?.foregroundColor, t) ?? foregroundColor,
      );

  @override
  ThemeExtension<ActionTheme> copyWith({Color? deleteColor, Color? renameColor, Color? lockColor, Color? foregroundColor}) => ActionTheme(
        deleteColor: deleteColor ?? this.deleteColor,
        editColor: renameColor ?? this.editColor,
        lockColor: lockColor ?? this.lockColor,
        foregroundColor: foregroundColor ?? this.foregroundColor,
      );
}

/// Calculate HSP and check if the primary color is bright or dark
/// brightness  =  sqrt( .299 R^2 + .587 G^2 + .114 B^2 )
/// c.f., http://alienryderflex.com/hsp.html
bool _isColorBright(Color color) {
  return sqrt(0.299 * pow(color.red, 2) + 0.587 * pow(color.green, 2) + 0.114 * pow(color.blue, 2)) > 150;
}
