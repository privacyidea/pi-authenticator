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

  static const String appName = "privacyIDEA Authenticator";
  static const String websiteLink = 'https://netknights.it/';
  static const String appIcon = 'res/logo/app_logo_light.png';

  static const Color primaryColor = Colors.lightBlue;
  static const Color themeColorDark = Colors.black;
  static const Color themeColorLight = Colors.white;

  static const Color backgroundColorDark = Color(0xFF303030);
  static const Color backgroundColorLight = Color(0xFFEFEFEF);

  // Slide action
  static const Color deleteColorDark = Color(0xffCD3C14);
  static const Color deleteColorLight = Color(0xffE04D2D);
  static const Color renameColorDark = Color(0xff527EDB);
  static const Color renameColorLight = Color(0xff6A8FE5);
  static const Color lockColorDark = Color(0xffFFCC00);
  static const Color lockColorLight = Color(0xffFFD633);

  static const Color buttonColor = primaryColor;
  static const Color textColor = primaryColor;
  static const Color timerColor = primaryColor;

  // List tile
  static const Color tileIconColorLight = Color(0xff9E9E9E);
  static const Color tileSubtitleColorLight = Color(0xff757575);
  static const Color tileIconColorDark = Color(0xffF5F5F5);
  static const Color tileSubtitleColorDark = Color(0xff9E9E9E);
}
