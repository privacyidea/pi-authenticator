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
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/push_request/push_capabilities.dart';
import 'package:privacyidea_authenticator/model/enums/biometric_push_key_status.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/enums/push_app_biometric_level.dart';
import 'package:privacyidea_authenticator/model/enums/push_token_rollout_state.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
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

void main() {
  _testTokenNotifier();
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
    test('cold start persists native biometric invalidation', () async {
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
      final mockRsaUtils = MockRsaUtils();
      final before = PushToken(
        label: 'Push',
        issuer: 'issuer',
        id: 'push-id',
        serial: 'serial',
        isRolledOut: true,
        forceBiometricOption: ForceBiometricOption.biometric,
        biometricKeyStatus: BiometricPushKeyStatus.protected,
      );
      final invalidated = before.copyWith(
        privateTokenKey: () => null,
        biometricKeyStatus: BiometricPushKeyStatus.invalidated,
      );
      when(mockRepo.loadTokens()).thenAnswer((_) async => [before]);
      when(
        mockRepo.saveOrReplaceToken(invalidated),
      ).thenAnswer((_) async => true);
      when(mockRsaUtils.supportsBiometricPushKeyProtection).thenReturn(true);
      when(
        mockRsaUtils.biometricPushKeyStatus(before.id),
      ).thenAnswer((_) async => RsaUtils.biometricKeyStatusInvalidated);
      final testProvider = tokenProviderOf(
        repo: mockRepo,
        rsaUtils: mockRsaUtils,
        ioClient: const PrivacyideaIOClient(),
        firebaseUtils: MockFirebaseUtils(),
      );

      final state = await container.read(testProvider.future);

      expect(state.tokens.single, invalidated);
      verify(mockRepo.saveOrReplaceToken(invalidated)).called(1);
    });
    test(
      'cold start never revives a locally invalidated biometric key',
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
        final mockRsaUtils = MockRsaUtils();
        final invalidated = PushToken(
          label: 'Push',
          issuer: 'issuer',
          id: 'push-id',
          serial: 'serial',
          isRolledOut: true,
          forceBiometricOption: ForceBiometricOption.biometric,
          biometricKeyStatus: BiometricPushKeyStatus.invalidated,
        );
        when(mockRepo.loadTokens()).thenAnswer((_) async => [invalidated]);
        when(mockRsaUtils.supportsBiometricPushKeyProtection).thenReturn(true);
        when(
          mockRsaUtils.biometricPushKeyStatus(invalidated.id),
        ).thenAnswer((_) async => RsaUtils.biometricKeyStatusProtected);
        when(
          mockRsaUtils.deleteBiometricPushKey(invalidated.id),
        ).thenAnswer((_) async {});
        final testProvider = tokenProviderOf(
          repo: mockRepo,
          rsaUtils: mockRsaUtils,
          ioClient: const PrivacyideaIOClient(),
          firebaseUtils: MockFirebaseUtils(),
        );

        final state = await container.read(testProvider.future);

        expect(state.tokens.single, invalidated);
        verify(mockRsaUtils.deleteBiometricPushKey(invalidated.id)).called(1);
        verifyNever(mockRsaUtils.biometricPushKeyStatus(invalidated.id));
        verifyNever(mockRepo.saveOrReplaceToken(any));
      },
    );
    group('applyContainerSync', () {
      test(
        'does not recreate a token deleted during synchronization',
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
          when(mockRepo.loadTokens()).thenAnswer((_) async => <Token>[]);
          final staleUpdate = PushToken(
            id: 'deleted-push-id',
            serial: 'deleted-push-serial',
            label: 'server label',
            issuer: 'server issuer',
            url: Uri.parse('https://privacyidea.example/ttype/push'),
            isRolledOut: true,
            fbToken: 'stale-firebase-token',
          );
          final testProvider = tokenProviderOf(
            repo: mockRepo,
            rsaUtils: const RsaUtils(),
            ioClient: const PrivacyideaIOClient(),
            firebaseUtils: MockFirebaseUtils(),
          );
          await container.read(testProvider.future);

          final failed = await container
              .read(testProvider.notifier)
              .applyContainerSync(
                updatedTokens: [staleUpdate],
                newTokens: const [],
                checkedContainersByTokenId: const {},
              );

          expect(failed, isEmpty);
          expect((await container.read(testProvider.future)).tokens, isEmpty);
          verifyNever(mockRepo.saveOrReplaceTokens(any));
        },
      );

      test(
        'rebases server fields onto the latest local Push lifecycle state',
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
          final localOrigin = TokenOriginSourceType.manually.toTokenOrigin(
            data: 'local-origin-data',
            originName: 'Local enrollment',
            createdAt: DateTime.utc(2026),
          );
          final serverOrigin = TokenOriginSourceType.container.toTokenOrigin(
            data: 'server-origin-data',
            originName: 'Server container',
            isPrivacyIdeaToken: true,
            createdAt: DateTime.utc(2026, 1, 2),
          );
          final current = PushToken(
            id: 'push-id',
            serial: 'push-serial',
            label: 'local label',
            issuer: 'local issuer',
            containerSerial: 'old-container',
            checkedContainer: const ['already-checked'],
            folderId: 42,
            sortIndex: 7,
            origin: localOrigin,
            url: Uri.parse('https://local.example/ttype/push'),
            forceBiometricOption: ForceBiometricOption.biometric,
            invalidateOnBiometricChange: true,
            biometricKeyStatus: BiometricPushKeyStatus.protected,
            publicTokenKey: 'current-token-public-key',
            publicServerKey: 'current-server-public-key',
            isRolledOut: true,
            rolloutState: PushTokenRollOutState.rolloutComplete,
            fbToken: 'current-firebase-token',
          );
          final incoming = PushToken(
            id: current.id,
            serial: current.serial,
            label: 'server label',
            issuer: 'server issuer',
            containerSerial: 'new-container',
            checkedContainer: const ['stale-server-check'],
            folderId: 999,
            sortIndex: 999,
            origin: serverOrigin,
            url: Uri.parse('https://server.example/ttype/push'),
            forceBiometricOption: ForceBiometricOption.biometric,
            invalidateOnBiometricChange: true,
            publicTokenKey: 'stale-token-public-key',
            publicServerKey: 'stale-server-public-key',
            privateTokenKey: 'stale-private-key',
            isRolledOut: false,
            rolloutState: PushTokenRollOutState.rolloutNotStarted,
            fbToken: 'stale-firebase-token',
          );
          when(mockRepo.loadTokens()).thenAnswer((_) async => [current]);
          List<Token>? persisted;
          when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((
            invocation,
          ) async {
            persisted = List<Token>.from(
              invocation.positionalArguments.single as List<Token>,
            );
            return <Token>[];
          });
          final testProvider = tokenProviderOf(
            repo: mockRepo,
            rsaUtils: const RsaUtils(),
            ioClient: const PrivacyideaIOClient(),
            firebaseUtils: MockFirebaseUtils(),
          );
          await container.read(testProvider.future);

          final failed = await container
              .read(testProvider.notifier)
              .applyContainerSync(
                updatedTokens: [incoming],
                newTokens: const [],
                checkedContainersByTokenId: const {
                  'push-id': ['new-container'],
                },
              );

          final updated =
              (await container.read(testProvider.future)).tokens.single
                  as PushToken;
          expect(failed, isEmpty);
          expect(updated.label, 'server label');
          expect(updated.issuer, 'server issuer');
          expect(updated.url, Uri.parse('https://server.example/ttype/push'));
          expect(updated.containerSerial, 'new-container');
          expect(updated.origin, serverOrigin);
          expect(updated.checkedContainer, [
            'already-checked',
            'new-container',
          ]);
          expect(updated.folderId, 42);
          expect(updated.sortIndex, 7);
          expect(updated.fbToken, 'current-firebase-token');
          expect(updated.isRolledOut, isTrue);
          expect(updated.rolloutState, PushTokenRollOutState.rolloutComplete);
          expect(updated.publicServerKey, 'current-server-public-key');
          expect(updated.publicTokenKey, 'current-token-public-key');
          expect(updated.privateTokenKey, isNull);
          expect(updated.biometricKeyStatus, BiometricPushKeyStatus.protected);
          expect(persisted, hasLength(1));
          expect(persisted!.single, same(updated));
          verify(mockRepo.saveOrReplaceTokens(any)).called(1);
        },
      );

      test(
        'invalidates and removes the native key when binding is tightened',
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
          final mockRsaUtils = MockRsaUtils();
          final current = PushToken(
            id: 'push-id',
            serial: 'push-serial',
            label: 'local label',
            issuer: 'issuer',
            url: Uri.parse('https://privacyidea.example/ttype/push'),
            forceBiometricOption: ForceBiometricOption.biometric,
            invalidateOnBiometricChange: false,
            privateTokenKey: 'legacy-private-key',
            publicTokenKey: 'token-public-key',
            isRolledOut: true,
            rolloutState: PushTokenRollOutState.rolloutComplete,
            fbToken: 'firebase-token',
          );
          final incoming = current.copyWith(
            label: 'server label',
            invalidateOnBiometricChange: true,
          );
          when(mockRepo.loadTokens()).thenAnswer((_) async => [current]);
          when(
            mockRepo.saveOrReplaceTokens(any),
          ).thenAnswer((_) async => <Token>[]);
          when(
            mockRsaUtils.supportsBiometricPushKeyProtection,
          ).thenReturn(false);
          when(
            mockRsaUtils.deleteBiometricPushKey(current.id),
          ).thenAnswer((_) async {});
          final testProvider = tokenProviderOf(
            repo: mockRepo,
            rsaUtils: mockRsaUtils,
            ioClient: const PrivacyideaIOClient(),
            firebaseUtils: MockFirebaseUtils(),
          );
          await container.read(testProvider.future);

          final failed = await container
              .read(testProvider.notifier)
              .applyContainerSync(
                updatedTokens: [incoming],
                newTokens: const [],
                checkedContainersByTokenId: const {},
              );

          final updated =
              (await container.read(testProvider.future)).tokens.single
                  as PushToken;
          expect(failed, isEmpty);
          expect(updated.invalidateOnBiometricChange, isTrue);
          expect(
            updated.biometricKeyStatus,
            BiometricPushKeyStatus.invalidated,
          );
          expect(updated.privateTokenKey, isNull);
          final persisted =
              verify(mockRepo.saveOrReplaceTokens(captureAny)).captured.single
                  as List<Token>;
          final persistedPush = persisted.single as PushToken;
          expect(
            persistedPush.biometricKeyStatus,
            BiometricPushKeyStatus.invalidated,
          );
          expect(persistedPush.privateTokenKey, isNull);
          verify(mockRsaUtils.deleteBiometricPushKey(current.id)).called(1);
        },
      );

      test(
        'deduplicates repeated Push updates and keeps the strongest policies',
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
          final mockRsaUtils = MockRsaUtils();
          final current = PushToken(
            id: 'push-id',
            serial: 'push-serial',
            label: 'local label',
            issuer: 'issuer',
            url: Uri.parse('https://privacyidea.example/ttype/push'),
            biometricLevel: PushAppBiometricLevel.any,
            invalidateOnBiometricChange: false,
            privateTokenKey: 'legacy-private-key',
            publicTokenKey: 'token-public-key',
            isRolledOut: true,
            rolloutState: PushTokenRollOutState.rolloutComplete,
            fbToken: 'firebase-token',
          );
          final strict = current.copyWith(
            label: 'strict update',
            forceBiometricOption: ForceBiometricOption.biometric,
            biometricLevel: PushAppBiometricLevel.strong,
            invalidateOnBiometricChange: true,
          );
          final weakBiometric = current.copyWith(
            label: 'weak biometric update',
            forceBiometricOption: ForceBiometricOption.biometric,
            biometricLevel: PushAppBiometricLevel.any,
            invalidateOnBiometricChange: false,
          );
          final noBiometric = current.copyWith(
            label: 'no biometric update',
            forceBiometricOption: ForceBiometricOption.none,
            biometricLevel: PushAppBiometricLevel.any,
            invalidateOnBiometricChange: false,
          );
          when(mockRepo.loadTokens()).thenAnswer((_) async => [current]);
          when(
            mockRepo.saveOrReplaceTokens(any),
          ).thenAnswer((_) async => <Token>[]);
          when(
            mockRsaUtils.supportsBiometricPushKeyProtection,
          ).thenReturn(false);
          when(
            mockRsaUtils.deleteBiometricPushKey(current.id),
          ).thenAnswer((_) async {});
          final testProvider = tokenProviderOf(
            repo: mockRepo,
            rsaUtils: mockRsaUtils,
            ioClient: const PrivacyideaIOClient(),
            firebaseUtils: MockFirebaseUtils(),
          );
          await container.read(testProvider.future);

          final failed = await container
              .read(testProvider.notifier)
              .applyContainerSync(
                updatedTokens: [strict, weakBiometric, noBiometric],
                newTokens: const [],
                checkedContainersByTokenId: const {},
              );

          final updated =
              (await container.read(testProvider.future)).tokens.single
                  as PushToken;
          expect(failed, isEmpty);
          expect(updated.label, 'no biometric update');
          expect(updated.forceBiometricOption, ForceBiometricOption.biometric);
          expect(updated.biometricLevel, PushAppBiometricLevel.strong);
          expect(updated.invalidateOnBiometricChange, isTrue);
          expect(
            updated.biometricKeyStatus,
            BiometricPushKeyStatus.invalidated,
          );
          expect(updated.privateTokenKey, isNull);
          final persisted =
              verify(mockRepo.saveOrReplaceTokens(captureAny)).captured.single
                  as List<Token>;
          expect(persisted, hasLength(1));
          expect((persisted.single as PushToken).id, current.id);
          verify(mockRsaUtils.deleteBiometricPushKey(current.id)).called(1);
        },
      );

      test('matches bulk persistence failures by token id', () async {
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
        final mockRsaUtils = MockRsaUtils();
        PushToken token(String id, String label) => PushToken(
          id: id,
          serial: 'shared-serial',
          label: label,
          issuer: 'issuer',
          url: Uri.parse('https://privacyidea.example/ttype/push'),
          isRolledOut: true,
          rolloutState: PushTokenRollOutState.rolloutComplete,
          fbToken: 'firebase-token',
        );

        final first = token('first-id', 'first local');
        final second = token('second-id', 'second local');
        when(mockRepo.loadTokens()).thenAnswer((_) async => [first, second]);
        when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((invocation) async {
          final candidates =
              invocation.positionalArguments.single as List<Token>;
          return [candidates.singleWhere((token) => token.id == first.id)];
        });
        when(mockRsaUtils.supportsBiometricPushKeyProtection).thenReturn(false);
        final testProvider = tokenProviderOf(
          repo: mockRepo,
          rsaUtils: mockRsaUtils,
          ioClient: const PrivacyideaIOClient(),
          firebaseUtils: MockFirebaseUtils(),
        );
        await container.read(testProvider.future);

        final failed = await container
            .read(testProvider.notifier)
            .applyContainerSync(
              updatedTokens: [
                first.copyWith(label: 'first server'),
                second.copyWith(label: 'second server'),
              ],
              newTokens: const [],
              checkedContainersByTokenId: const {},
            );

        final state = await container.read(testProvider.future);
        expect(failed.map((token) => token.id), [first.id]);
        expect(state.currentOfId<PushToken>(first.id)!.label, 'first local');
        expect(state.currentOfId<PushToken>(second.id)!.label, 'second server');
      });

      test(
        'rebases a colliding new Push token by identity instead of duplicating it',
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
          final mockRsaUtils = MockRsaUtils();
          final current = PushToken(
            id: 'local-id',
            serial: 'PIPU01',
            label: 'local label',
            issuer: 'privacyIDEA',
            url: Uri.parse('https://privacyidea.example/ttype/push'),
            publicServerKey: 'server-key',
            publicTokenKey: 'public-key',
            privateTokenKey: 'private-key',
            enrollmentCredentials: 'credential',
            isRolledOut: true,
            rolloutState: PushTokenRollOutState.rolloutComplete,
            fbToken: 'firebase-token',
          );
          final incoming = current.copyWith(
            id: 'server-id',
            label: 'server label',
            containerSerial: () => 'CONTAINER01',
          );
          when(mockRepo.loadTokens()).thenAnswer((_) async => [current]);
          List<Token>? persisted;
          when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((
            invocation,
          ) async {
            persisted = List<Token>.from(
              invocation.positionalArguments.single as List<Token>,
            );
            return <Token>[];
          });
          when(
            mockRsaUtils.supportsBiometricPushKeyProtection,
          ).thenReturn(false);
          final testProvider = tokenProviderOf(
            repo: mockRepo,
            rsaUtils: mockRsaUtils,
            ioClient: const PrivacyideaIOClient(),
            firebaseUtils: MockFirebaseUtils(),
          );
          await container.read(testProvider.future);

          final failed = await container
              .read(testProvider.notifier)
              .applyContainerSync(
                updatedTokens: const [],
                newTokens: [incoming],
                checkedContainersByTokenId: const {
                  'server-id': ['CONTAINER01'],
                },
              );

          final tokenState = await container.read(testProvider.future);
          expect(failed, isEmpty);
          expect(tokenState.tokens, hasLength(1));
          expect(tokenState.tokens.single.id, current.id);
          expect(tokenState.tokens.single.label, 'server label');
          expect(
            tokenState.tokens.single.checkedContainer,
            contains('CONTAINER01'),
          );
          expect(persisted, hasLength(1));
          expect(persisted!.single.id, current.id);
          expect(persisted!.any((token) => token.id == incoming.id), isFalse);
        },
      );

      test(
        'fail-closes a new rolled-out strong Push token before saving',
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
          final mockRsaUtils = MockRsaUtils();
          final incoming = PushToken(
            id: 'server-id',
            serial: 'PIPU02',
            issuer: 'privacyIDEA',
            forceBiometricOption: ForceBiometricOption.biometric,
            biometricLevel: PushAppBiometricLevel.strong,
            invalidateOnBiometricChange: true,
            privateTokenKey: 'legacy-private-key',
            publicTokenKey: 'public-key',
            publicServerKey: 'server-key',
            isRolledOut: true,
            rolloutState: PushTokenRollOutState.rolloutComplete,
            fbToken: 'firebase-token',
          );
          when(mockRepo.loadTokens()).thenAnswer((_) async => <Token>[]);
          List<Token>? persisted;
          when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((
            invocation,
          ) async {
            persisted = List<Token>.from(
              invocation.positionalArguments.single as List<Token>,
            );
            return <Token>[];
          });
          when(
            mockRsaUtils.supportsBiometricPushKeyProtection,
          ).thenReturn(false);
          when(
            mockRsaUtils.deleteBiometricPushKey(incoming.id),
          ).thenAnswer((_) async {});
          final testProvider = tokenProviderOf(
            repo: mockRepo,
            rsaUtils: mockRsaUtils,
            ioClient: const PrivacyideaIOClient(),
            firebaseUtils: MockFirebaseUtils(),
          );
          await container.read(testProvider.future);

          final failed = await container
              .read(testProvider.notifier)
              .applyContainerSync(
                updatedTokens: const [],
                newTokens: [incoming],
                checkedContainersByTokenId: const {},
              );

          final saved = persisted!.single as PushToken;
          final current =
              (await container.read(testProvider.future)).tokens.single
                  as PushToken;
          expect(failed, isEmpty);
          expect(saved.biometricKeyStatus, BiometricPushKeyStatus.invalidated);
          expect(saved.privateTokenKey, isNull);
          expect(
            current.biometricKeyStatus,
            BiometricPushKeyStatus.invalidated,
          );
          expect(current.privateTokenKey, isNull);
          verify(mockRsaUtils.deleteBiometricPushKey(incoming.id)).called(1);
        },
      );

      test(
        'does not delete tokens when another container update cannot be saved',
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
          final toUpdate = HOTPToken(
            id: 'update-id',
            serial: 'HOTP-UPDATE',
            issuer: 'privacyIDEA',
            algorithm: Algorithms.SHA1,
            digits: 6,
            secret: 'JBSWY3DPEHPK3PXP',
            counter: 1,
          );
          final toDelete = HOTPToken(
            id: 'delete-id',
            serial: 'HOTP-DELETE',
            issuer: 'privacyIDEA',
            algorithm: Algorithms.SHA1,
            digits: 6,
            secret: 'JBSWY3DPEHPK3PXP',
            counter: 2,
          );
          when(
            mockRepo.loadTokens(),
          ).thenAnswer((_) async => [toUpdate, toDelete]);
          when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((
            invocation,
          ) async {
            return List<Token>.from(
              invocation.positionalArguments.single as List<Token>,
            );
          });
          final testProvider = tokenProviderOf(
            repo: mockRepo,
            rsaUtils: const RsaUtils(),
            ioClient: const PrivacyideaIOClient(),
            firebaseUtils: MockFirebaseUtils(),
          );
          await container.read(testProvider.future);

          final failed = await container
              .read(testProvider.notifier)
              .applyContainerSync(
                updatedTokens: [toUpdate.copyWith(counter: 3)],
                newTokens: const [],
                deletedTokens: [toDelete],
                checkedContainersByTokenId: const {},
              );

          final tokenState = await container.read(testProvider.future);
          expect(failed.map((token) => token.id), [toUpdate.id]);
          expect(tokenState.currentOfId<HOTPToken>(toUpdate.id)!.counter, 1);
          expect(tokenState.currentOfId<HOTPToken>(toDelete.id), isNotNull);
          verifyNever(mockRepo.deleteTokens(any));
        },
      );

      test('keeps a failed biometric tightening terminally blocked', () async {
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
        final mockRsaUtils = MockRsaUtils();
        final current = PushToken(
          id: 'push-id',
          serial: 'PIPU03',
          issuer: 'privacyIDEA',
          url: Uri.parse('https://privacyidea.example/ttype/push'),
          biometricLevel: PushAppBiometricLevel.any,
          invalidateOnBiometricChange: false,
          privateTokenKey: 'legacy-private-key',
          publicTokenKey: 'public-key',
          publicServerKey: 'server-key',
          isRolledOut: true,
          rolloutState: PushTokenRollOutState.rolloutComplete,
          fbToken: 'firebase-token',
        );
        final incoming = current.copyWith(
          forceBiometricOption: ForceBiometricOption.biometric,
          biometricLevel: PushAppBiometricLevel.strong,
          invalidateOnBiometricChange: true,
        );
        when(mockRepo.loadTokens()).thenAnswer((_) async => [current]);
        when(mockRepo.saveOrReplaceTokens(any)).thenAnswer((invocation) async {
          return List<Token>.from(
            invocation.positionalArguments.single as List<Token>,
          );
        });
        when(mockRepo.saveOrReplaceToken(any)).thenAnswer((_) async => true);
        when(mockRsaUtils.supportsBiometricPushKeyProtection).thenReturn(false);
        when(
          mockRsaUtils.deleteBiometricPushKey(current.id),
        ).thenAnswer((_) async {});
        final testProvider = tokenProviderOf(
          repo: mockRepo,
          rsaUtils: mockRsaUtils,
          ioClient: const PrivacyideaIOClient(),
          firebaseUtils: MockFirebaseUtils(),
        );
        await container.read(testProvider.future);

        final failed = await container
            .read(testProvider.notifier)
            .applyContainerSync(
              updatedTokens: [incoming],
              newTokens: const [],
              checkedContainersByTokenId: const {},
            );

        final blocked =
            (await container.read(testProvider.future)).tokens.single
                as PushToken;
        expect(failed.map((token) => token.id), [current.id]);
        expect(blocked.biometricKeyStatus, BiometricPushKeyStatus.invalidated);
        expect(blocked.privateTokenKey, isNull);
        verify(mockRepo.saveOrReplaceToken(any)).called(1);
        verify(mockRsaUtils.deleteBiometricPushKey(current.id)).called(1);
      });
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
    test('incrementCounter', () async {
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
          counter: 523,
        ),
      ];
      when(mockRepo.loadTokens()).thenAnswer((_) async => before);
      when(
        mockRepo.saveOrReplaceToken(after.first),
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
      await notifier.incrementCounter(before.first);
      final state = await container.read(testProvider.future);
      expect(state, isNotNull);
      expect(state.tokens, after);
      verify(mockRepo.saveOrReplaceToken(after.first)).called(1);
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
        mockRsaUtils.trySignWithToken(
          any,
          any,
          onTokenChanged: anyNamed('onTokenChanged'),
        ),
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
          verify(
                mockRsaUtils.trySignWithToken(
                  any,
                  captureAny,
                  onTokenChanged: anyNamed('onTokenChanged'),
                ),
              ).captured.last
              as String;
      expect(signed, 'newFbToken|serial|${body['timestamp']}');
      expect(signed, isNot(contains('decline_reason')));
    });
    test(
      'biometric rollout stops when protected state cannot be persisted',
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
        final mockIOClient = MockPrivacyideaIOClient();
        final mockFirebaseUtils = MockFirebaseUtils();
        final mockRsaUtils = MockRsaUtils();
        final before = PushToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          serial: 'serial',
          isRolledOut: false,
          isPollOnly: true,
          url: Uri.parse('https://example.com'),
          publicTokenKey: 'public-key',
          privateTokenKey: 'private-key',
          forceBiometricOption: ForceBiometricOption.biometric,
        );
        final protected = before.copyWith(
          privateTokenKey: () => null,
          biometricKeyStatus: BiometricPushKeyStatus.protected,
        );
        when(mockRepo.loadTokens()).thenAnswer((_) async => [before]);
        when(
          mockRepo.saveOrReplaceToken(protected),
        ).thenAnswer((_) async => false);
        when(
          mockRsaUtils.protectBiometricPushKey(any),
        ).thenAnswer((_) async {});
        final testProvider = tokenProviderOf(
          repo: mockRepo,
          ioClient: mockIOClient,
          rsaUtils: mockRsaUtils,
          firebaseUtils: mockFirebaseUtils,
        );
        await container.read(testProvider.future);

        final result = await container
            .read(testProvider.notifier)
            .rolloutPushToken(before);

        expect(result, isFalse);
        verifyNever(
          mockIOClient.doPost(
            url: anyNamed('url'),
            body: anyNamed('body'),
            sslVerify: anyNamed('sslVerify'),
          ),
        );
      },
    );
    test(
      'retry keeps the public key paired with a protected private key',
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
        final mockIOClient = MockPrivacyideaIOClient();
        final mockRsaUtils = MockRsaUtils();
        final keyPair = await const RsaUtils().generateRSAKeyPair();
        final publicKey = const RsaUtils().serializeRSAPublicKeyPKCS1(
          keyPair.publicKey,
        );
        final before = PushToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          serial: 'serial',
          isRolledOut: false,
          isPollOnly: true,
          url: Uri.parse('https://example.com'),
          publicTokenKey: publicKey,
          biometricKeyStatus: BiometricPushKeyStatus.protected,
          forceBiometricOption: ForceBiometricOption.biometric,
        );
        when(mockRepo.loadTokens()).thenAnswer((_) async => [before]);
        when(mockRepo.saveOrReplaceToken(any)).thenAnswer((_) async => true);
        when(
          mockRsaUtils.serializeRSAPublicKeyPKCS8(any),
        ).thenReturn('public-key-for-server');
        when(
          mockRsaUtils.deserializeRSAPublicKeyPKCS1('server-public-key'),
        ).thenReturn(RSAPublicKey(BigInt.one, BigInt.one));
        when(
          mockIOClient.doPost(
            url: anyNamed('url'),
            body: anyNamed('body'),
            sslVerify: anyNamed('sslVerify'),
          ),
        ).thenAnswer(
          (_) async =>
              Response('{"detail": {"public_key": "server-public-key"}}', 200),
        );
        final testProvider = tokenProviderOf(
          repo: mockRepo,
          ioClient: mockIOClient,
          rsaUtils: mockRsaUtils,
          firebaseUtils: MockFirebaseUtils(),
        );
        await container.read(testProvider.future);

        final result = await container
            .read(testProvider.notifier)
            .rolloutPushToken(before);

        expect(result, isTrue);
        verifyNever(mockRsaUtils.generateRSAKeyPair());
        verifyNever(mockRsaUtils.protectBiometricPushKey(any));
        verify(
          mockIOClient.doPost(
            url: anyNamed('url'),
            body: anyNamed('body'),
            sslVerify: anyNamed('sslVerify'),
          ),
        ).called(1);
      },
    );
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
      'removeTokens reflects partial bulk deletion success in memory',
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
        final deleted = HOTPToken(
          id: 'deleted-id',
          serial: 'HOTP-DELETED',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'deleted-secret',
        );
        final failed = HOTPToken(
          id: 'failed-id',
          serial: 'HOTP-FAILED',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'failed-secret',
        );
        when(mockRepo.loadTokens()).thenAnswer((_) async => [deleted, failed]);
        when(
          mockRepo.deleteTokens(any),
        ).thenAnswer((_) async => <Token>[failed]);
        final testProvider = tokenProviderOf(
          repo: mockRepo,
          rsaUtils: const RsaUtils(),
          ioClient: const PrivacyideaIOClient(),
          firebaseUtils: MockFirebaseUtils(),
        );
        final notifier = container.read(testProvider.notifier);
        await container.read(testProvider.future);

        await notifier.removeTokens([deleted, failed]);

        final tokenState = await container.read(testProvider.future);
        expect(tokenState.currentOfId(deleted.id), isNull);
        expect(tokenState.currentOfId(failed.id), isNotNull);
        expect(tokenState.tokens.map((token) => token.id), [failed.id]);
      },
    );
    test(
      'waits for native key cleanup before re-adding the same Push id',
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
        final mockRsaUtils = MockRsaUtils();
        final mockFirebaseUtils = MockFirebaseUtils();
        final current = PushToken(
          id: 'push-id',
          serial: 'PIPU-RACE',
          label: 'old',
          issuer: 'privacyIDEA',
          isRolledOut: true,
        );
        final replacement = PushToken(
          id: current.id,
          serial: 'PIPU-NEW',
          label: 'new',
          issuer: 'privacyIDEA',
          isRolledOut: true,
          fbToken: 'firebase-token',
        );
        final cleanupStarted = Completer<void>();
        final allowCleanup = Completer<void>();
        var saveStarted = false;
        when(mockRepo.loadTokens()).thenAnswer((_) async => [current]);
        when(mockRepo.deleteToken(current)).thenAnswer((_) async => true);
        when(mockRsaUtils.deleteBiometricPushKey(current.id)).thenAnswer((_) {
          cleanupStarted.complete();
          return allowCleanup.future;
        });
        when(mockRepo.saveOrReplaceToken(any)).thenAnswer((_) async {
          saveStarted = true;
          return true;
        });
        when(mockRsaUtils.supportsBiometricPushKeyProtection).thenReturn(false);
        final testProvider = tokenProviderOf(
          repo: mockRepo,
          rsaUtils: mockRsaUtils,
          ioClient: const PrivacyideaIOClient(),
          firebaseUtils: mockFirebaseUtils,
        );
        final notifier = container.read(testProvider.notifier);
        await container.read(testProvider.future);

        final removeFuture = notifier.removeToken(current);
        await cleanupStarted.future;
        final addFuture = notifier.addOrReplaceToken(replacement);
        await Future<void>.delayed(Duration.zero);

        expect(saveStarted, isFalse);
        allowCleanup.complete();
        await removeFuture;
        expect(await addFuture, isTrue);
        expect(saveStarted, isTrue);
        final tokenState = await container.read(testProvider.future);
        expect(tokenState.tokens, hasLength(1));
        expect(tokenState.tokens.single.id, replacement.id);
        expect(tokenState.tokens.single.label, replacement.label);
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
