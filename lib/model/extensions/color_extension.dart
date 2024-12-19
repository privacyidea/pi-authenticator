/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
      Color.fromARGB(
        (alpha * (1 - factor) + other.alpha * factor).toInt().clamp(0, 255),
        (red * (1 - factor) + other.red * factor).toInt().clamp(0, 255),
        (green * (1 - factor) + other.green * factor).toInt().clamp(0, 255),
        (blue * (1 - factor) + other.blue * factor).toInt().clamp(0, 255),
      );

  Color inverted() => Color.fromARGB(alpha, 255 - red, 255 - green, 255 - blue);
}
