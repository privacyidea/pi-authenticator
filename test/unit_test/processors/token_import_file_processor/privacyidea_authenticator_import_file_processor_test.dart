import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/token_import_file_processor/privacyidea_authenticator_import_file_processor.dart';
import 'package:privacyidea_authenticator/processors/token_import_file_processor/two_fas_import_file_processor.dart';
import 'package:privacyidea_authenticator/utils/encryption/aes_encrypted.dart';
import 'package:privacyidea_authenticator/utils/encryption/token_encryption.dart';

void main() {
  _testPrivacyideaAuthenticatorImportFileProcessor();
}

const _password = 'correct horse battery staple';

XFile _xFile(String content, {String name = 'backup.pia'}) =>
    XFile.fromData(Uint8List.fromList(utf8.encode(content)), name: name);

/// Encrypts [plain] exactly like the app does for its backup, but with an
/// arbitrary payload instead of a token list.
Future<String> _encryptRawPayload(String plain) async => jsonEncode(
  (await AesEncrypted.encrypt(data: plain, password: _password)).toJson(),
);

/// Runs [processFile] and returns whatever came out: either the thrown object
/// or the returned result list.
Future<Object?> _outcomeOf(Future<List<ProcessorResult<Token>>> Function() run) async {
  try {
    return await run();
  } catch (e) {
    return e;
  }
}

void _expectFailureThatIsNotAPasswordProblem(Object? outcome) {
  expect(
    outcome,
    isNot(isA<BadDecryptionPasswordException>()),
    reason: 'A corrupt file must not be reported as "wrong password"',
  );
  if (outcome is List<ProcessorResult<Token>>) {
    expect(outcome, isNotEmpty);
    expect(outcome.every((r) => r.isFailed), isTrue, reason: 'No token may be imported from a corrupt file');
  } else {
    expect(outcome, isA<InvalidFileContentException>());
  }
}

List<Token> _allTokenTypes() => [
  HOTPToken(
    id: 'hotp-id',
    label: 'hotp label',
    issuer: 'hotp issuer',
    algorithm: Algorithms.SHA256,
    digits: 8,
    secret: 'JBSWY3DPEHPK3PXP',
    counter: 42,
    sortIndex: 3,
    folderId: 7,
  ),
  TOTPToken(
    id: 'totp-id',
    label: 'totp label',
    issuer: 'totp issuer',
    algorithm: Algorithms.SHA512,
    digits: 7,
    period: 60,
    secret: 'GEZDGNBVGY3TQOJQ',
    pin: true,
    tokenImage: 'https://example.com/image.png',
  ),
  SteamToken(id: 'steam-id', label: 'steam label', issuer: 'Steam', secret: 'MFRGGZDFMZTWQ2LK'),
  DayPasswordToken(
    id: 'day-id',
    label: 'day label',
    issuer: 'day issuer',
    period: const Duration(hours: 12),
    algorithm: Algorithms.SHA1,
    digits: 6,
    secret: 'MZXW6YTBOI======',
  ),
  PushToken(
    id: 'push-id',
    serial: 'PIPU0001ABCD',
    label: 'push label',
    issuer: 'push issuer',
    url: Uri.parse('https://pi.example.com/ttype/push'),
    sslVerify: true,
    isRolledOut: true,
  ),
];

