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
import 'dart:ui';

extension ColorExtension on Color {
  Color mixWith(
    Color other, [
    double factor = 0.5 /* 0.0 - 1.0 */,
  ]) =>
      Color.from(
        alpha: (a * (1 - factor) + other.a * factor).clamp(0, 1),
        red: (r * (1 - factor) + other.r * factor).clamp(0, 1),
        green: (g * (1 - factor) + other.g * factor).clamp(0, 1),
        blue: (b * (1 - factor) + other.b * factor).clamp(0, 1),
      );

  Color inverted() => Color.from(
        alpha: a,
        red: 1 - r,
        green: 1 - g,
        blue: 1 - b,
      );

  toJson() => {
        'a': a,
        'r': r,
        'g': g,
        'b': b,
      };
  static Color fromJson(dynamic json) {
    if (json is int) return Color(json);
    if (json is String) return Color(int.parse(json));
    if (json is Map) {
      return Color.from(
        alpha: json['a'] as double,
        red: json['r'] as double,
        green: json['g'] as double,
        blue: json['b'] as double,
      );
    }
    throw ArgumentError.value(json, 'json', 'Invalid color value');
  }
}
