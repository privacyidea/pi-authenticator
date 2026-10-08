import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/app_settings_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('pi_authenticator/settings');
  final channelLog = <MethodCall>[];

  setUp(() {
    channelLog.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          channelLog.add(call);
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
    resetLaunchUrlOverride();
  });

  group('openLockAndPasswordSettings on Android', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    test('invokes the native security-settings channel', () async {
      await openLockAndPasswordSettings();

      expect(channelLog, hasLength(1));
      expect(channelLog.single.method, 'openLockAndPasswordSettings');
    });

    test('swallows platform exceptions instead of throwing', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            throw PlatformException(code: 'UNAVAILABLE');
          });

      await expectLater(openLockAndPasswordSettings(), completes);
    });

    test('does not fall back to the iOS url launcher', () async {
      var launchedUrls = <Uri>[];
      launchUrlOverride = (url) async {
        launchedUrls.add(url);
        return true;
      };

      await openLockAndPasswordSettings();

      expect(launchedUrls, isEmpty);
    });
  });

  group('openLockAndPasswordSettings on iOS', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    });

    test('opens the app-settings deep link and skips the channel', () async {
      var launchedUrls = <Uri>[];
      launchUrlOverride = (url) async {
        launchedUrls.add(url);
        return true;
      };

      await openLockAndPasswordSettings();

      expect(launchedUrls, [Uri.parse('app-settings:')]);
      expect(channelLog, isEmpty);
    });
  });

  group('openLockAndPasswordSettings on unsupported platforms', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    });

    test('does nothing', () async {
      var launchedUrls = <Uri>[];
      launchUrlOverride = (url) async {
        launchedUrls.add(url);
        return true;
      };

      await openLockAndPasswordSettings();

      expect(launchedUrls, isEmpty);
      expect(channelLog, isEmpty);
    });
  });

  _testBatteryOptimizationHelpers();
}

/// The native side is mocked on the `pi_authenticator/settings` method channel.
/// `defaultTargetPlatform` is switched with `debugDefaultTargetPlatformOverride`.
void _testBatteryOptimizationHelpers() {
  group('battery optimization helpers', () {
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

    List<String> methods() => channelLog.map((c) => c.method).toList();

    group('on Android', () {
      setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);

      group('batteryOptimizationsIsDisabled', () {
        test('returns true when native reports true', () async {
          nativeHandler = (_) async => true;

          expect(await batteryOptimizationsIsDisabled(), isTrue);
          expect(methods(), ['batteryOptimizationsIsDisabled']);
        });

        test('returns false when native reports false', () async {
          nativeHandler = (_) async => false;

          expect(await batteryOptimizationsIsDisabled(), isFalse);
          expect(methods(), ['batteryOptimizationsIsDisabled']);
        });

        test('PlatformException falls back to true (do not nag the user)', () async {
          nativeHandler = (_) async => throw PlatformException(code: 'ERR');

          expect(await batteryOptimizationsIsDisabled(), isTrue);
        });

        test('MissingPluginException (no native handler) falls back to true', () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null);

          expect(await batteryOptimizationsIsDisabled(), isTrue);
        });

        test('null answer from native falls back to true', () async {
          nativeHandler = (_) async => null;

          expect(await batteryOptimizationsIsDisabled(), isTrue);
        });

        test('non bool answer from native falls back to true', () async {
          nativeHandler = (_) async => 'yes';

          expect(await batteryOptimizationsIsDisabled(), isTrue);
        });
      });

      group('requestIgnoreBatteryOptimizations', () {
        test('invokes the native method exactly once', () async {
          await requestIgnoreBatteryOptimizations();

          expect(methods(), ['requestIgnoreBatteryOptimizations']);
        });

        test('swallows PlatformException', () async {
          nativeHandler = (_) async => throw PlatformException(code: 'ERR');

          await expectLater(requestIgnoreBatteryOptimizations(), completes);
          expect(methods(), ['requestIgnoreBatteryOptimizations']);
        });

        test('swallows MissingPluginException', () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null);

          await expectLater(requestIgnoreBatteryOptimizations(), completes);
        });
      });

      group('openBatteryOptimizationSettings', () {
        test('invokes the native method exactly once', () async {
          await openBatteryOptimizationSettings();

          expect(methods(), ['openBatteryOptimizationSettings']);
        });

        test('swallows PlatformException', () async {
          nativeHandler = (_) async => throw PlatformException(code: 'ERR');

          await expectLater(openBatteryOptimizationSettings(), completes);
          expect(methods(), ['openBatteryOptimizationSettings']);
        });

        test('swallows MissingPluginException', () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null);

          await expectLater(openBatteryOptimizationSettings(), completes);
        });
      });
    });

    group('on non Android platforms', () {
      for (final platform in [
        TargetPlatform.iOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.macOS,
        TargetPlatform.fuchsia,
      ]) {
        group(platform.name, () {
          setUp(() => debugDefaultTargetPlatformOverride = platform);

          test('batteryOptimizationsIsDisabled is true without asking native', () async {
            nativeHandler = (_) async => false; // would be "not disabled" on Android

            expect(await batteryOptimizationsIsDisabled(), isTrue);
            expect(channelLog, isEmpty);
          });

          test('requestIgnoreBatteryOptimizations is a no-op', () async {
            await requestIgnoreBatteryOptimizations();

            expect(channelLog, isEmpty);
          });

          test('openBatteryOptimizationSettings is a no-op', () async {
            await openBatteryOptimizationSettings();

            expect(channelLog, isEmpty);
          });
        });
      }
    });
  });
}
