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
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/battery_optimization_provider.dart';

/// The native side is mocked on the `pi_authenticator/settings` method channel.
/// `defaultTargetPlatform` is switched with `debugDefaultTargetPlatformOverride`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('pi_authenticator/settings');

  late List<MethodCall> channelLog;
  Future<Object?> Function(MethodCall call) nativeHandler = (_) async => true;

  setUp(() {
    channelLog = [];
    nativeHandler = (_) async => true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          channelLog.add(call);
          return nativeHandler(call);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('batteryOptimizationsIsDisabledProvider', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);

    test('exposes the native answer', () async {
      nativeHandler = (_) async => false;
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        await container.read(batteryOptimizationsIsDisabledProvider.future),
        isFalse,
      );
    });

    test('caches the value until it is invalidated, then re-reads native', () async {
      nativeHandler = (_) async => false;
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        await container.read(batteryOptimizationsIsDisabledProvider.future),
        isFalse,
      );
      nativeHandler = (_) async => true; // user disabled the optimization

      expect(
        await container.read(batteryOptimizationsIsDisabledProvider.future),
        isFalse,
        reason: 'still the cached value',
      );
      expect(channelLog, hasLength(1));

      container.invalidate(batteryOptimizationsIsDisabledProvider);

      expect(
        await container.read(batteryOptimizationsIsDisabledProvider.future),
        isTrue,
      );
      expect(channelLog, hasLength(2));
    });

    test('native failure results in true instead of an error state', () async {
      nativeHandler = (_) async => throw PlatformException(code: 'ERR');
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        await container.read(batteryOptimizationsIsDisabledProvider.future),
        isTrue,
      );
      expect(container.read(batteryOptimizationsIsDisabledProvider).hasError, isFalse);
    });

    test('is true on non Android platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        await container.read(batteryOptimizationsIsDisabledProvider.future),
        isTrue,
      );
      expect(channelLog, isEmpty);
    });
  });
}
