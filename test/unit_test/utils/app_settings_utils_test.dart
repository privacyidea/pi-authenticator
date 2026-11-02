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
}
