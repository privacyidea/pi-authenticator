import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/push_request_queue.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/state_notifiers/push_request_notifier.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/network_utils.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:mockito/annotations.dart';

import 'push_request_notifier_test.mocks.dart';

class _MockPushProvider extends Mock implements PushProvider {
  @override
  PushRequestNotifier? pushSubscriber;
  @override
  Future<void> initialize({required PushRequestNotifier pushSubscriber, required FirebaseUtils firebaseUtils}) async {
    this.pushSubscriber = pushSubscriber;
  }

  void simulatePush(PushRequest pushRequest) {
    pushSubscriber?.newRequest(pushRequest);
  }
}

@GenerateMocks([RsaUtils, PrivacyIdeaIOClient, FirebaseUtils])
void main() {
  _testPushRequestNotifier();
}

void _testPushRequestNotifier() {
  group('PushRequestNotifier', () {
    test('newRequest', () async {
      final container = ProviderContainer();
      final mockPushProvider = _MockPushProvider();
      final mockFirebaseUtils = MockFirebaseUtils();
      final testProvider = StateNotifierProvider<PushRequestNotifier, PushRequest?>((ref) {
        final notifier = PushRequestNotifier(
          pushProvider: mockPushProvider,
          firebaseUtils: mockFirebaseUtils,
          ioClient: MockPrivacyIdeaIOClient(),
          rsaUtils: MockRsaUtils(),
        );
        mockPushProvider.initialize(pushSubscriber: notifier, firebaseUtils: mockFirebaseUtils);
        return notifier;
      });
      final pr = PushRequest(
        title: 'title',
        question: 'question',
        uri: Uri.parse('https://example.com/api/fetch?limit=10,20,30&max=100'),
        nonce: 'nonce',
        sslVerify: false,
        id: 1,
        expirationDate: DateTime.now().add(const Duration(minutes: 10)),
      );
      mockPushProvider.simulatePush(pr);
      expect(container.read(testProvider), pr);
    });
    test('accept', () async {
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
      final pushToken = PushToken(serial: 'serial', label: 'label', issuer: 'issuer', id: 'id', pushRequests: PushRequestQueue()..add(pr));
      when(mockRsaUtils.trySignWithToken(pushToken, any)).thenAnswer((_) async => 'signature');
      when(mockIoClient.doPost(
              url: Uri.parse('https://example.com/api/fetch?limit=10,20,30&max=100'),
              body: {'nonce': 'nonce', 'serial': 'serial', 'signature': 'signature'},
              sslVerify: false))
          .thenAnswer((_) async => Response('', 200));
      final testProvider = StateNotifierProvider<PushRequestNotifier, PushRequest?>((ref) {
        final notifier = PushRequestNotifier(
          pushProvider: mockPushProvider,
          ioClient: mockIoClient,
          rsaUtils: mockRsaUtils,
          firebaseUtils: mockFirebaseUtils,
        );
        mockPushProvider.initialize(pushSubscriber: notifier, firebaseUtils: mockFirebaseUtils);
        return notifier;
      });
      final notifier = container.read(testProvider.notifier);
      await notifier.acceptPop(pushToken);
      expect(container.read(testProvider)!.accepted, isTrue);
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
      final pushToken = PushToken(serial: 'serial', label: 'label', issuer: 'issuer', id: 'id', pushRequests: PushRequestQueue()..add(pr));
      when(mockRsaUtils.trySignWithToken(pushToken, any)).thenAnswer((_) async => 'signature');
      when(mockIoClient.doPost(
              url: Uri.parse('https://example.com/api/fetch?limit=10,20,30&max=100'),
              body: {'nonce': 'nonce', 'serial': 'serial', 'signature': 'signature', 'decline': '1'},
              sslVerify: false))
          .thenAnswer((_) async => Response('', 200));
      final testProvider = StateNotifierProvider<PushRequestNotifier, PushRequest?>((ref) {
        final notifier = PushRequestNotifier(
          pushProvider: mockPushProvider,
          ioClient: mockIoClient,
          rsaUtils: mockRsaUtils,
          firebaseUtils: mockFirebaseUtils,
        );
        mockPushProvider.initialize(pushSubscriber: notifier, firebaseUtils: mockFirebaseUtils);
        return notifier;
      });
      final notifier = container.read(testProvider.notifier);
      await notifier.declinePop(pushToken);
      expect(container.read(testProvider)!.accepted, isFalse);
    });
  });
}
