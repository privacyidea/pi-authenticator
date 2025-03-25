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
import 'package:no_screenshot/no_screenshot.dart';

import 'logger.dart';

class AllowScreenshotUtils {
  /// Enables the ability to take screenshots
  /// Returns true if the operation was successful
  Future<bool> allowScreenshots() {
    Logger.info("Screenshots allowed");
    return NoScreenshot.instance.screenshotOn();
  }

  /// Disables the ability to take screenshots
  /// Returns true if the operation was successful
  Future<bool> disallowScreenshots() {
    Logger.info("Screenshots not allowed");
    return NoScreenshot.instance.screenshotOff();
  }

  /// Toggles the ability to take screenshots
  /// Returns true if the operation was successful
  Future<bool> toggleAllowScreenshots(bool oldState) {
    if (oldState) {
      return allowScreenshots();
    } else {
      return disallowScreenshots();
    }
  }
}
