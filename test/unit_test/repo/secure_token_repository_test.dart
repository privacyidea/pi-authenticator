import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/repo/secure_storage.dart';
import 'package:privacyidea_authenticator/repo/secure_token_repository.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;
  late MockFlutterSecureStorage mockLegacyStorage;
  late SecureStorage storage;
  late SecureStorage legacyStorage;
  late SecureTokenRepository repository;

  const legacyPrefix = 'app_v3';
  const newPrefix = 'app_v4_token';

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockLegacyStorage = MockFlutterSecureStorage();
    storage = SecureStorage(storagePrefix: newPrefix, storage: mockStorage);
    legacyStorage = SecureStorage(storagePrefix: legacyPrefix, storage: mockLegacyStorage);
    repository = SecureTokenRepository(storage: storage, legacyStorage: legacyStorage);
  });

  TOTPToken createToken(String id) {
    return TOTPToken(
      label: id,
      issuer: 'issuer',
      secret: 'SECRET',
      id: id,
      algorithm: Algorithms.SHA1,
      digits: 6,
      period: 30,
    );
  }

  group('SecureTokenRepository', () {
    test('loadTokens returns empty list if nothing is stored', () async {
      when(mockStorage.readAll()).thenAnswer((_) async => {});
      when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});

      final tokens = await repository.loadTokens();

      expect(tokens, isEmpty);
    });

    test('loadTokens loads tokens from storage', () async {
      final token1 = createToken('id1');
      final token2 = createToken('id2');
      final tokenMap = {
        '${newPrefix}_${token1.id}': jsonEncode(token1.toJson()),
        '${newPrefix}_${token2.id}': jsonEncode(token2.toJson()),
      };

      when(mockStorage.readAll()).thenAnswer((_) async => tokenMap);
      when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});

      final tokens = await repository.loadTokens();

      expect(tokens.length, 2);
      expect(tokens.any((t) => t.id == 'id1'), isTrue);
      expect(tokens.any((t) => t.id == 'id2'), isTrue);
    });

    test('saveOrReplaceToken saves a token to storage', () async {
      final token = createToken('id1');
      final expectedKey = '${newPrefix}_${token.id}';
      final expectedValue = jsonEncode(token.toJson());

      when(mockStorage.write(key: expectedKey, value: expectedValue)).thenAnswer((_) async {});

      final result = await repository.saveOrReplaceToken(token);

      expect(result, isTrue);
      verify(mockStorage.write(key: expectedKey, value: expectedValue)).called(1);
    });

    test('deleteToken removes a token from storage', () async {
      final token = createToken('id1');
      final expectedKey = '${newPrefix}_${token.id}';

      when(mockStorage.delete(key: expectedKey)).thenAnswer((_) async {});

      final result = await repository.deleteToken(token);

      expect(result, isTrue);
      verify(mockStorage.delete(key: expectedKey)).called(1);
    });
  });

  group('Migration', () {
    test('loadTokens migrates legacy tokens', () async {
      final token1 = createToken('id1');
      final legacyKey = '${legacyPrefix}_${token1.id}';
      final newKey = '${newPrefix}_${token1.id}';
      final value = jsonEncode(token1.toJson());

      final legacyTokenMap = {legacyKey: value};
      final newTokenMap = {newKey: value};

      when(mockLegacyStorage.readAll()).thenAnswer((_) async => legacyTokenMap);
      when(mockStorage.write(key: newKey, value: value)).thenAnswer((_) async {});
      when(mockLegacyStorage.delete(key: legacyKey)).thenAnswer((_) async {});
      // When loadTokens reads from the new storage, it should find the migrated token.
      when(mockStorage.readAll()).thenAnswer((_) async => newTokenMap);

      final tokens = await repository.loadTokens();

      // Verify migration calls
      verify(mockStorage.write(key: newKey, value: value)).called(1);
      verify(mockLegacyStorage.delete(key: legacyKey)).called(1);

      // Verify the final list contains the migrated token
      expect(tokens.length, 1);
      expect(tokens.first.id, 'id1');
    });

    test('loadTokens does not migrate if no legacy tokens exist', () async {
      when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});
      when(mockStorage.readAll()).thenAnswer((_) async => {});

      await repository.loadTokens();

      verifyNever(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')));
      verifyNever(mockLegacyStorage.delete(key: anyNamed('key')));
    });
  });
}
