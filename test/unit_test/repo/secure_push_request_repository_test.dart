import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/push_request/push_default_request.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/repo/secure_push_request_repository.dart';
import 'package:privacyidea_authenticator/repo/secure_storage.dart';
import 'package:privacyidea_authenticator/utils/custom_int_buffer.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  late MockFlutterSecureStorage mockFlutterStorage;
  late MockFlutterSecureStorage mockLegacyFlutterStorage;
  late SecurePushRequestRepository repository;

  const newPrefix = SecurePushRequestRepository.PUSH_REQUEST_PREFIX;
  const newKeyName = SecurePushRequestRepository.KEY;
  const fullNewKey = '${newPrefix}_$newKeyName';

  const legacyPrefix = SecurePushRequestRepository.PUSH_REQUEST_PREFIX_LEGACY;
  const legacyKeyName = SecurePushRequestRepository.KEY_LEGACY;
  const fullLegacyKey = '${legacyPrefix}_$legacyKeyName';

  setUp(() {
    mockFlutterStorage = MockFlutterSecureStorage();
    mockLegacyFlutterStorage = MockFlutterSecureStorage();
    final storage = SecureStorage(
      storagePrefix: SecurePushRequestRepository.PUSH_REQUEST_PREFIX,
      storage: mockFlutterStorage,
    );
    final legacyStorage = SecureStorage(
      storagePrefix: SecurePushRequestRepository.PUSH_REQUEST_PREFIX_LEGACY,
      storage: mockLegacyFlutterStorage,
    );
    repository = SecurePushRequestRepository(
      secureStorage: storage,
      legacySecureStorage: legacyStorage,
    );
  });

  PushRequestState createState(List<String> pushRequestNonses) {
    final pushRequests = pushRequestNonses
        .map(
          (nonce) => PushDefaultRequest(
            serial: 'PIPU$nonce',
            signature: 'sig$nonce',
            title: 'title$nonce',
            question: 'question$nonce',
            uri: Uri.parse('https://example.com/$nonce'),
            nonce: nonce,
            sslVerify: true,
            expirationDate: DateTime.fromMillisecondsSinceEpoch(
              0,
            ).add(const Duration(minutes: 5)),
          ),
        )
        .toList();
    return PushRequestState(
      pushRequests: pushRequests,
      knownPushRequests: CustomIntBuffer(
        list: pushRequests.map((r) => r.id).toList(),
      ),
    );
  }

  group('SecurePushRequestRepository', () {
    test('saveState stores PushRequestState as JSON', () async {
      final state = createState(["1", "2", "3"]);
      final expectedValue = jsonEncode(state.toJson());

      when(
        mockFlutterStorage.write(key: fullNewKey, value: expectedValue),
      ).thenAnswer((_) async => {});

      await repository.saveState(state);

      verify(
        mockFlutterStorage.write(key: fullNewKey, value: expectedValue),
      ).called(1);
    });

    test('loadState returns empty state if nothing stored', () async {
      when(
        mockFlutterStorage.read(key: fullNewKey),
      ).thenAnswer((_) async => null);
      when(
        mockLegacyFlutterStorage.read(key: fullLegacyKey),
      ).thenAnswer((_) async => null);

      final state = await repository.loadState();

      expect(state.pushRequests, isEmpty);
      expect(state.knownPushRequests.list, isEmpty);
    });

    test('loadState loads state from storage', () async {
      final state = createState(["1", "2", "3"]);
      final stateJson = jsonEncode(state.toJson());

      when(
        mockFlutterStorage.read(key: fullNewKey),
      ).thenAnswer((_) async => stateJson);

      final loadedState = await repository.loadState();

      expect(loadedState.pushRequests.length, 3);
      expect(loadedState.knownPushRequests.list, [
        7045321,
        296362822,
        604030963,
      ]);
    });

    test('addRequest adds new request and saves state', () async {
      final initialState = createState(["1"]);
      final newRequest = PushDefaultRequest(
        serial: 'PIPU2',
        signature: 'sig2',
        title: 'b',
        question: '',
        uri: Uri(),
        nonce: '2',
        sslVerify: false,
        expirationDate: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      final finalState = initialState.withRequest(newRequest);

      when(
        mockFlutterStorage.read(key: fullNewKey),
      ).thenAnswer((_) async => jsonEncode(initialState.toJson()));
      when(
        mockFlutterStorage.write(
          key: fullNewKey,
          value: jsonEncode(finalState.toJson()),
        ),
      ).thenAnswer((_) async => {});

      final resultState = await repository.addRequest(newRequest);

      expect(resultState.pushRequests.length, 2);
      expect(resultState.pushRequests.any((r) => r.id == 296362822), isTrue);
      verify(
        mockFlutterStorage.write(
          key: fullNewKey,
          value: jsonEncode(finalState.toJson()),
        ),
      ).called(1);
    });

    test('clearState deletes state from storage', () async {
      when(mockFlutterStorage.delete(key: fullNewKey)).thenAnswer((_) async {});

      await repository.clearState();

      verify(mockFlutterStorage.delete(key: fullNewKey)).called(1);
    });
  });

  group('Legacy migration', () {
    test(
      'loadState migrates legacy state if no default state exists',
      () async {
        final legacyState = createState(["5"]);
        final legacyStateJson = jsonEncode(legacyState.toJson());

        when(
          mockFlutterStorage.read(key: fullNewKey),
        ).thenAnswer((_) async => null);
        when(
          mockLegacyFlutterStorage.read(key: fullLegacyKey),
        ).thenAnswer((_) async => legacyStateJson);
        when(
          mockFlutterStorage.write(key: fullNewKey, value: legacyStateJson),
        ).thenAnswer((_) async {});
        when(
          mockLegacyFlutterStorage.delete(key: fullLegacyKey),
        ).thenAnswer((_) async {});

        final resultState = await repository.loadState();

        expect(resultState.pushRequests.length, 1);
        expect(resultState.knownPushRequests.list, [155652735]);
        verify(
          mockFlutterStorage.write(key: fullNewKey, value: legacyStateJson),
        ).called(1);
        verify(mockLegacyFlutterStorage.delete(key: fullLegacyKey)).called(1);
      },
    );

    test('loadState prefers default state over legacy', () async {
      final defaultState = createState(["4"]);
      final legacyState = createState(["5"]);

      when(
        mockFlutterStorage.read(key: fullNewKey),
      ).thenAnswer((_) async => jsonEncode(defaultState.toJson()));

      final resultState = await repository.loadState();

      expect(resultState.pushRequests.length, 1);
      expect(resultState.knownPushRequests.list, [939782137]);
      verifyNever(mockLegacyFlutterStorage.read(key: anyNamed('key')));
      verifyNever(
        mockFlutterStorage.write(
          key: anyNamed('key'),
          value: jsonEncode(legacyState.toJson()),
        ),
      );
    });
  });
}
