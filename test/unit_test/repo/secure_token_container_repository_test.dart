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

  // Prefixes are derived from the repository implementation.
  const legacyPrefix = 'containerCredentials';
  const newPrefix = 'app_v4_token_container';

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockLegacyStorage = MockFlutterSecureStorage();
    // The repository uses these prefixes internally to create SecureStorage instances.
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
      final containerMap = {
        // SecureStorage prefixes keys, so mocks must use prefixed keys.
        "${newPrefix}_serial1": jsonEncode(createContainer('serial1').toJson()),
        "${newPrefix}_serial2": jsonEncode(createContainer('serial2').toJson()),
      };

      when(mockStorage.readAll()).thenAnswer((_) async => containerMap);
      when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});

      final state = await repository.loadContainerState();

      expect(state.containerList.length, 2);
      expect(state.containerList.any((c) => c.serial == 'serial1'), isTrue);
      expect(state.containerList.any((c) => c.serial == 'serial2'), isTrue);
    });

    test('saveContainer saves a container to storage', () async {
      final container = createContainer('serial1');
      final expectedKey = '${newPrefix}_${container.serial}';
      final expectedValue = jsonEncode(container.toJson());

      when(mockStorage.write(key: expectedKey, value: expectedValue)).thenAnswer((_) async {});
      // The method under test reloads the state, so we need to mock readAll.
      when(mockStorage.readAll()).thenAnswer((_) async => {expectedKey: expectedValue});
      when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});

      await repository.saveContainer(container);

      verify(mockStorage.write(key: expectedKey, value: expectedValue)).called(1);
    });

    test('deleteContainer removes a container from storage', () async {
      const serial = 'serial1';
      final expectedKey = '${newPrefix}_$serial';
      when(mockStorage.delete(key: expectedKey)).thenAnswer((_) async {});
      // The method under test reloads the state, so we need to mock readAll.
      when(mockStorage.readAll()).thenAnswer((_) async => {});
      when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});

      await repository.deleteContainer(serial);

      verify(mockStorage.delete(key: expectedKey)).called(1);
    });

    test('deleteAllContainer removes all containers from storage', () async {
      // This test reflects the implementation of SecureStorage.deleteAll(), which
      // reads all, filters by prefix, and then deletes one by one.
      final containerMap = {
        "${newPrefix}_serial1": jsonEncode(createContainer('serial1').toJson()),
        "${newPrefix}_serial2": jsonEncode(createContainer('serial2').toJson()),
        "some_other_key": "some_other_value",
      };
      // 1. Mock readAll to return some values
      when(mockStorage.readAll()).thenAnswer((_) async => containerMap);
      // 2. Mock delete for the keys that should be deleted
      when(mockStorage.delete(key: "${newPrefix}_serial1")).thenAnswer((_) async {});
      when(mockStorage.delete(key: "${newPrefix}_serial2")).thenAnswer((_) async {});
      // 3. Mock legacy readAll for the subsequent loadContainerState call
      when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});

      await repository.deleteAllContainer();

      // 4. Verify delete was called for the correct keys
      verify(mockStorage.delete(key: "${newPrefix}_serial1")).called(1);
      verify(mockStorage.delete(key: "${newPrefix}_serial2")).called(1);
      // 5. Verify delete was NOT called for the other key
      verifyNever(mockStorage.delete(key: "some_other_key"));
      // 6. Verify the underlying deleteAll is never called
      verifyNever(mockStorage.deleteAll());
    });
  });

  group('Migration', () {
    test('loadContainerState migrates legacy containers and returns them in state', () async {
      final container1 = createContainer('serial1');
      final legacyKey = '$legacyPrefix.${container1.serial}';
      final newKey = '${newPrefix}_${container1.serial}';
      final value = jsonEncode(container1.toJson());

      final legacyContainerMap = {legacyKey: value};
      final newContainerMap = <String, String>{newKey: value}; // This is what readAll should find AFTER migration

      when(mockLegacyStorage.readAll()).thenAnswer((_) async => legacyContainerMap);
      // When _migrate runs, it will write to the new storage.
      when(mockStorage.write(key: newKey, value: value)).thenAnswer((_) async {});
      // When loadContainerState then reads from the new storage, it should find the migrated data.
      when(mockStorage.readAll()).thenAnswer((_) async => newContainerMap);
      // The migration also deletes the old data.
      when(mockLegacyStorage.delete(key: legacyKey)).thenAnswer((_) async {});

      final state = await repository.loadContainerState();

      // Verify migration calls happened
      verify(mockStorage.write(key: newKey, value: value)).called(1);
      verify(mockLegacyStorage.delete(key: legacyKey)).called(1);

      // Verify the final state contains the migrated container
      expect(state.containerList.length, 1);
      expect(state.containerList.first.serial, 'serial1');
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
