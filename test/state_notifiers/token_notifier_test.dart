import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/push_request_queue.dart';
import 'package:privacyidea_authenticator/model/states/token_state.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/network_utils.dart';
import 'package:privacyidea_authenticator/utils/qr_parser.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

import 'token_notifier_test.mocks.dart';

@GenerateMocks(
  [
    TokenRepository,
    QrParser,
    RsaUtils,
    CustomIOClient,
    FirebaseUtils,
    LegacyUtils,
  ],
)
void main() {
  _testTokenNotifier();
}

void _testTokenNotifier() {
  group('TokenNotifier', () {
    test('refreshRolledOutPushTokens', () async {
      final container = ProviderContainer();
      final mockRepo = MockTokenRepository();
      final before = <PushToken>[
        PushToken(label: 'label', issuer: 'issuer', id: 'id', serial: 'serial', isRolledOut: true, pushRequests: PushRequestQueue()),
      ];
      final queue = PushRequestQueue()
        ..add(PushRequest(
            title: 'title',
            question: 'question',
            uri: Uri.parse('https://example.com'),
            nonce: 'nonce',
            sslVerify: false,
            id: 1,
            expirationDate: DateTime.now().add(const Duration(minutes: 3))));
      final after = <PushToken>[
        PushToken(label: 'label', issuer: 'issuer', id: 'id', serial: 'serial', isRolledOut: true, pushRequests: queue),
      ];
      final responses = [before, after];
      when(mockRepo.loadAllTokens()).thenAnswer((_) async => responses.removeAt(0));
      final testProvider = StateNotifierProvider<TokenNotifier, TokenState>(
        (ref) => TokenNotifier(repository: mockRepo),
      );
      final notifier = container.read(testProvider.notifier);
      await notifier.isInitialized;
      expect(await notifier.refreshRolledOutPushTokens(), true);
      final state = container.read(testProvider);
      expect(state, isNotNull);
      expect(state.tokens, after);
      verify(mockRepo.loadAllTokens()).called(2);
    });
    test('getTokenFromId', () async {
      final container = ProviderContainer();
      final mockRepo = MockTokenRepository();
      final before = <Token>[
        HOTPToken(label: 'label', issuer: 'issuer', id: 'id', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret'),
      ];
      final after = before;
      when(mockRepo.loadAllTokens()).thenAnswer((_) async => before);
      final testProvider = StateNotifierProvider<TokenNotifier, TokenState>(
        (ref) => TokenNotifier(repository: mockRepo),
      );
      final notifier = container.read(testProvider.notifier);
      expect(await notifier.getTokenFromId(before.first.id), before.first);
      final state = container.read(testProvider);
      expect(state, isNotNull);
      expect(state.tokens, after);
    });
    test('incrementCounter', () async {
      final container = ProviderContainer();
      final mockRepo = MockTokenRepository();
      final before = <HOTPToken>[
        HOTPToken(label: 'label', issuer: 'issuer', id: 'id', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret', counter: 522),
      ];
      final after = <HOTPToken>[
        HOTPToken(label: 'label', issuer: 'issuer', id: 'id', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret', counter: 523),
      ];
      when(mockRepo.loadAllTokens()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceToken(after.first)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<TokenNotifier, TokenState>(
        (ref) => TokenNotifier(
          repository: mockRepo,
        ),
      );
      final notifier = container.read(testProvider.notifier);
      expect(await notifier.incrementCounter(before.first), true);
      final state = container.read(testProvider);
      expect(state, isNotNull);
      expect(state.tokens, after);
      verify(mockRepo.saveOrReplaceToken(after.first)).called(1);
    });
    test('removeToken', () async {
      final container = ProviderContainer();
      final mockRepo = MockTokenRepository();
      final before = <Token>[
        HOTPToken(label: 'label', issuer: 'issuer', id: 'id', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret'),
        HOTPToken(label: 'label2', issuer: 'issuer2', id: 'id2', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret2'),
      ];
      final after = <Token>[
        HOTPToken(label: 'label', issuer: 'issuer', id: 'id', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret'),
      ];
      when(mockRepo.loadAllTokens()).thenAnswer((_) async => before);
      when(mockRepo.deleteToken(before.last)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<TokenNotifier, TokenState>(
        (ref) => TokenNotifier(repository: mockRepo),
      );
      final notifier = container.read(testProvider.notifier);
      expect(await notifier.removeToken(before.last), true);
      final state = container.read(testProvider);
      expect(state, isNotNull);
      expect(state.tokens, after);
      verify(mockRepo.deleteToken(before.last)).called(1);
    });
    group('addOrReplaceToken', () {
      test('add Token', () async {
        final container = ProviderContainer();
        final mockRepo = MockTokenRepository();
        final before = <Token>[
          HOTPToken(label: 'label', issuer: 'issuer', id: 'id', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret'),
        ];
        final after = <Token>[
          HOTPToken(label: 'label', issuer: 'issuer', id: 'id', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret'),
          HOTPToken(label: 'label2', issuer: 'issuer2', id: 'id2', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret2'),
        ];
        when(mockRepo.loadAllTokens()).thenAnswer((_) async => before);
        when(mockRepo.saveOrReplaceToken(after.last)).thenAnswer((_) async => true);
        final testProvider = StateNotifierProvider<TokenNotifier, TokenState>(
          (ref) => TokenNotifier(
            repository: mockRepo,
          ),
        );
        final notifier = container.read(testProvider.notifier);
        expect(await notifier.addOrReplaceToken(after.last), true);
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state.tokens, after);
        verify(mockRepo.saveOrReplaceToken(after.last)).called(1);
      });
      test('replace Token', () async {
        final container = ProviderContainer();
        final mockRepo = MockTokenRepository();
        final before = <Token>[
          HOTPToken(label: 'label', issuer: 'issuer', id: 'id', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret'),
          HOTPToken(label: 'label2', issuer: 'issuer2', id: 'id2', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret2'),
        ];
        final after = <Token>[
          HOTPToken(label: 'label', issuer: 'issuer', id: 'id', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret'),
          HOTPToken(label: 'labelUpdated', issuer: 'issuer2Updated', id: 'id2', algorithm: Algorithms.SHA256, digits: 8, secret: 'secret2Updated'),
        ];
        when(mockRepo.loadAllTokens()).thenAnswer((_) async => before);
        when(mockRepo.saveOrReplaceToken(after.last)).thenAnswer((_) async => true);
        final testProvider = StateNotifierProvider<TokenNotifier, TokenState>(
          (ref) => TokenNotifier(
            repository: mockRepo,
          ),
        );
        final notifier = container.read(testProvider.notifier);
        expect(await notifier.addOrReplaceToken(after.last), true);
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state.tokens, after);
        verify(mockRepo.saveOrReplaceToken(after.last)).called(1);
      });
    });
    test('addOrReplaceTokens', () async {
      final container = ProviderContainer();
      final mockRepo = MockTokenRepository();
      final before = <Token>[
        HOTPToken(label: 'label', issuer: 'issuer', id: 'id', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret'),
      ];
      final after = <Token>[
        HOTPToken(label: 'label', issuer: 'issuer', id: 'id', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret'),
        HOTPToken(label: 'label2', issuer: 'issuer2', id: 'id2', algorithm: Algorithms.SHA256, digits: 6, secret: 'secret2'),
        HOTPToken(label: 'label3', issuer: 'issuer3', id: 'id3', algorithm: Algorithms.SHA512, digits: 8, secret: 'secret3'),
      ];
      final failingToken = HOTPToken(label: 'label4', issuer: 'issuer4', id: 'id4', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret4');
      when(mockRepo.loadAllTokens()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceTokens([...after, failingToken])).thenAnswer((_) async => [failingToken]);
      final testProvider = StateNotifierProvider<TokenNotifier, TokenState>(
        (ref) => TokenNotifier(
          repository: mockRepo,
        ),
      );
      final notifier = container.read(testProvider.notifier);
      expect(await notifier.addOrReplaceTokens([...after, failingToken]), [failingToken]);
      final state = container.read(testProvider);
      expect(state, isNotNull);
      expect(state.tokens, after);
    });
    test('addTokenFromOtpAuth', () async {
      final container = ProviderContainer();
      final mockRepo = MockTokenRepository();
      final mockQrParser = MockQrParser();
      final before = <Token>[
        HOTPToken(label: 'label', issuer: 'issuer', id: 'id', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret'),
      ];
      final after = <Token>[
        HOTPToken(label: 'label', issuer: 'issuer', id: 'id', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret'),
        HOTPToken(label: 'label2', issuer: 'issuer2', id: 'id2', algorithm: Algorithms.SHA256, digits: 6, secret: 'secret2'),
      ];
      when(mockRepo.loadAllTokens()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceToken(any)).thenAnswer((_) async => true);
      when(mockQrParser.parseQRCodeToMap('otpAuthString')).thenReturn({
        URI_LABEL: 'label2',
        URI_ISSUER: 'issuer2',
        URI_ALGORITHM: 'SHA256',
        URI_DIGITS: 6,
        URI_SECRET: Uint8List.fromList([73, 65, 63, 72, 65, 74, 32]),
        URI_TYPE: enumAsString(TokenTypes.HOTP),
      });
      when(mockQrParser.is2StepURI(any)).thenReturn(false);
      final testProvider = StateNotifierProvider<TokenNotifier, TokenState>(
        (ref) => TokenNotifier(repository: mockRepo, qrParser: mockQrParser),
      );
      final notifier = container.read(testProvider.notifier);
      expect(await notifier.addTokenFromOtpAuth(otpAuth: 'otpAuthString'), true);
      final state = container.read(testProvider);
      expect(state, isNotNull);
      after.last = after.last.copyWith(id: state.tokens.last.id);
      expect(state.tokens, after);
      verify(mockRepo.saveOrReplaceToken(any)).called(1);
    });
    test('addPushRequestToToken', () async {
      final container = ProviderContainer();
      final mockRepo = MockTokenRepository();
      final mockRsaUtils = MockRsaUtils();
      final before = <PushToken>[
        PushToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          serial: 'serial',
          isRolledOut: true,
          pushRequests: PushRequestQueue(),
          url: Uri.parse('https://example.com'),
          privateTokenKey: 'privateTokenKey',
        ).withPublicServerKey(RSAPublicKey(BigInt.one, BigInt.one)),
      ];
      final pr = PushRequest(
        title: 'title',
        question: 'question',
        uri: Uri.parse('https://example.com'),
        nonce: 'nonce',
        serial: 'serial',
        sslVerify: false,
        id: 1,
        expirationDate: DateTime.now().add(const Duration(minutes: 3)),
      );
      final after = <PushToken>[
        PushToken(label: 'label', issuer: 'issuer', id: 'id', serial: 'serial', isRolledOut: true, pushRequests: PushRequestQueue()..add(pr)),
      ];
      when(mockRepo.loadAllTokens()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceToken(after.first)).thenAnswer((_) async => true);
      when(mockRsaUtils.verifyRSASignature(any, any, any)).thenReturn(true);
      final testProvider = StateNotifierProvider<TokenNotifier, TokenState>(
        (ref) => TokenNotifier(repository: mockRepo, rsaUtils: mockRsaUtils),
      );
      final notifier = container.read(testProvider.notifier);
      expect(await notifier.addPushRequestToToken(pr), true);
      final state = container.read(testProvider);
      expect(state, isNotNull);
      expect(state.tokens, after);
      verify(mockRepo.saveOrReplaceToken(after.first)).called(1);
      verify(mockRsaUtils.verifyRSASignature(any, any, any)).called(1);
    });
    test('removePushRequest', () async {
      final container = ProviderContainer();
      final mockRepo = MockTokenRepository();
      final pr = PushRequest(
          title: 'title',
          question: 'question',
          uri: Uri.parse('https://example.com'),
          nonce: 'nonce',
          serial: 'serial',
          sslVerify: false,
          id: 1,
          expirationDate: DateTime.now().add(const Duration(minutes: 3)));
      final before = <PushToken>[
        PushToken(label: 'label', issuer: 'issuer', id: 'id', serial: 'serial', isRolledOut: true, pushRequests: PushRequestQueue()..add(pr)),
      ];
      final after = <PushToken>[
        PushToken(label: 'label', issuer: 'issuer', id: 'id', serial: 'serial', isRolledOut: true, pushRequests: PushRequestQueue()),
      ];
      when(mockRepo.loadAllTokens()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceToken(after.first)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<TokenNotifier, TokenState>(
        (ref) => TokenNotifier(repository: mockRepo),
      );
      final notifier = container.read(testProvider.notifier);
      expect(await notifier.removePushRequest(pr), true);
      final state = container.read(testProvider);
      expect(state, isNotNull);
      expect(state.tokens, after);
      verify(mockRepo.saveOrReplaceToken(after.first)).called(1);
    });
    test('rolloutPushToken', () async {
      final container = ProviderContainer();
      final mockRepo = MockTokenRepository();
      final mockIOClient = MockCustomIOClient();
      final mockFirebaseUtils = MockFirebaseUtils();
      final mockRsaUtils = MockRsaUtils();
      final uri = Uri.parse('https://example.com');
      final before = <PushToken>[
        PushToken(label: 'label', issuer: 'issuer', id: 'id', serial: 'serial', isRolledOut: false, url: uri),
      ];
      final after = <PushToken>[
        PushToken(label: 'label', issuer: 'issuer', id: 'id', serial: 'serial', isRolledOut: true, url: uri),
      ];
      when(mockRepo.loadAllTokens()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceToken(after.first)).thenAnswer((_) async => true);
      when(mockRsaUtils.serializeRSAPublicKeyPKCS8(any)).thenAnswer((_) => 'publicKey');
      when(mockRsaUtils.generateRSAKeyPair()).thenAnswer((_) => const RsaUtils()
          .generateRSAKeyPair()); // We get here a random result anyway and is it more likely to make errors by mocking it than by using the real method
      when(mockFirebaseUtils.getFBToken()).thenAnswer((_) => Future.value('fbToken'));
      when(mockRsaUtils.deserializeRSAPublicKeyPKCS1('publicKey')).thenAnswer((_) => RSAPublicKey(BigInt.one, BigInt.one));
      when(mockIOClient.doPost(
        url: anyNamed('url'),
        body: anyNamed('body'),
        sslVerify: anyNamed('sslVerify'),
      )).thenAnswer((_) => Future.value(Response('{"detail": {"public_key": "publicKey"}}', 200)));
      final testProvider = StateNotifierProvider<TokenNotifier, TokenState>(
        (ref) => TokenNotifier(
          repository: mockRepo,
          qrParser: MockQrParser(),
          rsaUtils: mockRsaUtils,
          ioClient: mockIOClient,
          firebaseUtils: mockFirebaseUtils,
        ),
      );
      final notifier = container.read(testProvider.notifier);
      expect(await notifier.rolloutPushToken(before.first), true);
      final state = container.read(testProvider);
      expect(state, isNotNull);
      expect(state.tokens, after);
      verify(mockRepo.saveOrReplaceToken(after.first)).called(greaterThan(0));
      verify(mockRsaUtils.serializeRSAPublicKeyPKCS8(any)).called(greaterThan(0));
      verify(mockFirebaseUtils.getFBToken()).called(2);
      verify(mockRsaUtils.deserializeRSAPublicKeyPKCS1('publicKey')).called(2);
      verify(mockIOClient.doPost(
        url: anyNamed('url'),
        body: anyNamed('body'),
        sslVerify: anyNamed('sslVerify'),
      )).called(2);
    });
  });
}
