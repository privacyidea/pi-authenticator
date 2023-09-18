import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ThemeCustomizer {
  const ThemeCustomizer({
    required this.primaryColor,
    required this.onPrimary,
    required this.themeColor,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.deleteColor,
    required this.renameColor,
    required this.lockColor,
    required this.tileIconColor,
    required this.subtitleColor,
    required this.shadowColor,
  });

  const ThemeCustomizer.defaultLightWith({
    Color? primaryColor,
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
  })  : primaryColor = primaryColor ?? Colors.lightBlue,
        onPrimary = onPrimary ?? const Color(0xFF282828),
        themeColor = themeColor ?? Colors.white,
        backgroundColor = backgroundColor ?? const Color(0xFFEFEFEF),
        foregroundColor = foregroundColor ?? const Color(0xff282828),
        deleteColor = deleteColor ?? const Color(0xffE04D2D),
        renameColor = renameColor ?? const Color(0xff6A8FE5),
        lockColor = lockColor ?? const Color(0xffFFD633),
        tileIconColor = tileIconColor ?? const Color(0xff9E9E9E),
        subtitleColor = tileSubtitleColor ?? const Color(0xff757575),
        shadowColor = shadowColor ?? const Color(0xFF303030);

  const ThemeCustomizer.defaultDarkWith({
    Color? primaryColor,
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
  })  : primaryColor = primaryColor ?? Colors.lightBlue,
        onPrimary = onPrimary ?? const Color(0xFF282828),
        themeColor = themeColor ?? const Color(0xFF282828),
        backgroundColor = backgroundColor ?? const Color(0xFF303030),
        foregroundColor = foregroundColor ?? const Color(0xffF5F5F5),
        deleteColor = deleteColor ?? const Color(0xffCD3C14),
        renameColor = renameColor ?? const Color(0xff527EDB),
        lockColor = lockColor ?? const Color(0xffFFCC00),
        tileIconColor = tileIconColor ?? const Color(0xffF5F5F5),
        subtitleColor = tileSubtitleColor ?? const Color(0xff9E9E9E),
        shadowColor = shadowColor ?? const Color(0xFFEFEFEF);

  final Color primaryColor;
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
  final Color subtitleColor;

  final Color shadowColor;

  ThemeCustomizer copyWith({
    Color? primaryColor,
    Color? onPrimary,
    Color? themeColor,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? deleteColor,
    Color? renameColor,
    Color? lockColor,
    Color? tileIconColor,
    Color? subtitleColor,
    Color? shadowColor,
  }) =>
      ThemeCustomizer(
        primaryColor: primaryColor ?? this.primaryColor,
        onPrimary: onPrimary ?? this.onPrimary,
        themeColor: themeColor ?? this.themeColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        foregroundColor: foregroundColor ?? this.foregroundColor,
        deleteColor: deleteColor ?? this.deleteColor,
        renameColor: renameColor ?? this.renameColor,
        lockColor: lockColor ?? this.lockColor,
        tileIconColor: tileIconColor ?? this.tileIconColor,
        subtitleColor: subtitleColor ?? this.subtitleColor,
        shadowColor: shadowColor ?? this.shadowColor,
      );

  factory ThemeCustomizer.fromJson(Map<String, dynamic> json) => ThemeCustomizer(
        primaryColor: Color(json['primaryColor'] as int),
        onPrimary: Color(json['onPrimary'] as int),
        themeColor: Color(json['themeColor'] as int),
        backgroundColor: Color(json['backgroundColor'] as int),
        foregroundColor: Color(json['foregroundColor'] as int),
        deleteColor: Color(json['deleteColor'] as int),
        renameColor: Color(json['renameColor'] as int),
        lockColor: Color(json['lockColor'] as int),
        tileIconColor: Color(json['tileIconColor'] as int),
        subtitleColor: Color(json['subtitleColor'] as int),
        shadowColor: Color(json['shadowColor'] as int),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'primaryColor': primaryColor.value,
        'onPrimary': onPrimary.value,
        'themeColor': themeColor.value,
        'backgroundColor': backgroundColor.value,
        'foregroundColor': foregroundColor.value,
        'deleteColor': deleteColor.value,
        'renameColor': renameColor.value,
        'lockColor': lockColor.value,
        'tileIconColor': tileIconColor.value,
        'subtitleColor': subtitleColor.value,
        'shadowColor': shadowColor.value,
      };
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
  final Uint8List? appIconBytes;
  final Uint8List? appImageBytes;
  final Image appIcon;
  final Image appImage;
  final ThemeCustomizer lightTheme;
  final ThemeCustomizer darkTheme;

  ApplicationCustomizer({
    this.appName = "privacyIDEA Authenticator",
    this.websiteLink = 'https://netknights.it/',
    this.appIconBytes,
    this.appImageBytes,
    this.lightTheme = const ThemeCustomizer.defaultLightWith(),
    this.darkTheme = const ThemeCustomizer.defaultDarkWith(),
  })  : appIcon = appIconBytes != null ? Image.memory(appIconBytes) : Image.asset('res/logo/app_logo_light_small.png'),
        appImage = appImageBytes != null ? Image.memory(appImageBytes) : Image.asset('res/logo/app_logo_light.png');

  ApplicationCustomizer copyWith({
    String? appName,
    String? websiteLink,
    Uint8List? appIconBytes,
    Uint8List? appImageBytes,
    ThemeCustomizer? lightTheme,
    ThemeCustomizer? darkTheme,
    Color? primaryColor,
  }) =>
      ApplicationCustomizer(
        appName: appName ?? this.appName,
        websiteLink: websiteLink ?? this.websiteLink,
        appIconBytes: appIconBytes ?? this.appIconBytes,
        appImageBytes: appImageBytes ?? this.appImageBytes,
        lightTheme: lightTheme ?? this.lightTheme,
        darkTheme: darkTheme ?? this.darkTheme,
      );

  ThemeData generateLightTheme() => _generateTheme(lightTheme);

  ThemeData generateDarkTheme() => _generateTheme(darkTheme);

  factory ApplicationCustomizer.fromJson(Map<String, dynamic> json) => ApplicationCustomizer(
        appName: json['appName'] as String,
        websiteLink: json['websiteLink'] as String,
        appIconBytes: json['appIconBytes'] != null ? base64Decode(json['appIconBytes'] as String) : null,
        appImageBytes: json['appImageBytes'] != null ? base64Decode(json['appImageBytes'] as String) : null,
        lightTheme: ThemeCustomizer.fromJson(json['lightTheme'] as Map<String, dynamic>),
        darkTheme: ThemeCustomizer.fromJson(json['darkTheme'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'appName': appName,
      'websiteLink': websiteLink,
      'appIconBytes': appIconBytes != null ? base64Encode(appIconBytes!) : null,
      'appImageBytes': appImageBytes != null ? base64Encode(appImageBytes!) : null,
      'lightTheme': lightTheme.toJson(),
      'darkTheme': darkTheme.toJson(),
    };
  }
}

ThemeData _generateTheme(ThemeCustomizer theme) {
  return ThemeData(
      textTheme: const TextTheme().copyWith(
        bodyLarge: TextStyle(color: theme.foregroundColor),
        bodyMedium: TextStyle(color: theme.foregroundColor),
        titleMedium: TextStyle(color: theme.foregroundColor),
        titleSmall: TextStyle(color: theme.foregroundColor),
        displayLarge: TextStyle(color: theme.foregroundColor),
        displayMedium: TextStyle(color: theme.foregroundColor),
        displaySmall: TextStyle(color: theme.foregroundColor),
        headlineMedium: TextStyle(color: theme.foregroundColor),
        headlineSmall: TextStyle(color: theme.foregroundColor),
        titleLarge: TextStyle(color: theme.foregroundColor),
        bodySmall: TextStyle(color: theme.subtitleColor),
        labelLarge: TextStyle(color: theme.foregroundColor),
        labelSmall: TextStyle(color: theme.foregroundColor),
      ),
      scaffoldBackgroundColor: theme.backgroundColor,
      cardColor: theme.backgroundColor,
      appBarTheme: const AppBarTheme().copyWith(
        backgroundColor: theme.backgroundColor,
        shadowColor: theme.shadowColor,
        foregroundColor: theme.foregroundColor,
        elevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData().copyWith(
        backgroundColor: theme.themeColor,
        shadowColor: theme.shadowColor,
        iconTheme: MaterialStatePropertyAll(IconThemeData(color: theme.foregroundColor)),
        elevation: 3,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: theme.backgroundColor,
        titleTextStyle: TextStyle(color: theme.primaryColor),
        subtitleTextStyle: TextStyle(color: theme.subtitleColor),
        iconColor: theme.tileIconColor,
      ),
      colorScheme: ColorScheme.dark(
        primary: theme.primaryColor,
        secondary: theme.primaryColor,
        onPrimary: theme.onPrimary,
        onSecondary: theme.onPrimary,
        errorContainer: theme.deleteColor,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return theme.primaryColor;
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
            return theme.primaryColor;
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
            return theme.primaryColor;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return theme.primaryColor;
          }
          return null;
        }),
      ),
      extensions: [
        ActionTheme(
          deleteColor: theme.deleteColor,
          editColor: theme.renameColor,
          lockColor: theme.lockColor,
          foregroundColor: theme.foregroundColor,
        ),
      ]);
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
  ThemeExtension<ActionTheme> copyWith({Color? deleteColor, Color? editColor, Color? lockColor, Color? foregroundColor}) => ActionTheme(
        deleteColor: deleteColor ?? this.deleteColor,
        editColor: editColor ?? this.editColor,
        lockColor: lockColor ?? this.lockColor,
        foregroundColor: foregroundColor ?? this.foregroundColor,
      );
}

// /// Calculate HSP and check if the primary color is bright or dark
// /// brightness  =  sqrt( .299 R^2 + .587 G^2 + .114 B^2 )
// /// c.f., http://alienryderflex.com/hsp.html
// bool _isColorBright(Color color) {
//   return sqrt(0.299 * pow(color.red, 2) + 0.587 * pow(color.green, 2) + 0.114 * pow(color.blue, 2)) > 150;
// }
