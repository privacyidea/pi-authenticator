import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/repo/secure_storage.dart';
import 'package:privacyidea_authenticator/repo/secure_token_container_repository.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;
  late MockFlutterSecureStorage mockLegacyStorage;
  late SecureStorage storage;
  late SecureStorage legacyStorage;
  late SecureTokenContainerRepository repository;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockLegacyStorage = MockFlutterSecureStorage();
    storage = SecureStorage(storagePrefix: SecureTokenContainerRepository.TOKEN_CONTAINER_PREFIX, storage: mockStorage);
    legacyStorage = SecureStorage(storagePrefix: SecureTokenContainerRepository.TOKEN_CONTAINER_PREFIX_LEGACY, storage: mockLegacyStorage, seperator: '.');
    repository = SecureTokenContainerRepository(storage: storage, legacyStorage: legacyStorage);
  });

  TokenContainer createContainer(String serial) {
    return TokenContainer.finalized(
      serial: serial,
      issuer: 'issuer',
      nonce: 'nonce',
      timestamp: DateTime.now(),
      serverUrl: Uri.parse('https://example.com'),
      ecKeyAlgorithm: EcKeyAlgorithm.secp256r1,
      hashAlgorithm: Algorithms.SHA256,
      sslVerify: false,
      publicClientKey: 'publicClientKey',
      privateClientKey: 'privateClientKey',
    );
  }

  group('SecureTokenContainerRepository', () {
    test('loadContainerState returns empty state if nothing is stored', () async {
      when(mockStorage.readAll()).thenAnswer((_) async => {});
      when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});

      final state = await repository.loadContainerState();

      expect(state.containerList, isEmpty);
    });

    test('loadContainerState loads containers from storage', () async {
      final container1 = createContainer('serial1');
      final container2 = createContainer('serial2');
      final containerMap = {'serial1': jsonEncode(container1.toJson()), 'serial2': jsonEncode(container2.toJson())};
      when(mockStorage.readAll()).thenAnswer((_) async => containerMap);
      when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});

      final state = await repository.loadContainerState();

      expect(state.containerList.length, 2);
      expect(state.containerList.any((c) => c.serial == 'serial1'), isTrue);
      expect(state.containerList.any((c) => c.serial == 'serial2'), isTrue);
    });

    test('saveContainer saves a container to storage', () async {
      final container = createContainer('serial1');
      when(mockStorage.write(key: 'serial1', value: anyNamed('value'))).thenAnswer((_) async {});
      when(mockStorage.readAll()).thenAnswer((_) async => {'serial1': jsonEncode(container.toJson())});
      when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});

      await repository.saveContainer(container);

      verify(mockStorage.write(key: 'serial1', value: jsonEncode(container.toJson()))).called(1);
    });

    test('deleteContainer removes a container from storage', () async {
      when(mockStorage.delete(key: 'serial1')).thenAnswer((_) async {});
      when(mockStorage.readAll()).thenAnswer((_) async => {});
      when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});

      await repository.deleteContainer('serial1');

      verify(mockStorage.delete(key: 'serial1')).called(1);
    });

    test('deleteAllContainer removes all containers from storage', () async {
      when(mockStorage.deleteAll()).thenAnswer((_) async {});
      when(mockStorage.readAll()).thenAnswer((_) async => {});
      when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});

      await repository.deleteAllContainer();

      verify(mockStorage.deleteAll()).called(1);
    });
  });

  group('Migration', () {
    test('loadContainerState migrates legacy containers', () async {
      final container1 = createContainer('serial1');
      final legacyContainerMap = {'serial1': jsonEncode(container1.toJson())};

      when(mockLegacyStorage.readAll()).thenAnswer((_) async => legacyContainerMap);
      when(mockStorage.readAll()).thenAnswer((_) async => {});
      when(mockStorage.write(key: 'serial1', value: anyNamed('value'))).thenAnswer((_) async {});
      when(mockLegacyStorage.delete(key: 'serial1')).thenAnswer((_) async {});

      await repository.loadContainerState();

      verify(mockStorage.write(key: 'serial1', value: jsonEncode(container1.toJson()))).called(1);
      verify(mockLegacyStorage.delete(key: 'serial1')).called(1);
    });

    test('loadContainerState does not migrate if no legacy containers exist', () async {
      when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});
      when(mockStorage.readAll()).thenAnswer((_) async => {});

      await repository.loadContainerState();

      verifyNever(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')));
      verifyNever(mockLegacyStorage.delete(key: anyNamed('key')));
    });
  });
}
