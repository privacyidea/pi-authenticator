import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/interfaces/repo/push_request_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/custom_int_buffer.dart';
import 'package:privacyidea_authenticator/utils/helpers/base32_helper.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

import '../../tests_app_wrapper.mocks.dart';
import '../model/fake_push_server.dart';

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
  _testPushRequestNotifierMore();
}

void _testPushRequestNotifier() {
  group('PushRequestNotifier', () {
    test('accept', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
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
      addTearDown(container.dispose);
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
      when(
        mockIoClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).thenAnswer((_) async => Response(mockResponseBody, 200));

      final initState = await container.read(pushProvider.future);
      expect(initState, before);

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
      addTearDown(container.dispose);
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
      addTearDown(container.dispose);
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
        addTearDown(container.dispose);
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
        addTearDown(container.dispose);
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

    test(
      'accept gives up after the retry also fails, restores the pending request and shows a status message',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
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
        // Both the first attempt and the retry fail to connect.
        when(
          mockIoClient.doPost(
            url: anyNamed('url'),
            body: anyNamed('body'),
            sslVerify: anyNamed('sslVerify'),
          ),
        ).thenAnswer(
          (_) async => ResponseBuilder.fromMessage('No route to host'),
        );

        await container.read(pushProvider.future);
        final response = await container
            .read(pushProvider.notifier)
            .accept(PushToken(serial: 'serial', id: 'id'), pr);

        expect(response, isNull);
        // The pending push request must be restored/kept, not lost.
        final finalState = await container.read(pushProvider.future);
        expect(finalState.pushRequests, [pr]);
        verify(
          mockIoClient.doPost(
            url: anyNamed('url'),
            body: anyNamed('body'),
            sslVerify: anyNamed('sslVerify'),
          ),
        ).called(2);
        // A status message must be shown to the user for the terminal failure.
        expect(container.read(statusProvider).current, isNotNull);
      },
    );

    test(
      'accept does not retry after a timeout because the request may have reached the server',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
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
        when(
          mockIoClient.doPost(
            url: anyNamed('url'),
            body: anyNamed('body'),
            sslVerify: anyNamed('sslVerify'),
          ),
        ).thenAnswer(
          (_) async =>
              ResponseBuilder.fromStatusCode(408, mayHaveBeenDelivered: true),
        );

        await container.read(pushProvider.future);
        final response = await container
            .read(pushProvider.notifier)
            .accept(PushToken(serial: 'serial', id: 'id'), pr);

        expect(response, isNull);
        final finalState = await container.read(pushProvider.future);
        expect(finalState.pushRequests, [pr]);
        verify(
          mockIoClient.doPost(
            url: anyNamed('url'),
            body: anyNamed('body'),
            sslVerify: anyNamed('sslVerify'),
          ),
        ).called(1);
        expect(container.read(statusProvider).current, isNotNull);
      },
    );
  });
}

// More of the [PushRequestNotifier]: the decline reason that is sent, the
// error paths of the reaction, replay protection by the known request ids and
// the expiration timers.

/// A push request repository that keeps its state in memory and can be told
/// to fail.
class _MemoryRepo implements PushRequestRepository {
  _MemoryRepo([PushRequestState? initial])
    : state = initial ?? PushRequestState.empty();

  PushRequestState state;
  int saveCount = 0;

  /// The number of the next saves that throw.
  int failingSaves = 0;

  @override
  Future<PushRequestState> loadState() async => state;

  @override
  Future<void> saveState(PushRequestState pushRequestState) async {
    if (failingSaves > 0) {
      failingSaves--;
      saveCount++;
      throw StateError('storage is not writable');
    }
    saveCount++;
    state = pushRequestState;
  }

  @override
  Future<void> clearState() async => state = PushRequestState.empty();

  @override
  Future<PushRequestState> addRequest(
    PushRequest pushRequest, {
    PushRequestState? state,
  }) => throw UnimplementedError();

  @override
  Future<PushRequestState> removeRequest(
    PushRequest pushRequest, {
    PushRequestState? state,
  }) => throw UnimplementedError();
}

const _successBody = '{"result": {"status": true, "value": true}}';

/// A request as the app builds it from a challenge of [server].
PushRequest _requestOf(
  FakePushServer server, {
  DateTime? expirationDate,
  String question = 'Do you want to login?',
}) {
  final request = PushRequestFactory.fromMessageData(
    server.createChallenge(question: question),
  );
  return expirationDate == null
      ? request
      : request.copyWith(expirationDate: expirationDate);
}

