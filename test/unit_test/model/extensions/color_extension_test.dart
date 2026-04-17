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
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/extensions/color_extension.dart';

void main() {
  group('ColorExtension', () {
    group('mixWith', () {
      test('mixing with same color returns same color', () {
        const color = Color.fromARGB(255, 100, 100, 100);
        final mixed = color.mixWith(color);
        expect(mixed.a, closeTo(color.a, 0.01));
        expect(mixed.r, closeTo(color.r, 0.01));
        expect(mixed.g, closeTo(color.g, 0.01));
        expect(mixed.b, closeTo(color.b, 0.01));
      });

      test('mixing black and white at 0.5 gives grey', () {
        final black = const Color.fromARGB(255, 0, 0, 0);
        final white = const Color.fromARGB(255, 255, 255, 255);
        final mixed = black.mixWith(white);
        // Components should be around 0.5
        expect(mixed.r, closeTo(0.5, 0.02));
        expect(mixed.g, closeTo(0.5, 0.02));
        expect(mixed.b, closeTo(0.5, 0.02));
      });

      test('factor 0 returns original color', () {
        final red = const Color.fromARGB(255, 255, 0, 0);
        final blue = const Color.fromARGB(255, 0, 0, 255);
        final mixed = red.mixWith(blue, 0.0);
        expect(mixed.r, closeTo(red.r, 0.01));
        expect(mixed.g, closeTo(red.g, 0.01));
        expect(mixed.b, closeTo(red.b, 0.01));
      });

      test('factor 1 returns other color', () {
        final red = const Color.fromARGB(255, 255, 0, 0);
        final blue = const Color.fromARGB(255, 0, 0, 255);
        final mixed = red.mixWith(blue, 1.0);
        expect(mixed.r, closeTo(blue.r, 0.01));
        expect(mixed.g, closeTo(blue.g, 0.01));
        expect(mixed.b, closeTo(blue.b, 0.01));
      });
    });

    group('inverted', () {
      test('inverts color', () {
        final color = Color.from(alpha: 1.0, red: 0.2, green: 0.4, blue: 0.6);
        final inv = color.inverted();
        expect(inv.r, closeTo(0.8, 0.01));
        expect(inv.g, closeTo(0.6, 0.01));
        expect(inv.b, closeTo(0.4, 0.01));
        expect(inv.a, closeTo(1.0, 0.01));
      });

      test('double inversion returns original', () {
        final color = Color.from(alpha: 1.0, red: 0.3, green: 0.5, blue: 0.7);
        final doubleInv = color.inverted().inverted();
        expect(doubleInv.r, closeTo(color.r, 0.01));
        expect(doubleInv.g, closeTo(color.g, 0.01));
        expect(doubleInv.b, closeTo(color.b, 0.01));
      });
    });

    group('toJson / fromJson', () {
      test('round-trips via map', () {
        final color = Color.from(alpha: 1.0, red: 0.2, green: 0.4, blue: 0.6);
        final json = color.toJson();
        final restored = ColorExtension.fromJson(json);
        expect(restored.a, closeTo(color.a, 0.01));
        expect(restored.r, closeTo(color.r, 0.01));
        expect(restored.g, closeTo(color.g, 0.01));
        expect(restored.b, closeTo(color.b, 0.01));
      });

      test('fromJson parses int', () {
        final color = ColorExtension.fromJson(0xFFFF0000);
        expect(color, isA<Color>());
      });

      test('fromJson parses string', () {
        final color = ColorExtension.fromJson('${0xFFFF0000}');
        expect(color, isA<Color>());
      });

      test('fromJson throws on invalid type', () {
        expect(
          () => ColorExtension.fromJson([1, 2, 3]),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
