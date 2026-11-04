import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/allow_screenshot_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('kidpech_screen_security');
  final calls = <String>[];
  var fail = false;

  setUp(() {
    calls.clear();
    fail = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (fail) throw PlatformException(code: 'error');
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('AllowScreenshotUtils toggle', () {
    test('toggle with screenshots currently allowed disallows them (enable security)', () async {
      expect(await AllowScreenshotUtils().toggleAllowScreenshots(true), isTrue);
      expect(calls, ['enableScreenSecurity']);
    });

    test('toggle with screenshots currently disallowed allows them (disable security)', () async {
      expect(await AllowScreenshotUtils().toggleAllowScreenshots(false), isTrue);
      expect(calls, ['disableScreenSecurity']);
    });

    test('allowScreenshots / disallowScreenshots invoke the matching method', () async {
      expect(await AllowScreenshotUtils().allowScreenshots(), isTrue);
      expect(await AllowScreenshotUtils().disallowScreenshots(), isTrue);
      expect(calls, ['disableScreenSecurity', 'enableScreenSecurity']);
    });

    test('returns false when the platform call fails', () async {
      fail = true;
      expect(await AllowScreenshotUtils().allowScreenshots(), isFalse);
      expect(await AllowScreenshotUtils().disallowScreenshots(), isFalse);
      expect(await AllowScreenshotUtils().toggleAllowScreenshots(true), isFalse);
      expect(await AllowScreenshotUtils().toggleAllowScreenshots(false), isFalse);
    });
  });
}
