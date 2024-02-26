import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/interfaces/repo/push_request_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/state_notifiers/push_request_notifier.dart';
import 'package:privacyidea_authenticator/utils/network_utils.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:mockito/annotations.dart';

import 'push_request_notifier_test.mocks.dart';

@GenerateMocks([RsaUtils, PrivacyIdeaIOClient, PushProvider, PushRequestRepository])
void main() {
  _testPushRequestNotifier();
}

void _testPushRequestNotifier() {
  group('PushRequestNotifier', () {
    test('add', () async {
      final container = ProviderContainer();
      final mockPushProvider = MockPushProvider();
      final mockPushRequestRepository = MockPushRequestRepository();
      final notifier = PushRequestNotifier(
        ioClient: MockPrivacyIdeaIOClient(),
        pushProvider: mockPushProvider,
        rsaUtils: MockRsaUtils(),
        pushRepo: mockPushRequestRepository,
      );
      final testProvider = StateNotifierProvider<PushRequestNotifier, PushRequestState>((ref) => notifier);
      final pr0 = PushRequest(
        title: 'title0',
        question: 'question0',
        uri: Uri.parse('https://example.com'),
        nonce: 'nonce0',
        sslVerify: false,
        id: 1,
        expirationDate: DateTime.now().add(const Duration(minutes: 10)),
      );
      final pr1 = PushRequest(
        title: 'title1',
        question: 'question1',
        uri: Uri.parse('https://example.com'),
        nonce: 'nonce0',
        sslVerify: false,
        id: 2,
        expirationDate: DateTime.now().add(const Duration(minutes: 10)),
      );
      final before = PushRequestState(pushRequests: [pr0]);
      final after = PushRequestState(pushRequests: [pr0, pr1]);
      when(mockPushRequestRepository.loadState()).thenAnswer((_) async => before);
      when(mockPushRequestRepository.saveState(any)).thenAnswer((_) async => []);
      await notifier.add(pr1);
      expect(container.read(testProvider), after);
    });

    test('remove', () async {
      final container = ProviderContainer();
      final mockPushProvider = MockPushProvider();
      final mockPushRequestRepository = MockPushRequestRepository();
      final notifier = PushRequestNotifier(
        ioClient: MockPrivacyIdeaIOClient(),
        pushProvider: mockPushProvider,
        rsaUtils: MockRsaUtils(),
        pushRepo: mockPushRequestRepository,
      );
      final testProvider = StateNotifierProvider<PushRequestNotifier, PushRequestState>((ref) => notifier);
      final pr0 = PushRequest(
        title: 'title0',
        question: 'question0',
        uri: Uri.parse('https://example.com'),
        nonce: 'nonce0',
        sslVerify: false,
        id: 1,
        expirationDate: DateTime.now().add(const Duration(minutes: 10)),
      );
      final pr1 = PushRequest(
        title: 'title1',
        question: 'question1',
        uri: Uri.parse('https://example.com'),
        nonce: 'nonce0',
        sslVerify: false,
        id: 2,
        expirationDate: DateTime.now().add(const Duration(minutes: 10)),
      );
      final before = PushRequestState(pushRequests: [pr0, pr1]);
      final after = PushRequestState(pushRequests: [pr0]);
      when(mockPushRequestRepository.loadState()).thenAnswer((_) async => before);
      when(mockPushRequestRepository.saveState(any)).thenAnswer((_) async => []);
      await notifier.remove(pr1);
      expect(container.read(testProvider), after);
    });
    test('accept', () async {
      final container = ProviderContainer();
      final mockPushProvider = MockPushProvider();
      final mockIoClient = MockPrivacyIdeaIOClient();
      final mockRsaUtils = MockRsaUtils();
      final mockFirebaseUtils = MockFirebaseUtils();
      final pr = PushRequest(
        title: 'title',
        serial: 'serial',
        question: 'question',
        uri: Uri.parse('https://example.com/api/fetch?limit=10,20,30&max=100'),
        nonce: 'nonce',
        sslVerify: false,
        id: 1,
        expirationDate: DateTime.now().add(const Duration(minutes: 10)),
      );
      final pushToken = PushToken(serial: 'serial', label: 'label', issuer: 'issuer', id: 'id');
      when(mockRsaUtils.trySignWithToken(pushToken, any)).thenAnswer((_) async => 'signature');
      when(mockIoClient.doPost(
              url: Uri.parse('https://example.com/api/fetch?limit=10,20,30&max=100'),
              body: {'nonce': 'nonce', 'serial': 'serial', 'signature': 'signature'},
              sslVerify: false))
          .thenAnswer((_) async => Response('', 200));
    });
    test('decline', () async {
      final container = ProviderContainer();
      final mockPushProvider = _MockPushProvider();
      final mockIoClient = MockPrivacyIdeaIOClient();
      final mockRsaUtils = MockRsaUtils();
      final mockFirebaseUtils = MockFirebaseUtils();
      final pr = PushRequest(
        title: 'title',
        serial: 'serial',
        question: 'question',
        uri: Uri.parse('https://example.com/api/fetch?limit=10,20,30&max=100'),
        nonce: 'nonce',
        sslVerify: false,
        id: 1,
        expirationDate: DateTime.now().add(const Duration(minutes: 10)),
      );
      final pushToken = PushToken(serial: 'serial', label: 'label', issuer: 'issuer', id: 'id');
      when(mockRsaUtils.trySignWithToken(pushToken, any)).thenAnswer((_) async => 'signature');
      when(mockIoClient.doPost(
              url: Uri.parse('https://example.com/api/fetch?limit=10,20,30&max=100'),
              body: {'nonce': 'nonce', 'serial': 'serial', 'signature': 'signature', 'decline': '1'},
              sslVerify: false))
          .thenAnswer((_) async => Response('', 200));
      final testProvider = StateNotifierProvider<PushRequestNotifier, PushRequestState>((ref) {
        final notifier = PushRequestNotifier(
          pushProvider: mockPushProvider,
          ioClient: mockIoClient,
          rsaUtils: mockRsaUtils,
        );
        mockPushProvider.initialize(pushSubscriber: notifier, firebaseUtils: mockFirebaseUtils);
        return notifier;
      });
      final notifier = container.read(testProvider.notifier);
      await notifier.decline(pushToken);
      expect(container.read(testProvider)!.accepted, isFalse);
    });
  });
}
