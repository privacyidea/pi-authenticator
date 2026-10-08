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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// fake_async is a transitive dependency of flutter_test.
// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/push_request/push_capabilities.dart';
import 'package:privacyidea_authenticator/model/enums/push_token_rollout_state.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

import '../../../../../tests_app_wrapper.mocks.dart';

/// Waits for [check] to become true, throwing if [timeout] elapses first.
Future<void> _waitUntil(
  Future<bool> Function() check, {
  Duration timeout = const Duration(seconds: 5),
  Duration interval = const Duration(milliseconds: 20),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    if (await check()) return;
    await Future.delayed(interval);
  }
  throw TimeoutException('Condition not met within $timeout');
}

// ---- helpers of the former token_notifier_fixes_test.dart ----


ProviderContainer _container() {
  final mockSettingsRepo = MockSettingsRepository();
  when(mockSettingsRepo.loadSettings()).thenAnswer((_) async => SettingsState());
  final container = ProviderContainer(
    overrides: [
      settingsProvider.overrideWith(() => SettingsNotifier(repoOverride: mockSettingsRepo)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

HOTPToken _hotpWithCounter(String id, {int counter = 0}) => HOTPToken(
  label: 'label$id',
  issuer: 'issuer',
  id: id,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret$id',
  counter: counter,
);

// ---- helpers of the former token_notifier_show_hide_test.dart ----

/// Tests for TokenNotifier.showToken / showTokenById / hideToken /
/// hideLockedTokens / onMinimizeApp, including the hiding timer.
///
/// Everything runs inside `fakeAsync`: the hiding timers are driven with
/// `elapse` and never wait for real time.

int _idCounter = 0;

/// Ids are unique per token because the hiding timers live in a static map.
String _id(String name) => '${name}_${_idCounter++}';

HOTPToken _hotp(
  String id, {
  bool pin = false,
  bool? isHidden,
  ForceBiometricOption forceBiometricOption = ForceBiometricOption.none,
}) => HOTPToken(
  label: 'label $id',
  issuer: 'issuer',
  id: id,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret$id',
  pin: pin,
  isHidden: isHidden,
  forceBiometricOption: forceBiometricOption,
);

TOTPToken _totp(String id, {int period = 30, bool pin = true}) => TOTPToken(
  label: 'label $id',
  issuer: 'issuer',
  id: id,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret$id',
  period: period,
  pin: pin,
);

class _Env {
  final FakeAsync async;
  final ProviderContainer container;
  final TokenNotifierProvider provider;
  final MockTokenRepository repo;
  final MockLocalAuthentication localAuth;

  _Env(this.async, this.container, this.provider, this.repo, this.localAuth);

  TokenNotifier get notifier => container.read(provider.notifier);

  /// Completes [future] by flushing the fake microtask queue.
  T run<T>(Future<T> future) {
    late T result;
    Object? error;
    StackTrace? stackTrace;
    var done = false;
    future.then(
      (value) {
        result = value;
        done = true;
      },
      onError: (Object e, StackTrace s) {
        error = e;
        stackTrace = s;
        done = true;
      },
    );
    async.flushMicrotasks();
    if (!done) {
      throw StateError('Future did not complete within the fake microtasks');
    }
    if (error != null) Error.throwWithStackTrace(error!, stackTrace!);
    return result;
  }

  TokenState get state => run(container.read(provider.future));

  Token tokenOf(String id) => state.tokens.firstWhere((t) => t.id == id);

  /// The device offers a screen lock (and optionally enrolled biometrics).
  void supportedDevice({bool biometrics = false}) {
    when(localAuth.isDeviceSupported()).thenAnswer((_) async => true);
    if (biometrics) {
      when(localAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(
        localAuth.getAvailableBiometrics(),
      ).thenAnswer((_) async => [BiometricType.fingerprint]);
    }
  }

  void authResult(bool result) {
    when(
      localAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        biometricOnly: anyNamed('biometricOnly'),
        authMessages: anyNamed('authMessages'),
      ),
    ).thenAnswer((_) async => result);
  }

  void verifyAuthPrompts(int times, {bool? biometricOnly}) {
    verify(
      localAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        biometricOnly: biometricOnly ?? anyNamed('biometricOnly'),
        authMessages: anyNamed('authMessages'),
      ),
    ).called(times);
  }

  void verifyNoAuthPrompt() {
    verifyNever(localAuth.isDeviceSupported());
    verifyNever(
      localAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        biometricOnly: anyNamed('biometricOnly'),
        authMessages: anyNamed('authMessages'),
      ),
    );
  }

  /// Tokens passed to `repo.saveOrReplaceToken` so far.
  List<Token> get singleSaves =>
      verify(repo.saveOrReplaceToken(captureAny)).captured.cast<Token>();
}

void _fakeTest(
  String name,
  void Function(_Env env) body, {
  List<Token> tokens = const [],
  ForceBiometricOption appAuthMethod = ForceBiometricOption.any,
  String? skip,
}) {
  test(name, () {
    final localAuth = MockLocalAuthentication();
    localAuthInstance = localAuth;
    resetAuthMutex();
    addTearDown(() {
      localAuthInstance = LocalAuthentication();
      resetAuthMutex();
    });

    fakeAsync((async) {
      final settingsRepo = MockSettingsRepository();
      when(settingsRepo.loadSettings()).thenAnswer(
        (_) async => SettingsState(appAuthMethod: appAuthMethod),
      );
      when(settingsRepo.saveSettings(any)).thenAnswer((_) async => true);
      final repo = MockTokenRepository();
      when(repo.loadTokens()).thenAnswer((_) async => tokens);
      when(repo.saveOrReplaceToken(any)).thenAnswer((_) async => true);
      when(repo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => SettingsNotifier(repoOverride: settingsRepo),
          ),
        ],
      );
      final provider = tokenProviderOf(
        repo: repo,
        rsaUtils: const RsaUtils(),
        ioClient: const PrivacyideaIOClient(),
        firebaseUtils: MockFirebaseUtils(),
      );
      final env = _Env(async, container, provider, repo, localAuth);
      // Materialize the token state and the settings (app auth method).
      env.run(container.read(provider.future));
      env.run(container.read(settingsProvider.future));
      clearInteractions(repo);

      body(env);
      container.dispose();
    });
  }, skip: skip);
}

void main() {
  _testTokenNotifier();
  _testTokenNotifierFixes();
  _testTokenNotifierShowHide();
}

