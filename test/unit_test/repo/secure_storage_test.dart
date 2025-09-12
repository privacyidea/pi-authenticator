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
    secureStorage = SecureStorage(storagePrefix: storagePrefix, storage: mockStorage);
  });

  group('SecureStorage', () {
    test('getFullKey returns correct key', () {
      expect(secureStorage.getFullKey('mykey'), equals('testprefix_mykey'));
    });

    test('write calls storage.write with correct key and value', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value'))).thenAnswer((_) async => {});
      await secureStorage.write(key: 'foo', value: 'bar');
      verify(mockStorage.write(key: 'testprefix_foo', value: 'bar')).called(1);
    });

    test('read calls storage.read with correct key', () async {
      when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => 'value');
      final result = await secureStorage.read(key: 'foo');
      expect(result, 'value');
      verify(mockStorage.read(key: 'testprefix_foo')).called(1);
    });

    test('readAll returns only prefixed keys with prefix removed', () async {
      when(mockStorage.readAll()).thenAnswer((_) async => {'testprefix_key1': 'val1', 'testprefix_key2': 'val2', 'otherprefix_key3': 'val3'});
      final result = await secureStorage.readAll();
      expect(result, {'key1': 'val1', 'key2': 'val2'});
    });

    test('delete calls storage.delete with correct key', () async {
      when(mockStorage.delete(key: anyNamed('key'))).thenAnswer((_) async => {});
      await secureStorage.delete(key: 'foo');
      verify(mockStorage.delete(key: 'testprefix_foo')).called(1);
    });

    test('deleteAll deletes only prefixed keys', () async {
      when(mockStorage.readAll()).thenAnswer((_) async => {'testprefix_key1': 'val1', 'testprefix_key2': 'val2', 'otherprefix_key3': 'val3'});
      when(mockStorage.delete(key: anyNamed('key'))).thenAnswer((_) async => {});
      await secureStorage.deleteAll();
      verify(mockStorage.delete(key: 'testprefix_key1')).called(1);
      verify(mockStorage.delete(key: 'testprefix_key2')).called(1);
      verifyNever(mockStorage.delete(key: 'otherprefix_key3'));
    });
  });
}
