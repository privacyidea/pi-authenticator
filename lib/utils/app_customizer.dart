import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ThemeCustomization {
  static const ThemeCustomization defaultLightTheme = ThemeCustomization.defaultLightWith();
  static const ThemeCustomization defaultDarkTheme = ThemeCustomization.defaultDarkWith();

  const ThemeCustomization({
    required this.primaryColor,
    required this.onPrimary,
    required this.subtitleColor,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.shadowColor,
    required this.deleteColor,
    required this.renameColor,
    required this.lockColor,
    required this.actionButtonsForegroundColor,
    required this.tilePrimaryColor,
    required this.tileIconColor,
    required this.tileSubtitleColor,
    required this.navigationBarColor,
    required this.navigationBarIconColor,
    required this.qrButtonBackgroundColor,
    required this.qrButtonIconColor,
  });

  const ThemeCustomization.defaultLightWith({
    Color? primaryColor,
    Color? onPrimary,
    Color? subtitleColor,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? shadowColor,
    Color? deleteColor,
    Color? renameColor,
    Color? lockColor,
    this.actionButtonsForegroundColor,
    this.tilePrimaryColor,
    Color? tileIconColor,
    this.tileSubtitleColor,
    Color? navigationBarColor,
    this.navigationBarIconColor,
    this.qrButtonBackgroundColor,
    this.qrButtonIconColor,
  })  : primaryColor = primaryColor ?? Colors.lightBlue,
        onPrimary = onPrimary ?? const Color(0xFF282828),
        subtitleColor = subtitleColor ?? const Color(0xFF9E9E9E),
        navigationBarColor = navigationBarColor ?? Colors.white,
        backgroundColor = backgroundColor ?? const Color(0xFFEFEFEF),
        foregroundColor = foregroundColor ?? const Color(0xff282828),
        shadowColor = shadowColor ?? const Color(0xFF303030),
        deleteColor = deleteColor ?? const Color(0xffE04D2D),
        renameColor = renameColor ?? const Color(0xff6A8FE5),
        lockColor = lockColor ?? const Color(0xffFFD633),
        tileIconColor = tileIconColor ?? const Color(0xff9E9E9E);

  const ThemeCustomization.defaultDarkWith({
    Color? primaryColor,
    Color? onPrimary,
    Color? subtitleColor,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? shadowColor,
    Color? deleteColor,
    Color? renameColor,
    Color? lockColor,
    this.actionButtonsForegroundColor,
    this.tilePrimaryColor,
    Color? tileIconColor,
    this.tileSubtitleColor,
    Color? navigationBarColor,
    this.navigationBarIconColor,
    this.qrButtonBackgroundColor,
    this.qrButtonIconColor,
  })  : primaryColor = primaryColor ?? Colors.lightBlue,
        onPrimary = onPrimary ?? const Color(0xFF282828),
        subtitleColor = subtitleColor ?? const Color(0xFF9E9E9E),
        backgroundColor = backgroundColor ?? const Color(0xFF303030),
        foregroundColor = foregroundColor ?? const Color(0xffF5F5F5),
        shadowColor = shadowColor ?? const Color(0xFFEFEFEF),
        deleteColor = deleteColor ?? const Color(0xffCD3C14),
        renameColor = renameColor ?? const Color(0xff527EDB),
        lockColor = lockColor ?? const Color(0xffFFCC00),
        tileIconColor = tileIconColor ?? const Color(0xffF5F5F5),
        navigationBarColor = navigationBarColor ?? const Color(0xFF282828);

  // Basic colors
  final Color primaryColor;
  final Color onPrimary;
  final Color subtitleColor;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color shadowColor;

  // Slide action
  final Color deleteColor;
  final Color renameColor;
  final Color lockColor;
  final Color? actionButtonsForegroundColor; // Default: foregroundColor

  // List tile
  final Color? tilePrimaryColor; // Default: primaryColor
  final Color tileIconColor;
  final Color? tileSubtitleColor; // Default: subtitleColor

  // Navigation bar
  final Color navigationBarColor;
  final Color? navigationBarIconColor; // Default: foregroundColor
  final Color? qrButtonBackgroundColor; // Default: primaryColor
  final Color? qrButtonIconColor; // Default: onPrimary

  ThemeCustomization copyWith({
    Color? primaryColor,
    Color? onPrimary,
    Color? subtitleColor,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? shadowColor,
    Color? deleteColor,
    Color? renameColor,
    Color? lockColor,
    Color? Function()? actionButtonsForegroundColor,
    Color? Function()? tilePrimaryColor,
    Color? tileIconColor,
    Color? Function()? tileSubtitleColor,
    Color? navigationBarColor,
    Color? Function()? navigationBarIconColor,
    Color? Function()? qrButtonBackgroundColor,
    Color? Function()? qrButtonIconColor,
  }) =>
      ThemeCustomization(
        primaryColor: primaryColor ?? this.primaryColor,
        onPrimary: onPrimary ?? this.onPrimary,
        subtitleColor: subtitleColor ?? this.subtitleColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        foregroundColor: foregroundColor ?? this.foregroundColor,
        shadowColor: shadowColor ?? this.shadowColor,
        deleteColor: deleteColor ?? this.deleteColor,
        renameColor: renameColor ?? this.renameColor,
        lockColor: lockColor ?? this.lockColor,
        actionButtonsForegroundColor: actionButtonsForegroundColor != null ? actionButtonsForegroundColor() : this.actionButtonsForegroundColor,
        tilePrimaryColor: tilePrimaryColor != null ? tilePrimaryColor() : this.tilePrimaryColor,
        tileIconColor: tileIconColor ?? this.tileIconColor,
        tileSubtitleColor: tileSubtitleColor != null ? tileSubtitleColor() : this.tileSubtitleColor,
        navigationBarColor: navigationBarColor ?? this.navigationBarColor,
        navigationBarIconColor: navigationBarIconColor != null ? navigationBarIconColor() : this.navigationBarIconColor,
        qrButtonBackgroundColor: qrButtonBackgroundColor != null ? qrButtonBackgroundColor() : this.qrButtonBackgroundColor,
        qrButtonIconColor: qrButtonIconColor != null ? qrButtonIconColor() : this.qrButtonIconColor,
      );

  factory ThemeCustomization.fromJsonDark(Map<String, dynamic> json) => ThemeCustomization.defaultDarkWith(
        primaryColor: json['primaryColor'] != null ? Color(json['primaryColor'] as int) : null,
        onPrimary: json['onPrimary'] != null ? Color(json['onPrimary'] as int) : null,
        subtitleColor: json['subtitleColor'] != null ? Color(json['subtitleColor'] as int) : null,
        backgroundColor: json['backgroundColor'] != null ? Color(json['backgroundColor'] as int) : null,
        foregroundColor: json['foregroundColor'] != null ? Color(json['foregroundColor'] as int) : null,
        shadowColor: json['shadowColor'] != null ? Color(json['shadowColor'] as int) : null,
        deleteColor: json['deleteColor'] != null ? Color(json['deleteColor'] as int) : null,
        renameColor: json['renameColor'] != null ? Color(json['renameColor'] as int) : null,
        lockColor: json['lockColor'] != null ? Color(json['lockColor'] as int) : null,
        actionButtonsForegroundColor: json['actionButtonsForegroundColor'] != null ? Color(json['actionButtonsForegroundColor'] as int) : null,
        tilePrimaryColor: json['tilePrimaryColor'] != null ? Color(json['tilePrimaryColor'] as int) : null,
        tileIconColor: json['tileIconColor'] != null ? Color(json['tileIconColor'] as int) : null,
        tileSubtitleColor: json['tileSubtitleColor'] != null ? Color(json['tileSubtitleColor'] as int) : null,
        navigationBarColor: json['navigationBarColor'] != null ? Color(json['navigationBarColor'] as int) : null,
        navigationBarIconColor: json['navigationBarIconColor'] != null ? Color(json['navigationBarIconColor'] as int) : null,
        qrButtonBackgroundColor: json['qrButtonBackgroundColor'] != null ? Color(json['qrButtonBackgroundColor'] as int) : null,
        qrButtonIconColor: json['qrButtonIconColor'] != null ? Color(json['qrButtonIconColor'] as int) : null,
      );

  factory ThemeCustomization.fromJsonLight(Map<String, dynamic> json) => ThemeCustomization.defaultLightWith(
        primaryColor: json['primaryColor'] != null ? Color(json['primaryColor'] as int) : null,
        onPrimary: json['onPrimary'] != null ? Color(json['onPrimary'] as int) : null,
        subtitleColor: json['subtitleColor'] != null ? Color(json['subtitleColor'] as int) : null,
        backgroundColor: json['backgroundColor'] != null ? Color(json['backgroundColor'] as int) : null,
        foregroundColor: json['foregroundColor'] != null ? Color(json['foregroundColor'] as int) : null,
        shadowColor: json['shadowColor'] != null ? Color(json['shadowColor'] as int) : null,
        deleteColor: json['deleteColor'] != null ? Color(json['deleteColor'] as int) : null,
        renameColor: json['renameColor'] != null ? Color(json['renameColor'] as int) : null,
        lockColor: json['lockColor'] != null ? Color(json['lockColor'] as int) : null,
        actionButtonsForegroundColor: json['actionButtonsForegroundColor'] != null ? Color(json['actionButtonsForegroundColor'] as int) : null,
        tilePrimaryColor: json['tilePrimaryColor'] != null ? Color(json['tilePrimaryColor'] as int) : null,
        tileIconColor: json['tileIconColor'] != null ? Color(json['tileIconColor'] as int) : null,
        tileSubtitleColor: json['tileSubtitleColor'] != null ? Color(json['tileSubtitleColor'] as int) : null,
        navigationBarColor: json['navigationBarColor'] != null ? Color(json['navigationBarColor'] as int) : null,
        navigationBarIconColor: json['navigationBarIconColor'] != null ? Color(json['navigationBarIconColor'] as int) : null,
        qrButtonBackgroundColor: json['qrButtonBackgroundColor'] != null ? Color(json['qrButtonBackgroundColor'] as int) : null,
        qrButtonIconColor: json['qrButtonIconColor'] != null ? Color(json['qrButtonIconColor'] as int) : null,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'primaryColor': primaryColor.value,
        'onPrimary': onPrimary.value,
        'subtitleColor': subtitleColor.value,
        'backgroundColor': backgroundColor.value,
        'foregroundColor': foregroundColor.value,
        'shadowColor': shadowColor.value,
        'deleteColor': deleteColor.value,
        'renameColor': renameColor.value,
        'lockColor': lockColor.value,
        'actionButtonsForegroundColor': actionButtonsForegroundColor?.value,
        'tilePrimaryColor': tilePrimaryColor?.value,
        'tileIconColor': tileIconColor.value,
        'tileSubtitleColor': tileSubtitleColor?.value,
        'navigationBarColor': navigationBarColor.value,
        'navigationBarIconColor': navigationBarIconColor?.value,
        'qrButtonBackgroundColor': qrButtonBackgroundColor?.value,
      };
}