void _testTokenNotifier() {
  group('TokenNotifier', () {
    test('loadStateFromRepo', () async {
      final mockSettingsRepo = MockSettingsRepository();
      when(
        mockSettingsRepo.loadSettings(),
      ).thenAnswer((_) async => SettingsState());
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => SettingsNotifier(repoOverride: mockSettingsRepo),
          ),
        ],
      );
      addTearDown(container.dispose);
      final mockRepo = MockTokenRepository();
      final mockFirebaseUtils = MockFirebaseUtils();
      final before = [
        PushToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          serial: 'serial',
          isRolledOut: true,
        ),
      ];
      final after = [
        PushToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          serial: 'serial',
          isRolledOut: true,
        ),
        PushToken(
          label: 'label2',
          issuer: 'issuer2',
          id: 'id2',
          serial: 'serial2',
          isRolledOut: true,
        ),
      ];
      final responses = [before, after];
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(mockRepo.loadTokens()).thenAnswer((_) async {
        return responses.removeAt(0);
      });
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(
        mockFirebaseUtils.getFBToken(),
      ).thenAnswer((_) async => 'mockFbToken');
      final testProvider = tokenProviderOf(
        repo: mockRepo,
        rsaUtils: const RsaUtils(),
        ioClient: const PrivacyideaIOClient(),
        firebaseUtils: mockFirebaseUtils,
      );
      expect((await container.read(testProvider.future)).tokens, before);
      expect((await container.read(testProvider.future)).tokens, before);
      expect(
        (await container.read(testProvider.notifier).loadStateFromRepo())
            ?.tokens,
        after,
      );
      final state = await container.read(testProvider.future);
      expect(state, isNotNull);
      expect(state.tokens, after);
      verify(mockRepo.loadTokens()).called(2);
    });
    test('getTokenFromId', () async {
      final mockSettingsRepo = MockSettingsRepository();
      when(
        mockSettingsRepo.loadSettings(),
      ).thenAnswer((_) async => SettingsState());
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => SettingsNotifier(repoOverride: mockSettingsRepo),
          ),
        ],
      );
      addTearDown(container.dispose);
      final mockRepo = MockTokenRepository();
      final mockFirebaseUtils = MockFirebaseUtils();
      final before = [
        HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
        ),
      ];
      final after = before;
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(mockRepo.loadTokens()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(
        mockFirebaseUtils.getFBToken(),
      ).thenAnswer((_) async => 'mockFbToken');
      final testProvider = tokenProviderOf(
        repo: mockRepo,
        rsaUtils: const RsaUtils(),
        ioClient: const PrivacyideaIOClient(),
        firebaseUtils: mockFirebaseUtils,
      );
      final notifier = container.read(testProvider.notifier);
      expect(await notifier.getTokenById(before.first.id), before.first);
      final state = await container.read(testProvider.future);
      expect(state, isNotNull);
      expect(state.tokens, after);
    });
    test('incrementCounter uses the latest counter for queued calls', () async {
      final mockSettingsRepo = MockSettingsRepository();
      when(
        mockSettingsRepo.loadSettings(),
      ).thenAnswer((_) async => SettingsState());
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => SettingsNotifier(repoOverride: mockSettingsRepo),
          ),
        ],
      );
      addTearDown(container.dispose);
      final mockRepo = MockTokenRepository();
      final mockFirebaseUtils = MockFirebaseUtils();
      final before = [
        HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
          counter: 522,
        ),
      ];
      final after = [
        HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
          counter: 524,
        ),
      ];
      when(mockRepo.loadTokens()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceToken(any)).thenAnswer((_) async => true);
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(
        mockFirebaseUtils.getFBToken(),
      ).thenAnswer((_) async => 'mockFbToken');
      final testProvider = tokenProviderOf(
        repo: mockRepo,
        rsaUtils: const RsaUtils(),
        ioClient: const PrivacyideaIOClient(),
        firebaseUtils: mockFirebaseUtils,
      );
      final notifier = container.read(testProvider.notifier);
      final stateBefore = await container.read(testProvider.future);
      expect(stateBefore.tokens, before);
      await Future.wait([
        notifier.incrementCounter(before.first),
        notifier.incrementCounter(before.first),
      ]);
      final state = await container.read(testProvider.future);
      expect(state, isNotNull);
      expect(state.tokens, after);
      final savedTokens = verify(
        mockRepo.saveOrReplaceToken(captureAny),
      ).captured.cast<HOTPToken>();
      expect(savedTokens.map((token) => token.counter), [523, 524]);
    });
    test('removeToken', () async {
      final mockSettingsRepo = MockSettingsRepository();
      when(
        mockSettingsRepo.loadSettings(),
      ).thenAnswer((_) async => SettingsState());
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => SettingsNotifier(repoOverride: mockSettingsRepo),
          ),
        ],
      );
      addTearDown(container.dispose);
      final mockRepo = MockTokenRepository();
      final mockFirebaseUtils = MockFirebaseUtils();
      final before = <Token>[
        HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
        ),
        HOTPToken(
          label: 'label2',
          issuer: 'issuer2',
          id: 'id2',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret2',
        ),
      ];
      final after = <Token>[
        HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
        ),
      ];
      when(mockRepo.loadTokens()).thenAnswer((_) async => before);
      when(mockRepo.deleteToken(before.last)).thenAnswer((_) async => true);
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(
        mockFirebaseUtils.getFBToken(),
      ).thenAnswer((_) async => 'mockFbToken');
      final testProvider = tokenProviderOf(
        repo: mockRepo,
        rsaUtils: const RsaUtils(),
        ioClient: const PrivacyideaIOClient(),
        firebaseUtils: mockFirebaseUtils,
      );
      final notifier = container.read(testProvider.notifier);

      final stateBefore = await container.read(testProvider.future);
      expect(stateBefore.tokens, before);
      await notifier.removeToken(before.last);
      final state = await container.read(testProvider.future);
      expect(state, isNotNull);
      expect(state.tokens, after);
      verify(mockRepo.deleteToken(before.last)).called(1);
    });
    group('addOrReplaceToken', () {
      test('add new Token', () async {
        final mockSettingsRepo = MockSettingsRepository();
        when(
          mockSettingsRepo.loadSettings(),
        ).thenAnswer((_) async => SettingsState());
        final container = ProviderContainer(
          overrides: [
            settingsProvider.overrideWith(
              () => SettingsNotifier(repoOverride: mockSettingsRepo),
            ),
          ],
        );
        addTearDown(container.dispose);
        final mockRepo = MockTokenRepository();
        final mockFirebaseUtils = MockFirebaseUtils();
        final before = <Token>[
          HOTPToken(
            label: 'label',
            issuer: 'issuer',
            id: 'id',
            algorithm: Algorithms.SHA1,
            digits: 6,
            secret: 'secret',
          ),
        ];
        final after = <Token>[
          HOTPToken(
            label: 'label',
            issuer: 'issuer',
            id: 'id',
            algorithm: Algorithms.SHA1,
            digits: 6,
            secret: 'secret',
          ),
          HOTPToken(
            label: 'label2',
            issuer: 'issuer2',
            id: 'id2',
            algorithm: Algorithms.SHA1,
            digits: 6,
            secret: 'secret2',
          ),
        ];
        when(mockRepo.loadTokens()).thenAnswer((_) async => before);
        when(
          mockRepo.saveOrReplaceToken(after.last),
        ).thenAnswer((_) async => true);
        when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
        when(
          mockFirebaseUtils.getFBToken(),
        ).thenAnswer((_) async => 'mockFbToken');
        final testProvider = tokenProviderOf(
          repo: mockRepo,
          rsaUtils: const RsaUtils(),
          ioClient: const PrivacyideaIOClient(),
          firebaseUtils: mockFirebaseUtils,
        );
        final notifier = container.read(testProvider.notifier);

        final stateBefore = await container.read(testProvider.future);
        expect(stateBefore.tokens, before);
        await notifier.addOrReplaceToken(after.last);
        final state = await container.read(testProvider.future);
        expect(state, isNotNull);
        expect(state.tokens, after);
        verify(mockRepo.saveOrReplaceToken(after.last)).called(1);
      });
      test('replace Token', () async {
        final mockSettingsRepo = MockSettingsRepository();
        when(
          mockSettingsRepo.loadSettings(),
        ).thenAnswer((_) async => SettingsState());
        final container = ProviderContainer(
          overrides: [
            settingsProvider.overrideWith(
              () => SettingsNotifier(repoOverride: mockSettingsRepo),
            ),
          ],
        );
        addTearDown(container.dispose);
        final mockRepo = MockTokenRepository();
        final mockFirebaseUtils = MockFirebaseUtils();
        final before = <Token>[
          HOTPToken(
            label: 'label',
            issuer: 'issuer',
            id: 'id',
            algorithm: Algorithms.SHA1,
            digits: 6,
            secret: 'secret',
          ),
          HOTPToken(
            label: 'label2',
            issuer: 'issuer2',
            id: 'id2',
            algorithm: Algorithms.SHA1,
            digits: 6,
            secret: 'secret2',
          ),
        ];
        final after = <Token>[
          HOTPToken(
            label: 'label',
            issuer: 'issuer',
            id: 'id',
            algorithm: Algorithms.SHA1,
            digits: 6,
            secret: 'secret',
          ),
          HOTPToken(
            label: 'labelUpdated',
            issuer: 'issuer2Updated',
            id: 'id2',
            algorithm: Algorithms.SHA256,
            digits: 8,
            secret: 'secret2Updated',
          ),
        ];
        when(mockRepo.loadTokens()).thenAnswer((_) async => before);
        when(
          mockRepo.saveOrReplaceToken(after.last),
        ).thenAnswer((_) async => true);
        when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
        when(
          mockFirebaseUtils.getFBToken(),
        ).thenAnswer((_) async => 'mockFbToken');
        final testProvider = tokenProviderOf(
          repo: mockRepo,
          rsaUtils: const RsaUtils(),
          ioClient: const PrivacyideaIOClient(),
          firebaseUtils: mockFirebaseUtils,
        );
        final notifier = container.read(testProvider.notifier);

        final stateBefore = await container.read(testProvider.future);
        expect(stateBefore.tokens, before);
        await notifier.addOrReplaceToken(after.last);
        final state = await container.read(testProvider.future);
        expect(state, isNotNull);
        expect(state.tokens, after);
        verify(mockRepo.saveOrReplaceToken(after.last)).called(1);
      });
    });
    test('addOrReplaceTokens', () async {
      final mockSettingsRepo = MockSettingsRepository();
      when(
        mockSettingsRepo.loadSettings(),
      ).thenAnswer((_) async => SettingsState());
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => SettingsNotifier(repoOverride: mockSettingsRepo),
          ),
        ],
      );
      addTearDown(container.dispose);
      final mockRepo = MockTokenRepository();
      final mockFirebaseUtils = MockFirebaseUtils();
      final before = <Token>[
        HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
        ),
      ];
      final after = <Token>[
        HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
        ),
        HOTPToken(
          label: 'label2',
          issuer: 'issuer2',
          id: 'id2',
          algorithm: Algorithms.SHA256,
          digits: 6,
          secret: 'secret2',
        ),
        HOTPToken(
          label: 'label3',
          issuer: 'issuer3',
          id: 'id3',
          algorithm: Algorithms.SHA512,
          digits: 8,
          secret: 'secret3',
        ),
      ];
      when(mockRepo.loadTokens()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(
        mockRepo.saveOrReplaceTokens([...after]),
      ).thenAnswer((_) async => []);
      when(
        mockFirebaseUtils.getFBToken(),
      ).thenAnswer((_) async => 'mockFbToken');
      final testProvider = tokenProviderOf(
        repo: mockRepo,
        rsaUtils: const RsaUtils(),
        ioClient: const PrivacyideaIOClient(),
        firebaseUtils: mockFirebaseUtils,
      );
      final notifier = container.read(testProvider.notifier);
      await notifier.addOrReplaceTokens([...after]);
      final state = await container.read(testProvider.future);
      expect(state, isNotNull);
      expect(state.tokens, after);
    });
    test('addTokenFromOtpAuth', () async {
      WidgetsFlutterBinding.ensureInitialized();
      final mockSettingsRepo = MockSettingsRepository();
      when(
        mockSettingsRepo.loadSettings(),
      ).thenAnswer((_) async => SettingsState());

      final mockRepo = MockTokenRepository();
      final before = <Token>[
        HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
        ),
      ];
      final after = <Token>[
        HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
        ),
        TOTPToken(
          label: 'label2',
          issuer: 'issuer2',
          id: 'id2',
          algorithm: Algorithms.SHA256,
          digits: 6,
          secret: 'secret2',
          period: 30,
        ),
      ];
      when(mockRepo.loadTokens()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => SettingsNotifier(repoOverride: mockSettingsRepo),
          ),
          tokenProvider.overrideWith(
            () => TokenNotifier(repoOverride: mockRepo),
          ),
        ],
      );
      addTearDown(container.dispose);

      const qrCode =
          'otpauth://totp/issuer2:label2?secret=AAAAAAAA2&issuer=issuer2&algorithm=SHA256&digits=6&period=30';
      final tokenNotifier = container.read(tokenProvider.notifier);
      await scanQrCode(resultHandlerList: [tokenNotifier], qrCode: qrCode);
      await _waitUntil(
        () async =>
            (await container.read(tokenProvider.future)).tokens.length == 2,
      );
      final state = await container.read(tokenProvider.future);

      expect(state.tokens.length, 2);
      after.last = (after.last as TOTPToken).copyWith(id: state.tokens.last.id);
      expect(state.tokens, after);
      verify(mockRepo.saveOrReplaceTokens(any)).called(greaterThan(0));
    });
    test('addTokenFromOtpAuth: rolloutPushToken', () async {
      // -- PREPARE --
      WidgetsFlutterBinding.ensureInitialized();
      final mockSettingsRepo = MockSettingsRepository();
      when(
        mockSettingsRepo.loadSettings(),
      ).thenAnswer((_) async => SettingsState());
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => SettingsNotifier(repoOverride: mockSettingsRepo),
          ),
        ],
      );
      addTearDown(container.dispose);
      final mockTokenRepo = MockTokenRepository();
      final mockRsaUtils = MockRsaUtils();
      final mockIOClient = MockPrivacyideaIOClient();
      final mockFirebaseUtils = MockFirebaseUtils();
      const rsaUtils = RsaUtils();
      const publicServerKeyString =
          'MIICCgKCAgEAomCYODF47vz/axztjlmEcepqZPC8NNhXTlPu/FPGJ+qIOq+swTiEYgmv8DYIAslqLy3EHa7JUouSlE3f1l4OUcqZvPGgEP5Cpbjnaddy6u4Pt37YLDtlhX7nnd+VZnDLxXxqQ62e1CEOJVjKWq1x2Bq2GPcQz0fwWfGjNH7PtN+F00i3NiN0FPigOD4p7Bcru1ihWToQMobzf/p1945Yu0fwfpwUhHn0cfG5uKUrXl4T24s0b92MA8CmxYKKlenEQu9EezljeH2PJ0h1kfv58xjAEVEdwjCb8jzHwXomzJWUqZHt0BexavR+sUQNyk8r5OdX0fgOo+4W3/H+b/0Ktn47Frn827pYB8c2AX8lqxFocP6lj62hjCfKWss0rgqQBegTd9trCuN2iiw/Dj1HLFzK2Z8JwGDrQni1F8nyevaaZOuZI3I4DAFJzYKcP/zDvkNs6qpa+P1kzg50ml3m0RONGIHrzcSeo3aVeaMMdHXKhB5dqrig6Sjblqt2hwdPAWQPOiq9pTAXZIJmXI0UJb3bfWKlPIUmiZPRs+xYom+aZ9VEBTLdcxGC6puAJyUsjoXBJTJqH7O8g/pWA02UfPALEcuDAVQOSJbahodkWmrBg8jIMnjNOkN1t9hxHbg5XSWidgei4D/MJp4xH9w0eHyVZSnVTY5Iah0GkCVQFVsCAwEAAQ==';
      const publicTokenKeyString =
          'MIICCgKCAgEAuVWX4JptR4W2NHIMA4feqd/qUXKHAEfVUAKCYWdYEpq8x3tKWsFu9sVERA4rsTG+7Q6fEG1FdOSpJWVXW+paJpt7QDgp0/9VDr0Vn3bd6k7oYL2lDMm5NKEJA/Zk577OOXGogspksUkw3WtEg8meYB6mO8Tk+pPLmJnnLU2C+F8oeftRHQTXJhGMuWRLVhuA/hgMHUW7a7ICARiJhMz0hMWtQAzK0AHVxPDlybggYIYCSa2G5t53m62IDdOkb4LINpZVMCS2/tCDUJzVlzEmJF3G3cxxFaG3R4DkvkoUgLLpwdIj2Kw1FOJVkLyz1BJVfbmt6TvpsXc1G71yXk1p3MCFfilfiPY5U4LQfrR1A+F+rHFZtpQb2Hha1KMGGjBorHu5rpeFqLV1U2pL7CE/qjb/xUkVk1DbXH+26P3gLmrg2pm5TbMogskTUI29WDsklFj1LkH/sXRnWcIbYNp0QdN//FivlYFM4OxAoY1S1ofIu3Xj/rdVRtUvSE8kR7r1v6Xf6oHMkQIbS3mrQgJZNc0eV80TuCnT/YmvsTzT9jXGPQYUeZ4MvENnun7GB2TVdVgJ6srcknZgQGB2zWOUpf1I2xA9wzLTYhVpZKrU10eOxXr/Fao0tf2oNB+QldPRoUFL77z6VYHNIPFr9Yi/WFBVDl7gQ05hu+pVBNmhRN8CAwEAAQ==';
      const privateTokenKeyString =
          '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';
      final publicServerKey = rsaUtils.deserializeRSAPublicKeyPKCS1(
        publicServerKeyString,
      );
      final publicTokenKey = rsaUtils.deserializeRSAPublicKeyPKCS1(
        publicTokenKeyString,
      );
      final privateTokenKey = rsaUtils.deserializeRSAPrivateKeyPKCS1(
        privateTokenKeyString,
      );
      final before = <Token>[
        HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
        ),
      ];
      final pushTokenShouldBe = PushToken(
        label: 'PIPU0006BF18',
        issuer: 'privacyIDEA',
        id: '20663f77-a26e-41c3-8946-d0efb8b386d3',
        pin: false,
        serial: 'PIPU0006BF18',
        sslVerify: false,
        enrollmentCredentials: 'ae60d4744ac5384515574b85f538c6a4e0c7bc82',
        url: Uri.parse('https://192.168.178.30/ttype/push'),
        isRolledOut: true,
        rolloutState: PushTokenRollOutState.rolloutComplete,
        publicServerKey: publicServerKeyString,
        publicTokenKey: publicTokenKeyString,
        privateTokenKey: privateTokenKeyString,
        origin: TokenOriginSourceType.qrScan.toTokenOrigin(),
      );
      final after = <Token>[
        HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
        ),
        pushTokenShouldBe,
      ];
      const otpAuth =
          'otpauth://pipush/PIPU0006BF18?url=https%3A//192.168.178.30/ttype/push&ttl=10&issuer=privacyIDEA&enrollment_credential=ae60d4744ac5384515574b85f538c6a4e0c7bc82&v=1&serial=PIPU0006BF18&sslverify=0';
      when(mockFirebaseUtils.getFBToken()).thenAnswer((_) async => 'fbToken');
      when(mockTokenRepo.loadTokens()).thenAnswer((_) async => before);
      when(mockTokenRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(mockRsaUtils.generateRSAKeyPair()).thenAnswer(
        (realInvocation) async =>
            AsymmetricKeyPair(publicTokenKey, privateTokenKey),
      );
      when(
        mockRsaUtils.serializeRSAPublicKeyPKCS8(publicServerKey),
      ).thenReturn(publicServerKeyString);
      when(
        mockRsaUtils.serializeRSAPublicKeyPKCS8(publicTokenKey),
      ).thenReturn(publicTokenKeyString);
      when(
        mockRsaUtils.deserializeRSAPublicKeyPKCS1(publicServerKeyString),
      ).thenReturn(publicServerKey);
      when(
        mockRsaUtils.deserializeRSAPublicKeyPKCS1(publicTokenKeyString),
      ).thenReturn(publicTokenKey);
      when(
        mockRsaUtils.deserializeRSAPrivateKeyPKCS1(privateTokenKeyString),
      ).thenReturn(privateTokenKey);
      when(
        mockTokenRepo.saveOrReplaceTokens([after.last]),
      ).thenAnswer((_) async => []);
      when(
        mockTokenRepo.saveOrReplaceToken(after.last),
      ).thenAnswer((_) async => true);
      when(mockTokenRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(
        mockIOClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).thenAnswer(
        (_) async => Response(
          '{"detail": {"public_key": "$publicServerKeyString", "rollout_state": "enrolled", "serial": "PIPU0006BF18", "threadid": 140024860083968}, "id": 1, "jsonrpc": "2.0", "result": {"status": true, "value": true}, "time": 1701091444.6211884, "version": "privacyIDEA 3.9.dev3", "versionnumber": "3.9.dev3", "signature": "rsa_sha256_pss:c137b543b0df817ebd89ff53c5924c94f916c2bfebbe03ceb14e806ffdb46deb00fd336c83f3e0fb06ffbdf4926e83b5440f7f117498341608d644e4c1f2bbf9319eb59b98d5485c42b40325c9f29427cc8ae67728e486db247be0510a92f74936ea57436ecbe5304bcc50fcb624c3bde8e3039419592e9fbe8c0cb85431c2931ea8d6a6369fccf7e4c15c9cfaea896d8ec7896811545083bd6d3f5416e7d54b43f1f4752bf2a57c2b12a139fe217d1eec1292b071b9c6cef31e5f6eb957c7ad2a1d3bd105a74c80f961f5e307393824b8767807116a8573448f45f6cc112317105fb4e9e294f1a99faaf78b2f902ea1553cf5e428bfa98041c74cc23302df6f"}',
          200,
        ),
      );
      final testProvider = tokenProviderOf(
        repo: mockTokenRepo,
        ioClient: mockIOClient,
        rsaUtils: mockRsaUtils,
        firebaseUtils: mockFirebaseUtils,
      );

      final stateBefore = await container.read(testProvider.future);
      expect(stateBefore.tokens, before);

      // -- ACT --
      await scanQrCode(
        resultHandlerList: [container.read(testProvider.notifier)],
        qrCode: otpAuth,
      );

      // -- ASSERT --
      await _waitUntil(
        () async =>
            (await container.read(testProvider.future)).tokens.length == 2,
      );
      final tokenState = await container.read(testProvider.future);
      expect(tokenState, isNotNull);
      expect(tokenState.tokens, after);
      verify(mockRsaUtils.generateRSAKeyPair()).called(1);
      verify(
        mockIOClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).called(1);
    });
    test('rolloutPushToken', () async {
      final mockSettingsRepo = MockSettingsRepository();
      when(
        mockSettingsRepo.loadSettings(),
      ).thenAnswer((_) async => SettingsState());
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => SettingsNotifier(repoOverride: mockSettingsRepo),
          ),
        ],
      );
      addTearDown(container.dispose);
      final mockRepo = MockTokenRepository();
      final mockIOClient = MockPrivacyideaIOClient();
      final mockFirebaseUtils = MockFirebaseUtils();
      final mockRsaUtils = MockRsaUtils();
      final uri = Uri.parse('https://example.com');
      final before = <PushToken>[
        PushToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          serial: 'serial',
          isRolledOut: false,
          url: uri,
        ),
      ];
      final after = <PushToken>[
        PushToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          serial: 'serial',
          isRolledOut: true,
          url: uri,
        ),
      ];
      when(mockRepo.loadTokens()).thenAnswer((_) async => before);
      when(
        mockRepo.saveOrReplaceToken(after.first),
      ).thenAnswer((_) async => true);
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(
        mockRsaUtils.serializeRSAPublicKeyPKCS8(any),
      ).thenAnswer((_) => 'publicKey');
      when(
        mockRsaUtils.generateRSAKeyPair(),
      ).thenAnswer((_) => const RsaUtils().generateRSAKeyPair());
      when(
        mockFirebaseUtils.getFBToken(),
      ).thenAnswer((_) => Future.value('fbToken'));
      when(
        mockRsaUtils.deserializeRSAPublicKeyPKCS1('publicKey'),
      ).thenAnswer((_) => RSAPublicKey(BigInt.one, BigInt.one));
      when(
        mockIOClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).thenAnswer(
        (_) => Future.value(
          Response('{"detail": {"public_key": "publicKey"}}', 200),
        ),
      );
      final testProvider = tokenProviderOf(
        repo: mockRepo,
        ioClient: mockIOClient,
        rsaUtils: mockRsaUtils,
        firebaseUtils: mockFirebaseUtils,
      );

      final stateBefore = await container.read(testProvider.future);
      expect(stateBefore.tokens, before);
      expect(
        await container
            .read(testProvider.notifier)
            .rolloutPushToken(before.first),
        true,
      );
      final state = await container.read(testProvider.future);
      expect(state, isNotNull);
      expect(state.tokens, after);

      // privacyidea#5618 phase 1: "App includes a capabilities JSON array
      // (e.g. ["decline_reason"]) in the enrollment finalize request
      // (serial + fbtoken + pubkey)."
      final body =
          verify(
                mockIOClient.doPost(
                  url: anyNamed('url'),
                  body: captureAnyNamed('body'),
                  sslVerify: anyNamed('sslVerify'),
                ),
              ).captured.last
              as Map<String, String?>;
      expect(body.keys, containsAll(['serial', 'fbtoken', 'pubkey']));
      expect(body['capabilities'], '["decline_reason"]');
      expect(
        jsonDecode(body['capabilities']!),
        appPushCapabilities.names,
        reason: 'the announced names are the shared PushCapability vocabulary',
      );
    });
    test('updateFirebaseToken reports the app capabilities', () async {
      final mockSettingsRepo = MockSettingsRepository();
      when(
        mockSettingsRepo.loadSettings(),
      ).thenAnswer((_) async => SettingsState());
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => SettingsNotifier(repoOverride: mockSettingsRepo),
          ),
        ],
      );
      addTearDown(container.dispose);
      final mockRepo = MockTokenRepository();
      final mockIOClient = MockPrivacyideaIOClient();
      final mockRsaUtils = MockRsaUtils();
      final token = PushToken(
        id: 'id',
        serial: 'serial',
        isRolledOut: true,
        url: Uri.parse('https://example.com'),
      );
      when(mockRepo.loadTokens()).thenAnswer((_) async => [token]);
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(mockRepo.saveOrReplaceToken(any)).thenAnswer((_) async => true);
      when(
        mockRsaUtils.trySignWithToken(any, any),
      ).thenAnswer((_) async => 'signature');
      when(
        mockIOClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).thenAnswer((_) async => Response('{"result": {"status": true}}', 200));

      final testProvider = tokenProviderOf(
        repo: mockRepo,
        ioClient: mockIOClient,
        rsaUtils: mockRsaUtils,
        firebaseUtils: MockFirebaseUtils(),
      );
      await container.read(testProvider.future);
      expect(
        await container
            .read(testProvider.notifier)
            .updateFirebaseToken(token, 'newFbToken'),
        isTrue,
      );

      // privacyidea#5618 phase 2: "Refresh the stored set from the
      // already-signed poll / fbtoken-update channel".
      final body =
          verify(
                mockIOClient.doPost(
                  url: anyNamed('url'),
                  body: captureAnyNamed('body'),
                  sslVerify: anyNamed('sslVerify'),
                ),
              ).captured.last
              as Map<String, String?>;
      expect(body['capabilities'], '["decline_reason"]');

      final signed =
          verify(mockRsaUtils.trySignWithToken(any, captureAny)).captured.last
              as String;
      expect(signed, 'newFbToken|serial|${body['timestamp']}');
      expect(signed, isNot(contains('decline_reason')));
    });
    test(
      'removeTokens does not run push tokens through the generic bulk-delete path',
      () async {
        // Regression test: `otherTokens` used to be computed via
        // `tokens.whereType<Token>()`, which matches PushToken too (since
        // PushToken is a Token), causing push tokens to be deleted twice:
        // once via the generic bulk `deleteTokens` call and again via
        // `_removePushToken`'s dedicated cleanup path.
        final mockSettingsRepo = MockSettingsRepository();
        when(
          mockSettingsRepo.loadSettings(),
        ).thenAnswer((_) async => SettingsState());
        final container = ProviderContainer(
          overrides: [
            settingsProvider.overrideWith(
              () => SettingsNotifier(repoOverride: mockSettingsRepo),
            ),
          ],
        );
        addTearDown(container.dispose);
        final mockRepo = MockTokenRepository();
        final mockFirebaseUtils = MockFirebaseUtils();
        final regularToken = HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
        );
        final pushToken = PushToken(
          label: 'pushLabel',
          issuer: 'issuer',
          id: 'pushId',
          serial: 'serial',
          isRolledOut: true,
        );
        final before = <Token>[regularToken, pushToken];

        when(mockRepo.loadTokens()).thenAnswer((_) async => before);
        when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
        when(
          mockRepo.deleteTokens(any),
        ).thenAnswer((invocation) async => <Token>[]);
        when(mockRepo.deleteToken(pushToken)).thenAnswer((_) async => true);
        // Taking the "no firebase token available" branch inside
        // _removePushToken avoids needing to mock the network sync path.
        when(mockFirebaseUtils.getFBToken()).thenAnswer((_) async => null);
        final testProvider = tokenProviderOf(
          repo: mockRepo,
          rsaUtils: const RsaUtils(),
          ioClient: const PrivacyideaIOClient(),
          firebaseUtils: mockFirebaseUtils,
        );
        final notifier = container.read(testProvider.notifier);

        final stateBefore = await container.read(testProvider.future);
        expect(stateBefore.tokens, before);

        await notifier.removeTokens([regularToken, pushToken]);

        // The bulk delete must only ever be called with the non-push token.
        final captured =
            verify(mockRepo.deleteTokens(captureAny)).captured.single
                as List<Token>;
        expect(captured, [regularToken]);
        expect(captured.contains(pushToken), isFalse);

        // The push token is removed exactly once, via its own dedicated path.
        verify(mockRepo.deleteToken(pushToken)).called(1);
      },
    );
    test(
      'addNewTokens returns the tokens that failed to save instead of always []',
      () async {
        final mockSettingsRepo = MockSettingsRepository();
        when(
          mockSettingsRepo.loadSettings(),
        ).thenAnswer((_) async => SettingsState());
        final container = ProviderContainer(
          overrides: [
            settingsProvider.overrideWith(
              () => SettingsNotifier(repoOverride: mockSettingsRepo),
            ),
          ],
        );
        addTearDown(container.dispose);
        final mockRepo = MockTokenRepository();
        final mockFirebaseUtils = MockFirebaseUtils();
        final existing = HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
        );
        final newToken = HOTPToken(
          label: 'label2',
          issuer: 'issuer2',
          id: 'id2',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret2',
        );
        when(mockRepo.loadTokens()).thenAnswer((_) async => [existing]);
        // Simulate the repository failing to persist the new token.
        when(
          mockRepo.saveOrReplaceTokens(any),
        ).thenAnswer((_) async => [newToken]);
        when(
          mockFirebaseUtils.getFBToken(),
        ).thenAnswer((_) async => 'mockFbToken');
        final testProvider = tokenProviderOf(
          repo: mockRepo,
          rsaUtils: const RsaUtils(),
          ioClient: const PrivacyideaIOClient(),
          firebaseUtils: mockFirebaseUtils,
        );
        final notifier = container.read(testProvider.notifier);

        final failedTokens = await notifier.addNewTokens([newToken]);

        expect(failedTokens, [newToken]);
        // The failed token must not have been added to the state either.
        final state = await container.read(testProvider.future);
        expect(state.tokens, [existing]);
      },
    );
    test('loadFromRepo', () async {
      final mockSettingsRepo = MockSettingsRepository();
      when(
        mockSettingsRepo.loadSettings(),
      ).thenAnswer((_) async => SettingsState());
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => SettingsNotifier(repoOverride: mockSettingsRepo),
          ),
        ],
      );
      addTearDown(container.dispose);
      final mockRepo = MockTokenRepository();
      final mockFirebaseUtils = MockFirebaseUtils();
      final before = <Token>[
        HOTPToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret',
        ),
      ];
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(mockRepo.loadTokens()).thenAnswer((_) => Future.value(before));
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(
        mockFirebaseUtils.getFBToken(),
      ).thenAnswer((_) async => 'mockFbToken');
      final testProvider = tokenProviderOf(
        repo: mockRepo,
        rsaUtils: const RsaUtils(),
        ioClient: const PrivacyideaIOClient(),
        firebaseUtils: mockFirebaseUtils,
      );
      final newState = await container
          .read(testProvider.notifier)
          .loadStateFromRepo();
      expect(newState?.tokens, before);
      expect((await container.read(testProvider.future)).tokens, before);
    });
  });
}

