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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/api/impl/privacy_idea_container_api.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/mains/app_init.dart';
import 'package:privacyidea_authenticator/mains/main_netknights.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/repo/preference_introduction_repository.dart';
import 'package:privacyidea_authenticator/repo/preference_settings_repository.dart';
import 'package:privacyidea_authenticator/repo/preference_token_folder_repository.dart';
import 'package:privacyidea_authenticator/utils/app_info_utils.dart';
import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view.dart';
import 'package:privacyidea_authenticator/widgets/app_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_backend.dart';
import 'fake_device_storage.dart';
import 'log_capture.dart';
import 'platform_fakes.dart';

export 'fake_backend.dart';
export 'fake_device_storage.dart';
export 'log_capture.dart';
export 'platform_fakes.dart';

/// The version the fake package info reports. Seeding it as the latest started
/// version keeps the patch notes dialog closed.
const testAppVersion = '4.8.1';

final l10n = AppLocalizationsEn();

/// [RsaUtils] that hands out pre generated short keys instead of generating a
/// 4096 bit key in an isolate, which never finishes inside a widget test.
class FastKeyRsaUtils extends RsaUtils {
  final List<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> keyPairs;
  int generated = 0;

  FastKeyRsaUtils(this.keyPairs);

  @override
  Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>>
  generateRSAKeyPair() async => keyPairs[generated++ % keyPairs.length];
}

/// Runs the real app (AppWrapper + PrivacyIDEAAuthenticator, exactly as
/// main_netknights.dart builds it) on fake platform boundaries:
///
/// * [storage]: in memory secure storage and shared preferences under the
///   real repositories,
/// * [backend]: every HTTP request of the app, recorded and routed to fakes,
/// * [platform]: plugin channels, deep links and connectivity.
///
/// Nothing inside lib/ is replaced except the network client and the RSA key
/// generator, which are injected through the notifiers' constructor
/// overrides that exist for this purpose.
class AppHarness {
  final WidgetTester tester;
  final FakeDeviceStorage storage;
  final FakeBackend backend;
  final PlatformFakes platform;
  final LogCapture logs;
  final RsaUtils rsaUtils;
  final FirebaseUtils firebaseUtils = NoFirebaseUtils();
  late PushProvider pushProvider;
  bool _started = false;

  /// Every status bar message the app showed, in English.
  final List<String> statusMessages = [];

  AppHarness._({
    required this.tester,
    required this.storage,
    required this.backend,
    required this.platform,
    required this.logs,
    required this.rsaUtils,
  });

  static bool _isolatePrepared = false;

  /// Several singletons of the app cache a future or a stream subscription
  /// the first time they are used (the repositories' SharedPreferences,
  /// AppInfoUtils, the deep link sources). Work bound to one test's fake async
  /// zone never runs again once that test is over, so these are created once
  /// in the real zone, and the deep link stream of app_links keeps a listener
  /// from there so its forwarding subscription never moves into a test zone.
  /// The Logger is created there too, and its FlutterError.onError hook is
  /// undone, so framework errors keep failing the test instead of being
  /// logged.
  static Future<void> _prepareIsolate(WidgetTester tester) async {
    if (_isolatePrepared) return;
    _isolatePrepared = true;
    await tester.runAsync(() async {
      final onError = FlutterError.onError;
      Logger.instance;
      FlutterError.onError = onError;
      SharedPreferences.setMockInitialValues({});
      PackageInfo.setMockInitialValues(
        appName: 'privacyIDEA Authenticator',
        packageName: 'it.netknights.piauthenticator',
        version: testAppVersion,
        buildNumber: '408101',
        buildSignature: '',
      );
      await SharedPreferences.getInstance();
      await PreferenceSettingsRepository().loadSettings();
      await PreferenceTokenFolderRepository().loadState();
      await PreferenceIntroductionRepository().loadCompletedIntroductions();
      await AppInfoUtils.init();
      PlatformFakes.installAppLinks();
      await Future.wait(sources.map((source) => source.initialUri));
      for (final source in sources) {
        source.stream.listen((_) {});
      }
    });
  }

  /// Installs an empty device. Seed [storage] afterwards, then [start].
  static Future<AppHarness> prepare(
    WidgetTester tester, {
    RsaUtils? rsaUtils,
    bool returningUser = true,
  }) async {
    final logs = LogCapture.install();
    await _prepareIsolate(tester);
    final platform = PlatformFakes.install();
    final storage = await FakeDeviceStorage.install();
    if (returningUser) {
      await storage.seedReturningUser(appVersion: testAppVersion);
    }
    final harness = AppHarness._(
      tester: tester,
      storage: storage,
      backend: FakeBackend(),
      platform: platform,
      logs: logs,
      rsaUtils: rsaUtils ?? const RsaUtils(),
    );
    harness._newPushProvider();

    harness.setScreen(phoneScreen);
    addTearDown(tester.view.reset);
    addTearDown(platform.uninstall);
    return harness;
  }

  /// A 1080x2340 phone at 2.625 device pixels per logical pixel.
  static const phoneScreen = Size(411.43, 891.43);

  /// The test font draws every glyph one em wide, about twice as wide as the
  /// app's real fonts, so a row of large digits that fits on a phone can
  /// overflow in a test. Such a test runs on a wider screen.
  static const wideScreen = Size(800, 891.43);

  void setScreen(Size logicalSize) {
    tester.view.devicePixelRatio = 2.625;
    tester.view.physicalSize = logicalSize * 2.625;
  }

