import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

import '../../../../../tests_app_wrapper.mocks.dart';

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

HOTPToken _hotp(String id, {int counter = 0}) => HOTPToken(
  label: 'label$id',
  issuer: 'issuer',
  id: id,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret$id',
  counter: counter,
);

void main() {
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
        final existing = _hotp('1');
        final newToken = _hotp('2');
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
        final t1 = _hotp('1');
        final t2 = _hotp('2');
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
        expect(result, t1);
        expect((await container.read(testProvider.future)).tokens, [t1, t2]);
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
      final token = _hotp('1');
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
