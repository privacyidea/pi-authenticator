import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/app_feature.dart';
import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';

void main() {
  _testAppCustomizer();
}

void _testAppCustomizer() {
  group('App Customizer Test', () {
    // Arrange
    final customization = ApplicationCustomization(
      appName: 'test',
      websiteLink: 'https://test',
      appIconUint8List: defaultIconUint8List,
      appImageUint8List: defaultImageUint8List,
      lightTheme: ApplicationCustomization.defaultCustomization.lightTheme,
      darkTheme: ApplicationCustomization.defaultCustomization.darkTheme,
      disabledFeatures: {AppFeature.patchNotes},
    );
    test('constructor', () {
      // Assert
      expect(customization.appName, equals('test'));
      expect(customization.websiteLink, equals('https://test'));
      expect(customization.appIconUint8List, equals(defaultIconUint8List));
      expect(customization.appImageUint8List, equals(defaultImageUint8List));
      expect(customization.lightTheme, equals(ApplicationCustomization.defaultCustomization.lightTheme));
      expect(customization.darkTheme, equals(ApplicationCustomization.defaultCustomization.darkTheme));
      expect(customization.disabledFeatures, equals({AppFeature.patchNotes}));
    });
    test('copyWith', () {
      // Act
      final newCustomization = customization.copyWith(
        appName: 'test2',
        websiteLink: 'https://test2',
        appIconUint8List: defaultImageUint8List,
        appImageUint8List: defaultIconUint8List,
        lightTheme: ApplicationCustomization.defaultCustomization.darkTheme,
        darkTheme: ApplicationCustomization.defaultCustomization.lightTheme,
        disabledFeatures: {},
      );
      // Assert
      expect(newCustomization.appName, equals('test2'));
      expect(newCustomization.websiteLink, equals('https://test2'));
      expect(newCustomization.appIconUint8List, equals(defaultImageUint8List));
      expect(newCustomization.appImageUint8List, equals(defaultIconUint8List));
    });
    group('serialization', () {
      test('toJson', () {
        // Act
        final json = customization.toJson();
        // Assert
        expect(json['appName'], equals('test'));
        expect(json['websiteLink'], equals('https://test'));
        expect(json['appIconBASE64'], equals(base64Encode(defaultIconUint8List)));
        expect(json['appImageBASE64'], equals(base64Encode(defaultImageUint8List)));
        expect(json['lightTheme'], equals(ApplicationCustomization.defaultCustomization.lightTheme.toJson()));
        expect(json['darkTheme'], equals(ApplicationCustomization.defaultCustomization.darkTheme.toJson()));
        expect(json['disabledFeatures'], equals({AppFeature.patchNotes.name}));
      });
      test('fromJson', () {
        // Act
        final newCustomization = ApplicationCustomization.fromJson({
          'appName': 'test2',
          'websiteLink': 'https://test2',
          'appIconBASE64': base64Encode(defaultImageUint8List),
          'appImageBASE64': base64Encode(defaultIconUint8List),
          'lightTheme': ApplicationCustomization.defaultCustomization.lightTheme.toJson(),
          'darkTheme': ApplicationCustomization.defaultCustomization.darkTheme.toJson(),
          'disabledFeatures': [],
        });
        // Assert
        expect(newCustomization.appName, equals('test2'));
        expect(newCustomization.websiteLink, equals('https://test2'));
        expect(newCustomization.appIconUint8List, equals(defaultImageUint8List));
        expect(newCustomization.appImageUint8List, equals(defaultIconUint8List));
        expect(newCustomization.lightTheme, equals(ApplicationCustomization.defaultCustomization.lightTheme));
        expect(newCustomization.darkTheme, equals(ApplicationCustomization.defaultCustomization.darkTheme));
        expect(newCustomization.disabledFeatures, isA<Set>());
        expect(newCustomization.disabledFeatures, isEmpty);
      });
    });
  });
}
