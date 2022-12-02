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

  static final String appName = "privacyIDEA Authenticator";
  static final String websiteLink = 'https://netknights.it/';
  static final String appIcon = 'res/logo/app_logo_light.png';

  static final Color primaryColor = Colors.lightBlue;
  static final Color themeColorDark = Colors.black;
  static final Color themeColorLight = Colors.white;

  // Slide action
  static final Color deleteColorDark = Color(0xffCD3C14);
  static final Color deleteColorLight = deleteColorDark;
  static final Color renameColorDark = Color(0xff527EDB);
  static final Color renameColorLight = renameColorDark;
  static final Color lockColorDark = Color(0xffFFCC00);
  static final Color lockColorLight = lockColorDark;

  static final Color buttonColor = primaryColor;
  static final Color textColor = primaryColor;
  static final Color timerColor = primaryColor;
}