class ApplicationCustomization {
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
  final Uint8List? appIconBASE64;
  final Uint8List? appImageBASE64;
  final Image appIcon;
  final Image appImage;
  final ThemeCustomization lightTheme;
  final ThemeCustomization darkTheme;

  static final defaultCustomization = ApplicationCustomization(
    appName: 'privacyIDEA Authenticator',
    websiteLink: 'https://netknights.it/',
    appIconBASE64: null,
    appImageBASE64: null,
    lightTheme: ThemeCustomization.defaultLightTheme,
    darkTheme: ThemeCustomization.defaultDarkTheme,
  );

  ApplicationCustomization({
    required this.appName,
    required this.websiteLink,
    this.appIconBASE64,
    this.appImageBASE64,
    required this.lightTheme,
    required this.darkTheme,
  })  : appIcon = appIconBASE64 != null ? Image.memory(appIconBASE64) : Image.asset('res/logo/app_logo_light_small.png'),
        appImage = appImageBASE64 != null ? Image.memory(appImageBASE64) : Image.asset('res/logo/app_logo_light.png');

  ApplicationCustomization copyWith({
    String? appName,
    String? websiteLink,
    Uint8List? appIconBASE64,
    Uint8List? appImageBASE64,
    ThemeCustomization? lightTheme,
    ThemeCustomization? darkTheme,
    Color? primaryColor,
  }) =>
      ApplicationCustomization(
        appName: appName ?? this.appName,
        websiteLink: websiteLink ?? this.websiteLink,
        appIconBASE64: appIconBASE64 ?? this.appIconBASE64,
        appImageBASE64: appImageBASE64 ?? this.appImageBASE64,
        lightTheme: lightTheme ?? this.lightTheme,
        darkTheme: darkTheme ?? this.darkTheme,
      );

