import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/push_request/push_default_request.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/custom_int_buffer.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  _testPushRequestNotifier();
}

void _testPushRequestNotifier() {
  group('PushRequestNotifier', () {
    test('accept', () async {
      final container = ProviderContainer();
      final mockIoClient = MockPrivacyideaIOClient();
      final mockPushProvider = MockPushProvider();
      final mockRsaUtils = MockRsaUtils();
      final mockPushRepo = MockPushRequestRepository();
      final pushProvider = pushRequestProviderOf(
        ioClient: mockIoClient,
        rsaUtils: mockRsaUtils,
        pushProvider: mockPushProvider,
        pushRepo: mockPushRepo,
      );

      final pr = PushDefaultRequest(
        title: 'title',
        question: 'question',
        uri: Uri.parse('http://example.com'),
        nonce: 'nonce',
        sslVerify: false,
        expirationDate: DateTime.now().add(const Duration(minutes: 5)),
        signature: 'signature',
        serial: 'serial',
        accepted: null,
      );
      final before = PushRequestState(
        pushRequests: [pr],
        knownPushRequests: CustomIntBuffer(list: [pr.id]),
      );
      final after = PushRequestState(
        pushRequests: [],
        knownPushRequests: CustomIntBuffer(list: [pr.id]),
      );
      when(mockPushRepo.loadState()).thenAnswer((_) async => before);
      when(
        mockRsaUtils.trySignWithToken(any, any),
      ).thenAnswer((_) async => 'signature');
      when(
        mockIoClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).thenAnswer((_) async => Response('', 200));
      when(mockPushRepo.saveState(any)).thenAnswer((_) async {});
      when(mockPushRepo.loadState()).thenAnswer((_) async => before);
      final initState = await container.read(pushProvider.future);
      verify(mockPushRepo.loadState()).called(1);
      expect(initState, before);
      when(
        mockRsaUtils.trySignWithToken(any, any),
      ).thenAnswer((_) async => 'signature');
      when(
        mockIoClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).thenAnswer((_) async => Response('', 200));
      when(mockPushRepo.saveState(any)).thenAnswer((_) async {});

      await container
          .read(pushProvider.notifier)
          .accept(PushToken(serial: 'serial', id: 'id'), pr);

      expect(await container.read(pushProvider.future), after);
      verify(mockRsaUtils.trySignWithToken(any, any)).called(1);
      verify(
        mockIoClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).called(1);
      verify(mockPushRepo.saveState(any)).called(2);
    });
    test('decline', () async {
      final container = ProviderContainer();
      final mockIoClient = MockPrivacyideaIOClient();
      final mockPushProvider = MockPushProvider();
      final mockRsaUtils = MockRsaUtils();
      final mockPushRepo = MockPushRequestRepository();
      final pushProvider = pushRequestProviderOf(
        ioClient: mockIoClient,
        rsaUtils: mockRsaUtils,
        pushProvider: mockPushProvider,
        pushRepo: mockPushRepo,
      );
      final pr = PushDefaultRequest(
        title: 'title',
        question: 'question',
        uri: Uri.parse('http://example.com'),
        nonce: 'nonce',
        sslVerify: false,
        expirationDate: DateTime.now().add(const Duration(minutes: 5)),
        signature: 'signature',
        serial: 'serial',
        accepted: null,
      );
      final before = PushRequestState(
        pushRequests: [pr],
        knownPushRequests: CustomIntBuffer(list: [pr.id]),
      );
      final after = PushRequestState(
        pushRequests: [],
        knownPushRequests: CustomIntBuffer(list: [pr.id]),
      );
      when(mockPushRepo.loadState()).thenAnswer((_) async => before);
      when(
        mockRsaUtils.trySignWithToken(any, any),
      ).thenAnswer((_) async => 'signature');
      when(
        mockIoClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).thenAnswer((_) async => Response('', 200));
      when(mockPushRepo.saveState(any)).thenAnswer((_) async {});
      when(mockPushRepo.loadState()).thenAnswer((_) async => before);
      final initState = await container.read(pushProvider.future);
      expect(initState, before);
      when(
        mockRsaUtils.trySignWithToken(any, any),
      ).thenAnswer((_) async => 'signature');
      when(
        mockIoClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).thenAnswer((_) async => Response('', 200));
      when(mockPushRepo.saveState(any)).thenAnswer((_) async {});
      await container
          .read(pushProvider.notifier)
          .decline(PushToken(serial: 'serial', id: 'id'), pr);
      expect((await container.read(pushProvider.future)), after);
      verify(mockPushRepo.loadState()).called(1);
      verify(mockRsaUtils.trySignWithToken(any, any)).called(1);
      verify(
        mockIoClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).called(1);
      verify(mockPushRepo.saveState(any)).called(2);
    });

    test('add', () async {
      final container = ProviderContainer();
      final mockIoClient = MockPrivacyideaIOClient();
      final mockPushProvider = MockPushProvider();
      final mockRsaUtils = MockRsaUtils();
      final mockPushRepo = MockPushRequestRepository();
      final pushProvider = pushRequestProviderOf(
        ioClient: mockIoClient,
        rsaUtils: mockRsaUtils,
        pushProvider: mockPushProvider,
        pushRepo: mockPushRepo,
      );
      final pr = PushDefaultRequest(
        title: 'title',
        question: 'question',
        uri: Uri.parse('http://example.com'),
        nonce: 'nonce',
        sslVerify: false,
        expirationDate: DateTime.now().add(const Duration(minutes: 5)),
        signature: 'signature',
        serial: 'serial',
        accepted: null,
      );
      final pr2 = pr.copyWith(serial: 'serial2', nonce: 'nonce2');
      final before = PushRequestState(
        pushRequests: [pr],
        knownPushRequests: CustomIntBuffer(list: [pr.id]),
      );
      final after = PushRequestState(
        pushRequests: [pr, pr2],
        knownPushRequests: CustomIntBuffer(list: [pr.id, pr2.id]),
      );
      when(mockPushRepo.loadState()).thenAnswer((_) async => before);
      when(mockPushRepo.saveState(any)).thenAnswer((_) async {});

      final initState = await container.read(pushProvider.future);
      expect(initState, before);
      await container.read(pushProvider.notifier).add(pr2);
      expect((await container.read(pushProvider.future)), after);
    });
    test('remove', () async {
      final container = ProviderContainer();
      final mockIoClient = MockPrivacyideaIOClient();
      final mockPushProvider = MockPushProvider();
      final mockRsaUtils = MockRsaUtils();
      final mockPushRepo = MockPushRequestRepository();
      final pushProvider = pushRequestProviderOf(
        ioClient: mockIoClient,
        rsaUtils: mockRsaUtils,
        pushProvider: mockPushProvider,
        pushRepo: mockPushRepo,
      );
      final pr = PushDefaultRequest(
        title: 'title',
        question: 'question',
        uri: Uri.parse('http://example.com'),
        nonce: 'nonce',
        sslVerify: false,
        expirationDate: DateTime.now().add(const Duration(minutes: 5)),
        signature: 'signature',
        serial: 'serial',
        accepted: null,
      );
      final pr2 = pr.copyWith(serial: 'serial2');
      final before = PushRequestState(
        pushRequests: [pr, pr2],
        knownPushRequests: CustomIntBuffer(list: [pr.id, pr2.id]),
      );
      final after = PushRequestState(
        pushRequests: [pr],
        knownPushRequests: CustomIntBuffer(list: [pr.id, pr2.id]),
      );
      when(mockPushRepo.loadState()).thenAnswer((_) async => before);
      when(mockPushRepo.saveState(any)).thenAnswer((_) async {});

      final initState = await container.read(pushProvider.future);
      expect(initState, before);
      final success = await container.read(pushProvider.notifier).remove(pr2);
      expect(success, true);
      expect(await container.read(pushProvider.future), after);
    });
  });
}
