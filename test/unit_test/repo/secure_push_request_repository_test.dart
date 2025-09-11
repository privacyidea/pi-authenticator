import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/repo/secure_push_request_repository.dart';
import 'package:privacyidea_authenticator/utils/custom_int_buffer.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  late MockSecureStorage mockStorage;
  late MockSecureStorage mockLegacyStorage;
  late SecurePushRequestRepository repository;

  setUp(() {
    mockStorage = MockSecureStorage();
    mockLegacyStorage = MockSecureStorage();
    repository = SecurePushRequestRepository(secureStorage: mockStorage, legacySecureStorage: mockLegacyStorage);
  });

  group('SecurePushRequestRepository', () {
    test('saveState stores PushRequestState as JSON', () async {
      final state = PushRequestState(
        pushRequests: [
          PushRequest(id: 1, title: 'a', question: '', uri: Uri(), nonce: '', sslVerify: false, expirationDate: DateTime.parse('2024-01-01T00:00:00Z')),
        ],
        knownPushRequests: CustomIntBuffer(list: [1]),
      );
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value'))).thenAnswer((_) async => {});
      await repository.saveState(state);
      verify(mockStorage.write(key: anyNamed('key'), value: jsonEncode(state.toJson()))).called(1);
    });

    test('loadState returns empty state if nothing stored', () async {
      when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);
      when(mockLegacyStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);
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
      final initialState = PushRequestState(
        pushRequests: [],
        knownPushRequests: CustomIntBuffer(list: []),
      );
      when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => jsonEncode(initialState.toJson()));
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value'))).thenAnswer((_) async => {});
      final newState = await repository.addRequest(pushRequest);
      expect(newState.pushRequests.any((r) => r.id == 2), isTrue);
    });

    test('addRequest does not duplicate existing request', () async {
      final pushRequest = PushRequest(
        id: 3,
        title: 'c',
        question: '',
        uri: Uri(),
        nonce: '',
        sslVerify: false,
        expirationDate: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      final initialState = PushRequestState(
        pushRequests: [pushRequest],
        knownPushRequests: CustomIntBuffer(list: [3]),
      );
      when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => jsonEncode(initialState.toJson()));
      final newState = await repository.addRequest(pushRequest);
      expect(newState.pushRequests.length, 1);
    });

    test('removeRequest removes request and saves state', () async {
      final pushRequest = PushRequest(
        id: 4,
        title: 'd',
        question: '',
        uri: Uri(),
        nonce: '',
        sslVerify: false,
        expirationDate: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      final initialState = PushRequestState(
        pushRequests: [pushRequest],
        knownPushRequests: CustomIntBuffer(list: [4]),
      );
      when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => jsonEncode(initialState.toJson()));
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value'))).thenAnswer((_) async => {});
      final newState = await repository.removeRequest(pushRequest);
      expect(newState.pushRequests, isEmpty);
    });

    test('clearState deletes state from storage', () async {
      when(mockStorage.delete(key: anyNamed('key'))).thenAnswer((_) async => {});
      await repository.clearState();
      verify(mockStorage.delete(key: anyNamed('key'))).called(1);
    });
  });

  group('Legacy migration', () {
    test('loadState migrates legacy state if no default state exists', () async {
      final legacyState = PushRequestState(
        pushRequests: [
          PushRequest(id: 5, title: 'e', question: '', uri: Uri(), nonce: '', sslVerify: false, expirationDate: DateTime.parse('2024-01-01T00:00:00Z')),
        ],
        knownPushRequests: CustomIntBuffer(list: [5]),
      );
      when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);
      when(mockLegacyStorage.read(key: anyNamed('key'))).thenAnswer((_) async => jsonEncode(legacyState.toJson()));
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value'))).thenAnswer((_) async => {});
      when(mockLegacyStorage.delete(key: anyNamed('key'))).thenAnswer((_) async => {});
      final state = await repository.loadState();
      expect(state.pushRequests.length, 1);
      expect(state.pushRequests.first.id, 5);
      verify(mockStorage.write(key: anyNamed('key'), value: anyNamed('value'))).called(1);
      verify(mockLegacyStorage.delete(key: anyNamed('key'))).called(1);
    });

    test('loadState prefers default state over legacy', () async {
      final defaultState = PushRequestState(
        pushRequests: [
          PushRequest(id: 6, title: 'f', question: '', uri: Uri(), nonce: '', sslVerify: false, expirationDate: DateTime.parse('2024-01-01T00:00:00Z')),
        ],
        knownPushRequests: CustomIntBuffer(list: [6]),
      );
      final legacyState = PushRequestState(
        pushRequests: [
          PushRequest(id: 7, title: 'g', question: '', uri: Uri(), nonce: '', sslVerify: false, expirationDate: DateTime.parse('2024-01-01T00:00:00Z')),
        ],
        knownPushRequests: CustomIntBuffer(list: [7]),
      );
      when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => jsonEncode(defaultState.toJson()));
      when(mockLegacyStorage.read(key: anyNamed('key'))).thenAnswer((_) async => jsonEncode(legacyState.toJson()));
      final state = await repository.loadState();
      expect(state.pushRequests.length, 1);
      expect(state.pushRequests.first.id, 6);
    });

    test('migration does nothing if no legacy state exists', () async {
      when(mockLegacyStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);
      final result = await repository.loadState();
      expect(result.pushRequests, isEmpty);
    });
  });
}
