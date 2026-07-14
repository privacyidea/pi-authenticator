import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/push_request/push_default_request.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/custom_int_buffer.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';

import '../../tests_app_wrapper.mocks.dart';

const mockResponseBody = '''
{
  "id": 1,
  "jsonrpc": "2.0",
  "result": {
    "status": true
  },
  "time": 0.1,
  "version": "privacyIDEA 1.0",
  "version_number": "1.0",
  "detail": null,
  "signature": "signature"
}
''';

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
      );

      final before = PushRequestState(
        pushRequests: [pr],
        knownPushRequests: CustomIntBuffer(list: [pr.id]),
      );

      final after = PushRequestState(
        pushRequests: [],
        knownPushRequests: CustomIntBuffer(list: [pr.id]),
      );

      // Setup mock behavior for repository and client
      when(mockPushRepo.loadState()).thenAnswer((_) async => before);
      when(mockPushRepo.saveState(any)).thenAnswer((_) async {});
      when(
        mockRsaUtils.trySignWithToken(any, any),
      ).thenAnswer((_) async => 'signature');
      when(
        mockIoClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).thenAnswer((_) async => Response(mockResponseBody, 200));

      // Verify initial state loading
      final initState = await container.read(pushProvider.future);
      expect(initState, before);

      // Execute the accept action
      final response = await container
          .read(pushProvider.notifier)
          .accept(PushToken(serial: 'serial', id: 'id'), pr);

      expect(response, isNotNull);

      // Verify state has been updated to 'after' state
      final finalState = await container.read(pushProvider.future);
      expect(finalState, after);

      // Verify that necessary calls were triggered
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
      ).thenAnswer((_) async => Response(mockResponseBody, 200));
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
      ).thenAnswer((_) async => Response(mockResponseBody, 200));
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

    test(
      'accept does not retry when the server returns a real (non-connection-failure) response',
      () async {
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
        );

        final before = PushRequestState(
          pushRequests: [pr],
          knownPushRequests: CustomIntBuffer(list: [pr.id]),
        );

        when(mockPushRepo.loadState()).thenAnswer((_) async => before);
        when(mockPushRepo.saveState(any)).thenAnswer((_) async {});
        when(
          mockRsaUtils.trySignWithToken(any, any),
        ).thenAnswer((_) async => 'signature');
        // A real server response with a non-2xx status but a body that isn't
        // marked as a connection failure must NOT trigger a retry, even
        // though HttpStatusChecker would classify 400 as an error status.
        when(
          mockIoClient.doPost(
            url: anyNamed('url'),
            body: anyNamed('body'),
            sslVerify: anyNamed('sslVerify'),
          ),
        ).thenAnswer((_) async => Response(mockResponseBody, 400));

        await container.read(pushProvider.future);
        await container
            .read(pushProvider.notifier)
            .accept(PushToken(serial: 'serial', id: 'id'), pr);

        verify(
          mockIoClient.doPost(
            url: anyNamed('url'),
            body: anyNamed('body'),
            sslVerify: anyNamed('sslVerify'),
          ),
        ).called(1);
      },
    );

    test(
      'accept retries exactly once after a connection failure and succeeds if the retry works',
      () async {
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
        when(mockPushRepo.saveState(any)).thenAnswer((_) async {});
        when(
          mockRsaUtils.trySignWithToken(any, any),
        ).thenAnswer((_) async => 'signature');

        var callCount = 0;
        when(
          mockIoClient.doPost(
            url: anyNamed('url'),
            body: anyNamed('body'),
            sslVerify: anyNamed('sslVerify'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            // Simulates PrivacyideaIOClient.doPost() catching a network
            // exception and synthesizing a marked response instead of
            // throwing.
            return ResponseBuilder.fromMessage('No route to host');
          }
          return Response(mockResponseBody, 200);
        });

        await container.read(pushProvider.future);
        final response = await container
            .read(pushProvider.notifier)
            .accept(PushToken(serial: 'serial', id: 'id'), pr);

        expect(response, isNotNull);
        expect(await container.read(pushProvider.future), after);
        verify(
          mockIoClient.doPost(
            url: anyNamed('url'),
            body: anyNamed('body'),
            sslVerify: anyNamed('sslVerify'),
          ),
        ).called(2);
      },
    );
  });
}
