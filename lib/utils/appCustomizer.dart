import 'package:flutter/material.dart';

class ApplicationCustomizer {

  // CHANGE APPLICATION NAME
  static final String appName = "privacyIDEA Authenticator";
  // Edit in android/app/src/main/AndroidManifest.xml file
  // <application
  //         android:label="app name">

  // Edit in ios/Runner/Info.plist file
  // <key>CFBundleName</key>
  // 	<string>app name</string>

  // CHANGE PACKAGENAME
  // Type in terminal
  // flutter pub run change_app_package_name:main new.package.name

  static final String websiteLink = 'https://netknights.it/';

  static final String appIcon = 'res/logo/app_logo_light.svg';

  // CHANGE LAUNCHER ICONS
  // Edit in pubspec.yaml file
  // flutter_icons:
  // android: true
  // ios: true
  // image_path: appIcon as string

  // Type in terminal
  // flutter pub run flutter_launcher_icons:main

  static final Color primaryColor = Colors.lightBlue;
  static final Color themeColorDark = Colors.black;
  static final Color themeColorLight = Colors.white;

  // Slideable action
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