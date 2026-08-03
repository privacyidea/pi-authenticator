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
import 'package:privacyidea_authenticator/utils/identifiers.dart';

import '../../log_file.dart';
import '../../tests_app_wrapper.mocks.dart';

/// What the log file has to say about a token that could not be loaded.
///
/// A token that is dropped is gone from the app without the user doing
/// anything, so the log file they send in is the only thing that can tell them
/// why. Every one of these cases has to name the entry it happened to, what
/// went wrong with it and what the entry looked like, has to do so without
/// verbose logging being on, and none of them may hand out the secret while
/// doing it.
void main() {
  late MockFlutterSecureStorage mockStorage;
  late MockFlutterSecureStorage mockLegacyStorage;
  late SecureTokenRepository repository;
  late LogFile logFile;

  const secret = 'JBSWY3DPEHPK3PXP';

  setUpAll(() async => logFile = await LogFile.setUp());

  tearDownAll(() => logFile.tearDown());

  setUp(() async {
    mockStorage = MockFlutterSecureStorage();
    mockLegacyStorage = MockFlutterSecureStorage();
    repository = SecureTokenRepository(
      storage: SecureStorage(
        storagePrefix: SECURE_REPO_PREFIX_TOKEN,
        storage: mockStorage,
        excludedPrefixes: const [SECURE_REPO_PREFIX_TOKEN_CONTAINER],
      ),
      legacyStorage: SecureStorage(
        storagePrefix: GLOBAL_SECURE_REPO_PREFIX_LEGACY,
        storage: mockLegacyStorage,
      ),
    );
    when(mockLegacyStorage.readAll()).thenAnswer((_) async => {});
    await logFile.clear();
  });

  String fullKey(String id) => '${SECURE_REPO_PREFIX_TOKEN}_$id';

  Map<String, dynamic> storedToken({String id = 'id1'}) => TOTPToken(
    label: 'alice@example.com',
    issuer: 'privacyIDEA',
    secret: secret,
    id: id,
    algorithm: Algorithms.SHA1,
    digits: 6,
    period: 30,
  ).toJson();

  /// Puts [entries] into the storage, keyed the way the storage keys them.
  void givenStored(Map<String, String> entries) => when(
    mockStorage.readAll(),
  ).thenAnswer((_) async => entries.map((k, v) => MapEntry(fullKey(k), v)));

  /// The entry of the log file that reports on the token [id].
  Future<String> entryAbout(String id) async =>
      (await logFile.entriesContaining(id)).single;

  group('an entry that is not valid json', () {
    const broken = '{"type": "TOTP", "secret": "$secret", "digits":';

    test('the log names the entry it happened to', () async {
      givenStored({'id1': broken});

      await repository.loadTokens();

      expect(await entryAbout('id1'), contains('is not valid json'));
    });

    test('the log holds the reason the entry could not be parsed', () async {
      givenStored({'id1': broken});

      await repository.loadTokens();

      final entry = await entryAbout('id1');
      expect(entry, contains('FormatException'));
      // What tells a truncated entry apart from one that was never json to
      // begin with, together with how far the parser got.
      expect(entry, contains('Unexpected end of input'));
      expect(entry, contains('character ${broken.length + 1}'));
      expect(entry, contains('It holds ${broken.length} characters'));
    });

    test('the secret stays out of the log', () async {
      // The parse error quotes the text it choked on, so the entry reaches the
      // log through the error even though the repository never logs it.
      givenStored({'id1': broken});

      await repository.loadTokens();

      expect(await logFile.read(), isNot(contains(secret)));
    });
  });

  group('an entry whose token type cannot be used', () {
    test('the log says that the type is missing', () async {
      final json = storedToken()..remove('type');
      givenStored({'id1': jsonEncode(json)});

      await repository.loadTokens();

      final entry = await entryAbout('id1');
      expect(entry, contains('Could not load token id1'));
      expect(entry, contains('Token type is not defined in the json'));
    });

    test('the log names the type that is not supported', () async {
      final json = storedToken()..['type'] = 'yubikey';
      givenStored({'id1': jsonEncode(json)});

      await repository.loadTokens();

      final entry = await entryAbout('id1');
      expect(entry, contains('Token type [yubikey] is not supported'));
      expect(entry, contains('type: "yubikey"'));
    });

    test('the secret stays out of the log', () async {
      // Both errors carry the whole entry as their invalid value, so the log
      // filter is what keeps the secret out of them.
      final json = storedToken()..remove('type');
      givenStored({'id1': jsonEncode(json)});

      await repository.loadTokens();

      expect(await logFile.read(), isNot(contains(secret)));
    });
  });

  group('an entry the token is missing a value in', () {
    test('the log shows which names the entry still holds', () async {
      // The cast that fails does not say what it was reading, so what is left
      // to go on is the shape of the entry: 'secret' is not in it.
      final json = storedToken()..remove('secret');
      givenStored({'id1': jsonEncode(json)});

      await repository.loadTokens();

      final entry = await entryAbout('id1');
      expect(entry, contains('type: "TOTP"'));
      expect(entry, contains('digits: 6'));
      expect(entry, contains('period: 30'));
      expect(entry, isNot(contains('secret')));
    });

    test('the log holds the reason the value could not be read', () async {
      final json = storedToken()..remove('digits');
      givenStored({'id1': jsonEncode(json)});

      await repository.loadTokens();

      final entry = await entryAbout('id1');
      expect(entry, contains("type 'Null' is not a subtype of type"));
      expect(entry, isNot(contains('digits')));
    });

    test('the log names the value that could not be read back', () async {
      final json = storedToken()..['algorithm'] = 'SHA9';
      givenStored({'id1': jsonEncode(json)});

      await repository.loadTokens();

      final entry = await entryAbout('id1');
      expect(entry, contains('SHA9'));
      expect(entry, contains('SHA1, SHA256, SHA512'));
      expect(entry, contains('algorithm: "SHA9"'));
    });
  });

  group('a load that drops tokens', () {
    test('the log says how many tokens were dropped', () async {
      givenStored({
        'good': jsonEncode(storedToken(id: 'good')),
        'broken': 'not-json-at-all',
        'unsupported': jsonEncode(
          storedToken(id: 'unsupported')..['type'] = 'yubikey',
        ),
      });

      final tokens = await repository.loadTokens();

      expect(tokens, hasLength(1));
      expect(
        await logFile.read(),
        contains('Loaded 1/3 tokens from secure storage'),
      );
    });

    test('every dropped token is reported on its own', () async {
      givenStored({
        'broken': 'not-json-at-all',
        'unsupported': jsonEncode(
          storedToken(id: 'unsupported')..['type'] = 'yubikey',
        ),
      });

      await repository.loadTokens();

      expect(await logFile.entriesContaining('broken'), hasLength(1));
      expect(await logFile.entriesContaining('unsupported'), hasLength(1));
    });

    test('a load without a failure is not written to the log', () async {
      // Verbose logging is off, so the count of a healthy load is the console's
      // business and the file stays with what went wrong.
      givenStored({'good': jsonEncode(storedToken(id: 'good'))});

      final tokens = await repository.loadTokens();

      expect(tokens, hasLength(1));
      expect(await logFile.read(), isEmpty);
    });
  });

  group('a storage that cannot be read at all', () {
    test('the log holds the error the platform reported', () async {
      when(mockStorage.readAll()).thenThrow(
        PlatformException(
          code: 'BAD_DECRYPT',
          message: 'Could not decrypt the value',
        ),
      );

      final tokens = await repository.loadTokens();

      expect(tokens, isEmpty);
      final log = await logFile.read();
      expect(log, contains('could not be decrypted'));
      expect(log, contains('BAD_DECRYPT'));
      expect(log, contains('Could not decrypt the value'));
    });
  });

  group('a single token that is loaded by id', () {
    test('the log names the token that is not in the storage', () async {
      when(mockStorage.read(key: fullKey('id1'))).thenAnswer((_) async => null);

      final token = await repository.loadToken('id1');

      expect(token, isNull);
      expect(await entryAbout('id1'), contains('not found in secure storage'));
    });

    test('the log holds the reason the token could not be read', () async {
      final json = storedToken()..['type'] = 'yubikey';
      when(
        mockStorage.read(key: fullKey('id1')),
      ).thenAnswer((_) async => jsonEncode(json));

      final token = await repository.loadToken('id1');

      expect(token, isNull);
      final entry = await entryAbout('id1');
      expect(entry, contains('Could not load token id1'));
      expect(entry, contains('Token type [yubikey] is not supported'));
      expect(await logFile.read(), isNot(contains(secret)));
    });

    test('an entry that is not valid json is reported as well', () async {
      when(
        mockStorage.read(key: fullKey('id1')),
      ).thenAnswer((_) async => 'not-json-at-all');

      final token = await repository.loadToken('id1');

      expect(token, isNull);
      final entry = await entryAbout('id1');
      expect(entry, contains('is not valid json'));
      expect(entry, contains('FormatException'));
    });
  });
}
