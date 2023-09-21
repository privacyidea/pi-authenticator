import 'package:flutter/material.dart';

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

// Light Mode
// Logo hellblau: 		R94/G197/B237
// Zahlen blau: 		R94/G197/B237
// Kreis blau: 		R94/G197/B237

// Delete button Lila: 	R104/G96/B128
// Edit button türkis: 	R0/G128/B128
// Lock button blau: 	R94/G197/B237

// Decline button Lila: 	R104/G96/B128
// Accept button blau: 	R94/G197/B237
// Button sub hellblau: R94/G197/B237

// ————————————————————

// Dark Mode
// Logo hellblau: 		R94/G197/B237
// Zahlen hellblau: 	R94/G197/B237
// Kreis hellblau: 		R94/G197/B237

// Delete button Lila: 	R104/G96/B128
// Edit button türkis: 	R0/G128/B128
// Lock button blau: 	R94/G197/B237

// Decline button Lila: 	R104/G96/B128
// Accept button blau: 	R94/G197/B237
// Button sub hellblau: R94/G197/B237

  static const String appName = "GEOMAR Authenticator";
  static const String websiteLink = 'https://www.geomar.de/';
  static const String appLogo = 'res/logo/app_logo.jpg';
  static const String appIcon = 'res/logo/app_icon.png';

  static const Color primaryColorDark = Color.fromARGB(255, 94, 197, 237);
  static const Color primaryColorLight = Color(0xff01589D);
  static const Color themeColorDark = Color(0xFF282828);
  static const Color themeColorLight = Colors.white;

  static const Color backgroundColorDark = Color(0xFF303030);
  static const Color backgroundColorLight = Color(0xFFEFEFEF);

  // Slide action
  static const Color deleteColorDark = Color(0xff695F81);
  static const Color deleteColorLight = deleteColorDark;
  static const Color renameColorDark = Color(0xff017F7E);
  static const Color renameColorLight = renameColorDark;
  static const Color lockColorDark = Color(0xff01589D);
  static const Color lockColorLight = lockColorDark;

  static const Color acceptColorDark = Color(0xff01589D);
  static const Color onAcceptColorDark = backgroundColorDark;
  static const Color acceptColorLight = acceptColorDark;
  static const Color onAcceptColorLight = onAcceptColorDark;
  static const Color declineColorDark = Color(0xff695F81);
  static const Color onDeclineColorDark = backgroundColorDark;
  static const Color declineColorLight = declineColorDark;
  static const Color onDeclineColorLight = onDeclineColorDark;

  static const Color actionButtonForegroundDark = Colors.white;
  static const Color actionButtonForegroundLight = Colors.white;

  static const Color floatingActionButtonColorDark = primaryColorDark;
  static const Color floatingActionButtonForegroundColorDark = themeColorDark;
  static const Color floatingActionButtonColorLight = primaryColorDark;
  static const Color floatingActionButtonForegroundColorLight = themeColorDark;

  static const Color buttonColorDark = primaryColorDark;
  static const Color buttonColorLight = Color(0xff01589D);
  static const Color textColorDark = primaryColorDark;
  static const Color textColorLight = Color(0xff01589D);
  static const Color timerColorDark = primaryColorDark;
  static const Color timerColorLight = Color(0xff01589D);

  // List tile
  static const Color tileIconColorLight = Color(0xff9E9E9E);
  static const Color tileSubtitleColorLight = Color(0xff757575);
  static const Color tileIconColorDark = Color(0xffF5F5F5);
  static const Color tileSubtitleColorDark = Color(0xff9E9E9E);
}
