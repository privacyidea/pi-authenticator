import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_customization.dart';

void main() {
  _testThemeCustomization();
}

void _testThemeCustomization() {
  group('Theme Customization Test', () {
    // Arrange
    const customization = ThemeCustomization(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF000000),
      onPrimary: Color(0xFF000001),
      subtitleColor: Color(0xFF000002),
      backgroundColor: Color(0xFF000003),
      foregroundColor: Color(0xFF000004),
      shadowColor: Color(0xFF000005),
      deleteColor: Color(0xFF000006),
      renameColor: Color(0xFF000007),
      lockColor: Color(0xFF000008),
      exportColor: Color(0xFF000009),
      disabledColor: Color(0xFF00000A),
      tileIconColor: Color(0xFF00000B),
      navigationBarColor: Color(0xFF00000C),
      actionButtonsForegroundColor: Color(0xFF00000D),
      tilePrimaryColor: Color(0xFF00000E),
      tileSubtitleColor: Color(0xFF00000F),
      navigationBarIconColor: Color(0xFF000010),
      qrButtonBackgroundColor: Color(0xFF000011),
      qrButtonIconColor: Color(0xFF000012),
    );
    test('constructor', () {
      // Assert
      expect(customization.brightness, equals(Brightness.dark));
      expect(customization.primaryColor, equals(const Color(0xFF000000)));
      expect(customization.onPrimary, equals(const Color(0xFF000001)));
      expect(customization.subtitleColor, equals(const Color(0xFF000002)));
      expect(customization.backgroundColor, equals(const Color(0xFF000003)));
      expect(customization.foregroundColor, equals(const Color(0xFF000004)));
      expect(customization.shadowColor, equals(const Color(0xFF000005)));
      expect(customization.deleteColor, equals(const Color(0xFF000006)));
      expect(customization.renameColor, equals(const Color(0xFF000007)));
      expect(customization.lockColor, equals(const Color(0xFF000008)));
      expect(customization.exportColor, equals(const Color(0xFF000009)));
      expect(customization.disabledColor, equals(const Color(0xFF00000A)));
      expect(customization.tileIconColor, equals(const Color(0xFF00000B)));
      expect(customization.navigationBarColor, equals(const Color(0xFF00000C)));
      expect(customization.actionButtonsForegroundColor, equals(const Color(0xFF00000D)));
      expect(customization.tilePrimaryColor, equals(const Color(0xFF00000E)));
      expect(customization.tileSubtitleColor, equals(const Color(0xFF00000F)));
      expect(customization.navigationBarIconColor, equals(const Color(0xFF000010)));
      expect(customization.qrButtonBackgroundColor, equals(const Color(0xFF000011)));
      expect(customization.qrButtonIconColor, equals(const Color(0xFF000012)));
    });
    test('copyWith', () {
      // Act
      final newCustomization = customization.copyWith(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFFFFFFF),
        onPrimary: const Color(0xFFFFFFFE),
        subtitleColor: const Color(0xFFFFFFFD),
        backgroundColor: const Color(0xFFFFFFFC),
        foregroundColor: const Color(0xFFFFFFFB),
        shadowColor: const Color(0xFFFFFFFA),
        deleteColor: const Color(0xFFFFFFF9),
        renameColor: const Color(0xFFFFFFF8),
        lockColor: const Color(0xFFFFFFF7),
        exportColor: const Color(0xFFFFFFF6),
        disabledColor: const Color(0xFFFFFFF5),
        tileIconColor: const Color(0xFFFFFFF4),
        navigationBarColor: const Color(0xFFFFFFF3),
        actionButtonsForegroundColor: () => const Color(0xFFFFFFF2),
        tilePrimaryColor: () => const Color(0xFFFFFFF1),
        tileSubtitleColor: () => const Color(0xFFFFFFF0),
        navigationBarIconColor: () => const Color(0xFFFFFFEF),
        qrButtonBackgroundColor: () => const Color(0xFFFFFFEE),
        qrButtonIconColor: () => const Color(0xFFFFFFED),
      );
      // Assert
      expect(newCustomization.brightness, equals(Brightness.light));
      expect(newCustomization.primaryColor, equals(const Color(0xFFFFFFFF)));
      expect(newCustomization.onPrimary, equals(const Color(0xFFFFFFFE)));
      expect(newCustomization.subtitleColor, equals(const Color(0xFFFFFFFD)));
      expect(newCustomization.backgroundColor, equals(const Color(0xFFFFFFFC)));
      expect(newCustomization.foregroundColor, equals(const Color(0xFFFFFFFB)));
      expect(newCustomization.shadowColor, equals(const Color(0xFFFFFFFA)));
      expect(newCustomization.deleteColor, equals(const Color(0xFFFFFFF9)));
      expect(newCustomization.renameColor, equals(const Color(0xFFFFFFF8)));
      expect(newCustomization.lockColor, equals(const Color(0xFFFFFFF7)));
      expect(newCustomization.exportColor, equals(const Color(0xFFFFFFF6)));
      expect(newCustomization.disabledColor, equals(const Color(0xFFFFFFF5)));
      expect(newCustomization.tileIconColor, equals(const Color(0xFFFFFFF4)));
      expect(newCustomization.navigationBarColor, equals(const Color(0xFFFFFFF3)));
      expect(newCustomization.actionButtonsForegroundColor, equals(const Color(0xFFFFFFF2)));
      expect(newCustomization.tilePrimaryColor, equals(const Color(0xFFFFFFF1)));
      expect(newCustomization.tileSubtitleColor, equals(const Color(0xFFFFFFF0)));
      expect(newCustomization.navigationBarIconColor, equals(const Color(0xFFFFFFEF)));
      expect(newCustomization.qrButtonBackgroundColor, equals(const Color(0xFFFFFFEE)));
      expect(newCustomization.qrButtonIconColor, equals(const Color(0xFFFFFFED)));
    });
    group('default themes', () {
      test('defaultLightWith', () {
        // Act
        const newCustomization = ThemeCustomization.defaultLightWith(
          primaryColor: Color(0xFFFFFFFF),
          onPrimary: Color(0xFFFFFFFE),
          subtitleColor: Color(0xFFFFFFFD),
          backgroundColor: Color(0xFFFFFFFC),
          foregroundColor: Color(0xFFFFFFFB),
          shadowColor: Color(0xFFFFFFFA),
          deleteColor: Color(0xFFFFFFF9),
          renameColor: Color(0xFFFFFFF8),
          lockColor: Color(0xFFFFFFF7),
          exportColor: Color(0xFFFFFFF6),
          disabledColor: Color(0xFFFFFFF5),
          tileIconColor: Color(0xFFFFFFF4),
          navigationBarColor: Color(0xFFFFFFF3),
          actionButtonsForegroundColor: Color(0xFFFFFFF2),
          tilePrimaryColor: Color(0xFFFFFFF1),
          tileSubtitleColor: Color(0xFFFFFFF0),
          navigationBarIconColor: Color(0xFFFFFFEF),
          qrButtonBackgroundColor: Color(0xFFFFFFEE),
          qrButtonIconColor: Color(0xFFFFFFED),
        );
        // Assert
        expect(newCustomization.brightness, equals(Brightness.light));
        expect(newCustomization.primaryColor, equals(const Color(0xFFFFFFFF)));
        expect(newCustomization.onPrimary, equals(const Color(0xFFFFFFFE)));
        expect(newCustomization.subtitleColor, equals(const Color(0xFFFFFFFD)));
        expect(newCustomization.backgroundColor, equals(const Color(0xFFFFFFFC)));
        expect(newCustomization.foregroundColor, equals(const Color(0xFFFFFFFB)));
        expect(newCustomization.shadowColor, equals(const Color(0xFFFFFFFA)));
        expect(newCustomization.deleteColor, equals(const Color(0xFFFFFFF9)));
        expect(newCustomization.renameColor, equals(const Color(0xFFFFFFF8)));
        expect(newCustomization.lockColor, equals(const Color(0xFFFFFFF7)));
        expect(newCustomization.exportColor, equals(const Color(0xFFFFFFF6)));
        expect(newCustomization.disabledColor, equals(const Color(0xFFFFFFF5)));
        expect(newCustomization.tileIconColor, equals(const Color(0xFFFFFFF4)));
        expect(newCustomization.navigationBarColor, equals(const Color(0xFFFFFFF3)));
        expect(newCustomization.actionButtonsForegroundColor, equals(const Color(0xFFFFFFF2)));
        expect(newCustomization.tilePrimaryColor, equals(const Color(0xFFFFFFF1)));
        expect(newCustomization.tileSubtitleColor, equals(const Color(0xFFFFFFF0)));
        expect(newCustomization.navigationBarIconColor, equals(const Color(0xFFFFFFEF)));
        expect(newCustomization.qrButtonBackgroundColor, equals(const Color(0xFFFFFFEE)));
        expect(newCustomization.qrButtonIconColor, equals(const Color(0xFFFFFFED)));
      });
      test('defaultDarkWith', () {
        // Act
        const newCustomization = ThemeCustomization.defaultDarkWith(
          primaryColor: Color(0xFFFFFFFF),
          onPrimary: Color(0xFFFFFFFE),
          subtitleColor: Color(0xFFFFFFFD),
          backgroundColor: Color(0xFFFFFFFC),
          foregroundColor: Color(0xFFFFFFFB),
          shadowColor: Color(0xFFFFFFFA),
          deleteColor: Color(0xFFFFFFF9),
          renameColor: Color(0xFFFFFFF8),
          lockColor: Color(0xFFFFFFF7),
          exportColor: Color(0xFFFFFFF6),
          disabledColor: Color(0xFFFFFFF5),
          tileIconColor: Color(0xFFFFFFF4),
          navigationBarColor: Color(0xFFFFFFF3),
          actionButtonsForegroundColor: Color(0xFFFFFFF2),
          tilePrimaryColor: Color(0xFFFFFFF1),
          tileSubtitleColor: Color(0xFFFFFFF0),
          navigationBarIconColor: Color(0xFFFFFFEF),
          qrButtonBackgroundColor: Color(0xFFFFFFEE),
          qrButtonIconColor: Color(0xFFFFFFED),
        );
        // Assert
        expect(newCustomization.brightness, equals(Brightness.dark));
        expect(newCustomization.primaryColor, equals(const Color(0xFFFFFFFF)));
        expect(newCustomization.onPrimary, equals(const Color(0xFFFFFFFE)));
        expect(newCustomization.subtitleColor, equals(const Color(0xFFFFFFFD)));
        expect(newCustomization.backgroundColor, equals(const Color(0xFFFFFFFC)));
        expect(newCustomization.foregroundColor, equals(const Color(0xFFFFFFFB)));
        expect(newCustomization.shadowColor, equals(const Color(0xFFFFFFFA)));
        expect(newCustomization.deleteColor, equals(const Color(0xFFFFFFF9)));
        expect(newCustomization.renameColor, equals(const Color(0xFFFFFFF8)));
        expect(newCustomization.lockColor, equals(const Color(0xFFFFFFF7)));
        expect(newCustomization.exportColor, equals(const Color(0xFFFFFFF6)));
        expect(newCustomization.disabledColor, equals(const Color(0xFFFFFFF5)));
        expect(newCustomization.tileIconColor, equals(const Color(0xFFFFFFF4)));
        expect(newCustomization.navigationBarColor, equals(const Color(0xFFFFFFF3)));
        expect(newCustomization.actionButtonsForegroundColor, equals(const Color(0xFFFFFFF2)));
        expect(newCustomization.tilePrimaryColor, equals(const Color(0xFFFFFFF1)));
        expect(newCustomization.tileSubtitleColor, equals(const Color(0xFFFFFFF0)));
        expect(newCustomization.navigationBarIconColor, equals(const Color(0xFFFFFFEF)));
        expect(newCustomization.qrButtonBackgroundColor, equals(const Color(0xFFFFFFEE)));
        expect(newCustomization.qrButtonIconColor, equals(const Color(0xFFFFFFED)));
      });
    });
    group('serialization', () {
      test('fromJson', () {
        // Act
        final newCustomization = ThemeCustomization.fromJson({
          'brightness': 'light',
          'primaryColor': 0xFFFFFFFF,
          'onPrimary': 0xFFFFFFFE,
          'subtitleColor': 0xFFFFFFFD,
          'backgroundColor': 0xFFFFFFFC,
          'foregroundColor': 0xFFFFFFFB,
          'shadowColor': 0xFFFFFFFA,
          'deleteColor': 0xFFFFFFF9,
          'renameColor': 0xFFFFFFF8,
          'lockColor': 0xFFFFFFF7,
          'exportColor': 0xFFFFFFF6,
          'disabledColor': 0xFFFFFFF5,
          'tileIconColor': 0xFFFFFFF4,
          'navigationBarColor': 0xFFFFFFF3,
          '_actionButtonsForegroundColor': 0xFFFFFFF2,
          '_tilePrimaryColor': 0xFFFFFFF1,
          '_tileSubtitleColor': 0xFFFFFFF0,
          '_navigationBarIconColor': 0xFFFFFFEF,
          '_qrButtonBackgroundColor': 0xFFFFFFEE,
          '_qrButtonIconColor': 0xFFFFFFED,
        });
        // Assert
        expect(newCustomization.brightness, equals(Brightness.light));
        expect(newCustomization.primaryColor, equals(const Color(0xFFFFFFFF)));
        expect(newCustomization.onPrimary, equals(const Color(0xFFFFFFFE)));
        expect(newCustomization.subtitleColor, equals(const Color(0xFFFFFFFD)));
        expect(newCustomization.backgroundColor, equals(const Color(0xFFFFFFFC)));
        expect(newCustomization.foregroundColor, equals(const Color(0xFFFFFFFB)));
        expect(newCustomization.shadowColor, equals(const Color(0xFFFFFFFA)));
        expect(newCustomization.deleteColor, equals(const Color(0xFFFFFFF9)));
        expect(newCustomization.renameColor, equals(const Color(0xFFFFFFF8)));
        expect(newCustomization.lockColor, equals(const Color(0xFFFFFFF7)));
        expect(newCustomization.exportColor, equals(const Color(0xFFFFFFF6)));
        expect(newCustomization.disabledColor, equals(const Color(0xFFFFFFF5)));
        expect(newCustomization.tileIconColor, equals(const Color(0xFFFFFFF4)));
        expect(newCustomization.navigationBarColor, equals(const Color(0xFFFFFFF3)));
        expect(newCustomization.actionButtonsForegroundColor, equals(const Color(0xFFFFFFF2)));
        expect(newCustomization.tilePrimaryColor, equals(const Color(0xFFFFFFF1)));
        expect(newCustomization.tileSubtitleColor, equals(const Color(0xFFFFFFF0)));
        expect(newCustomization.navigationBarIconColor, equals(const Color(0xFFFFFFEF)));
        expect(newCustomization.qrButtonBackgroundColor, equals(const Color(0xFFFFFFEE)));
        expect(newCustomization.qrButtonIconColor, equals(const Color(0xFFFFFFED)));
      });
      test('toJson', () {
        // Act
        final json = customization.toJson();
        // Assert
        expect(json['brightness'], equals('dark'));
        expect(json['primaryColor'], equals(0xFF000000));
        expect(json['onPrimary'], equals(0xFF000001));
        expect(json['subtitleColor'], equals(0xFF000002));
        expect(json['backgroundColor'], equals(0xFF000003));
        expect(json['foregroundColor'], equals(0xFF000004));
        expect(json['shadowColor'], equals(0xFF000005));
        expect(json['deleteColor'], equals(0xFF000006));
        expect(json['renameColor'], equals(0xFF000007));
        expect(json['lockColor'], equals(0xFF000008));
        expect(json['exportColor'], equals(0xFF000009));
        expect(json['disabledColor'], equals(0xFF00000A));
        expect(json['tileIconColor'], equals(0xFF00000B));
        expect(json['navigationBarColor'], equals(0xFF00000C));
        expect(json['_actionButtonsForegroundColor'], equals(0xFF00000D));
        expect(json['_tilePrimaryColor'], equals(0xFF00000E));
        expect(json['_tileSubtitleColor'], equals(0xFF00000F));
        expect(json['_navigationBarIconColor'], equals(0xFF000010));
        expect(json['_qrButtonBackgroundColor'], equals(0xFF000011));
        expect(json['_qrButtonIconColor'], equals(0xFF000012));
      });
    });
  });
}