  void _newPushProvider() {
    globalRef = null;
    PushProvider.instance = null;
    pushProvider = PushProvider(
      ioClient: backend,
      rsaUtils: rsaUtils,
      firebaseUtils: firebaseUtils,
    );
  }

  List<Override> get _overrides => [
    tokenProvider.overrideWith(
      () => TokenNotifier(
        ioClientOverride: backend,
        rsaUtilsOverride: rsaUtils,
        firebaseUtilsOverride: firebaseUtils,
      ),
    ),
    pushRequestProvider.overrideWith(
      () => PushRequestNotifier(
        ioClientOverride: backend,
        rsaUtilsOverride: rsaUtils,
        pushProviderOverride: pushProvider,
      ),
    ),
    tokenContainerProvider.overrideWith(
      () => TokenContainerNotifier(
        containerApiOverride: PiContainerApi(ioClient: backend),
      ),
    ),
  ];

  /// Starts the app like main() does and waits for the main view.
  Future<void> start({
    bool untilMainView = true,
    ApplicationCustomization? customization,
  }) async {
    assert(!_started, 'The app is already running.');
    _started = true;
    await initializeApp();
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides,
        child: AppWrapper(
          child: PrivacyIDEAAuthenticator(
            customization ?? ApplicationCustomization.defaultCustomization,
          ),
        ),
      ),
    );
    container.listen<StatusState>(statusProvider, (_, next) {
      final current = next.current;
      if (current == null) return;
      final details = current.details?.call(l10n);
      statusMessages.add(
        '${current.message(l10n)}${details != null ? ' ($details)' : ''}',
      );
    }, fireImmediately: true);
    if (untilMainView) {
      await pumpUntilFound(find.byType(MainView), reason: 'app start');
    }
  }

  /// Ends the app the way the OS kills it: the widget tree and every provider
  /// are disposed, the storage stays. Fake time runs on so that delayed work
  /// the app scheduled cannot leak into the next test.
  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    await tester.pumpWidget(const SizedBox());
    pushProvider.setPollingEnabled(false);
    globalRef = null;
    PushProvider.instance = null;
    for (var i = 0; i < 18; i++) {
      await _yieldToRealZone();
      await tester.pump(const Duration(seconds: 10));
    }
  }

  /// Kills the app and starts it again on the same device.
  Future<void> restart() async {
    await stop();
    _newPushProvider();
    await start();
  }

  /// The root container, which holds every provider of the running app.
  ProviderContainer get container => ProviderScope.containerOf(
    tester.element(find.byType(AppWrapper)),
    listen: false,
  );

  TokenState get tokenState => container.read(tokenProvider).requireValue;

  PushRequestState get pushRequestState =>
      container.read(pushRequestProvider).requireValue;

  /// Lets the real event loop run the callbacks of futures that were created
  /// in the real zone, see [_prepareIsolate].
  Future<void> _yieldToRealZone() => tester.runAsync(() async {});

  /// Pumps frames in steps of [step] fake time until [condition] holds.
  Future<void> pumpUntil(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 30),
    Duration step = const Duration(milliseconds: 100),
    String? reason,
  }) async {
    var waited = Duration.zero;
    while (!condition()) {
      if (waited >= timeout) {
        throw TestFailure(
          'Timed out after $timeout waiting for ${reason ?? 'condition'}.\n'
          'Requests: ${backend.requests}\n'
          'Errors: ${logs.errors.join('\n')}',
        );
      }
      await _yieldToRealZone();
      await tester.pump(step);
      waited += step;
    }
  }

  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
    String? reason,
  }) => pumpUntil(
    () => finder.evaluate().isNotEmpty,
    timeout: timeout,
    reason: reason ?? '$finder',
  );

  Future<void> pumpUntilGone(
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
    String? reason,
  }) => pumpUntil(
    () => finder.evaluate().isEmpty,
    timeout: timeout,
    reason: reason ?? 'gone: $finder',
  );

  /// Lets pending async work and animations of up to [duration] finish.
  Future<void> settle([Duration duration = const Duration(seconds: 1)]) async {
    final steps = duration.inMilliseconds ~/ 50;
    for (var i = 0; i < steps; i++) {
      await _yieldToRealZone();
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Pulls the token list down, which polls the push servers and syncs the
  /// containers. The list only offers it while there is something to fetch.
  Future<void> pullToRefresh() async {
    final indicator = find.byType(RefreshIndicator);
    await pumpUntilFound(indicator, reason: 'the pull to refresh indicator');
    await tester.fling(indicator.first, const Offset(0, 400), 1000);
    await settle(const Duration(seconds: 2));
  }

  Future<void> tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await settle(const Duration(milliseconds: 500));
  }

  void expectNoErrorLogs() {
    expect(
      logs.errors.toList(),
      isEmpty,
      reason: 'The app logged errors:\n${logs.errors.join('\n')}',
    );
  }
}

/// A widget test that runs the app on a fresh fake device. [body] seeds the
/// device, calls [AppHarness.start] and drives the flow; the app is stopped
/// afterwards.
void appTest(
  String description,
  Future<void> Function(AppHarness app) body, {
  String? skip,
  RsaUtils? rsaUtils,
  bool returningUser = true,
}) {
  testWidgets(
    skip == null ? description : '$description [skipped: $skip]',
    skip: skip != null,
    (tester) async {
      final app = await AppHarness.prepare(
        tester,
        rsaUtils: rsaUtils,
        returningUser: returningUser,
      );
      try {
        await body(app);
      } catch (_) {
        // A failed test still has to dispose the app, or its providers and
        // timers leak into the next test of the file.
        await app.stop().catchError((_) {});
        rethrow;
      }
      await app.stop();
    },
  );
}