  ThemeData generateLightTheme() => _generateTheme(lightTheme, Brightness.light);

  ThemeData generateDarkTheme() => _generateTheme(darkTheme, Brightness.dark);

  factory ApplicationCustomization.fromJson(Map<String, dynamic> json) => defaultCustomization.copyWith(
        appName: json['appName'] as String,
        websiteLink: json['websiteLink'] as String,
        appIconBASE64: json['appIconBASE64'] != null ? base64Decode(json['appIconBASE64'] as String) : null,
        appImageBASE64: json['appImageBASE64'] != null ? base64Decode(json['appImageBASE64'] as String) : null,
        lightTheme: ThemeCustomization.fromJsonLight(json['lightTheme'] as Map<String, dynamic>),
        darkTheme: ThemeCustomization.fromJsonDark(json['darkTheme'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'appName': appName,
      'websiteLink': websiteLink,
      'appIconBASE64': appIconBASE64 != null ? base64Encode(appIconBASE64!) : null,
      'appImageBASE64': appImageBASE64 != null ? base64Encode(appImageBASE64!) : null,
      'lightTheme': lightTheme.toJson(),
      'darkTheme': darkTheme.toJson(),
    };
  }
}

ThemeData _generateTheme(ThemeCustomization theme, Brightness brightness) {
  return ThemeData(
      brightness: brightness,
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
        bodySmall: TextStyle(color: theme.tileSubtitleColor),
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
      primaryIconTheme: IconThemeData(color: theme.foregroundColor),
      navigationBarTheme: const NavigationBarThemeData().copyWith(
        backgroundColor: theme.navigationBarColor,
        shadowColor: theme.shadowColor,
        iconTheme: MaterialStatePropertyAll(IconThemeData(color: theme.navigationBarIconColor ?? theme.foregroundColor)),
        elevation: 3,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: theme.qrButtonBackgroundColor ?? theme.primaryColor,
        foregroundColor: theme.qrButtonIconColor ?? theme.onPrimary,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: theme.backgroundColor,
        titleTextStyle: TextStyle(color: theme.tilePrimaryColor ?? theme.primaryColor),
        subtitleTextStyle: TextStyle(color: theme.tileSubtitleColor),
        iconColor: theme.tileIconColor,
      ),
      colorScheme: brightness == Brightness.light
          ? ColorScheme.light(
              primary: theme.primaryColor,
              secondary: theme.primaryColor,
              onPrimary: theme.onPrimary,
              onSecondary: theme.onPrimary,
              errorContainer: theme.deleteColor,
            )
          : ColorScheme.dark(
              primary: theme.primaryColor,
              secondary: theme.primaryColor,
              onPrimary: theme.onPrimary,
              onSecondary: theme.onPrimary,
              errorContainer: theme.deleteColor,
            ),
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
          foregroundColor: theme.actionButtonsForegroundColor ?? theme.foregroundColor,
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
