import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/repo/secure_storage.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorage secureStorage;
  const storagePrefix = 'testprefix';

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureStorage = SecureStorage(
      storagePrefix: storagePrefix,
      storage: mockStorage,
    );
  });

  group('SecureStorage', () {
    test('getFullKey returns correct key', () {
      expect(secureStorage.getFullKey('mykey'), equals('testprefix_mykey'));
    });

    test('write calls storage.write with correct key and value', () async {
      when(
        mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
      ).thenAnswer((_) async => {});
      await secureStorage.write(key: 'foo', value: 'bar');
      verify(mockStorage.write(key: 'testprefix_foo', value: 'bar')).called(1);
    });

    test('read calls storage.read with correct key', () async {
      when(
        mockStorage.read(key: anyNamed('key')),
      ).thenAnswer((_) async => 'value');
      final result = await secureStorage.read(key: 'foo');
      expect(result, 'value');
      verify(mockStorage.read(key: 'testprefix_foo')).called(1);
    });

    test('readAll returns only prefixed keys with prefix removed', () async {
      when(mockStorage.readAll()).thenAnswer(
        (_) async => {
          'testprefix_key1': 'val1',
          'testprefix_key2': 'val2',
          'otherprefix_key3': 'val3',
        },
      );
      final result = await secureStorage.readAll();
      expect(result, {'key1': 'val1', 'key2': 'val2'});
    });

    test('delete calls storage.delete with correct key', () async {
      when(
        mockStorage.delete(key: anyNamed('key')),
      ).thenAnswer((_) async => {});
      await secureStorage.delete(key: 'foo');
      verify(mockStorage.delete(key: 'testprefix_foo')).called(1);
    });

    test('deleteAll deletes only prefixed keys', () async {
      when(mockStorage.readAll()).thenAnswer(
        (_) async => {
          'testprefix_key1': 'val1',
          'testprefix_key2': 'val2',
          'otherprefix_key3': 'val3',
        },
      );
      when(
        mockStorage.delete(key: anyNamed('key')),
      ).thenAnswer((_) async => {});
      await secureStorage.deleteAll();
      verify(mockStorage.delete(key: 'testprefix_key1')).called(1);
      verify(mockStorage.delete(key: 'testprefix_key2')).called(1);
      verifyNever(mockStorage.delete(key: 'otherprefix_key3'));
    });
  });

  group('SecureStorage with an overlapping prefix', () {
    // The real prefixes: the token one is a prefix of the container one, so
    // 'app_v4_token_container_1' starts with 'app_v4_token_' as well.
    const tokenPrefix = 'app_v4_token';
    const containerPrefix = 'app_v4_token_container';

    late MockFlutterSecureStorage mockStorage;
    late SecureStorage tokenStorage;

    const storedPairs = {
      'app_v4_token_id1': 'token1',
      'app_v4_token_id2': 'token2',
      'app_v4_token_container_c1': 'container1',
      'app_v4_token_container_c2': 'container2',
    };

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      tokenStorage = SecureStorage(
        storagePrefix: tokenPrefix,
        storage: mockStorage,
        excludedPrefixes: const [containerPrefix],
      );
      when(mockStorage.readAll()).thenAnswer((_) async => storedPairs);
      when(
        mockStorage.delete(key: anyNamed('key')),
      ).thenAnswer((_) async => {});
    });

    test('readAll does not return entries of the container storage', () async {
      final result = await tokenStorage.readAll();
      expect(result, {'id1': 'token1', 'id2': 'token2'});
    });

    test('deleteAll does not delete entries of the container storage', () async {
      await tokenStorage.deleteAll();
      verify(mockStorage.delete(key: 'app_v4_token_id1')).called(1);
      verify(mockStorage.delete(key: 'app_v4_token_id2')).called(1);
      verifyNever(mockStorage.delete(key: 'app_v4_token_container_c1'));
      verifyNever(mockStorage.delete(key: 'app_v4_token_container_c2'));
    });

    test('the container storage still reaches its own entries', () async {
      final containerStorage = SecureStorage(
        storagePrefix: containerPrefix,
        storage: mockStorage,
      );
      final result = await containerStorage.readAll();
      expect(result, {'c1': 'container1', 'c2': 'container2'});
    });

    test('without the exclusion the entries would collide', () async {
      final unguarded = SecureStorage(
        storagePrefix: tokenPrefix,
        storage: mockStorage,
      );
      final result = await unguarded.readAll();
      expect(result.keys, contains('container_c1'));
    });
  });
}
