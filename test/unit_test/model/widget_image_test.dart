/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/image_format.dart';
import 'package:privacyidea_authenticator/model/widget_image.dart';

void main() {
  group('Uint8ListConverter', () {
    const converter = Uint8ListConverter();

    test('encodes and decodes Uint8List round-trip', () {
      final original = Uint8List.fromList([1, 2, 3, 4, 5]);
      final json = converter.toJson(original);
      final decoded = converter.fromJson(json);
      expect(decoded, original);
    });

    test('toJson returns base64 string', () {
      final data = Uint8List.fromList([0, 255]);
      final result = converter.toJson(data);
      expect(result, base64Encode([0, 255]));
    });

    test('fromJson decodes base64 string', () {
      final b64 = base64Encode([10, 20, 30]);
      final result = converter.fromJson(b64);
      expect(result, Uint8List.fromList([10, 20, 30]));
    });
  });

  group('WidgetImage', () {
    WidgetImage createTestImage({
      String fileName = 'test',
      ImageFormat imageFormat = ImageFormat.png,
      Uint8List? imageData,
    }) {
      return WidgetImage(
        fileName: fileName,
        imageFormat: imageFormat,
        imageData: imageData ?? Uint8List.fromList([1, 2, 3]),
      );
    }

    test('fullFileName combines name and extension', () {
      final img = createTestImage(fileName: 'logo');
      expect(img.fullFileName, 'logo.png');
    });

    test('equality based on format and data', () {
      final data = Uint8List.fromList([1, 2, 3]);
      final a = createTestImage(fileName: 'a', imageData: data);
      final b = createTestImage(fileName: 'b', imageData: data);
      // Same format and data → equal (fileName is not part of equality)
      expect(a, equals(b));
    });

    test('not equal with different data', () {
      final a = createTestImage(imageData: Uint8List.fromList([1, 2]));
      final b = createTestImage(imageData: Uint8List.fromList([3, 4]));
      expect(a, isNot(equals(b)));
    });

    test('not equal with different format', () {
      final data = Uint8List.fromList([1, 2, 3]);
      final a = WidgetImage(
        fileName: 'test',
        imageFormat: ImageFormat.png,
        imageData: data,
      );
      final b = WidgetImage(
        fileName: 'test',
        imageFormat: ImageFormat.svg,
        imageData: data,
      );
      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent with equality', () {
      final data = Uint8List.fromList([1, 2, 3]);
      final a = createTestImage(imageData: data);
      final b = createTestImage(imageData: data);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString returns readable representation', () {
      final img = createTestImage(fileName: 'myImg');
      expect(img.toString(), contains('myImg'));
      expect(img.toString(), contains('WidgetImage'));
    });

    test('copyWith creates modified copy', () {
      final original = createTestImage(fileName: 'original');
      final copy = original.copyWith(fileName: 'copy');
      expect(copy.fileName, 'copy');
      expect(copy.imageFormat, original.imageFormat);
      expect(copy.imageData, original.imageData);
    });

    test('copyWith without args returns equivalent', () {
      final original = createTestImage();
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('toJson and fromJson round-trip', () {
      final original = createTestImage(fileName: 'roundtrip');
      final json = original.toJson();
      final restored = WidgetImage.fromJson(json);
      expect(restored.fileName, original.fileName);
      expect(restored.imageFormat, original.imageFormat);
      expect(restored.imageData, original.imageData);
    });
  });
}
