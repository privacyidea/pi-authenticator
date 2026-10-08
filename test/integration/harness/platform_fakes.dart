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

import 'dart:async';

import 'package:app_links_platform_interface/app_links_platform_interface.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart' show AuthMessages;
import 'package:privacyidea_authenticator/utils/lock_auth.dart';

/// The deep link side of the operating system.
///
/// The app reads its link sources once per isolate (the top level `sources`
/// of deeplink_notifier.dart), so the initial link a test file sets before the
/// first app start is the cold start link of every app start in that file.
class FakeAppLinks extends AppLinksPlatform {
  Uri? initialLink;
  final _links = StreamController<Uri>.broadcast();

  @override
  Future<Uri?> getInitialLink() async => initialLink;

  @override
  Future<String?> getInitialLinkString() async => initialLink?.toString();

  @override
  Future<Uri?> getLatestLink() async => initialLink;

  @override
  Future<String?> getLatestLinkString() async => initialLink?.toString();

  @override
  Stream<Uri> get uriLinkStream => _links.stream;

  @override
  Stream<String> get stringLinkStream =>
      _links.stream.map((uri) => uri.toString());

  /// Delivers [uri] the way the OS does while the app is running.
  void open(Uri uri) => _links.add(uri);
}

class FakeConnectivity extends ConnectivityPlatform {
  List<ConnectivityResult> current = [ConnectivityResult.wifi];
  final _changes = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => current;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _changes.stream;

  void change(List<ConnectivityResult> results) {
    current = results;
    _changes.add(results);
  }
}

/// The device's screen lock / biometric prompt. [nextResult] is what the user
/// does with the next prompt.
class FakeLocalAuthentication extends LocalAuthentication {
  bool deviceSupported = true;
  bool nextResult = true;
  final List<String> prompts = [];

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<AuthMessages> authMessages = const <AuthMessages>[],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async {
    prompts.add(localizedReason);
    return nextResult;
  }

  @override
  Future<bool> isDeviceSupported() async => deviceSupported;

  @override
  Future<bool> get canCheckBiometrics async => deviceSupported;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async =>
      deviceSupported ? [BiometricType.strong] : [];
}

/// The notification shade. Without it the plugin has no platform instance in
/// a test and every call throws.
class FakeNotifications extends FlutterLocalNotificationsPlatform {
  int cancelAllCalls = 0;

  @override
  Future<void> cancelAll() async => cancelAllCalls++;

  @override
  Future<void> cancel({required int id}) async {}
}

/// Answers every plugin channel the app touches on its way to the main view
/// and records what was asked, so a test can assert on it.
class PlatformFakes {
  static const screenSecurityChannel = MethodChannel('kidpech_screen_security');
  static const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );

  final FakeAppLinks appLinks;
  final FakeConnectivity connectivity = FakeConnectivity();
  final FakeLocalAuthentication localAuth = FakeLocalAuthentication();
  final FakeNotifications notifications = FakeNotifications();
  final List<MethodCall> screenSecurityCalls = [];
  final List<MethodCall> platformCalls = [];
  String? clipboardText;

  PlatformFakes._(this.appLinks);

  /// The app reads its deep link sources once per isolate, so this fake and
  /// its initial link are shared by all tests of a test file. A file that
  /// tests a cold start sets [coldStartLink] before its first test.
  static final FakeAppLinks isolateAppLinks = FakeAppLinks();
  static Uri? coldStartLink;

  static void installAppLinks() {
    isolateAppLinks.initialLink = coldStartLink;
    AppLinksPlatform.instance = isolateAppLinks;
  }

  factory PlatformFakes.install() {
    final fakes = PlatformFakes._(isolateAppLinks);
    ConnectivityPlatform.instance = fakes.connectivity;
    FlutterLocalNotificationsPlatform.instance = fakes.notifications;
    localAuthInstance = fakes.localAuth;
    resetAuthMutex();

    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(screenSecurityChannel, (call) async {
      fakes.screenSecurityCalls.add(call);
      return true;
    });
    messenger.setMockMethodCallHandler(permissionChannel, (call) async {
      // PermissionStatus.granted
      if (call.method == 'checkPermissionStatus') return 1;
      if (call.method == 'requestPermissions') {
        final permissions = (call.arguments as List).cast<int>();
        return {for (final p in permissions) p: 1};
      }
      return null;
    });
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      fakes.platformCalls.add(call);
      switch (call.method) {
        case 'Clipboard.setData':
          fakes.clipboardText = (call.arguments as Map)['text'] as String?;
          return null;
        case 'Clipboard.getData':
          return {'text': fakes.clipboardText};
        case 'Clipboard.hasStrings':
          return {'value': fakes.clipboardText != null};
      }
      return null;
    });
    return fakes;
  }

  void uninstall() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final channel in [
      screenSecurityChannel,
      permissionChannel,
      SystemChannels.platform,
    ]) {
      messenger.setMockMethodCallHandler(channel, null);
    }
  }
}
