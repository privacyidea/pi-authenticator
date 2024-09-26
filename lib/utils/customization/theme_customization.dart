import 'dart:math';

import 'package:flutter/material.dart';

import 'theme_extentions/action_theme.dart';
import 'theme_extentions/extended_text_theme.dart';
import 'theme_extentions/push_request_theme.dart';

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
    required this.tileIconColor,
    required this.navigationBarColor,
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
    Color? tileIconColor,
    Color? navigationBarColor,
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
        shadowColor = shadowColor ?? const Color(0xff303030),
        deleteColor = deleteColor ?? const Color(0xffE04D2D),
        renameColor = renameColor ?? const Color(0xff6A8FE5),
        lockColor = lockColor ?? const Color(0xffFFD633),
        tileIconColor = tileIconColor ?? const Color(0xff757575),
        navigationBarColor = navigationBarColor ?? const Color(0xFFFFFFFF),
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
    Color? tileIconColor,
    Color? navigationBarColor,
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
        shadowColor = shadowColor ?? const Color(0xFFEFEFEF),
        deleteColor = deleteColor ?? const Color(0xffCD3C14),
        renameColor = renameColor ?? const Color(0xff527EDB),
        lockColor = lockColor ?? const Color(0xffFFCC00),
        tileIconColor = tileIconColor ?? const Color(0xffF5F5F5),
        navigationBarColor = navigationBarColor ?? const Color(0xFF282828),
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

  // Push Request colors
  final Color? _pushAuthRequestAcceptColor;
  Color get pushAuthRequestAcceptColor => _pushAuthRequestAcceptColor ?? primaryColor;
  final Color? _pushAuthRequestDeclineColor;
  Color get pushAuthRequestDeclineColor => _pushAuthRequestDeclineColor ?? deleteColor;

  // Slide action
  final Color deleteColor;
  final Color renameColor;
  final Color lockColor;
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
    Color? tileIconColor,
    Color? navigationBarColor,
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
        tileIconColor: tileIconColor ?? this.tileIconColor,
        navigationBarColor: navigationBarColor ?? this.navigationBarColor,
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
        tileIconColor: json['tileIconColor'] != null ? Color(json['tileIconColor'] as int) : null,
        navigationBarColor: json['navigationBarColor'] != null ? Color(json['navigationBarColor'] as int) : null,
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
        tileIconColor: json['tileIconColor'] != null ? Color(json['tileIconColor'] as int) : null,
        navigationBarColor: json['navigationBarColor'] != null ? Color(json['navigationBarColor'] as int) : null,
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
        'tileIconColor': tileIconColor.value,
        'navigationBarColor': navigationBarColor.value,
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
            /// Copied from \flutter\lib\src\material\text_theme.dart
            ///
            ///
            /// | NAME           | SIZE |  WEIGHT |  SPACING |             |
            /// |----------------|------|---------|----------|-------------|
            /// | displayLarge   | 96.0 | light   | -1.5     |             |
            /// | displayMedium  | 60.0 | light   | -0.5     |             |
            /// | displaySmall   | 48.0 | regular |  0.0     |             |
            /// | headlineMedium | 34.0 | regular |  0.25    |             |
            /// | headlineSmall  | 24.0 | regular |  0.0     |             |
            /// | titleLarge     | 24.0 | medium  |  0.15    |             |
            /// | titleMedium    | 20.0 | medium  |  0.15    |             |
            /// | titleSmall     | 16.0 | medium  |  0.1     |             |
            /// | bodyLarge      | 16.0 | regular |  0.5     |             |
            /// | bodyMedium     | 14.0 | regular |  0.25    |             |
            /// | bodySmall      | 12.0 | regular |  0.4     |             |
            /// | labelLarge     | 14.0 | medium  |  1.25    |             |
            /// | labelSmall     | 10.0 | regular |  1.5     |             |
            ///
            /// ...where "light" is `FontWeight.w300`, "regular" is `FontWeight.w400` and
            /// "medium" is `FontWeight.w500`.
            ///
            /// By default, text styles are initialized to match the 2018 Material Design
            /// specification as listed above. To provide backwards compatibility, the 2014
            /// specification is also available.
            displayLarge: TextStyle(color: foregroundColor, fontFamily: fontFamily),
            displayMedium: TextStyle(color: foregroundColor, fontFamily: fontFamily),
            displaySmall: TextStyle(color: foregroundColor, fontFamily: fontFamily),
            headlineMedium: TextStyle(color: foregroundColor, fontFamily: fontFamily),
            headlineSmall: TextStyle(color: foregroundColor, fontFamily: fontFamily),
            titleLarge: TextStyle(color: primaryColor, fontFamily: fontFamily, fontSize: 24),
            titleMedium: TextStyle(color: foregroundColor, fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w500),
            titleSmall: TextStyle(color: foregroundColor, fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(color: foregroundColor, fontFamily: fontFamily),
            bodyMedium: TextStyle(color: foregroundColor, fontFamily: fontFamily),
            bodySmall: TextStyle(color: subtitleColor, fontFamily: fontFamily),
            labelLarge: TextStyle(color: foregroundColor, fontFamily: fontFamily),
            labelSmall: TextStyle(color: foregroundColor, fontFamily: fontFamily),
          ),
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(foregroundColor),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: onPrimary,
              backgroundColor: primaryColor,
              padding: const EdgeInsets.all(6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              shadowColor: shadowColor,
              elevation: 1.5,
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
            subtitleTextStyle: TextStyle(color: tileSubtitleColor),
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
            ActionTheme(
              deleteColor: deleteColor,
              editColor: renameColor,
              lockColor: lockColor,
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
      'tileIconColor: $tileIconColor, '
      'navigationBarColor: $navigationBarColor, '
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
        other.actionButtonsForegroundColor == actionButtonsForegroundColor &&
        other.tilePrimaryColor == tilePrimaryColor &&
        other.tileIconColor == tileIconColor &&
        other.tileSubtitleColor == tileSubtitleColor &&
        other.navigationBarColor == navigationBarColor &&
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
        actionButtonsForegroundColor,
        tilePrimaryColor,
        tileIconColor,
        tileSubtitleColor,
        navigationBarColor,
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