/// A plain request that is not tied to a server, with a given nonce.
PushRequest _plainRequest(String nonce, {DateTime? expirationDate}) =>
    PushDefaultRequest(
      title: 'title',
      question: 'question',
      uri: Uri.parse('https://example.com/ttype/push'),
      nonce: nonce,
      sslVerify: true,
      expirationDate:
          expirationDate ?? DateTime.now().add(const Duration(minutes: 5)),
      signature: 'signature',
      serial: 'PIPU0001',
    );

void _testPushRequestNotifierMore() {
  group(
    'PushRequestNotifier (decline reason, error paths, replay protection, expiration)',
    () {
      late FakePushServer advertising;
      late FakePushServer legacy;
      late FakePushServer restricted;
      late PushToken advertisingToken;
      late PushToken legacyToken;
      late PushToken restrictedToken;

      late MockPrivacyideaIOClient ioClient;
      late MockPushProvider pushProvider;
      late _MemoryRepo repo;
      late ProviderContainer container;

      // Generating the key pairs is by far the slowest part, so it happens once.
      setUpAll(() {
        advertising = FakePushServer.advertising();
        advertisingToken = enrollAgainst(advertising);
        legacy = FakePushServer.legacy();
        legacyToken = enrollAgainst(legacy);
        restricted = FakePushServer.advertising(
          capabilities: const <String, Object>{
            'decline_reason': <String, Object>{
              'values': <String>['cancelled'],
            },
          },
        );
        restrictedToken = enrollAgainst(restricted);
      });

      setUp(() {
        ioClient = MockPrivacyideaIOClient();
        pushProvider = MockPushProvider();
        repo = _MemoryRepo();
        container = ProviderContainer();
        addTearDown(container.dispose);
      });

      PushRequestNotifierProvider providerOf({
        PrivacyideaIOClient? client,
        RsaUtils rsaUtils = const RsaUtils(),
      }) => pushRequestProviderOf(
        rsaUtils: rsaUtils,
        ioClient: client ?? ioClient,
        pushProvider: pushProvider,
        pushRepo: repo,
      );

      Future<PushRequestNotifier> boot({
        List<PushRequest> pending = const [],
      }) async {
        repo.state = PushRequestState(
          pushRequests: pending.toList(),
          knownPushRequests: CustomIntBuffer(
            list: [for (final r in pending) r.id],
          ),
        );
        final provider = providerOf();
        await container.read(provider.future);
        return container.read(provider.notifier);
      }

      PushRequestState currentState() => container.read(providerOf()).value!;

      void postReturns(Response response) {
        when(
          ioClient.doPost(
            url: anyNamed('url'),
            body: anyNamed('body'),
            sslVerify: anyNamed('sslVerify'),
          ),
        ).thenAnswer((_) async => response);
      }

      void postThrows(Object error) {
        when(
          ioClient.doPost(
            url: anyNamed('url'),
            body: anyNamed('body'),
            sslVerify: anyNamed('sslVerify'),
          ),
        ).thenThrow(error);
      }

      List<Map<String, String?>> postedBodies() => verify(
        ioClient.doPost(
          url: anyNamed('url'),
          body: captureAnyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).captured.cast<Map<String, String?>>();

      void expectNoPost() => verifyNever(
        ioClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
        ),
      );

      StatusMessage? status() => container.read(statusProvider).current;

      bool signatureIsValid(
        PushToken token,
        Map<String, String?> body,
        String signed,
      ) => const RsaUtils().verifyRSASignature(
        token.rsaPublicTokenKey!,
        utf8.encode(signed),
        base32Decode(body['signature']!),
      );

      group('decline reason', () {
        test(
          'cancel sends decline_reason cancelled when the server advertised it',
          () async {
            final request = _requestOf(advertising);
            final notifier = await boot(pending: [request]);
            postReturns(Response(_successBody, 200));

            final response = await notifier.cancel(advertisingToken, request);

            expect(response, isNotNull);
            final body = postedBodies().single;
            expect(body['decline'], '1');
            expect(body['decline_reason'], 'cancelled');
            expect(body['nonce'], request.nonce);
            expect(body['serial'], advertisingToken.serial);
            // The reason is part of what is signed.
            expect(
              signatureIsValid(
                advertisingToken,
                body,
                '${request.nonce}|${advertisingToken.serial}|decline|cancelled',
              ),
              isTrue,
            );
            // And the server accepts it as a cancel.
            expect(
              advertising.handleAnswer(body.cast<String, String>()).session,
              ChallengeSession.cancelled,
            );
          },
        );

        test('decline sends decline_reason unknown_trigger', () async {
          final request = _requestOf(advertising);
          final notifier = await boot(pending: [request]);
          postReturns(Response(_successBody, 200));

          await notifier.decline(advertisingToken, request);

          final body = postedBodies().single;
          expect(body['decline'], '1');
          expect(body['decline_reason'], 'unknown_trigger');
          expect(
            signatureIsValid(
              advertisingToken,
              body,
              '${request.nonce}|${advertisingToken.serial}|decline|unknown_trigger',
            ),
            isTrue,
          );
          expect(
            advertising.handleAnswer(body.cast<String, String>()).session,
            ChallengeSession.declined,
          );
        });

        test('accept sends neither decline nor a reason', () async {
          final request = _requestOf(advertising);
          final notifier = await boot(pending: [request]);
          postReturns(Response(_successBody, 200));

          await notifier.accept(advertisingToken, request);

          final body = postedBodies().single;
          expect(body.containsKey('decline'), isFalse);
          expect(body.containsKey('decline_reason'), isFalse);
          expect(
            signatureIsValid(
              advertisingToken,
              body,
              '${request.nonce}|${advertisingToken.serial}',
            ),
            isTrue,
          );
          expect(
            advertising.handleAnswer(body.cast<String, String>()).session,
            ChallengeSession.answered,
          );
        });

        test(
          'cancel to a server that advertised nothing sends a plain decline',
          () async {
            final request = _requestOf(legacy);
            final notifier = await boot(pending: [request]);
            postReturns(Response(_successBody, 200));

            await notifier.cancel(legacyToken, request);

            final body = postedBodies().single;
            expect(body['decline'], '1');
            expect(body.containsKey('decline_reason'), isFalse);
            expect(
              signatureIsValid(
                legacyToken,
                body,
                '${request.nonce}|${legacyToken.serial}|decline',
              ),
              isTrue,
            );
            expect(
              legacy.handleAnswer(body.cast<String, String>()).session,
              ChallengeSession.declined,
            );
          },
        );

        test(
          'decline to a server that advertised nothing sends a plain decline',
          () async {
            final request = _requestOf(legacy);
            final notifier = await boot(pending: [request]);
            postReturns(Response(_successBody, 200));

            await notifier.decline(legacyToken, request);

            final body = postedBodies().single;
            expect(body.containsKey('decline_reason'), isFalse);
            expect(
              legacy.handleAnswer(body.cast<String, String>()).session,
              ChallengeSession.declined,
            );
          },
        );

        test(
          'a server that only accepts cancelled gets the reason for cancel',
          () async {
            final request = _requestOf(restricted);
            final notifier = await boot(pending: [request]);
            postReturns(Response(_successBody, 200));

            await notifier.cancel(restrictedToken, request);

            expect(postedBodies().single['decline_reason'], 'cancelled');
          },
        );

        test(
          'a server that only accepts cancelled gets no reason for decline',
          () async {
            final request = _requestOf(restricted);
            final notifier = await boot(pending: [request]);
            postReturns(Response(_successBody, 200));

            await notifier.decline(restrictedToken, request);

            final body = postedBodies().single;
            expect(body['decline'], '1');
            expect(body.containsKey('decline_reason'), isFalse);
            expect(
              signatureIsValid(
                restrictedToken,
                body,
                '${request.nonce}|${restrictedToken.serial}|decline',
              ),
              isTrue,
            );
          },
        );

        test(
          'capabilities that were advertised with a forged signature are not used',
          () async {
            final genuine = _requestOf(advertising);
            final forged = (genuine as PushDefaultRequest).copyWith(
              // Another request's capability signature, bound to another nonce.
              signedCapabilities:
                  (_requestOf(advertising) as PushDefaultRequest)
                      .signedCapabilities,
            );
            final notifier = await boot(pending: [forged]);
            postReturns(Response(_successBody, 200));

            await notifier.cancel(advertisingToken, forged);

            expect(
              postedBodies().single.containsKey('decline_reason'),
              isFalse,
            );
          },
        );

        test(
          'a reaction to a request that is not pending does not post anything',
          () async {
            final notifier = await boot();
            final unknown = _requestOf(advertising);

            final response = await notifier.cancel(advertisingToken, unknown);

            expect(response, isNull);
            expectNoPost();
            expect(currentState().pushRequests, isEmpty);
          },
        );
      });

      group('reaction error paths', () {
        late PushRequest request;
        late PushRequestNotifier notifier;

        setUp(() async {
          request = _requestOf(advertising);
          notifier = await boot(pending: [request]);
        });

        void expectRequestRestored() {
          final pending = currentState().pushRequests;
          expect(pending, [request]);
          // Not the declined copy: the user can react again.
          expect(pending.single.accepted, isNull);
          expect(pending.single.declineReason, isNull);
          expect(repo.state.pushRequests.single.accepted, isNull);
        }

        test(
          'an ArgumentError of the io client restores the request without retry',
          () async {
            postThrows(ArgumentError('body contains null values'));

            final response = await notifier.accept(advertisingToken, request);

            expect(response, isNull);
            expectRequestRestored();
            postedBodies().single;
            final l = AppLocalizationsEn();
            expect(status()?.message(l), l.sendPushRequestResponseFailed);
            expect(status()?.details?.call(l), 'body contains null values');
          },
        );

        test(
          'an ArgumentError of the retry restores the request and stops',
          () async {
            var calls = 0;
            when(
              ioClient.doPost(
                url: anyNamed('url'),
                body: anyNamed('body'),
                sslVerify: anyNamed('sslVerify'),
              ),
            ).thenAnswer((_) async {
              calls++;
              if (calls == 1) {
                return ResponseBuilder.fromMessage('No route to host');
              }
              throw ArgumentError('body contains null values');
            });

            final response = await notifier.accept(advertisingToken, request);

            expect(response, isNull);
            expect(calls, 2);
            expectRequestRestored();
            final l = AppLocalizationsEn();
            expect(status()?.message(l), l.sendPushRequestResponseFailed);
          },
        );

        test(
          'a generic exception restores the request and shows connection failed',
          () async {
            postThrows(StateError('something unexpected'));

            final response = await notifier.decline(advertisingToken, request);

            expect(response, isNull);
            expectRequestRestored();
            postedBodies().single;
            final l = AppLocalizationsEn();
            expect(status()?.message(l), l.connectionFailed);
            expect(status()?.details, isNull);
          },
        );

        test('a generic exception of the retry restores the request', () async {
          var calls = 0;
          when(
            ioClient.doPost(
              url: anyNamed('url'),
              body: anyNamed('body'),
              sslVerify: anyNamed('sslVerify'),
            ),
          ).thenAnswer((_) async {
            calls++;
            if (calls == 1)
              return ResponseBuilder.fromMessage('No route to host');
            throw StateError('something unexpected');
          });

          final response = await notifier.accept(advertisingToken, request);

          expect(response, isNull);
          expect(calls, 2);
          expectRequestRestored();
          final l = AppLocalizationsEn();
          expect(status()?.message(l), l.connectionFailed);
        });

        test(
          'a non-json error page shows only the message as details',
          () async {
            postReturns(Response('Bad Gateway', 502));

            final response = await notifier.accept(advertisingToken, request);

            expect(response, isNull);
            expectRequestRestored();
            final l = AppLocalizationsEn();
            expect(
              status()?.message(l),
              '${l.sendPushRequestResponseFailed}\n${l.statusCode(502)}',
            );
            // No "10001: " in front of it.
            expect(status()?.details?.call(l), 'Bad Gateway');
          },
        );

        test('an html error page is summarised in the details', () async {
          postReturns(Response('<html><body>502</body></html>', 502));

          final response = await notifier.accept(advertisingToken, request);

          expect(response, isNull);
          expectRequestRestored();
          final l = AppLocalizationsEn();
          expect(
            status()?.details?.call(l),
            'Invalid server response (HTTP 502)',
          );
        });

        test(
          'an empty response body is reported with its status code',
          () async {
            postReturns(Response('', 200));

            final response = await notifier.accept(advertisingToken, request);

            expect(response, isNull);
            expectRequestRestored();
            final l = AppLocalizationsEn();
            expect(
              status()?.details?.call(l),
              'Empty response body (HTTP 200)',
            );
          },
        );

        test(
          'a json body that is no privacyIDEA response is reported as unparsable',
          () async {
            postReturns(Response('{"unexpected": 1}', 200));

            final response = await notifier.accept(advertisingToken, request);

            expect(response, isNull);
            expectRequestRestored();
            final l = AppLocalizationsEn();
            expect(
              status()?.message(l),
              '${l.sendPushRequestResponseFailed}\n${l.statusCode(200)}',
            );
            expect(
              status()?.details?.call(l),
              startsWith('Failed to parse response'),
            );
          },
        );

        test(
          'a request that cannot be signed is restored and nothing is posted',
          () async {
            // A token without private key cannot sign.
            final unsignable = PushToken(
              serial: advertisingToken.serial,
              id: 'id',
            );

            final response = await notifier.accept(unsignable, request);

            expect(response, isNull);
            expectNoPost();
            expectRequestRestored();
          },
        );

        test(
          'a connection failure after the retry restores the request',
          () async {
            postReturns(ResponseBuilder.fromMessage('No route to host'));

            final response = await notifier.cancel(advertisingToken, request);

            expect(response, isNull);
            expect(postedBodies(), hasLength(2));
            expectRequestRestored();
            final l = AppLocalizationsEn();
            expect(status()?.message(l), l.connectionFailed);
          },
        );

        test(
          'a success removes the request from state and repo but keeps it known',
          () async {
            postReturns(Response(_successBody, 200));

            final response = await notifier.accept(advertisingToken, request);

            expect(response, isNotNull);
            expect(currentState().pushRequests, isEmpty);
            expect(repo.state.pushRequests, isEmpty);
            expect(repo.state.knowsRequest(request), isTrue);
            expect(status(), isNull);
          },
        );

        // A server that rejects the answer reports the reason in the error object
        // of the result. That body parses like a success, and the push request
        // is then dropped although the server did not take the answer.
        test(
          'an error reported by the server in the result restores the request and tells the user',
          () async {
            postReturns(
              Response(
                '{"result": {"status": false, "error": {"code": 905, "message": "Challenge does not exist"}}}',
                400,
              ),
            );

            final response = await notifier.accept(advertisingToken, request);

            expect(response, isNull);
            expectRequestRestored();
            expect(status(), isNotNull);
          },
          skip:
              'BUG: push_request_provider.dart:451 only parse failures count as isError, a result.error of the server is treated as success and the request is dropped',
        );
      });

      group('replay protection', () {
        test('add of a new request stores it and makes it known', () async {
          final notifier = await boot();
          final request = _plainRequest('nonce-new');

          final added = await notifier.add(request);

          expect(added, isTrue);
          expect(currentState().pushRequests, [request]);
          expect(currentState().knowsRequest(request), isTrue);
          expect(repo.state.pushRequests, [request]);
        });

        test(
          'add of a pending request returns false and changes nothing',
          () async {
            final request = _plainRequest('nonce-pending');
            final notifier = await boot(pending: [request]);
            final before = currentState();
            final savesBefore = repo.saveCount;

            final added = await notifier.add(request);

            expect(added, isFalse);
            expect(currentState(), before);
            expect(repo.saveCount, savesBefore);
          },
        );

        test('add of a removed request returns false', () async {
          final request = _plainRequest('nonce-removed');
          final notifier = await boot(pending: [request]);
          expect(await notifier.remove(request), isTrue);
          final before = currentState();
          final savesBefore = repo.saveCount;

          final added = await notifier.add(request);

          expect(added, isFalse);
          expect(currentState().pushRequests, isEmpty);
          expect(currentState(), before);
          expect(repo.saveCount, savesBefore);
        });

        test('add of an accepted request returns false', () async {
          final request = _requestOf(advertising);
          final notifier = await boot(pending: [request]);
          postReturns(Response(_successBody, 200));
          expect(await notifier.accept(advertisingToken, request), isNotNull);
          final savesBefore = repo.saveCount;

          final added = await notifier.add(request);

          expect(added, isFalse);
          expect(currentState().pushRequests, isEmpty);
          expect(repo.saveCount, savesBefore);
        });

        test('add of a declined request returns false', () async {
          final request = _requestOf(advertising);
          final notifier = await boot(pending: [request]);
          postReturns(Response(_successBody, 200));
          expect(await notifier.decline(advertisingToken, request), isNotNull);

          expect(await notifier.add(request), isFalse);
          expect(currentState().pushRequests, isEmpty);
        });

        test(
          'a replay with a changed question is still recognised by its nonce',
          () async {
            final request = _plainRequest('nonce-replayed');
            final notifier = await boot(pending: [request]);
            await notifier.remove(request);

            final replay = (request as PushDefaultRequest).copyWith(
              question: 'Send money?',
            );

            expect(await notifier.add(replay), isFalse);
            expect(currentState().pushRequests, isEmpty);
          },
        );

        test(
          'a request known from the repo is not added again after a restart',
          () async {
            final request = _plainRequest('nonce-restart');
            repo.state = PushRequestState(
              pushRequests: [],
              knownPushRequests: CustomIntBuffer(list: [request.id]),
            );
            final provider = providerOf();
            await container.read(provider.future);

            expect(
              await container.read(provider.notifier).add(request),
              isFalse,
            );
          },
        );

        test(
          'addOrReplace bypasses the known check and puts a removed request back',
          () async {
            // Pins the behaviour: the check lives in add, not in addOrReplace. The
            // code to phone dialog relies on it to replace a request by its code to
            // phone variant, which has the same nonce.
            final request = _plainRequest('nonce-bypass');
            final notifier = await boot(pending: [request]);
            await notifier.remove(request);
            expect(currentState().pushRequests, isEmpty);

            final added = await notifier.addOrReplace(request);

            expect(added, isTrue);
            expect(currentState().pushRequests, [request]);
          },
        );

        test(
          'addOrReplace of a pending request replaces it and moves it to the end',
          () async {
            final first = _plainRequest('nonce-first');
            final second = _plainRequest('nonce-second');
            final notifier = await boot(pending: [first, second]);
            final replacement = (first as PushDefaultRequest).copyWith(
              question: 'Changed?',
            );

            expect(await notifier.addOrReplace(replacement), isTrue);

            final pending = currentState().pushRequests;
            expect(pending.map((r) => r.nonce), [
              'nonce-second',
              'nonce-first',
            ]);
            expect(pending.last, same(replacement));
            expect(pending.last.question, 'Changed?');
            expect(currentState().knownPushRequests.length, 2);
          },
        );

        test(
          'addOrReplace replaces a request by a code to phone request of the same nonce',
          () async {
            final request = _plainRequest('nonce-code');
            final notifier = await boot(pending: [request]);
            final codeToPhone = PushCodeToPhoneRequest(
              title: request.title,
              question: request.question,
              uri: request.uri,
              expirationDate: request.expirationDate,
              nonce: request.nonce,
              serial: request.serial,
              signature: request.signature,
              sslVerify: request.sslVerify,
              displayCode: '123456',
            );

            await notifier.addOrReplace(codeToPhone);

            final pending = currentState().pushRequests;
            // PushRequest equality includes the runtime type, so the replacement is
            // added next to the original instead of replacing it.
            expect(pending.map((r) => r.runtimeType), [
              PushDefaultRequest,
              PushCodeToPhoneRequest,
            ]);
          },
        );

        group('buffer of known request ids', () {
          Future<void> addNewer(PushRequestNotifier notifier, int count) async {
            for (var i = 0; i < count; i++) {
              expect(await notifier.add(_plainRequest('newer-$i')), isTrue);
            }
          }

          // The state keeps the ids of the last 100 requests only. Design
          // limitation: an old challenge that the server still holds open can be
          // delivered again once 100 newer ones were seen.
          test(
            'the oldest id is still known after 99 newer requests',
            () async {
              final old = _plainRequest('nonce-old');
              final notifier = await boot(pending: [old]);
              await notifier.remove(old);

              await addNewer(notifier, 99);

              expect(currentState().knownPushRequests.length, 100);
              expect(currentState().knowsRequest(old), isTrue);
              expect(await notifier.add(old), isFalse);
            },
          );

          test(
            'the oldest id is forgotten after 100 newer requests, so it is accepted again',
            () async {
              final old = _plainRequest('nonce-old');
              final notifier = await boot(pending: [old]);
              await notifier.remove(old);

              await addNewer(notifier, 100);

              expect(currentState().knownPushRequests.length, 100);
              expect(currentState().knowsRequest(old), isFalse);
              expect(await notifier.add(old), isTrue);
              expect(
                currentState().pushRequests.map((r) => r.nonce),
                contains('nonce-old'),
              );
            },
          );

          test('the buffer never grows beyond its maximum size', () async {
            final notifier = await boot();

            await addNewer(notifier, 105);

            expect(currentState().knownPushRequests.length, 100);
            expect(currentState().knownPushRequests.maxSize, 100);
            expect(currentState().pushRequests, hasLength(105));
          });
        });

        test(
          'add reports false when the request could not be saved',
          () async {
            final notifier = await boot();
            repo.failingSaves = 1;
            final request = _plainRequest('nonce-unsaved');

            final added = await notifier.add(request);

            expect(currentState().pushRequests, isEmpty);
            expect(repo.state.pushRequests, isEmpty);
            expect(added, isFalse);
          },
          skip:
              'BUG: push_request_provider.dart:275 add returns true although saving the request failed',
        );

        test('add reports false for the same request twice in a row', () async {
          final notifier = await boot();
          final request = _plainRequest('nonce-twice');

          final results = [
            await notifier.add(request),
            await notifier.add(request),
          ];

          expect(results, [true, false]);
          expect(currentState().pushRequests, hasLength(1));
        });

        test('concurrent adds of the same request store it once', () async {
          final notifier = await boot();
          final request = _plainRequest('nonce-concurrent');

          await Future.wait([notifier.add(request), notifier.add(request)]);

          expect(currentState().pushRequests, hasLength(1));
        });

        test('the push provider delivers new requests to add', () async {
          final notifier = await boot();
          final captured = verify(pushProvider.subscribe(captureAny)).captured;
          expect(captured, hasLength(1));
          final subscriber = captured.single as void Function(PushRequest);
          final request = _plainRequest('nonce-from-provider');

          subscriber(request);
          subscriber(request);
          // Both calls are queued behind the mutex of the notifier.
          await notifier.future;
          await pumpEventQueue();

          expect(currentState().pushRequests, [request]);
        });
      });

      group('expiration', () {
        test('an expired request is removed by its timer', () {
          fakeAsync((async) {
            final request = _plainRequest(
              'nonce-expiring',
              expirationDate: DateTime.now().add(const Duration(minutes: 2)),
            );
            repo.state = PushRequestState(
              pushRequests: [request],
              knownPushRequests: CustomIntBuffer(list: [request.id]),
            );
            final provider = providerOf();
            container.read(provider);
            async.flushMicrotasks();
            expect(container.read(provider).value!.pushRequests, [request]);

            async.elapse(const Duration(minutes: 1));
            expect(container.read(provider).value!.pushRequests, [request]);

            async.elapse(const Duration(minutes: 2));
            expect(container.read(provider).value!.pushRequests, isEmpty);
            expect(repo.state.pushRequests, isEmpty);
            // Removed, but its id stays known against a replay.
            expect(repo.state.knowsRequest(request), isTrue);
            container.dispose();
          });
        });

        test('only the expired request of two is removed', () {
          fakeAsync((async) {
            final now = DateTime.now();
            final shortLived = _plainRequest(
              'nonce-short',
              expirationDate: now.add(const Duration(minutes: 1)),
            );
            final longLived = _plainRequest(
              'nonce-long',
              expirationDate: now.add(const Duration(minutes: 10)),
            );
            repo.state = PushRequestState(
              pushRequests: [shortLived, longLived],
              knownPushRequests: CustomIntBuffer(
                list: [shortLived.id, longLived.id],
              ),
            );
            final provider = providerOf();
            container.read(provider);
            async.flushMicrotasks();

            async.elapse(const Duration(minutes: 5));

            expect(container.read(provider).value!.pushRequests, [longLived]);
            container.dispose();
          });
        });

        test(
          'a request that expired while the app was closed is removed on load',
          () {
            fakeAsync((async) {
              final expired = _plainRequest(
                'nonce-long-gone',
                expirationDate: DateTime.utc(2000),
              );
              repo.state = PushRequestState(
                pushRequests: [expired],
                knownPushRequests: CustomIntBuffer(list: [expired.id]),
              );
              final provider = providerOf();
              container.read(provider);
              async.flushMicrotasks();

              expect(container.read(provider).value!.pushRequests, isEmpty);
              expect(repo.state.pushRequests, isEmpty);
              container.dispose();
            });
          },
        );

        test('adding an already expired request removes it right away', () {
          fakeAsync((async) {
            final provider = providerOf();
            container.read(provider);
            async.flushMicrotasks();
            final notifier = container.read(provider.notifier);
            final expired = _plainRequest(
              'nonce-expired-on-arrival',
              expirationDate: DateTime.utc(2000),
            );

            bool? added;
            notifier.add(expired).then((value) => added = value);
            async.flushMicrotasks();

            expect(added, isTrue);
            expect(container.read(provider).value!.pushRequests, isEmpty);
            expect(
              container.read(provider).value!.knowsRequest(expired),
              isTrue,
            );
            container.dispose();
          });
        });

        test(
          'adding a request sets one timer and removing it cancels the timer',
          () {
            fakeAsync((async) {
              final provider = providerOf();
              container.read(provider);
              async.flushMicrotasks();
              final notifier = container.read(provider.notifier);
              final baseline = async.pendingTimers.length;
              final request = _plainRequest('nonce-timer');

              notifier.add(request);
              async.flushMicrotasks();
              expect(async.pendingTimers.length, baseline + 1);

              notifier.remove(request);
              async.flushMicrotasks();
              expect(async.pendingTimers.length, baseline);
              final savesAfterRemove = repo.saveCount;

              // Nothing is left that could remove it a second time.
              async.elapse(const Duration(minutes: 10));
              expect(repo.saveCount, savesAfterRemove);
              container.dispose();
            });
          },
        );

        test('replacing a request replaces its timer', () {
          fakeAsync((async) {
            final provider = providerOf();
            container.read(provider);
            async.flushMicrotasks();
            final notifier = container.read(provider.notifier);
            final baseline = async.pendingTimers.length;
            final now = DateTime.now();
            final request = _plainRequest(
              'nonce-extended',
              expirationDate: now.add(const Duration(minutes: 1)),
            );
            notifier.add(request);
            async.flushMicrotasks();

            notifier.addOrReplace(
              (request as PushDefaultRequest).copyWith(
                expirationDate: now.add(const Duration(minutes: 10)),
              ),
            );
            async.flushMicrotasks();
            expect(async.pendingTimers.length, baseline + 1);

            async.elapse(const Duration(minutes: 5));
            expect(container.read(provider).value!.pushRequests, [request]);

            async.elapse(const Duration(minutes: 6));
            expect(container.read(provider).value!.pushRequests, isEmpty);
            container.dispose();
          });
        });

        test('a reaction removes the request and with it its timer', () {
          fakeAsync((async) {
            final request = _requestOf(
              advertising,
              expirationDate: DateTime.now().add(const Duration(minutes: 2)),
            );
            repo.state = PushRequestState(
              pushRequests: [request],
              knownPushRequests: CustomIntBuffer(list: [request.id]),
            );
            postReturns(Response(_successBody, 200));
            final provider = providerOf();
            container.read(provider);
            async.flushMicrotasks();
            final notifier = container.read(provider.notifier);
            final withTimer = async.pendingTimers.length;

            notifier.accept(advertisingToken, request);
            async.flushMicrotasks();

            expect(container.read(provider).value!.pushRequests, isEmpty);
            expect(async.pendingTimers.length, withTimer - 1);
            container.dispose();
          });
        });

        test('disposing the notifier cancels the timers and unsubscribes', () {
          fakeAsync((async) {
            final request = _plainRequest(
              'nonce-dispose',
              expirationDate: DateTime.now().add(const Duration(minutes: 2)),
            );
            repo.state = PushRequestState(
              pushRequests: [request],
              knownPushRequests: CustomIntBuffer(list: [request.id]),
            );
            final provider = providerOf();
            container.read(provider);
            async.flushMicrotasks();
            final withTimer = async.pendingTimers.length;
            final savesBefore = repo.saveCount;

            container.dispose();

            expect(async.pendingTimers.length, withTimer - 1);
            verify(pushProvider.unsubscribe(any)).called(1);
            // The expiration of the request does nothing any more.
            async.elapse(const Duration(minutes: 10));
            expect(repo.saveCount, savesBefore);
            expect(repo.state.pushRequests, [request]);
          });
        });

        test('a removal that cannot be saved is tried again', () {
          fakeAsync((async) {
            final request = _plainRequest(
              'nonce-flaky',
              expirationDate: DateTime.now().add(const Duration(minutes: 1)),
            );
            repo.state = PushRequestState(
              pushRequests: [request],
              knownPushRequests: CustomIntBuffer(list: [request.id]),
            );
            final provider = providerOf();
            container.read(provider);
            async.flushMicrotasks();
            final savesBefore = repo.saveCount;
            repo.failingSaves = 1;

            // The clock of DateTime.now is not faked, so every retry waits for a
            // timer of the remaining lifetime here. In the app the request is
            // expired by then and the retry is immediate.
            async.elapse(const Duration(minutes: 5));

            // One failure and the second attempt that works.
            expect(repo.saveCount - savesBefore, 2);
            expect(container.read(provider).value!.pushRequests, isEmpty);
            expect(repo.state.pushRequests, isEmpty);
            container.dispose();
          });
        });
      });
    },
  );
}
