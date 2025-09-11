import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/repo/secure_push_request_repository.dart';
import 'package:privacyidea_authenticator/repo/secure_storage.dart';
import 'package:privacyidea_authenticator/utils/custom_int_buffer.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  late MockFlutterSecureStorage mockFlutterStorage;
  late SecureStorage storage;
  late MockFlutterSecureStorage mockLegacyFlutterStorage;
  late SecureStorage legacyStorage;
  late SecurePushRequestRepository repository;

  setUp(() {
    mockFlutterStorage = MockFlutterSecureStorage();
    storage = SecureStorage(storagePrefix: SecurePushRequestRepository.PUSH_REQUEST_PREFIX, storage: mockFlutterStorage);
    mockLegacyFlutterStorage = MockFlutterSecureStorage();
    legacyStorage = SecureStorage(storagePrefix: SecurePushRequestRepository.PUSH_REQUEST_PREFIX_LEGACY, storage: mockLegacyFlutterStorage);

    repository = SecurePushRequestRepository(secureStorage: storage, legacySecureStorage: legacyStorage);
  });

  PushRequestState createState(List<int> pushRequestIds) {
    return PushRequestState(
      pushRequests: pushRequestIds
          .map(
            (id) => PushRequest(
              id: id,
              title: 'title$id',
              question: 'question$id',
              uri: Uri.parse('https://example.com/$id'),
              nonce: 'nonce$id',
              sslVerify: true,
              expirationDate: DateTime.now().add(const Duration(minutes: 5)),
            ),
          )
          .toList(),
      knownPushRequests: CustomIntBuffer(list: pushRequestIds),
    );
  }

  group('SecurePushRequestRepository', () {
    test('saveState stores PushRequestState as JSON', () async {
      final state = createState([1, 2, 3]);
      when(mockFlutterStorage.write(key: SecurePushRequestRepository.KEY, value: anyNamed('value'))).thenAnswer((_) async => {});
      await repository.saveState(state);
      final captured = verify(mockFlutterStorage.write(key: captureAnyNamed('key'), value: captureAnyNamed('value'))).captured;
      expect(captured[0], 'app_v4_push_request_state');
      final storedJson = captured[1] as String;
      final decoded = jsonDecode(storedJson) as Map<String, dynamic>;
      expect(decoded['pushRequests'], isA<List<dynamic>>());
      expect((decoded['pushRequests'] as List).length, 3);
      expect(decoded['knownPushRequests'], {
        'maxSize': 100,
        'list': [1, 2, 3],
      });
    });

    test('loadState returns empty state if nothing stored', () async {
      when(mockFlutterStorage.read(key: 'app_v4_push_request_state')).thenAnswer((_) async => null);
      // when(legacyStorage.read(key: SecurePushRequestRepository.KEY)).thenAnswer((_) async => null);
      final state = await repository.loadState();
      expect(state.pushRequests, isEmpty);
      expect(state.knownPushRequests.list, isEmpty);
    });

    test('addRequest adds new request and saves state', () async {
      final pushRequest = PushRequest(
        id: 2,
        title: 'b',
        question: '',
        uri: Uri(),
        nonce: '',
        sslVerify: false,
        expirationDate: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      final initialState = createState([1]);
      when(mockFlutterStorage.read(key: 'app_v4_push_request_state')).thenAnswer((_) async => jsonEncode(initialState.toJson()));
      when(mockFlutterStorage.write(key: 'app_v4_push_request_state', value: anyNamed('value'))).thenAnswer((_) async => {});
      final newState = await repository.addRequest(pushRequest);
      expect(newState.pushRequests.length, 2);
      expect(newState.pushRequests.any((r) => r.id == 1), isTrue);
      expect(newState.pushRequests.any((r) => r.id == 2), isTrue);
    });

    test('addRequest does not duplicate existing request', () async {
      final initialState = createState([3]);
      final pushRequest = initialState.pushRequests.first;
      when(mockFlutterStorage.read(key: 'app_v4_push_request_state')).thenAnswer((_) async => jsonEncode(initialState.toJson()));
      final newState = await repository.addRequest(pushRequest);
      expect(newState.pushRequests.length, 1);
      expect(newState.pushRequests.first.id, 3);
      verifyNever(mockFlutterStorage.write(key: 'app_v4_push_request_state', value: anyNamed('value')));
    });

    test('removeRequest removes request and saves state', () async {
      final initialState = createState([4]);
      final pushRequest = initialState.pushRequests.first;
      when(mockFlutterStorage.read(key: 'app_v4_push_request_state')).thenAnswer((_) async => jsonEncode(initialState.toJson()));
      when(mockFlutterStorage.write(key: 'app_v4_push_request_state', value: anyNamed('value'))).thenAnswer((_) async => {});
      final newState = await repository.removeRequest(pushRequest);
      expect(newState.pushRequests, isEmpty);
      expect(newState.knownPushRequests.list, [4]);
    });

    test('clearState deletes state from storage', () async {
      final initialState = createState([5]);
      String? mockState = jsonEncode(initialState.toJson());
      when(mockFlutterStorage.read(key: 'app_v4_push_request_state')).thenAnswer((_) async => mockState);
      final loadedState = await repository.loadState();
      expect(loadedState.pushRequests.length, 1);
      expect(loadedState.pushRequests.first.id, 5);
      when(mockFlutterStorage.delete(key: 'app_v4_push_request_state')).thenAnswer((_) async {
        mockState = null;
      });
      await repository.clearState();
      verify(mockFlutterStorage.delete(key: 'app_v4_push_request_state')).called(1);
      final newState = await repository.loadState();
      expect(newState.pushRequests, isEmpty);
      expect(newState.knownPushRequests.list, isEmpty);
    });
  });

  group('Legacy migration', () {
    test('loadState migrates legacy state if no default state exists', () async {
      final legacyState = createState([5]);
      final legacyStateJson = jsonEncode(legacyState.toJson());
      when(mockFlutterStorage.read(key: 'app_v4_push_request_state')).thenAnswer((args) async => null);
      when(mockLegacyFlutterStorage.read(key: 'app_v3_pr_state')).thenAnswer((args) async => legacyStateJson);
      final asd = await repository.loadState();
      expect(asd.pushRequests.length, 1);
      expect(asd.knownPushRequests.list, [5]);
    });

    test('loadState prefers default state over legacy', () async {
      final defaultState = createState([4]);
      final defaultStateJson = jsonEncode(defaultState.toJson());
      final legacyState = createState([5]);
      final legacyStateJson = jsonEncode(legacyState.toJson());
      when(mockFlutterStorage.read(key: 'app_v4_push_request_state')).thenAnswer((args) async => defaultStateJson);
      when(mockLegacyFlutterStorage.read(key: 'app_v3_pr_state')).thenAnswer((args) async => legacyStateJson);
      final asd = await repository.loadState();

      expect(asd.pushRequests.length, 1);
      expect(asd.knownPushRequests.list, [4]);
    });

    test('migration does nothing and returns an empty state if no legacy state exists', () async {
      when(mockFlutterStorage.read(key: 'app_v4_push_request_state')).thenAnswer((args) async => null);
      when(mockLegacyFlutterStorage.read(key: 'app_v3_pr_state')).thenAnswer((args) async => null);
      final result = await repository.loadState();
      expect(result.pushRequests, isEmpty);
      expect(result.knownPushRequests.list, isEmpty);
    });
  });
}