void _testTokenNotifierFixes() {
  group('TokenNotifier fixes since v4.7.3', () {
    group('rollout error status details', () {
      Future<StatusMessage?> rolloutWith(Response response) async {
        final container = _container();
        final mockRepo = MockTokenRepository();
        final mockIOClient = MockPrivacyideaIOClient();
        final mockFirebaseUtils = MockFirebaseUtils();
        final mockRsaUtils = MockRsaUtils();
        final token = PushToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          serial: 'serial',
          isRolledOut: false,
          url: Uri.parse('https://example.com'),
        );
        when(mockRepo.loadTokens()).thenAnswer((_) async => [token]);
        when(mockRepo.saveOrReplaceToken(any)).thenAnswer((_) async => true);
        when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
        when(mockRsaUtils.serializeRSAPublicKeyPKCS8(any)).thenAnswer((_) => 'publicKey');
        when(mockRsaUtils.generateRSAKeyPair()).thenAnswer((_) => const RsaUtils().generateRSAKeyPair());
        when(mockFirebaseUtils.getFBToken()).thenAnswer((_) => Future.value('fbToken'));
        when(mockRsaUtils.deserializeRSAPublicKeyPKCS1('publicKey')).thenAnswer((_) => RSAPublicKey(BigInt.one, BigInt.one));
        when(
          mockIOClient.doPost(url: anyNamed('url'), body: anyNamed('body'), sslVerify: anyNamed('sslVerify')),
        ).thenAnswer((_) async => response);
        final testProvider = tokenProviderOf(repo: mockRepo, ioClient: mockIOClient, rsaUtils: mockRsaUtils, firebaseUtils: mockFirebaseUtils);
        await container.read(testProvider.future);
        expect(await container.read(testProvider.notifier).rolloutPushToken(token), isFalse);
        return container.read(statusProvider).current;
      }

      test('no message in the response shows the status code as details', () async {
        final status = await rolloutWith(Response('{"result": {"status": false}}', 500));
        expect(status, isNotNull);
        final l = AppLocalizationsEn();
        expect(status!.message(l), l.errorRollOutFailed('label'));
        expect(status.details!(l), l.statusCode(500));
      });

      test('empty body shows the status code as details', () async {
        final status = await rolloutWith(Response('', 500));
        final l = AppLocalizationsEn();
        expect(status!.details!(l), l.statusCode(500));
      });

      test('message in the response is shown as details', () async {
        final status = await rolloutWith(Response('{"result": {"error": {"message": "Enrollment broke"}}}', 500));
        final l = AppLocalizationsEn();
        expect(status!.message(l), l.errorRollOutFailed('label'));
        expect(status.details!(l), 'Enrollment broke');
      });
    });

    group('failed tokens are returned', () {
      test('addOrReplaceTokens returns the tokens that failed to save', () async {
        final container = _container();
        final mockRepo = MockTokenRepository();
        final existing = _hotpWithCounter('1');
        final newToken = _hotpWithCounter('2');
        when(mockRepo.loadTokens()).thenAnswer((_) async => [existing]);
        when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => [newToken]);
        final testProvider = tokenProviderOf(
          repo: mockRepo,
          rsaUtils: const RsaUtils(),
          ioClient: const PrivacyideaIOClient(),
          firebaseUtils: MockFirebaseUtils(),
        );
        final notifier = container.read(testProvider.notifier);
        await container.read(testProvider.future);
        expect(await notifier.addOrReplaceTokens([newToken]), [newToken]);
        expect((await container.read(testProvider.future)).tokens, [existing]);
      });

      test('failing single save returns the old token and leaves the state untouched', () async {
        final container = _container();
        final mockRepo = MockTokenRepository();
        final t1 = _hotpWithCounter('1');
        final t2 = _hotpWithCounter('2');
        when(mockRepo.loadTokens()).thenAnswer((_) async => [t1, t2]);
        when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
        when(mockRepo.saveOrReplaceToken(any)).thenAnswer((_) async => false);
        final testProvider = tokenProviderOf(
          repo: mockRepo,
          rsaUtils: const RsaUtils(),
          ioClient: const PrivacyideaIOClient(),
          firebaseUtils: MockFirebaseUtils(),
        );
        final notifier = container.read(testProvider.notifier);
        await container.read(testProvider.future);
        final result = await notifier.incrementCounter(t1);
        // Token == only compares the id, so the counter has to be checked.
        expect(result!.counter, 0);
        final tokens = (await container.read(testProvider.future)).tokens;
        expect(tokens, [t1, t2]);
        expect((tokens.first as HOTPToken).counter, 0);
      });
    });

    test('updateFirebaseToken: state contains the new fbToken once it returned', () async {
      final container = _container();
      final mockRepo = MockTokenRepository();
      final mockIOClient = MockPrivacyideaIOClient();
      final mockRsaUtils = MockRsaUtils();
      final token = PushToken(id: 'id', serial: 'serial', isRolledOut: true, url: Uri.parse('https://example.com'));
      when(mockRepo.loadTokens()).thenAnswer((_) async => [token]);
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      when(mockRepo.saveOrReplaceToken(any)).thenAnswer((_) async {
        // Slow save: a non-awaited update would not be applied yet.
        await Future.delayed(const Duration(milliseconds: 50));
        return true;
      });
      when(mockRsaUtils.trySignWithToken(any, any)).thenAnswer((_) async => 'signature');
      when(
        mockIOClient.doPost(url: anyNamed('url'), body: anyNamed('body'), sslVerify: anyNamed('sslVerify')),
      ).thenAnswer((_) async => Response('{"result": {"status": true}}', 200));
      final testProvider = tokenProviderOf(repo: mockRepo, ioClient: mockIOClient, rsaUtils: mockRsaUtils, firebaseUtils: MockFirebaseUtils());
      await container.read(testProvider.future);
      expect(await container.read(testProvider.notifier).updateFirebaseToken(token, 'newFb'), isTrue);
      final tokens = container.read(testProvider).value!.tokens;
      expect((tokens.single as PushToken).fbToken, 'newFb');
    });

    test('concurrent updateToken calls on the same token both apply', () async {
      final container = _container();
      final mockRepo = MockTokenRepository();
      final token = _hotpWithCounter('1');
      when(mockRepo.loadTokens()).thenAnswer((_) async => [token]);
      when(mockRepo.saveOrReplaceToken(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 20));
        return true;
      });
      when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      final testProvider = tokenProviderOf(
        repo: mockRepo,
        rsaUtils: const RsaUtils(),
        ioClient: const PrivacyideaIOClient(),
        firebaseUtils: MockFirebaseUtils(),
      );
      final notifier = container.read(testProvider.notifier);
      await container.read(testProvider.future);
      await Future.wait([
        notifier.updateToken<HOTPToken>(token, (t) => t.copyWith(counter: t.counter + 1)),
        notifier.updateToken<HOTPToken>(token, (t) => t.copyWith(counter: t.counter + 1)),
      ]);
      final state = await container.read(testProvider.future);
      expect((state.tokens.single as HOTPToken).counter, 2);
    });
  });
}

