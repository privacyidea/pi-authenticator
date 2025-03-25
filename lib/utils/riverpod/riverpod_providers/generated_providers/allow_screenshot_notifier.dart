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
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../logger.dart';
import 'settings_notifier.dart';

part 'screenshot_notifier.g.dart';

@Riverpod(keepAlive: true)
class ScreenshotNotifier extends _$ScreenshotNotifier {
  final _ssHelper = NoScreenshot.instance;

  @override
  Future<bool> build() {
    Logger.info("New ScreenshotNotifier created");
    final allowScreenshot = ref.watch(settingsProvider.selectAsync((settings) => settings.allowScreenshots));
    allowScreenshot.then((value) => value ? _ssHelper.screenshotOn() : _ssHelper.screenshotOff());
    return allowScreenshot;
  }

  /// Enables the ability to take screenshots and passes the new state to the settings provider
  /// Returns true if the operation was successful
  Future<bool> screenshotOn() async {
    final success = await _ssHelper.screenshotOn();
    if (success) {
      ref.read(settingsProvider.notifier).updateState((state) => state.copyWith(allowScreenshots: true));
    }
    return success;
  }

  /// Disables the ability to take screenshots and passes the new state to the settings provider
  /// Returns true if the operation was successful
  Future<bool> screenshotOff() async {
    final success = await _ssHelper.screenshotOff();
    if (success) {
      ref.read(settingsProvider.notifier).updateState((state) => state.copyWith(allowScreenshots: false));
    }
    return success;
  }

  /// Toggles the ability to take screenshots and passes the new state to the settings provider
  /// Returns the new state if the operation was successful
  /// Returns the old state if the operation was not successful
  Future<bool> toggleAllowScreenshots() async {
    final bool success;
    final oldState = await future;
    if (oldState) {
      success = await screenshotOff();
    } else {
      success = await screenshotOn();
    }
    if (success) {
      ref.read(settingsProvider.notifier).updateState((state) => state.copyWith(allowScreenshots: !oldState));
      return !oldState;
    } else {
      return oldState;
    }
  }
}