void _testPrivacyideaAuthenticatorImportFileProcessor() {
  group('Privacyidea Authenticator Import File Processor', () {
    const processor = PrivacyIDEAAuthenticatorImportFileProcessor();
    late String encryptedBackup;
    late List<Token> originalTokens;

    setUpAll(() async {
      originalTokens = _allTokenTypes();
      encryptedBackup = await TokenEncryption.encrypt(tokens: originalTokens, password: _password);
    });

    group('fileIsValid', () {
      test('is true for a backup created by the app itself', () async {
        expect(await processor.fileIsValid(_xFile(encryptedBackup)), isTrue);
      });

      for (final missingField in ['data', 'salt', 'iv', 'mac']) {
        test('is false when "$missingField" is missing', () async {
          final json = jsonDecode(encryptedBackup) as Map<String, dynamic>..remove(missingField);
          expect(await processor.fileIsValid(_xFile(jsonEncode(json))), isFalse);
        });

        test('is false when "$missingField" is null', () async {
          final json = jsonDecode(encryptedBackup) as Map<String, dynamic>..[missingField] = null;
          expect(await processor.fileIsValid(_xFile(jsonEncode(json))), isFalse);
        });
      }

      test('is false for non json content', () async {
        expect(await processor.fileIsValid(_xFile('this is not json')), isFalse);
      });

      test('is false for an empty file', () async {
        expect(await processor.fileIsValid(_xFile('')), isFalse);
      });

      test('is false for a json list', () async {
        expect(await processor.fileIsValid(_xFile('[1, 2, 3]')), isFalse);
      });

      test('is false for an empty json object', () async {
        expect(await processor.fileIsValid(_xFile('{}')), isFalse);
      });

      test(
        'is false when the kdf and cypher description is missing (file cannot be decrypted)',
        () async {
          final json = jsonDecode(encryptedBackup) as Map<String, dynamic>
            ..remove('kdf')
            ..remove('cypher');
          expect(await processor.fileIsValid(_xFile(jsonEncode(json))), isFalse);
        },
        skip: 'BUG: fileIsValid (privacyidea_authenticator_import_file_processor.dart:43) only checks data/salt/iv/mac, a file without kdf/cypher is accepted',
      );
    });

    group('fileNeedsPassword', () {
      test('is always true', () async {
        expect(await processor.fileNeedsPassword(_xFile(encryptedBackup)), isTrue);
      });
    });

    group('processFile', () {
      test('round trip with the app export restores every token type with all fields', () async {
        final results = await processor.processFile(_xFile(encryptedBackup), password: _password);

        expect(results.length, originalTokens.length);
        expect(results.every((r) => r.isSuccess), isTrue);
        final tokens = results.map((r) => r.asSuccess!.resultData).toList();

        final hotp = tokens[0] as HOTPToken;
        expect(hotp.id, 'hotp-id');
        expect(hotp.label, 'hotp label');
        expect(hotp.issuer, 'hotp issuer');
        expect(hotp.algorithm, Algorithms.SHA256);
        expect(hotp.digits, 8);
        expect(hotp.secret, 'JBSWY3DPEHPK3PXP');
        expect(hotp.counter, 42);
        expect(hotp.sortIndex, 3);

        final totp = tokens[1] as TOTPToken;
        expect(totp.id, 'totp-id');
        expect(totp.label, 'totp label');
        expect(totp.issuer, 'totp issuer');
        expect(totp.algorithm, Algorithms.SHA512);
        expect(totp.digits, 7);
        expect(totp.period, 60);
        expect(totp.secret, 'GEZDGNBVGY3TQOJQ');
        expect(totp.pin, isTrue);
        expect(totp.tokenImage, 'https://example.com/image.png');

        final steam = tokens[2] as SteamToken;
        expect(steam.id, 'steam-id');
        expect(steam.secret, 'MFRGGZDFMZTWQ2LK');
        expect(steam.digits, 5);

        final day = tokens[3] as DayPasswordToken;
        expect(day.id, 'day-id');
        expect(day.period, const Duration(hours: 12));
        expect(day.secret, 'MZXW6YTBOI======');
        expect(day.digits, 6);

        final push = tokens[4] as PushToken;
        expect(push.id, 'push-id');
        expect(push.serial, 'PIPU0001ABCD');
        expect(push.url, Uri.parse('https://pi.example.com/ttype/push'));
        expect(push.sslVerify, isTrue);
        expect(push.isRolledOut, isTrue);
      });

      test('the folder assignment of the exporting device is dropped on import', () async {
        // The first exported token lives in folder 7.
        expect(originalTokens.first.folderId, 7);

        final results = await processor.processFile(_xFile(encryptedBackup), password: _password);

        expect(results.every((r) => r.asSuccess!.resultData.folderId == null), isTrue);
      });

      test('processTokenMigrate forwards the password as args', () async {
        final results = await processor.processTokenMigrate(_xFile(encryptedBackup), args: _password);

        expect(results.length, originalTokens.length);
        expect(results.every((r) => r.isSuccess), isTrue);
      });

      test('reads a backup from a real file on disk', () async {
        final dir = Directory.systemTemp.createTempSync('pia_backup_test');
        try {
          final file = File('${dir.path}${Platform.pathSeparator}backup.pia')..writeAsStringSync(encryptedBackup);

          final results = await processor.processFile(XFile(file.path), password: _password);

          expect(results.length, originalTokens.length);
          expect(results.map((r) => r.asSuccess!.resultData.id), originalTokens.map((t) => t.id));
        } finally {
          dir.deleteSync(recursive: true);
        }
      });

      test('a wrong password throws BadDecryptionPasswordException', () async {
        await expectLater(
          processor.processFile(_xFile(encryptedBackup), password: 'wrong password'),
          throwsA(isA<BadDecryptionPasswordException>()),
        );
      });

      test('a manipulated ciphertext (authentication tag mismatch) throws BadDecryptionPasswordException', () async {
        // AES-GCM cannot tell a wrong key from manipulated data, so this has to surface as a decryption failure
        final json = jsonDecode(encryptedBackup) as Map<String, dynamic>;
        final data = base64Decode(json['data'] as String);
        data[0] = data[0] ^ 0xFF;
        json['data'] = base64Encode(data);

        await expectLater(
          processor.processFile(_xFile(jsonEncode(json)), password: _password),
          throwsA(isA<BadDecryptionPasswordException>()),
        );
      });

      test('a missing password throws BadDecryptionPasswordException', () async {
        await expectLater(
          processor.processFile(_xFile(encryptedBackup)),
          throwsA(isA<BadDecryptionPasswordException>()),
        );
      }, skip: 'BUG: processFile (privacyidea_authenticator_import_file_processor.dart:63) throws AssertionError (debug) for a null password instead of BadDecryptionPasswordException');

      group('corrupt files are not reported as "wrong password"', () {
        test('non json content', () async {
          final outcome = await _outcomeOf(() => processor.processFile(_xFile('definitely not json'), password: _password));
          _expectFailureThatIsNotAPasswordProblem(outcome);
        }, skip: 'BUG: privacyidea_authenticator_import_file_processor.dart:73 catch (e) turns every decrypt error (FormatException, TypeError) into BadDecryptionPasswordException');

        test('empty file', () async {
          final outcome = await _outcomeOf(() => processor.processFile(_xFile(''), password: _password));
          _expectFailureThatIsNotAPasswordProblem(outcome);
        }, skip: 'BUG: privacyidea_authenticator_import_file_processor.dart:73 catch (e) turns every decrypt error into BadDecryptionPasswordException');

        test('json that is not an encrypted backup', () async {
          final outcome = await _outcomeOf(() => processor.processFile(_xFile('{"foo": "bar"}'), password: _password));
          _expectFailureThatIsNotAPasswordProblem(outcome);
        }, skip: 'BUG: privacyidea_authenticator_import_file_processor.dart:73 catch (e) turns every decrypt error into BadDecryptionPasswordException');

        test('correct password but the payload is not a token list', () async {
          final file = _xFile(await _encryptRawPayload('{"not": "a list"}'));
          final outcome = await _outcomeOf(() => processor.processFile(file, password: _password));
          _expectFailureThatIsNotAPasswordProblem(outcome);
        }, skip: 'BUG: privacyidea_authenticator_import_file_processor.dart:73 correct password but undecodable payload is reported as wrong password');

        test('correct password but the payload contains an unknown token type', () async {
          final file = _xFile(await _encryptRawPayload('[{"type": "NOT_A_TOKEN_TYPE", "id": "x"}]'));
          final outcome = await _outcomeOf(() => processor.processFile(file, password: _password));
          _expectFailureThatIsNotAPasswordProblem(outcome);
        }, skip: 'BUG: privacyidea_authenticator_import_file_processor.dart:73 correct password but unknown token type is reported as wrong password');
      });

      test('an empty token list in the backup yields an empty result list', () async {
        final file = _xFile(await _encryptRawPayload('[]'));

        final results = await processor.processFile(file, password: _password);

        expect(results, isEmpty);
      });
    });
  });
}
