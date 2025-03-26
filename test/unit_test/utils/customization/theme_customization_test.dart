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
      warningColor: Color(0xFF000013),
      successColor: Color(0xFF000014),
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
      expect(customization.warningColor, equals(const Color(0xFF000013)));
      expect(customization.successColor, equals(const Color(0xFF000014)));
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
        warningColor: const Color(0xFFFFFFEC),
        successColor: const Color(0xFFFFFFEB),
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
      expect(newCustomization.warningColor, equals(const Color(0xFFFFFFEC)));
      expect(newCustomization.successColor, equals(const Color(0xFFFFFFEB)));
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
          warningColor: Color(0xFFFFFFEC),
          successColor: Color(0xFFFFFFEB),
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
        expect(newCustomization.warningColor, equals(const Color(0xFFFFFFEC)));
        expect(newCustomization.successColor, equals(const Color(0xFFFFFFEB)));
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
          warningColor: Color(0xFFFFFFEC),
          successColor: Color(0xFFFFFFEB),
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
        expect(newCustomization.warningColor, equals(const Color(0xFFFFFFEC)));
        expect(newCustomization.successColor, equals(const Color(0xFFFFFFEB)));
      });
    });
    group('serialization', () {
      test('fromJson (old)', () {
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
          'warningColor': 0xFFFFFFEC,
          'successColor': 0xFFFFFFEB,
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
        expect(newCustomization.warningColor, equals(const Color(0xFFFFFFEC)));
        expect(newCustomization.successColor, equals(const Color(0xFFFFFFEB)));
      });
      test('fromJson (new)', () {
        // Act
        final newCustomization = ThemeCustomization.fromJson({
          'brightness': 'light',
          'primaryColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 1.0},
          'onPrimary': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.996078431372549},
          'subtitleColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9921568627450981},
          'backgroundColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9882352941176471},
          'foregroundColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.984313725490196},
          'shadowColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9803921568627451},
          'deleteColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9764705882352941},
          'renameColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9725490196078431},
          'lockColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9686274509803922},
          'exportColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9647058823529412},
          'disabledColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9607843137254902},
          'tileIconColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9568627450980393},
          'navigationBarColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9529411764705882},
          '_actionButtonsForegroundColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9490196078431372},
          '_tilePrimaryColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9450980392156862},
          '_tileSubtitleColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9411764705882353},
          '_navigationBarIconColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9372549019607843},
          '_qrButtonBackgroundColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9333333333333333},
          '_qrButtonIconColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9294117647058824},
          'warningColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9254901960784314},
          'successColor': {'a': 1.0, 'r': 1.0, 'g': 1.0, 'b': 0.9215686274509803},
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
        expect(newCustomization.warningColor, equals(const Color(0xFFFFFFEC)));
        expect(newCustomization.successColor, equals(const Color(0xFFFFFFEB)));
      });
      test('toJson (new)', () {
        // Act
        final json = customization.toJson();
        // Assert
        expect(json['brightness'], equals('dark'));
        expect(json['primaryColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.0}));
        expect(json['onPrimary'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.00392156862745098}));
        expect(json['subtitleColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.00784313725490196}));
        expect(json['backgroundColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.011764705882352941}));
        expect(json['foregroundColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.01568627450980392}));
        expect(json['shadowColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.0196078431372549}));
        expect(json['deleteColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.023529411764705882}));
        expect(json['renameColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.027450980392156862}));
        expect(json['lockColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.03137254901960784}));
        expect(json['exportColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.03529411764705882}));
        expect(json['disabledColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.0392156862745098}));
        expect(json['tileIconColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.043137254901960784}));
        expect(json['navigationBarColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.047058823529411764}));
        expect(json['_actionButtonsForegroundColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.050980392156862744}));
        expect(json['_tilePrimaryColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.054901960784313725}));
        expect(json['_tileSubtitleColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.058823529411764705}));
        expect(json['_navigationBarIconColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.06274509803921569}));
        expect(json['_qrButtonBackgroundColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.06666666666666667}));
        expect(json['_qrButtonIconColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.07058823529411765}));
        expect(json['warningColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.07450980392156863}));
        expect(json['successColor'], equals({'a': 1.0, 'r': 0.0, 'g': 0.0, 'b': 0.0784313725490196}));
      });
    });
  });
}
