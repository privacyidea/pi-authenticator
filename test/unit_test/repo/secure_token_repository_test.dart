/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:convert';

import 'package:flutter/services.dart';
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
    storage = SecureStorage(
      storagePrefix: SecureTokenRepository.TOKEN_PREFIX,
      storage: mockStorage,
    );
    legacyStorage = SecureStorage(
      storagePrefix: SecureTokenRepository.TOKEN_PREFIX_LEGACY,
      storage: mockLegacyStorage,
    );
    repository = SecureTokenRepository(
      storage: storage,
      legacyStorage: legacyStorage,
    );
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

  group('SecureTokenRepository - Core Logic', () {
    test(
      'loadTokens returns empty list on PlatformException (Decryption Error)',
      () async {
        when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});
        when(
          mockStorage.readAll(),
        ).thenThrow(PlatformException(code: 'DECRYPT_FAILED'));

        final tokens = await repository.loadTokens();

        expect(tokens, isEmpty);
      },
    );

    test(
      'loadTokens filters out corrupted single tokens but returns valid ones',
      () async {
        final validToken = createToken('valid');
        final tokenMap = {
          '${newPrefix}_valid': jsonEncode(validToken.toJson()),
          '${newPrefix}_corrupt': 'not-json-at-all',
        };

        when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});
        when(mockStorage.readAll()).thenAnswer((_) async => tokenMap);

        final tokens = await repository.loadTokens();

        expect(tokens.length, 1);
        expect(tokens.first.id, 'valid');
      },
    );

    test('saveOrReplaceToken returns false on storage error', () async {
      final token = createToken('id1');
      when(
        mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
      ).thenThrow(Exception('Storage Full'));

      final result = await repository.saveOrReplaceToken(token);

      expect(result, isFalse);
    });

    test('loadToken handles non-existent ID gracefully', () async {
      when(
        mockStorage.read(key: '${newPrefix}_missing'),
      ).thenAnswer((_) async => null);

      final token = await repository.loadToken('missing');

      expect(token, isNull);
    });
  });

  group('SecureTokenRepository - Migration Corners', () {
    test('Migration continues even if one token write fails', () async {
      final t1 = createToken('id1');
      final t2 = createToken('id2');
      final legacyMap = {
        '${legacyPrefix}_id1': jsonEncode(t1.toJson()),
        '${legacyPrefix}_id2': jsonEncode(t2.toJson()),
      };

      when(mockLegacyStorage.readAll()).thenAnswer((_) async => legacyMap);

      when(
        mockStorage.write(key: '${newPrefix}_id1', value: anyNamed('value')),
      ).thenThrow(Exception('Individual write failure'));
      when(
        mockStorage.write(key: '${newPrefix}_id2', value: anyNamed('value')),
      ).thenAnswer((_) async {});

      when(
        mockStorage.readAll(),
      ).thenAnswer((_) async => {'${newPrefix}_id2': jsonEncode(t2.toJson())});

      final tokens = await repository.loadTokens();

      expect(tokens.length, 1);
      expect(tokens.first.id, 'id2');
      verify(mockLegacyStorage.delete(key: '${legacyPrefix}_id2')).called(1);
      verifyNever(mockLegacyStorage.delete(key: '${legacyPrefix}_id1'));
    });

    test('Migration skips entries without type field', () async {
      final invalidLegacyData = {
        '${legacyPrefix}_no_type': jsonEncode({
          'id': 'some-id',
          'label': 'no-type',
        }),
      };

      when(
        mockLegacyStorage.readAll(),
      ).thenAnswer((_) async => invalidLegacyData);
      when(mockStorage.readAll()).thenAnswer((_) async => {});

      await repository.loadTokens();

      verifyNever(
        mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
      );
    });
  });

  group('SecureTokenRepository - Bulk Operations', () {
    test('deleteTokens returns list of tokens that failed to delete', () async {
      final t1 = createToken('id1');
      final t2 = createToken('id2');

      when(
        mockStorage.delete(key: '${newPrefix}_id1'),
      ).thenAnswer((_) async {});
      when(
        mockStorage.delete(key: '${newPrefix}_id2'),
      ).thenThrow(Exception('Delete failed'));

      final failed = await repository.deleteTokens([t1, t2]);

      expect(failed.length, 1);
      expect(failed.first.id, 'id2');
    });

    test('saveOrReplaceTokens returns failed tokens', () async {
      final t1 = createToken('id1');
      when(
        mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
      ).thenThrow(Exception('Write failed'));

      final failed = await repository.saveOrReplaceTokens([t1]);

      expect(failed, isNotEmpty);
      expect(failed.first.id, 'id1');
    });
  });
}
