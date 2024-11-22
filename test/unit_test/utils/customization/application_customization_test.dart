import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/app_feature.dart';
import 'package:privacyidea_authenticator/model/enums/image_file_type.dart';
import 'package:privacyidea_authenticator/model/widget_image.dart';
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
      appbarIcon: WidgetImage(
        fileType: ImageFileType.png,
        imageData: defaultIconUint8List,
        fileName: "appbarIcon",
      ),
      splashScreenImage: WidgetImage(
        fileType: ImageFileType.png,
        imageData: defaultImageUint8List,
        fileName: "splashScreenImage",
      ),
      lightTheme: ApplicationCustomization.defaultCustomization.lightTheme,
      darkTheme: ApplicationCustomization.defaultCustomization.darkTheme,
      disabledFeatures: {AppFeature.patchNotes},
    );
    test('constructor', () {
      // Assert
      expect(customization.appName, equals('test'));
      expect(customization.websiteLink, equals('https://test'));
      expect(customization.appbarIcon.imageData, equals(defaultIconUint8List));
      expect(() => customization.appbarIcon.getWidget, returnsNormally);
      expect(customization.splashScreenImage.getWidget, isA<Widget>());
      expect(customization.splashScreenImage.imageData, equals(defaultImageUint8List));
      expect(() => customization.splashScreenImage.getWidget, returnsNormally);
      expect(customization.splashScreenImage.getWidget, isA<Widget>());
      expect(customization.lightTheme, equals(ApplicationCustomization.defaultCustomization.lightTheme));
      expect(customization.darkTheme, equals(ApplicationCustomization.defaultCustomization.darkTheme));
      expect(customization.disabledFeatures, equals({AppFeature.patchNotes}));
    });
    test('copyWith', () {
      // Act
      final newCustomization = customization.copyWith(
        appName: 'test2',
        websiteLink: 'https://test2',
        appbarIcon: WidgetImage(
          fileType: ImageFileType.png,
          imageData: defaultImageUint8List,
          fileName: "appbarIcon",
        ),
        splashScreenImage: WidgetImage(
          fileType: ImageFileType.png,
          imageData: defaultIconUint8List,
          fileName: "appImage",
        ),
        lightTheme: ApplicationCustomization.defaultCustomization.darkTheme,
        darkTheme: ApplicationCustomization.defaultCustomization.lightTheme,
        disabledFeatures: {},
      );
      // Assert
      expect(newCustomization.appName, equals('test2'));
      expect(newCustomization.websiteLink, equals('https://test2'));
      expect(newCustomization.appbarIcon.imageData, equals(defaultImageUint8List));
      expect(newCustomization.splashScreenImage.imageData, equals(defaultIconUint8List));
    });
    group('serialization', () {
      test('toJson', () {
        // Act
        final json = customization.toJson();
        // Assert
        expect(json['appName'], equals('test'));
        expect(json['websiteLink'], equals('https://test'));
        expect(json['appIcon'], equals({'fileType': 'png', 'imageData': base64Encode(defaultIconUint8List)}));
        expect(json['appImage'], equals({'fileType': 'png', 'imageData': base64Encode(defaultImageUint8List)}));
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
        expect(newCustomization.appbarIcon.imageData, equals(defaultIconUint8List));
        expect(newCustomization.splashScreenImage.imageData, equals(defaultImageUint8List));
        expect(newCustomization.lightTheme, equals(ApplicationCustomization.defaultCustomization.lightTheme));
        expect(newCustomization.darkTheme, equals(ApplicationCustomization.defaultCustomization.darkTheme));
        expect(newCustomization.disabledFeatures, isA<Set>());
        expect(newCustomization.disabledFeatures, isEmpty);
      });
    });
  });
}
