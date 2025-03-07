/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../../../model/extensions/color_extension.dart';
import 'theme_extentions/action_theme.dart';
import 'theme_extentions/elevated_delete_button_theme.dart';
import 'theme_extentions/extended_text_theme.dart';
import 'theme_extentions/push_request_theme.dart';
import 'theme_extentions/status_colors.dart';

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
    required this.exportColor,
    required this.disabledColor,
    required this.tileIconColor,
    required this.navigationBarColor,
    required this.warningColor,
    required this.successColor,
    Color? pushAuthRequestAcceptColor,
    Color? pushAuthRequestDeclineColor,
    Color? actionButtonsForegroundColor,
    Color? tilePrimaryColor,
    Color? tileSubtitleColor,
    Color? navigationBarIconColor,
    Color? qrButtonBackgroundColor,
    Color? qrButtonIconColor,
  })  : _pushAuthRequestAcceptColor = pushAuthRequestAcceptColor,
        _pushAuthRequestDeclineColor = pushAuthRequestDeclineColor,
        _actionButtonsForegroundColor = actionButtonsForegroundColor,
        _tilePrimaryColor = tilePrimaryColor,
        _tileSubtitleColor = tileSubtitleColor,
        _navigationBarIconColor = navigationBarIconColor,
        _qrButtonBackgroundColor = qrButtonBackgroundColor,
        _qrButtonIconColor = qrButtonIconColor;

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
    Color? exportColor,
    Color? disabledColor,
    Color? tileIconColor,
    Color? navigationBarColor,
    Color? warningColor,
    Color? successColor,
    // From here on the colors have a default value based on another given color so they can be null
    Color? pushAuthRequestAcceptColor, // Default: primaryColor
    Color? pushAuthRequestDeclineColor, // Default: deleteColor
    Color? actionButtonsForegroundColor, // Default: foregroundColor
    Color? tilePrimaryColor, // Default: primaryColor
    Color? tileSubtitleColor, // Default: subtitleColor
    Color? navigationBarIconColor, // Default: foregroundColor
    Color? qrButtonBackgroundColor, // Default: primaryColor
    Color? qrButtonIconColor, // Default: onPrimary
  })  : brightness = Brightness.light,
        primaryColor = primaryColor ?? const Color(0xff03A9F4),
        onPrimary = onPrimary ?? const Color(0xff282828),
        subtitleColor = subtitleColor ?? const Color(0xff9E9E9E),
        backgroundColor = backgroundColor ?? const Color(0xffEFEFEF),
        foregroundColor = foregroundColor ?? const Color(0xff282828),
        shadowColor = shadowColor ?? const Color(0x4C303030),
        deleteColor = deleteColor ?? const Color(0xffe85e40),
        renameColor = renameColor ?? const Color(0xff7f9bdd),
        lockColor = lockColor ?? const Color(0xffffd633),
        exportColor = exportColor ?? const Color.fromARGB(255, 49, 197, 74),
        disabledColor = disabledColor ?? const Color(0xffAAAAAA),
        tileIconColor = tileIconColor ?? const Color(0xff757575),
        navigationBarColor = navigationBarColor ?? const Color(0xFFFFFFFF),
        warningColor = warningColor ?? const Color(0xFFFFB833),
        successColor = successColor ?? const Color(0xFF4CAF50),
        // From here on the colors have a default value based on another given color so they can be null
        _pushAuthRequestAcceptColor = pushAuthRequestAcceptColor,
        _pushAuthRequestDeclineColor = pushAuthRequestDeclineColor,
        _actionButtonsForegroundColor = actionButtonsForegroundColor,
        _tilePrimaryColor = tilePrimaryColor,
        _tileSubtitleColor = tileSubtitleColor,
        _navigationBarIconColor = navigationBarIconColor,
        _qrButtonBackgroundColor = qrButtonBackgroundColor,
        _qrButtonIconColor = qrButtonIconColor;

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
    Color? disabledColor,
    Color? exportColor,
    Color? tileIconColor,
    Color? navigationBarColor,
    Color? warningColor,
    Color? successColor,
    // From here on the colors have a default value based on another given color so they can be null
    Color? pushAuthRequestAcceptColor, // Default: primaryColor
    Color? pushAuthRequestDeclineColor, // Default: deleteColor
    Color? actionButtonsForegroundColor, // Default: foregroundColor
    Color? tilePrimaryColor, // Default: primaryColor
    Color? tileSubtitleColor, // Default: subtitleColor
    Color? navigationBarIconColor, // Default: foregroundColor
    Color? qrButtonBackgroundColor, // Default: primaryColor
    Color? qrButtonIconColor, // Default: onPrimary
  })  : brightness = Brightness.dark,
        primaryColor = primaryColor ?? const Color(0xff03A9F4),
        onPrimary = onPrimary ?? const Color(0xFF282828),
        subtitleColor = subtitleColor ?? const Color(0xFF9E9E9E),
        backgroundColor = backgroundColor ?? const Color(0xFF303030),
        foregroundColor = foregroundColor ?? const Color(0xffF5F5F5),
        shadowColor = shadowColor ?? const Color(0x4CEFEFEF),
        deleteColor = deleteColor ?? const Color(0xffb93f1d),
        renameColor = renameColor ?? const Color(0xff4a72c6),
        lockColor = lockColor ?? const Color(0xffe4ba11),
        exportColor = exportColor ?? const Color.fromARGB(255, 36, 148, 45),
        disabledColor = disabledColor ?? const Color(0x4C303030),
        tileIconColor = tileIconColor ?? const Color(0xffF5F5F5),
        navigationBarColor = navigationBarColor ?? const Color(0xFF282828),
        warningColor = warningColor ?? const Color(0xFFFFB833),
        successColor = successColor ?? const Color(0xFF4CAF50),
        // From here on the colors have a default value based on another given color so they can be null
        _pushAuthRequestAcceptColor = pushAuthRequestAcceptColor,
        _pushAuthRequestDeclineColor = pushAuthRequestDeclineColor,
        _actionButtonsForegroundColor = actionButtonsForegroundColor,
        _tilePrimaryColor = tilePrimaryColor,
        _tileSubtitleColor = tileSubtitleColor,
        _navigationBarIconColor = navigationBarIconColor,
        _qrButtonBackgroundColor = qrButtonBackgroundColor,
        _qrButtonIconColor = qrButtonIconColor;

  final Brightness brightness;

  // Basic colors
  final Color primaryColor;
  final Color onPrimary;
  final Color subtitleColor;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color shadowColor;
  final Color warningColor;
  final Color successColor;

  // Push Request colors
  final Color? _pushAuthRequestAcceptColor;
  Color get pushAuthRequestAcceptColor => _pushAuthRequestAcceptColor ?? primaryColor;
  final Color? _pushAuthRequestDeclineColor;
  Color get pushAuthRequestDeclineColor => _pushAuthRequestDeclineColor ?? deleteColor;

  // Slide action
  final Color deleteColor;
  final Color renameColor;
  final Color lockColor;
  final Color exportColor;
  final Color disabledColor;
  final Color? _actionButtonsForegroundColor; // Default: foregroundColor
  Color get actionButtonsForegroundColor => _actionButtonsForegroundColor ?? foregroundColor;

  // List tile
  final Color? _tilePrimaryColor; // Default: primaryColor
  Color get tilePrimaryColor => _tilePrimaryColor ?? primaryColor;
  final Color tileIconColor;
  final Color? _tileSubtitleColor; // Default: subtitleColor
  Color get tileSubtitleColor => _tileSubtitleColor ?? subtitleColor;

  // Navigation bar
  final Color navigationBarColor;
  final Color? _navigationBarIconColor; // Default: foregroundColor
  Color get navigationBarIconColor => _navigationBarIconColor ?? foregroundColor;
  final Color? _qrButtonBackgroundColor; // Default: primaryColor
  Color get qrButtonBackgroundColor => _qrButtonBackgroundColor ?? primaryColor;
  final Color? _qrButtonIconColor; // Default: onPrimary
  Color get qrButtonIconColor => _qrButtonIconColor ?? onPrimary;

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
    Color? exportColor,
    Color? disabledColor,
    Color? tileIconColor,
    Color? navigationBarColor,
    Color? warningColor,
    Color? successColor,
    // From here on the colors have a default value based on another given color so they can be null
    Color? Function()? pushAuthRequestAcceptColor, // Default: primaryColor
    Color? Function()? pushAuthRequestDeclineColor, // Default: deleteColor
    Color? Function()? actionButtonsForegroundColor, // Default: foregroundColor
    Color? Function()? tilePrimaryColor, // Default: primaryColor
    Color? Function()? tileSubtitleColor, // Default: subtitleColor
    Color? Function()? navigationBarIconColor, // Default: foregroundColor
    Color? Function()? qrButtonBackgroundColor, // Default: primaryColor
    Color? Function()? qrButtonIconColor, // Default: onPrimary
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
        exportColor: exportColor ?? this.exportColor,
        disabledColor: disabledColor ?? this.disabledColor,
        tileIconColor: tileIconColor ?? this.tileIconColor,
        navigationBarColor: navigationBarColor ?? this.navigationBarColor,
        warningColor: warningColor ?? this.warningColor,
        successColor: successColor ?? this.successColor,
        // From here on the colors have a default value based on another given color so they can be null
        pushAuthRequestAcceptColor: pushAuthRequestAcceptColor != null ? pushAuthRequestAcceptColor() : _pushAuthRequestAcceptColor,
        pushAuthRequestDeclineColor: pushAuthRequestDeclineColor != null ? pushAuthRequestDeclineColor() : _pushAuthRequestDeclineColor,
        actionButtonsForegroundColor: actionButtonsForegroundColor != null ? actionButtonsForegroundColor() : _actionButtonsForegroundColor,
        tilePrimaryColor: tilePrimaryColor != null ? tilePrimaryColor() : _tilePrimaryColor,
        tileSubtitleColor: tileSubtitleColor != null ? tileSubtitleColor() : _tileSubtitleColor,
        navigationBarIconColor: navigationBarIconColor != null ? navigationBarIconColor() : _navigationBarIconColor,
        qrButtonBackgroundColor: qrButtonBackgroundColor != null ? qrButtonBackgroundColor() : _qrButtonBackgroundColor,
        qrButtonIconColor: qrButtonIconColor != null ? qrButtonIconColor() : _qrButtonIconColor,
      );

  factory ThemeCustomization.fromJson(Map<String, dynamic> json) {
    bool isLightTheme = json['brightness'] == 'light';
    bool isDarkTheme = json['brightness'] == 'dark';
    if (json['brightness'] == null && json['primaryColor'] != null) {
      isLightTheme = _isColorBright(Color(json['primaryColor'] as int));
    }
    if (isLightTheme) {
      return ThemeCustomization.defaultLightWith(
        primaryColor: json['primaryColor'] != null ? Color(json['primaryColor'] as int) : null,
        onPrimary: json['onPrimary'] != null ? Color(json['onPrimary'] as int) : null,
        subtitleColor: json['subtitleColor'] != null ? Color(json['subtitleColor'] as int) : null,
        backgroundColor: json['backgroundColor'] != null ? Color(json['backgroundColor'] as int) : null,
        foregroundColor: json['foregroundColor'] != null ? Color(json['foregroundColor'] as int) : null,
        shadowColor: json['shadowColor'] != null ? Color(json['shadowColor'] as int) : null,
        deleteColor: json['deleteColor'] != null ? Color(json['deleteColor'] as int) : null,
        renameColor: json['renameColor'] != null ? Color(json['renameColor'] as int) : null,
        lockColor: json['lockColor'] != null ? Color(json['lockColor'] as int) : null,
        exportColor: json['exportColor'] != null ? Color(json['exportColor'] as int) : null,
        disabledColor: json['disabledColor'] != null ? Color(json['disabledColor'] as int) : null,
        tileIconColor: json['tileIconColor'] != null ? Color(json['tileIconColor'] as int) : null,
        navigationBarColor: json['navigationBarColor'] != null ? Color(json['navigationBarColor'] as int) : null,
        warningColor: json['warningColor'] != null ? Color(json['warningColor'] as int) : null,
        successColor: json['successColor'] != null ? Color(json['successColor'] as int) : null,
        pushAuthRequestAcceptColor: json['_pushAuthRequestAcceptColor'] != null ? Color(json['_pushAuthRequestAcceptColor'] as int) : null,
        pushAuthRequestDeclineColor: json['_pushAuthRequestDeclineColor'] != null ? Color(json['_pushAuthRequestDeclineColor'] as int) : null,
        actionButtonsForegroundColor: json['_actionButtonsForegroundColor'] != null ? Color(json['_actionButtonsForegroundColor'] as int) : null,
        tilePrimaryColor: json['_tilePrimaryColor'] != null ? Color(json['_tilePrimaryColor'] as int) : null,
        tileSubtitleColor: json['_tileSubtitleColor'] != null ? Color(json['_tileSubtitleColor'] as int) : null,
        navigationBarIconColor: json['_navigationBarIconColor'] != null ? Color(json['_navigationBarIconColor'] as int) : null,
        qrButtonBackgroundColor: json['_qrButtonBackgroundColor'] != null ? Color(json['_qrButtonBackgroundColor'] as int) : null,
        qrButtonIconColor: json['_qrButtonIconColor'] != null ? Color(json['_qrButtonIconColor'] as int) : null,
      );
    }
    if (isDarkTheme) {
      return ThemeCustomization.defaultDarkWith(
        primaryColor: json['primaryColor'] != null ? Color(json['primaryColor'] as int) : null,
        onPrimary: json['onPrimary'] != null ? Color(json['onPrimary'] as int) : null,
        subtitleColor: json['subtitleColor'] != null ? Color(json['subtitleColor'] as int) : null,
        backgroundColor: json['backgroundColor'] != null ? Color(json['backgroundColor'] as int) : null,
        foregroundColor: json['foregroundColor'] != null ? Color(json['foregroundColor'] as int) : null,
        shadowColor: json['shadowColor'] != null ? Color(json['shadowColor'] as int) : null,
        deleteColor: json['deleteColor'] != null ? Color(json['deleteColor'] as int) : null,
        renameColor: json['renameColor'] != null ? Color(json['renameColor'] as int) : null,
        lockColor: json['lockColor'] != null ? Color(json['lockColor'] as int) : null,
        exportColor: json['exportColor'] != null ? Color(json['exportColor'] as int) : null,
        disabledColor: json['disabledColor'] != null ? Color(json['disabledColor'] as int) : null,
        tileIconColor: json['tileIconColor'] != null ? Color(json['tileIconColor'] as int) : null,
        navigationBarColor: json['navigationBarColor'] != null ? Color(json['navigationBarColor'] as int) : null,
        warningColor: json['warningColor'] != null ? Color(json['warningColor'] as int) : null,
        successColor: json['successColor'] != null ? Color(json['successColor'] as int) : null,
        pushAuthRequestAcceptColor: json['_pushAuthRequestAcceptColor'] != null ? Color(json['_pushAuthRequestAcceptColor'] as int) : null,
        pushAuthRequestDeclineColor: json['_pushAuthRequestDeclineColor'] != null ? Color(json['_pushAuthRequestDeclineColor'] as int) : null,
        actionButtonsForegroundColor: json['_actionButtonsForegroundColor'] != null ? Color(json['_actionButtonsForegroundColor'] as int) : null,
        tilePrimaryColor: json['_tilePrimaryColor'] != null ? Color(json['_tilePrimaryColor'] as int) : null,
        tileSubtitleColor: json['_tileSubtitleColor'] != null ? Color(json['_tileSubtitleColor'] as int) : null,
        navigationBarIconColor: json['_navigationBarIconColor'] != null ? Color(json['_navigationBarIconColor'] as int) : null,
        qrButtonBackgroundColor: json['_qrButtonBackgroundColor'] != null ? Color(json['_qrButtonBackgroundColor'] as int) : null,
        qrButtonIconColor: json['_qrButtonIconColor'] != null ? Color(json['_qrButtonIconColor'] as int) : null,
      );
    }
    throw Exception('Invalid brightness value: ${json['brightness']}');
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
        'exportColor': exportColor.value,
        'disabledColor': disabledColor.value,
        'tileIconColor': tileIconColor.value,
        'navigationBarColor': navigationBarColor.value,
        'warningColor': warningColor.value,
        'successColor': successColor.value,
        '_pushAuthRequestAcceptColor': _pushAuthRequestAcceptColor?.value,
        '_actionButtonsForegroundColor': _actionButtonsForegroundColor?.value,
        '_tilePrimaryColor': _tilePrimaryColor?.value,
        '_tileSubtitleColor': _tileSubtitleColor?.value,
        '_navigationBarIconColor': _navigationBarIconColor?.value,
        '_qrButtonBackgroundColor': _qrButtonBackgroundColor?.value,
        '_qrButtonIconColor': _qrButtonIconColor?.value,
      };

  ThemeData generateTheme({String? fontFamily}) => ThemeData(
          useMaterial3: false,
          brightness: brightness,
          primaryColor: primaryColor,
          canvasColor: backgroundColor,
          textTheme: const TextTheme().copyWith(
            /// Original sheet from \flutter\lib\src\material\text_theme.dart
            ///
            ///
            /// | NAME           | SIZE |  WEIGHT |  SPACING |   Color     |
            /// |----------------|------|---------|----------|-------------|
            /// | displayLarge   | 96.0 | light   | -1.5     | foreground  |
            /// | displayMedium  | 60.0 | light   | -0.5     | foreground  |
            /// | displaySmall   | 48.0 | regular |  0.0     | foreground  |
            /// | headlineMedium | 34.0 | regular |  0.25    | foreground  |
            /// | headlineSmall  | 24.0 | regular |  0.0     | foreground  |
            /// | titleLarge     | 24.0 | medium  |  0.15    | primary     |
            /// | titleMedium    | 20.0 | medium  |  0.15    | primary     |
            /// | titleSmall     | 18.0 | medium  |  0.1     | foreground  |
            /// | bodyLarge      | 16.0 | regular |  0.5     | foreground  |
            /// | bodyMedium     | 14.0 | regular |  0.25    | foreground  |
            /// | bodySmall      | 12.0 | regular |  0.4     | subtitle    |
            /// | labelLarge     | 14.0 | medium  |  1.25    | foreground  |
            /// | labelSmall     | 12.0 | regular |  1.5     | foreground  |
            ///
            /// ...where "light" is `FontWeight.w300`, "regular" is `FontWeight.w400` and
            /// "medium" is `FontWeight.w500`.
            ///
            displayLarge: TextStyle(color: foregroundColor, fontFamily: fontFamily),
            displayMedium: TextStyle(color: foregroundColor, fontFamily: fontFamily),
            displaySmall: TextStyle(color: foregroundColor, fontFamily: fontFamily),
            headlineMedium: TextStyle(color: foregroundColor, fontFamily: fontFamily),
            headlineSmall: TextStyle(color: foregroundColor, fontFamily: fontFamily),
            titleLarge: TextStyle(color: primaryColor, fontFamily: fontFamily, fontSize: 24),
            titleMedium: TextStyle(color: primaryColor, fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w500),
            titleSmall: TextStyle(color: foregroundColor, fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(color: foregroundColor, fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400),
            bodyMedium: TextStyle(color: foregroundColor, fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400),
            bodySmall: TextStyle(color: subtitleColor, fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400),
            labelLarge: TextStyle(color: foregroundColor, fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500),
            labelSmall: TextStyle(color: foregroundColor, fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400),
          ),
          disabledColor: tileIconColor.withOpacity(0.38), // 38% opacity used for disabled icon buttons
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(foregroundColor),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: onPrimary,
              backgroundColor: primaryColor,
              disabledBackgroundColor: backgroundColor.mixWith(foregroundColor, 0.12),
              disabledForegroundColor: backgroundColor.mixWith(foregroundColor, 0.38),
              padding: const EdgeInsets.all(6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              shadowColor: shadowColor,
              elevation: 1.5,
            ),
          ),
          scaffoldBackgroundColor: backgroundColor,
          cardTheme: CardTheme(
            color: backgroundColor,
            shadowColor: shadowColor,
            elevation: 4,
            margin: const EdgeInsets.all(4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          cardColor: backgroundColor,
          shadowColor: shadowColor,
          // shadowColor: Colors.transparent,
          appBarTheme: const AppBarTheme().copyWith(
            backgroundColor: backgroundColor,
            shadowColor: shadowColor,
            foregroundColor: foregroundColor,
            elevation: 0,
            titleSpacing: 6,
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: foregroundColor),
            hintStyle: TextStyle(color: primaryColor),
            errorStyle: TextStyle(color: deleteColor),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: shadowColor),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: subtitleColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
          primaryIconTheme: IconThemeData(color: onPrimary),
          iconTheme: IconThemeData(color: foregroundColor),
          navigationBarTheme: const NavigationBarThemeData().copyWith(
            backgroundColor: navigationBarColor,
            shadowColor: shadowColor,
            iconTheme: WidgetStatePropertyAll(IconThemeData(color: navigationBarIconColor)),
            elevation: 3,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: qrButtonBackgroundColor,
            foregroundColor: qrButtonIconColor,
            elevation: 0,
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              overlayColor: WidgetStateColor.resolveWith((states) => foregroundColor.withOpacity(0.1)),
            ),
          ),
          listTileTheme: ListTileThemeData(
            tileColor: Colors.transparent,
            titleTextStyle: TextStyle(color: tilePrimaryColor),
            subtitleTextStyle: TextStyle(color: tileSubtitleColor, fontSize: 14), //bodyMedium fontSize
            iconColor: tileIconColor,
          ),
          colorScheme: brightness == Brightness.light
              ? ColorScheme.light(
                  primary: primaryColor,
                  secondary: primaryColor,
                  onPrimary: onPrimary,
                  onSecondary: onPrimary,
                  error: deleteColor,
                  errorContainer: deleteColor,
                )
              : ColorScheme.dark(
                  primary: primaryColor,
                  secondary: primaryColor,
                  onPrimary: onPrimary,
                  onSecondary: onPrimary,
                  error: deleteColor,
                  errorContainer: deleteColor,
                ),
          checkboxTheme: CheckboxThemeData(
            checkColor: WidgetStateProperty.resolveWith<Color?>((_) => onPrimary),
            fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return null;
              }
              if (states.contains(WidgetState.selected)) {
                return primaryColor;
              }
              return null;
            }),
          ),
          radioTheme: RadioThemeData(
            fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return null;
              }
              if (states.contains(WidgetState.selected)) {
                return primaryColor;
              }
              return null;
            }),
          ),
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return null;
              }
              if (states.contains(WidgetState.selected)) {
                return primaryColor;
              }
              return null;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return null;
              }
              if (states.contains(WidgetState.selected)) {
                return primaryColor;
              }
              return null;
            }),
          ),
          extensions: [
            ElevatedDeleteButtonTheme(
              style: ElevatedButton.styleFrom(
                backgroundColor: deleteColor,
                foregroundColor: onPrimary,
              ),
            ),
            ActionTheme(
              deleteColor: deleteColor,
              editColor: renameColor,
              lockColor: lockColor,
              transferColor: exportColor,
              disabledColor: disabledColor,
              foregroundColor: actionButtonsForegroundColor,
            ),
            ExtendedTextTheme(
              tokenTile: TextStyle(
                color: primaryColor,
              ),
              tokenTileSubtitle: TextStyle(
                color: tileSubtitleColor,
              ),
            ),
            PushRequestTheme(
              acceptColor: pushAuthRequestAcceptColor,
              declineColor: pushAuthRequestDeclineColor,
            ),
            StatusColors(
              error: deleteColor,
              warning: warningColor,
              success: successColor,
            ),
          ]);

  @override
  String toString() => 'ThemeCustomization('
      'brightness: $brightness, '
      'primaryColor: $primaryColor, '
      'onPrimary: $onPrimary, '
      'subtitleColor: $subtitleColor, '
      'backgroundColor: $backgroundColor, '
      'foregroundColor: $foregroundColor, '
      'shadowColor: $shadowColor, '
      'deleteColor: $deleteColor, '
      'renameColor: $renameColor, '
      'lockColor: $lockColor, '
      'exportColor: $exportColor, '
      'disabledColor: $disabledColor, '
      'tileIconColor: $tileIconColor, '
      'navigationBarColor: $navigationBarColor, '
      'warningColor: $warningColor, '
      'successColor: $successColor, '
      'actionButtonsForegroundColor: $actionButtonsForegroundColor, '
      '_actionButtonsForegroundColor: $_actionButtonsForegroundColor, '
      'tilePrimaryColor: $tilePrimaryColor, '
      '_tilePrimaryColor: $_tilePrimaryColor, '
      'tileSubtitleColor: $tileSubtitleColor, '
      '_tileSubtitleColor: $_tileSubtitleColor, '
      'navigationBarIconColor: $navigationBarIconColor, '
      '_navigationBarIconColor: $_navigationBarIconColor, '
      'qrButtonBackgroundColor: $qrButtonBackgroundColor, '
      '_qrButtonBackgroundColor: $_qrButtonBackgroundColor, '
      'qrButtonIconColor: $qrButtonIconColor'
      "_qrButtonIconColor: $_qrButtonIconColor,"
      ')';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ThemeCustomization &&
        other.brightness == brightness &&
        other.primaryColor == primaryColor &&
        other.onPrimary == onPrimary &&
        other.subtitleColor == subtitleColor &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.shadowColor == shadowColor &&
        other.deleteColor == deleteColor &&
        other.renameColor == renameColor &&
        other.lockColor == lockColor &&
        other.exportColor == exportColor &&
        other.disabledColor == disabledColor &&
        other.tileIconColor == tileIconColor &&
        other.navigationBarColor == navigationBarColor &&
        other.warningColor == warningColor &&
        other.successColor == successColor &&
        other.actionButtonsForegroundColor == actionButtonsForegroundColor &&
        other.tilePrimaryColor == tilePrimaryColor &&
        other.tileSubtitleColor == tileSubtitleColor &&
        other.navigationBarIconColor == navigationBarIconColor &&
        other.qrButtonBackgroundColor == qrButtonBackgroundColor &&
        other.qrButtonIconColor == qrButtonIconColor;
  }

  @override
  int get hashCode => Object.hashAll([
        brightness,
        primaryColor,
        onPrimary,
        subtitleColor,
        backgroundColor,
        foregroundColor,
        shadowColor,
        deleteColor,
        renameColor,
        lockColor,
        exportColor,
        disabledColor,
        tileIconColor,
        navigationBarColor,
        warningColor,
        successColor,
        actionButtonsForegroundColor,
        tilePrimaryColor,
        tileSubtitleColor,
        navigationBarIconColor,
        qrButtonBackgroundColor,
        qrButtonIconColor,
      ]);
}

// /// Calculate HSP and check if the primary color is bright or dark
// /// brightness  =  sqrt( .299 R^2 + .587 G^2 + .114 B^2 )
// /// c.f., http://alienryderflex.com/hsp.html
bool _isColorBright(Color color) {
  return sqrt(0.299 * pow(color.red, 2) + 0.587 * pow(color.green, 2) + 0.114 * pow(color.blue, 2)) > 150;
}