void _testTokenNotifierShowHide() {
  group('showToken', () {
    final deniedId = _id('denied');
    _fakeTest(
      'auth denied: returns null, the token stays hidden, nothing is persisted and no timer starts',
      tokens: [_hotp(deniedId, pin: true)],
      (env) {
        final token = env.tokenOf(deniedId) as HOTPToken;
        expect(token.isHidden, isTrue);
        env.supportedDevice();
        env.authResult(false);

        final result = env.run(env.notifier.showToken(token));

        expect(result, isNull);
        expect(env.tokenOf(deniedId).isHidden, isTrue);
        env.verifyAuthPrompts(1);
        env.async.elapse(const Duration(minutes: 2));
        verifyNever(env.repo.saveOrReplaceToken(any));
        expect(env.tokenOf(deniedId).isHidden, isTrue);
      },
    );

    final unsupportedId = _id('unsupported');
    _fakeTest(
      'device without any screen lock: returns null and the token stays hidden',
      tokens: [_hotp(unsupportedId, pin: true)],
      (env) {
        final token = env.tokenOf(unsupportedId) as HOTPToken;
        when(env.localAuth.isDeviceSupported()).thenAnswer((_) async => false);
        env.authResult(true);

        final result = env.run(env.notifier.showToken(token));

        expect(result, isNull);
        expect(env.tokenOf(unsupportedId).isHidden, isTrue);
        verifyNever(
          env.localAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        );
      },
    );

    final okId = _id('ok');
    _fakeTest(
      'auth success: token becomes visible, is persisted and hidden again after showDuration',
      tokens: [_hotp(okId, pin: true)],
      (env) {
        final token = env.tokenOf(okId) as HOTPToken;
        env.supportedDevice();
        env.authResult(true);

        final result = env.run(env.notifier.showToken(token));

        expect(result, isNotNull);
        expect(result!.id, okId);
        expect(result.isHidden, isFalse);
        expect(env.tokenOf(okId).isHidden, isFalse);
        expect(env.singleSaves.single.isHidden, isFalse);

        env.async.elapse(token.showDuration - const Duration(seconds: 1));
        expect(
          env.tokenOf(okId).isHidden,
          isFalse,
          reason: 'still visible one second before showDuration',
        );

        env.async.elapse(const Duration(seconds: 2));
        expect(
          env.tokenOf(okId).isHidden,
          isTrue,
          reason: 'hidden again after showDuration',
        );
        final saved = verify(
          env.repo.saveOrReplaceToken(captureAny),
        ).captured.cast<Token>();
        expect(saved.single.isHidden, isTrue);
        expect(saved.single.id, okId);
      },
    );

    final twiceId = _id('twice');
    _fakeTest(
      'showing a visible token again restarts the hiding timer',
      tokens: [_hotp(twiceId, pin: true)],
      (env) {
        final token = env.tokenOf(twiceId) as HOTPToken;
        env.supportedDevice();
        env.authResult(true);

        env.run(env.notifier.showToken(token));
        env.async.elapse(const Duration(seconds: 20));
        expect(env.run(env.notifier.showToken(token))?.isHidden, isFalse);

        // The first timer would fire at 30s, the second one at 50s.
        env.async.elapse(const Duration(seconds: 15));
        expect(
          env.tokenOf(twiceId).isHidden,
          isFalse,
          reason: 'the first timer was cancelled',
        );
        env.async.elapse(const Duration(seconds: 14));
        expect(env.tokenOf(twiceId).isHidden, isFalse);
        env.async.elapse(const Duration(seconds: 2));
        expect(env.tokenOf(twiceId).isHidden, isTrue);
        env.verifyAuthPrompts(2);
      },
    );

    final aId = _id('timerA');
    final bId = _id('timerB');
    _fakeTest(
      'hiding timers are independent per token',
      tokens: [_hotp(aId, pin: true), _hotp(bId, pin: true)],
      (env) {
        env.supportedDevice();
        env.authResult(true);

        env.run(env.notifier.showToken(env.tokenOf(aId) as HOTPToken));
        env.async.elapse(const Duration(seconds: 10));
        env.run(env.notifier.showToken(env.tokenOf(bId) as HOTPToken));

        env.async.elapse(const Duration(seconds: 21)); // t = 31s
        expect(env.tokenOf(aId).isHidden, isTrue);
        expect(env.tokenOf(bId).isHidden, isFalse);

        env.async.elapse(const Duration(seconds: 10)); // t = 41s
        expect(env.tokenOf(bId).isHidden, isTrue);
      },
    );

    final totpId = _id('totp');
    _fakeTest(
      'TOTP token stays visible for more than one period and is hidden after at most two',
      tokens: [_totp(totpId)],
      (env) {
        final token = env.tokenOf(totpId) as TOTPToken;
        env.supportedDevice();
        env.authResult(true);

        env.run(env.notifier.showToken(token));
        expect(env.tokenOf(totpId).isHidden, isFalse);

        // showDuration = period + secondsUntilNextOTP, so it lies in (30s, 60s].
        env.async.elapse(const Duration(seconds: 29));
        expect(env.tokenOf(totpId).isHidden, isFalse);

        env.async.elapse(const Duration(seconds: 32)); // t = 61s
        expect(env.tokenOf(totpId).isHidden, isTrue);
      },
    );

    final saveFailId = _id('saveFail');
    _fakeTest(
      'repository refuses to save: the old (hidden) token is returned and no timer is started',
      tokens: [_hotp(saveFailId, pin: true)],
      (env) {
        final token = env.tokenOf(saveFailId) as HOTPToken;
        env.supportedDevice();
        env.authResult(true);
        when(env.repo.saveOrReplaceToken(any)).thenAnswer((_) async => false);

        final result = env.run(env.notifier.showToken(token));

        expect(result, isNotNull);
        expect(result!.isHidden, isTrue);
        expect(env.tokenOf(saveFailId).isHidden, isTrue);
        verify(env.repo.saveOrReplaceToken(any)).called(1);

        env.async.elapse(const Duration(minutes: 2));
        // No timer: the hide path would try to save a second time.
        verifyNever(env.repo.saveOrReplaceToken(any));
      },
    );

    final missingId = _id('missing');
    _fakeTest(
      'token that is not in the state: null, no timer',
      (env) {
        env.supportedDevice();
        env.authResult(true);

        final result = env.run(
          env.notifier.showToken(_hotp(missingId, pin: true)),
        );

        expect(result, isNull);
        verifyNever(env.repo.saveOrReplaceToken(any));
        env.async.elapse(const Duration(minutes: 2));
        verifyNever(env.repo.saveOrReplaceToken(any));
      },
    );

    final concurrentId = _id('concurrent');
    _fakeTest(
      'a second showToken while the first authentication is running returns null',
      tokens: [_hotp(concurrentId, pin: true)],
      (env) {
        final token = env.tokenOf(concurrentId) as HOTPToken;
        env.supportedDevice();
        final completer = Completer<bool>();
        when(
          env.localAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).thenAnswer((_) => completer.future);

        final first = env.notifier.showToken(token);
        env.async.flushMicrotasks();
        final second = env.run(env.notifier.showToken(token));
        expect(second, isNull);

        completer.complete(true);
        final firstResult = env.run(first);

        expect(firstResult?.isHidden, isFalse);
        env.verifyAuthPrompts(1);
      },
    );

    group('which auth requirement reaches lockAuth', () {
      final bioId = _id('bio');
      _fakeTest(
        'token forceBiometricOption.biometric: biometric-only prompt, enrolment is checked',
        tokens: [
          _hotp(bioId, forceBiometricOption: ForceBiometricOption.biometric),
        ],
        (env) {
          final token = env.tokenOf(bioId) as HOTPToken;
          expect(token.isHidden, isTrue, reason: 'forced option implies locked');
          env.supportedDevice(biometrics: true);
          env.authResult(true);

          final result = env.run(env.notifier.showToken(token));

          expect(result?.isHidden, isFalse);
          env.verifyAuthPrompts(1, biometricOnly: true);
          verify(env.localAuth.getAvailableBiometrics()).called(1);
        },
      );

      final bioMissingId = _id('bioMissing');
      _fakeTest(
        'token forceBiometricOption.biometric without enrolled biometrics: null and no prompt',
        tokens: [
          _hotp(
            bioMissingId,
            forceBiometricOption: ForceBiometricOption.biometric,
          ),
        ],
        (env) {
          final token = env.tokenOf(bioMissingId) as HOTPToken;
          env.supportedDevice();
          when(env.localAuth.canCheckBiometrics).thenAnswer((_) async => true);
          when(
            env.localAuth.getAvailableBiometrics(),
          ).thenAnswer((_) async => []);
          env.authResult(true);

          final result = env.run(env.notifier.showToken(token));

          expect(result, isNull);
          expect(env.tokenOf(bioMissingId).isHidden, isTrue);
          verifyNever(
            env.localAuth.authenticate(
              localizedReason: anyNamed('localizedReason'),
              biometricOnly: anyNamed('biometricOnly'),
              authMessages: anyNamed('authMessages'),
            ),
          );
        },
      );

      final pinId = _id('pinOpt');
      _fakeTest(
        'token forceBiometricOption.any: device credentials allowed',
        tokens: [_hotp(pinId, forceBiometricOption: ForceBiometricOption.any)],
        (env) {
          final token = env.tokenOf(pinId) as HOTPToken;
          env.supportedDevice();
          env.authResult(true);

          env.run(env.notifier.showToken(token));

          env.verifyAuthPrompts(1, biometricOnly: false);
        },
      );

      final plainPinId = _id('plainPin');
      _fakeTest(
        'token with only a lock (pin) and app setting any: device credentials allowed',
        tokens: [_hotp(plainPinId, pin: true)],
        (env) {
          final token = env.tokenOf(plainPinId) as HOTPToken;
          env.supportedDevice();
          env.authResult(true);

          env.run(env.notifier.showToken(token));

          env.verifyAuthPrompts(1, biometricOnly: false);
        },
      );

      final appBioId = _id('appBio');
      _fakeTest(
        'app-wide biometric setting is merged into the request of a plain locked token',
        tokens: [_hotp(appBioId, pin: true)],
        appAuthMethod: ForceBiometricOption.biometric,
        (env) {
          final token = env.tokenOf(appBioId) as HOTPToken;
          env.supportedDevice(biometrics: true);
          env.authResult(true);

          final result = env.run(env.notifier.showToken(token));

          expect(result?.isHidden, isFalse);
          env.verifyAuthPrompts(1, biometricOnly: true);
        },
      );
    });
  });

  group('showTokenById', () {
    final pushId = _id('push');
    _fakeTest(
      'push token: null without any authentication',
      tokens: [PushToken(serial: 'serial', id: pushId, isLocked: true)],
      (env) {
        env.supportedDevice();
        env.authResult(true);

        final result = env.run(env.notifier.showTokenById(pushId));

        expect(result, isNull);
        env.verifyNoAuthPrompt();
        verifyNever(env.repo.saveOrReplaceToken(any));
      },
    );

    _fakeTest('unknown id: null without any authentication', (env) {
      env.supportedDevice();
      env.authResult(true);

      final result = env.run(env.notifier.showTokenById(_id('unknown')));

      expect(result, isNull);
      env.verifyNoAuthPrompt();
    });

    final otpId = _id('byId');
    _fakeTest(
      'OTP token: authenticates once, shows the token and hides it after showDuration',
      tokens: [_hotp(otpId, pin: true)],
      (env) {
        env.supportedDevice();
        env.authResult(true);

        final result = env.run(env.notifier.showTokenById(otpId));

        expect(result?.id, otpId);
        expect(result?.isHidden, isFalse);
        expect(env.tokenOf(otpId).isHidden, isFalse);
        env.verifyAuthPrompts(1);

        env.async.elapse(const Duration(seconds: 31));
        expect(env.tokenOf(otpId).isHidden, isTrue);
      },
    );

    final deniedId = _id('byIdDenied');
    _fakeTest(
      'OTP token with denied authentication: null and the token stays hidden',
      tokens: [_hotp(deniedId, pin: true)],
      (env) {
        env.supportedDevice();
        env.authResult(false);

        final result = env.run(env.notifier.showTokenById(deniedId));

        expect(result, isNull);
        expect(env.tokenOf(deniedId).isHidden, isTrue);
        env.verifyAuthPrompts(1);
      },
    );

    final bioId = _id('byIdBio');
    _fakeTest(
      'token forceBiometricOption is forwarded when shown by id',
      tokens: [
        _hotp(bioId, forceBiometricOption: ForceBiometricOption.biometric),
      ],
      (env) {
        env.supportedDevice(biometrics: true);
        env.authResult(true);

        env.run(env.notifier.showTokenById(bioId));

        env.verifyAuthPrompts(1, biometricOnly: true);
      },
    );
  });

  group('hideToken', () {
    final visibleId = _id('hide');
    _fakeTest(
      'hides a visible token and persists it',
      tokens: [_hotp(visibleId, pin: true, isHidden: false)],
      (env) {
        final token = env.tokenOf(visibleId) as HOTPToken;
        expect(token.isHidden, isFalse);

        final result = env.run(env.notifier.hideToken(token));

        expect(result?.isHidden, isTrue);
        expect(env.tokenOf(visibleId).isHidden, isTrue);
        expect(env.singleSaves.single.isHidden, isTrue);
        env.verifyNoAuthPrompt();
      },
    );

    _fakeTest('unknown token: null and nothing persisted', (env) {
      final result = env.run(
        env.notifier.hideToken(_hotp(_id('nope'), pin: true, isHidden: false)),
      );

      expect(result, isNull);
      verifyNever(env.repo.saveOrReplaceToken(any));
    });
  });

  group('hideLockedTokens', () {
    final lockedVisible = _id('lockedVisible');
    final lockedHidden = _id('lockedHidden');
    final unlocked = _id('unlocked');
    final biometricVisible = _id('biometricVisible');

    _fakeTest(
      'hides only locked tokens that are currently visible',
      tokens: [
        _hotp(lockedVisible, pin: true, isHidden: false),
        _hotp(lockedHidden, pin: true),
        _hotp(unlocked),
        _hotp(
          biometricVisible,
          forceBiometricOption: ForceBiometricOption.biometric,
          isHidden: false,
        ),
      ],
      (env) {
        expect(env.tokenOf(lockedVisible).isHidden, isFalse);
        expect(env.tokenOf(biometricVisible).isHidden, isFalse);

        final ok = env.run(env.notifier.hideLockedTokens());

        expect(ok, isTrue);
        expect(env.tokenOf(lockedVisible).isHidden, isTrue);
        expect(env.tokenOf(biometricVisible).isHidden, isTrue);
        expect(env.tokenOf(lockedHidden).isHidden, isTrue);
        expect(env.tokenOf(unlocked).isHidden, isFalse);
        expect(env.tokenOf(unlocked).isLocked, isFalse);

        final saved = (verify(
          env.repo.saveOrReplaceTokens(captureAny),
        ).captured.single as List).cast<Token>();
        expect(saved.map((t) => t.id).toSet(), {
          lockedVisible,
          biometricVisible,
        });
        env.verifyNoAuthPrompt();
      },
    );

    final alreadyHidden = _id('alreadyHidden');
    _fakeTest(
      'nothing to hide: returns true and does not touch the repository',
      tokens: [_hotp(alreadyHidden, pin: true), _hotp(_id('plain'))],
      (env) {
        final ok = env.run(env.notifier.hideLockedTokens());

        expect(ok, isTrue);
        verifyNever(env.repo.saveOrReplaceTokens(any));
        verifyNever(env.repo.saveOrReplaceToken(any));
      },
    );

    final failId = _id('failHide');
    _fakeTest(
      'repository fails to save the hidden token: hideLockedTokens reports failure',
      tokens: [_hotp(failId, pin: true, isHidden: false)],
      (env) {
        when(env.repo.saveOrReplaceTokens(any)).thenAnswer(
          (invocation) async =>
              (invocation.positionalArguments.first as List).cast<Token>(),
        );

        final ok = env.run(env.notifier.hideLockedTokens());

        expect(ok, isFalse);
      },
      skip:
          'BUG: token_notifier.dart:454-458 hideLockedTokens counts tokens that are still in the state, so a failed save is reported as success and onMinimizeApp never logs the failure',
    );

    final failStateId = _id('failHideState');
    _fakeTest(
      'repository fails to save the hidden token: the state keeps the token visible (characterization)',
      tokens: [_hotp(failStateId, pin: true, isHidden: false)],
      (env) {
        when(env.repo.saveOrReplaceTokens(any)).thenAnswer(
          (invocation) async =>
              (invocation.positionalArguments.first as List).cast<Token>(),
        );

        env.run(env.notifier.hideLockedTokens());

        // Characterization: the state is only updated for tokens that were
        // saved, so the token is still visible after the failed save.
        expect(env.tokenOf(failStateId).isHidden, isFalse);
      },
    );
  });

  group('onMinimizeApp', () {
    final shownId = _id('minimizeShown');
    final otherId = _id('minimizeOther');
    final plainId = _id('minimizePlain');
    _fakeTest(
      'hides tokens that were unlocked by the user and leaves unlocked tokens alone',
      tokens: [
        _hotp(shownId, pin: true),
        _hotp(otherId, pin: true),
        _hotp(plainId),
      ],
      (env) {
        env.supportedDevice();
        env.authResult(true);
        env.run(env.notifier.showToken(env.tokenOf(shownId) as HOTPToken));
        expect(env.tokenOf(shownId).isHidden, isFalse);

        final ok = env.run(env.notifier.onMinimizeApp());

        expect(ok, isTrue);
        expect(env.tokenOf(shownId).isHidden, isTrue);
        expect(env.tokenOf(otherId).isHidden, isTrue);
        expect(env.tokenOf(plainId).isHidden, isFalse);
      },
    );

    final timerId = _id('minimizeTimer');
    _fakeTest(
      'cancels pending hiding timers',
      tokens: [_hotp(timerId, pin: true)],
      (env) {
        env.supportedDevice();
        env.authResult(true);
        env.run(env.notifier.showToken(env.tokenOf(timerId) as HOTPToken));
        expect(env.singleSaves, hasLength(1));
        clearInteractions(env.repo);

        env.run(env.notifier.onMinimizeApp());
        expect(env.tokenOf(timerId).isHidden, isTrue);
        clearInteractions(env.repo);

        env.async.elapse(const Duration(minutes: 2));

        // A surviving timer would hide the token again via a single save.
        verifyNever(env.repo.saveOrReplaceToken(any));
      },
    );

    final againId = _id('minimizeAgain');
    _fakeTest(
      'a token shown after minimizing is hidden again by a new timer',
      tokens: [_hotp(againId, pin: true)],
      (env) {
        env.supportedDevice();
        env.authResult(true);
        env.run(env.notifier.showToken(env.tokenOf(againId) as HOTPToken));
        env.run(env.notifier.onMinimizeApp());
        expect(env.tokenOf(againId).isHidden, isTrue);

        env.run(env.notifier.showToken(env.tokenOf(againId) as HOTPToken));
        expect(env.tokenOf(againId).isHidden, isFalse);

        env.async.elapse(const Duration(seconds: 31));
        expect(env.tokenOf(againId).isHidden, isTrue);
      },
    );

    final noLockedId = _id('minimizeNoLocked');
    _fakeTest(
      'without locked tokens it succeeds and only reads state',
      tokens: [_hotp(noLockedId)],
      (env) {
        final ok = env.run(env.notifier.onMinimizeApp());

        expect(ok, isTrue);
        expect(env.tokenOf(noLockedId).isHidden, isFalse);
        verifyNever(env.repo.saveOrReplaceTokens(any));
      },
    );
  });
}
