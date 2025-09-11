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
      // readAll on the raw storage returns prefixed keys
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
      when(mockStorage.readAll()).thenAnswer((_) async => newTokenMap);

      final tokens = await repository.loadTokens();

      verify(mockStorage.write(key: newKey, value: value)).called(1);
      verify(mockLegacyStorage.delete(key: legacyKey)).called(1);

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

    test('loadTokens ignores invalid entries during migration', () async {
      final validToken = createToken('id1');
      final validTokenValue = jsonEncode(validToken.toJson());
      final validLegacyKey = '${legacyPrefix}_${validToken.id}';
      final validNewKey = '${newPrefix}_${validToken.id}';

      final legacyData = {
        validLegacyKey: validTokenValue, // Valid token
        '${legacyPrefix}_invalid_json': 'this is not a json string', // Invalid JSON
        '${legacyPrefix}_missing_type': jsonEncode({'some_key': 'some_value'}), // Valid JSON, but not a token
      };

      final expectedNewTokenMap = {
        validNewKey: validTokenValue,
      };

      when(mockLegacyStorage.readAll()).thenAnswer((_) async => legacyData);
      when(mockStorage.readAll()).thenAnswer((_) async => expectedNewTokenMap);

      // Expect write and delete to be called only for the valid token
      when(mockStorage.write(key: validNewKey, value: validTokenValue)).thenAnswer((_) async {});
      when(mockLegacyStorage.delete(key: validLegacyKey)).thenAnswer((_) async {});

      final tokens = await repository.loadTokens();

      // Verify that only the valid token was migrated
      verify(mockStorage.write(key: validNewKey, value: validTokenValue)).called(1);
      verify(mockLegacyStorage.delete(key: validLegacyKey)).called(1);

      // Verify that write/delete were NOT called for invalid entries
      verifyNever(mockStorage.write(key: '${legacyPrefix}_invalid_json', value: anyNamed('value')));
      verifyNever(mockLegacyStorage.delete(key: '${legacyPrefix}_invalid_json'));
      verifyNever(mockStorage.write(key: '${legacyPrefix}_missing_type', value: anyNamed('value')));
      verifyNever(mockLegacyStorage.delete(key: '${legacyPrefix}_missing_type'));

      // Verify the final list contains only the valid migrated token
      expect(tokens.length, 1);
      expect(tokens.first.id, 'id1');
    });
  });
}
