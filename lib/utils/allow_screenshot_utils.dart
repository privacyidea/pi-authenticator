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
import 'package:screen_security/screen_security.dart';

import 'logger.dart';

class AllowScreenshotUtils {
  final _screenSecurity = ScreenSecurity();

  /// Enables the ability to take screenshots
  /// Returns true if the operation was successful
  Future<bool> allowScreenshots() async {
    try {
      await _screenSecurity.disable();
      Logger.info("Screenshots allowed");
      return true;
    } catch (e, s) {
      Logger.warning("Failed to allow screenshots", error: e, stackTrace: s);
      return false;
    }
  }

  /// Disables the ability to take screenshots
  /// Returns true if the operation was successful
  Future<bool> disallowScreenshots() async {
    try {
      await _screenSecurity.enable();
      Logger.info("Screenshots not allowed");
      return true;
    } catch (e, s) {
      Logger.warning("Failed to disallow screenshots", error: e, stackTrace: s);
      return false;
    }
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
