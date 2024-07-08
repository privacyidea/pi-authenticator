import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/interfaces/repo/push_request_repository.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/state_notifiers/push_request_notifier.dart';
import 'package:privacyidea_authenticator/utils/custom_int_buffer.dart';
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
    test('accept', () async {
      final container = ProviderContainer();
      final mockIoClient = MockPrivacyIdeaIOClient();
      final mockPushProvider = MockPushProvider();
      final mockRsaUtils = MockRsaUtils();
      final mockPushRepo = MockPushRequestRepository();
      final provider = StateNotifierProvider<PushRequestNotifier, PushRequestState>((ref) => PushRequestNotifier(
            ref: ref,
            ioClient: mockIoClient,
            pushProvider: mockPushProvider,
            rsaUtils: mockRsaUtils,
            pushRepo: mockPushRepo,
          ));
      final pr = PushRequest(
        title: 'title',
        question: 'question',
        uri: Uri.parse('http://example.com'),
        nonce: 'nonce',
        sslVerify: false,
        id: 1,
        expirationDate: DateTime.now().add(const Duration(minutes: 5)),
        signature: 'signature',
        serial: 'serial',
        accepted: null,
      );
      final before = PushRequestState(pushRequests: [pr], knownPushRequests: CustomIntBuffer(list: [pr.id]));
      final after = PushRequestState(pushRequests: [], knownPushRequests: CustomIntBuffer(list: [pr.id]));
      when(mockPushRepo.loadState()).thenAnswer((_) async => before);
      when(mockRsaUtils.trySignWithToken(any, any)).thenAnswer((_) async => 'signature');
      when(mockIoClient.doPost(
        url: anyNamed('url'),
        body: anyNamed('body'),
        sslVerify: anyNamed('sslVerify'),
      )).thenAnswer((_) async => Response('', 200));
      when(mockPushRepo.saveState(any)).thenAnswer((_) async {});
      when(mockPushRepo.loadState()).thenAnswer((_) async => before);
      final initState = await container.read(provider.notifier).initState;
      expect(initState, before);
      when(mockRsaUtils.trySignWithToken(any, any)).thenAnswer((_) async => 'signature');
      when(mockIoClient.doPost(
        url: anyNamed('url'),
        body: anyNamed('body'),
        sslVerify: anyNamed('sslVerify'),
      )).thenAnswer((_) async => Response('', 200));
      when(mockPushRepo.saveState(any)).thenAnswer((_) async {});

      await container.read(provider.notifier).accept(PushToken(serial: 'serial', id: 'id'), pr);

      expect(container.read(provider), after);
      verify(mockPushRepo.loadState()).called(1);
      verify(mockRsaUtils.trySignWithToken(any, any)).called(1);
      verify(mockIoClient.doPost(
        url: anyNamed('url'),
        body: anyNamed('body'),
        sslVerify: anyNamed('sslVerify'),
      )).called(1);
      verify(mockPushRepo.saveState(any)).called(2);
    });
    test('decline', () async {
      final container = ProviderContainer();
      final mockIoClient = MockPrivacyIdeaIOClient();
      final mockPushProvider = MockPushProvider();
      final mockRsaUtils = MockRsaUtils();
      final mockPushRepo = MockPushRequestRepository();
      final provider = StateNotifierProvider<PushRequestNotifier, PushRequestState>((ref) => PushRequestNotifier(
            ref: ref,
            ioClient: mockIoClient,
            pushProvider: mockPushProvider,
            rsaUtils: mockRsaUtils,
            pushRepo: mockPushRepo,
          ));
      final pr = PushRequest(
        title: 'title',
        question: 'question',
        uri: Uri.parse('http://example.com'),
        nonce: 'nonce',
        sslVerify: false,
        id: 1,
        expirationDate: DateTime.now().add(const Duration(minutes: 5)),
        signature: 'signature',
        serial: 'serial',
        accepted: null,
      );
      final before = PushRequestState(pushRequests: [pr], knownPushRequests: CustomIntBuffer(list: [pr.id]));
      final after = PushRequestState(pushRequests: [], knownPushRequests: CustomIntBuffer(list: [pr.id]));
      when(mockPushRepo.loadState()).thenAnswer((_) async => before);
      when(mockRsaUtils.trySignWithToken(any, any)).thenAnswer((_) async => 'signature');
      when(mockIoClient.doPost(
        url: anyNamed('url'),
        body: anyNamed('body'),
        sslVerify: anyNamed('sslVerify'),
      )).thenAnswer((_) async => Response('', 200));
      when(mockPushRepo.saveState(any)).thenAnswer((_) async {});
      when(mockPushRepo.loadState()).thenAnswer((_) async => before);
      final initState = await container.read(provider.notifier).initState;
      expect(initState, before);
      when(mockRsaUtils.trySignWithToken(any, any)).thenAnswer((_) async => 'signature');
      when(mockIoClient.doPost(
        url: anyNamed('url'),
        body: anyNamed('body'),
        sslVerify: anyNamed('sslVerify'),
      )).thenAnswer((_) async => Response('', 200));
      when(mockPushRepo.saveState(any)).thenAnswer((_) async {});
      await container.read(provider.notifier).decline(PushToken(serial: 'serial', id: 'id'), pr);
      expect(container.read(provider), after);
      verify(mockPushRepo.loadState()).called(1);
      verify(mockRsaUtils.trySignWithToken(any, any)).called(1);
      verify(mockIoClient.doPost(
        url: anyNamed('url'),
        body: anyNamed('body'),
        sslVerify: anyNamed('sslVerify'),
      )).called(1);
      verify(mockPushRepo.saveState(any)).called(2);
    });

    test('add', () async {
      final container = ProviderContainer();
      final mockIoClient = MockPrivacyIdeaIOClient();
      final mockPushProvider = MockPushProvider();
      final mockRsaUtils = MockRsaUtils();
      final mockPushRepo = MockPushRequestRepository();
      final provider = StateNotifierProvider<PushRequestNotifier, PushRequestState>((ref) => PushRequestNotifier(
            ref: ref,
            ioClient: mockIoClient,
            pushProvider: mockPushProvider,
            rsaUtils: mockRsaUtils,
            pushRepo: mockPushRepo,
          ));
      final pr = PushRequest(
        title: 'title',
        question: 'question',
        uri: Uri.parse('http://example.com'),
        nonce: 'nonce',
        sslVerify: false,
        id: 1,
        expirationDate: DateTime.now().add(const Duration(minutes: 5)),
        signature: 'signature',
        serial: 'serial',
        accepted: null,
      );
      final pr2 = pr.copyWith(id: 2);
      final before = PushRequestState(pushRequests: [pr], knownPushRequests: CustomIntBuffer(list: [pr.id]));
      final after = PushRequestState(pushRequests: [pr, pr2], knownPushRequests: CustomIntBuffer(list: [pr.id, pr2.id]));
      when(mockPushRepo.loadState()).thenAnswer((_) async => before);
      when(mockPushRepo.saveState(any)).thenAnswer((_) async {});

      final initState = await container.read(provider.notifier).initState;
      expect(initState, before);
      await container.read(provider.notifier).add(pr2);
      expect(container.read(provider), after);
    });
    test('remove', () async {
      final container = ProviderContainer();
      final mockIoClient = MockPrivacyIdeaIOClient();
      final mockPushProvider = MockPushProvider();
      final mockRsaUtils = MockRsaUtils();
      final mockPushRepo = MockPushRequestRepository();
      final provider = StateNotifierProvider<PushRequestNotifier, PushRequestState>((ref) => PushRequestNotifier(
            ref: ref,
            ioClient: mockIoClient,
            pushProvider: mockPushProvider,
            rsaUtils: mockRsaUtils,
            pushRepo: mockPushRepo,
          ));
      final pr = PushRequest(
        title: 'title',
        question: 'question',
        uri: Uri.parse('http://example.com'),
        nonce: 'nonce',
        sslVerify: false,
        id: 1,
        expirationDate: DateTime.now().add(const Duration(minutes: 5)),
        signature: 'signature',
        serial: 'serial',
        accepted: null,
      );
      final pr2 = pr.copyWith(id: 2);
      final before = PushRequestState(pushRequests: [pr, pr2], knownPushRequests: CustomIntBuffer(list: [pr.id, pr2.id]));
      final after = PushRequestState(pushRequests: [pr], knownPushRequests: CustomIntBuffer(list: [pr.id, pr2.id]));
      when(mockPushRepo.loadState()).thenAnswer((_) async => before);
      when(mockPushRepo.saveState(any)).thenAnswer((_) async {});

      final initState = await container.read(provider.notifier).initState;
      expect(initState, before);
      final success = await container.read(provider.notifier).remove(pr2);
      expect(success, true);
      expect(container.read(provider), after);
    });
  });
}
