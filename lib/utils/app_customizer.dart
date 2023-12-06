import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ThemeCustomization {
  static const ThemeCustomization defaultLightTheme = ThemeCustomization.defaultLightWith();
  static const ThemeCustomization defaultDarkTheme = ThemeCustomization.defaultDarkWith();

  const ThemeCustomization({
    required this.brightness,
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
  })  : brightness = Brightness.light,
        primaryColor = primaryColor ?? Colors.lightBlue,
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
  })  : brightness = Brightness.dark,
        primaryColor = primaryColor ?? Colors.lightBlue,
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

  final Brightness brightness;

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
    Brightness? brightness,
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
        brightness: brightness ?? this.brightness,
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

  factory ThemeCustomization.fromJson(Map<String, dynamic> json) {
    bool isLightTheme = json['brightness'] == 'light';
    if (json['brightness'] == null && json['primaryColor'] != null) {
      isLightTheme = _isColorBright(Color(json['primaryColor'] as int));
    }
    return isLightTheme
        ? ThemeCustomization.defaultLightWith(
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
          )
        : ThemeCustomization.defaultDarkWith(
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
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'brightness': brightness == Brightness.light ? 'light' : 'dark',
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

  ThemeData generateTheme() {
    return ThemeData(
        useMaterial3: false,
        brightness: brightness,
        textTheme: const TextTheme().copyWith(
          bodyLarge: TextStyle(color: foregroundColor),
          bodyMedium: TextStyle(color: foregroundColor),
          titleMedium: TextStyle(color: foregroundColor),
          titleSmall: TextStyle(color: foregroundColor),
          displayLarge: TextStyle(color: foregroundColor),
          displayMedium: TextStyle(color: foregroundColor),
          displaySmall: TextStyle(color: foregroundColor),
          headlineMedium: TextStyle(color: foregroundColor),
          headlineSmall: TextStyle(color: foregroundColor),
          titleLarge: TextStyle(color: foregroundColor),
          bodySmall: TextStyle(color: tileSubtitleColor),
          labelLarge: TextStyle(color: foregroundColor),
          labelSmall: TextStyle(color: foregroundColor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        scaffoldBackgroundColor: backgroundColor,
        cardColor: backgroundColor,
        shadowColor: shadowColor,
        // shadowColor: Colors.transparent,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: backgroundColor,
          shadowColor: shadowColor,
          foregroundColor: foregroundColor,
          elevation: 0,
        ),
        primaryIconTheme: IconThemeData(color: foregroundColor),
        navigationBarTheme: const NavigationBarThemeData().copyWith(
          backgroundColor: navigationBarColor,
          shadowColor: shadowColor,
          iconTheme: MaterialStatePropertyAll(IconThemeData(color: navigationBarIconColor ?? foregroundColor)),
          elevation: 3,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: qrButtonBackgroundColor ?? primaryColor,
          foregroundColor: qrButtonIconColor ?? onPrimary,
          elevation: 0,
        ),
        listTileTheme: ListTileThemeData(
          tileColor: backgroundColor,
          titleTextStyle: TextStyle(color: tilePrimaryColor ?? primaryColor),
          subtitleTextStyle: TextStyle(color: tileSubtitleColor ?? subtitleColor),
          iconColor: tileIconColor,
        ),
        colorScheme: brightness == Brightness.light
            ? ColorScheme.light(
                primary: primaryColor,
                secondary: primaryColor,
                onPrimary: onPrimary,
                onSecondary: onPrimary,
                errorContainer: deleteColor,
              )
            : ColorScheme.dark(
                primary: primaryColor,
                secondary: primaryColor,
                onPrimary: onPrimary,
                onSecondary: onPrimary,
                errorContainer: deleteColor,
              ),
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
            deleteColor: deleteColor,
            editColor: renameColor,
            lockColor: lockColor,
            foregroundColor: actionButtonsForegroundColor ?? foregroundColor,
          ),
        ]);
  }
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
  final Uint8List appIconUint8List;
  final Uint8List appImageUint8List;
  Image get appIcon => Image.memory(appIconUint8List);
  Image get appImage => Image.memory(appImageUint8List);
  final ThemeCustomization lightTheme;
  final ThemeCustomization darkTheme;

  static final defaultCustomization = ApplicationCustomization(
    appName: 'privacyIDEA Authenticator',
    websiteLink: 'https://netknights.it/',
    appIconUint8List: defaultIconUint8List,
    appImageUint8List: defaultImageUint8List,
    lightTheme: ThemeCustomization.defaultLightTheme,
    darkTheme: ThemeCustomization.defaultDarkTheme,
  );

  const ApplicationCustomization({
    required this.appName,
    required this.websiteLink,
    required this.appIconUint8List,
    required this.appImageUint8List,
    required this.lightTheme,
    required this.darkTheme,
  });

  ApplicationCustomization copyWith({
    String? appName,
    String? websiteLink,
    Uint8List? appIconUint8List,
    Uint8List? appImageUint8List,
    ThemeCustomization? lightTheme,
    ThemeCustomization? darkTheme,
    Color? primaryColor,
  }) =>
      ApplicationCustomization(
        appName: appName ?? this.appName,
        websiteLink: websiteLink ?? this.websiteLink,
        appIconUint8List: appIconUint8List ?? this.appIconUint8List,
        appImageUint8List: appImageUint8List ?? this.appImageUint8List,
        lightTheme: lightTheme ?? this.lightTheme,
        darkTheme: darkTheme ?? this.darkTheme,
      );

  ThemeData generateLightTheme() => lightTheme.generateTheme();

  ThemeData generateDarkTheme() => darkTheme.generateTheme();

  factory ApplicationCustomization.fromJson(Map<String, dynamic> json) => defaultCustomization.copyWith(
        appName: json['appName'] as String,
        websiteLink: json['websiteLink'] as String,
        appIconUint8List: json['appIconBASE64'] != null ? base64Decode(json['appIconBASE64']! as String) : null,
        appImageUint8List: json['appImageBASE64'] != null ? base64Decode(json['appImageBASE64'] as String) : null,
        lightTheme: ThemeCustomization.fromJson(json['lightTheme'] as Map<String, dynamic>),
        darkTheme: ThemeCustomization.fromJson(json['darkTheme'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'appName': appName,
      'websiteLink': websiteLink,
      'appIconBASE64': base64Encode(appIconUint8List),
      'appImageBASE64': base64Encode(appImageUint8List),
      'lightTheme': lightTheme.toJson(),
      'darkTheme': darkTheme.toJson(),
    };
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
bool _isColorBright(Color color) {
  return sqrt(0.299 * pow(color.red, 2) + 0.587 * pow(color.green, 2) + 0.114 * pow(color.blue, 2)) > 150;
}

final Uint8List defaultIconUint8List = base64Decode(
  "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",
);
final Uint8List defaultImageUint8List = base64Decode(
  "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",
);
