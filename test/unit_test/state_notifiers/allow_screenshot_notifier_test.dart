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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/allow_screenshot_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  _testAllowScreenshotNotifier();
}

void _testAllowScreenshotNotifier() {
  late MockAllowScreenshotUtils mockScreenshotUtils;
  late MockSettingsRepository mockSettingsRepository;
  late AllowScreenshotNotifier notifier;
  late ProviderContainer container;
  late SettingsState settingsState;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockScreenshotUtils = MockAllowScreenshotUtils();
    mockSettingsRepository = MockSettingsRepository();
    settingsState = SettingsState(allowScreenshots: false);
    container = ProviderContainer(overrides: [
      allowScreenshotProvider.overrideWith(
        () => AllowScreenshotNotifier(screenshotUtilsOverride: mockScreenshotUtils),
      ),
      settingsProvider.overrideWith(
        () => SettingsNotifier(repoOverride: mockSettingsRepository),
      ),
    ]);
    notifier = container.read(allowScreenshotProvider.notifier);
    when(mockScreenshotUtils.allowScreenshots()).thenAnswer((_) async => true);
    when(mockScreenshotUtils.disallowScreenshots()).thenAnswer((_) async => false);
    when(mockSettingsRepository.loadSettings()).thenAnswer((_) async => settingsState);
    when(mockSettingsRepository.saveSettings(any)).thenAnswer((invocation) async {
      final newState = invocation.positionalArguments[0] as SettingsState;
      settingsState = newState;
      return true;
    });
  });

  test('Initial state is fetched correctly', () async {
    when(mockScreenshotUtils.disallowScreenshots()).thenAnswer((_) async => true);

    final result = await notifier.build(screenshotUtils: mockScreenshotUtils);

    verify(mockSettingsRepository.loadSettings()).called(1);
    expect(result, false);
  });

  test('allowScreenshots enables screenshots and updates settings', () async {
    when(mockScreenshotUtils.allowScreenshots()).thenAnswer((_) async => true);
    when(mockScreenshotUtils.disallowScreenshots()).thenAnswer((_) async => true);

    final result = await notifier.allowScreenshots();

    expect(result, true);
    verify(mockScreenshotUtils.allowScreenshots()).called(1);
    verify(mockSettingsRepository.saveSettings(any)).called(1);
    final newSettingsState = await container.read(settingsProvider.future);
    expect(newSettingsState.allowScreenshots, true);
    final newAllowScreenshots = (await container.read(settingsProvider.future)).allowScreenshots;
    expect(newAllowScreenshots, true);
  });

  test('allowScreenshots failed to enable screenshots', () async {
    when(mockScreenshotUtils.allowScreenshots()).thenAnswer((_) async => false);
    when(mockScreenshotUtils.disallowScreenshots()).thenAnswer((_) async => true);

    final result = await notifier.allowScreenshots();

    expect(result, false);
    verify(mockScreenshotUtils.allowScreenshots()).called(1);
    verifyNever(mockSettingsRepository.saveSettings(any));
    final newSettingsState = await container.read(settingsProvider.future);
    expect(newSettingsState.allowScreenshots, false);
    final newAllowScreenshots = (await container.read(settingsProvider.future)).allowScreenshots;
    expect(newAllowScreenshots, false);
  });

  test('disallowScreenshots disables screenshots and updates settings', () async {
    when(mockScreenshotUtils.allowScreenshots()).thenAnswer((_) async => true); // to set the initial state to true
    when(mockScreenshotUtils.disallowScreenshots()).thenAnswer((_) async => true);

    await notifier.allowScreenshots(); // to set the initial state to true
    final result = await notifier.disallowScreenshots();

    expect(result, true);
    verify(mockScreenshotUtils.disallowScreenshots()).called(2);
    verify(mockSettingsRepository.saveSettings(any)).called(2);
    final newSettingsState = await container.read(settingsProvider.future);
    expect(newSettingsState.allowScreenshots, false);
    final newAllowScreenshots = (await container.read(settingsProvider.future)).allowScreenshots;
    expect(newAllowScreenshots, false);
  });
  test('disallowScreenshots failed to disable screenshots', () async {
    when(mockScreenshotUtils.allowScreenshots()).thenAnswer((_) async => true); // to set the initial state to true
    when(mockScreenshotUtils.disallowScreenshots()).thenAnswer((_) async => false);

    await notifier.allowScreenshots(); // to set the initial state to true
    final result = await notifier.disallowScreenshots();

    expect(result, false);
    verify(mockScreenshotUtils.disallowScreenshots()).called(2);
    verify(mockSettingsRepository.saveSettings(any)).called(1);
    final newSettingsState = await container.read(settingsProvider.future);
    expect(newSettingsState.allowScreenshots, true);
    final newAllowScreenshots = (await container.read(settingsProvider.future)).allowScreenshots;
    expect(newAllowScreenshots, true);
  });

  test('toggleAllowScreenshots toggles the allowness of screenshots and updates settings', () async {
    when(mockScreenshotUtils.toggleAllowScreenshots(any)).thenAnswer((_) async => true);

    final result = await notifier.toggleAllowScreenshots();

    expect(result, true);
    verify(mockScreenshotUtils.disallowScreenshots()).called(1);
    verify(mockScreenshotUtils.toggleAllowScreenshots(false)).called(1);
    verify(mockSettingsRepository.saveSettings(any)).called(1);
    final newSettingsState = await container.read(settingsProvider.future);
    expect(newSettingsState.allowScreenshots, true);
    final newAllowScreenshots = (await container.read(settingsProvider.future)).allowScreenshots;
    expect(newAllowScreenshots, true);
  });
  test('toggleAllowScreenshots failed to toggle the allowness of screenshots', () async {
    when(mockScreenshotUtils.toggleAllowScreenshots(any)).thenAnswer((_) async => false);

    final result = await notifier.toggleAllowScreenshots();

    expect(result, false);
    verify(mockScreenshotUtils.disallowScreenshots()).called(1);
    verify(mockScreenshotUtils.toggleAllowScreenshots(false)).called(1);
    verifyNever(mockSettingsRepository.saveSettings(any));
    final newSettingsState = await container.read(settingsProvider.future);
    expect(newSettingsState.allowScreenshots, false);
    final newAllowScreenshots = (await container.read(settingsProvider.future)).allowScreenshots;
    expect(newAllowScreenshots, false);
  });
}
