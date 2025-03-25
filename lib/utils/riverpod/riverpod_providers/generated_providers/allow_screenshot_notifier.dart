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

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../allow_screenshot_utils.dart';
import '../../../logger.dart';
import 'settings_notifier.dart';

part 'allow_screenshot_notifier.g.dart';

final allowScreenshotProvider = allowScreenshotNotifierProviderOf(
  screenshotUtils: AllowScreenshotUtils(),
);

@Riverpod(keepAlive: true)
class AllowScreenshotNotifier extends _$AllowScreenshotNotifier {
  @override
  AllowScreenshotUtils get screenshotUtils => _screenshotUtilsOverride ?? _screenshotUtils;
  final AllowScreenshotUtils? _screenshotUtilsOverride;
  late final AllowScreenshotUtils _screenshotUtils;

  AllowScreenshotNotifier({AllowScreenshotUtils? screenshotUtilsOverride}) : _screenshotUtilsOverride = screenshotUtilsOverride;

  @override
  Future<bool> build({
    required AllowScreenshotUtils screenshotUtils,
  }) async {
    Logger.info("New ScreenshotNotifier created");

    final allowScreenshot = await ref.watch(settingsProvider.selectAsync((settings) => settings.allowScreenshots));
    allowScreenshot ? screenshotUtils.allowScreenshots() : screenshotUtils.notAllowScreenshots();
    return allowScreenshot;
  }

  /// Enables the ability to take screenshots and passes the new state to the settings provider
  /// Returns true if the operation was successful
  Future<bool> screenshotOn() async {
    final success = await screenshotUtils.allowScreenshots();
    if (success) {
      ref.read(settingsProvider.notifier).updateState((state) => state.copyWith(allowScreenshots: true));
    }
    return success;
  }

  /// Disables the ability to take screenshots and passes the new state to the settings provider
  /// Returns true if the operation was successful
  Future<bool> screenshotOff() async {
    final success = await screenshotUtils.notAllowScreenshots();
    if (success) {
      ref.read(settingsProvider.notifier).updateState((state) => state.copyWith(allowScreenshots: false));
    }
    return success;
  }

  /// Toggles the ability to take screenshots and passes the new state to the settings provider
  /// Returns the new state if the operation was successful
  /// Returns the old state if the operation was not successful
  Future<bool> toggleAllowScreenshots() async {
    final oldState = await future;
    final bool success = await screenshotUtils.toggleAllowScreenshots(oldState);
    if (success) {
      ref.read(settingsProvider.notifier).updateState((state) => state.copyWith(allowScreenshots: !oldState));
      return !oldState;
    } else {
      return oldState;
    }
  }
}
