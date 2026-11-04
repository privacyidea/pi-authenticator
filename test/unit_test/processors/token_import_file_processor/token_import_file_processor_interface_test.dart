import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart' show Scrypt, ScryptParameters;
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/token_import_file_processor/aegis_import_file_processor.dart';
import 'package:privacyidea_authenticator/processors/token_import_file_processor/authenticator_pro_import_file_processor.dart';
import 'package:privacyidea_authenticator/processors/token_import_file_processor/free_otp_plus_import_file_processor.dart';
import 'package:privacyidea_authenticator/processors/token_import_file_processor/privacyidea_authenticator_import_file_processor.dart';
import 'package:privacyidea_authenticator/processors/token_import_file_processor/token_import_file_processor_interface.dart';
import 'package:privacyidea_authenticator/processors/token_import_file_processor/two_fas_import_file_processor.dart';
import 'package:privacyidea_authenticator/utils/token_import_origins.dart';

void main() {
  _testProcessFileByAny();
}

const _password = 'by any password';
const _secretA = 'JBSWY3DPEHPK3PXP';
const _secretB = 'GEZDGNBVGY3TQOJQ';

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

XFile _xFile(Object content, {String name = 'import.json'}) => XFile.fromData(
  Uint8List.fromList(
    utf8.encode(content is String ? content : jsonEncode(content)),
  ),
  name: name,
);

Uint8List _randomBytes(int length) {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

List<Map<String, dynamic>> _aegisEntries() => [
  {
    'type': 'totp',
    'uuid': '11111111-2222-3333-4444-555555555551',
    'name': 'aegis totp',
    'issuer': 'Aegis Issuer',
    'info': {'secret': _secretA, 'algo': 'SHA1', 'digits': 6, 'period': 30},
  },
  {
    'type': 'hotp',
    'uuid': '11111111-2222-3333-4444-555555555552',
    'name': 'aegis hotp',
    'issuer': 'Aegis Issuer',
    'info': {'secret': _secretB, 'algo': 'SHA1', 'digits': 6, 'counter': 5},
  },
];

Map<String, dynamic> _aegisPlain() => {
  'version': 1,
  'header': {'slots': null, 'params': null},
  'db': {'version': 3, 'entries': _aegisEntries(), 'groups': <Object>[]},
};

Future<Map<String, dynamic>> _aegisEncrypted({
  String password = _password,
}) async {
  final salt = _randomBytes(32);
  final kdf = Scrypt()..init(ScryptParameters(1024, 8, 1, 32, salt));
  final passwordKey = Uint8List(32);
  kdf.deriveKey(Uint8List.fromList(utf8.encode(password)), 0, passwordKey, 0);
  final masterKey = _randomBytes(32);
  final cipher = crypto.AesGcm.with256bits();
  final slotNonce = _randomBytes(12);
  final slotBox = await cipher.encrypt(
    masterKey,
    secretKey: crypto.SecretKey(passwordKey),
    nonce: slotNonce,
  );
  final dbNonce = _randomBytes(12);
  final db = jsonEncode({
    'version': 3,
    'entries': _aegisEntries(),
    'groups': <Object>[],
  });
  final dbBox = await cipher.encrypt(
    utf8.encode(db),
    secretKey: crypto.SecretKey(masterKey),
    nonce: dbNonce,
  );
  return {
    'version': 1,
    'header': {
      'slots': [
        {
          'type': 1,
          'uuid': 'ce52ebc8-5856-44d4-ac11-ff6019950ebf',
          'key': _hex(slotBox.cipherText),
          'key_params': {
            'nonce': _hex(slotNonce),
            'tag': _hex(slotBox.mac.bytes),
          },
          'n': 1024,
          'r': 8,
          'p': 1,
          'salt': _hex(salt),
        },
      ],
      'params': {'nonce': _hex(dbNonce), 'tag': _hex(dbBox.mac.bytes)},
    },
    'db': base64Encode(dbBox.cipherText),
  };
}

List<Map<String, dynamic>> _twoFasServices() => [
  {
    'name': '2FAS Issuer',
    'secret': _secretA,
    'otp': {
      'label': '2fas totp',
      'digits': 6,
      'period': 30,
      'algorithm': 'SHA1',
      'tokenType': 'TOTP',
    },
  },
  {
    'name': '2FAS Issuer',
    'secret': _secretB,
    'otp': {
      'label': '2fas hotp',
      'digits': 6,
      'algorithm': 'SHA1',
      'counter': 3,
      'tokenType': 'HOTP',
    },
  },
];

Map<String, dynamic> _twoFasPlain() => {
  'services': _twoFasServices(),
  'groups': <Object>[],
  'schemaVersion': 4,
};

Future<Map<String, dynamic>> _twoFasEncrypted({
  String password = _password,
}) async {
  final salt = _randomBytes(256);
  final iv = _randomBytes(12);
  final key = await crypto.Pbkdf2(
    macAlgorithm: crypto.Hmac.sha256(),
    iterations: 10000,
    bits: 256,
  ).deriveKeyFromPassword(password: password, nonce: salt);
  final box = await crypto.AesGcm.with256bits().encrypt(
    utf8.encode(jsonEncode(_twoFasServices())),
    secretKey: key,
    nonce: iv,
  );
  return {
    'services': <Object>[],
    'groups': <Object>[],
    'servicesEncrypted':
        '${base64Encode(box.concatenation(nonce: false))}:${base64Encode(salt)}:${base64Encode(iv)}',
    'schemaVersion': 4,
  };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void _testProcessFileByAny() {
  group('TokenImportFileProcessor.processFileByAny', () {
    group('implementations', () {
      test('the fallback order is Aegis first, then 2FAS', () {
        final types = TokenImportFileProcessor.implementations
            .map((p) => p.runtimeType)
            .toList();

        expect(types.take(2), [
          AegisImportFileProcessor,
          TwoFasAuthenticatorImportFileProcessor,
        ]);
      });

      test('contains no duplicates', () {
        final types = TokenImportFileProcessor.implementations
            .map((p) => p.runtimeType)
            .toList();

        expect(types.toSet().length, types.length);
      });

      test(
        'contains every file processor the import UI offers (TokenImportOrigins)',
        () {
          final offeredByUi = TokenImportOrigins.appList
              .expand((origin) => origin.importSources)
              .map((source) => source.processor)
              .whereType<TokenImportFileProcessor>()
              .map((p) => p.runtimeType)
              .toSet();
          final registered = TokenImportFileProcessor.implementations
              .map((p) => p.runtimeType)
              .toSet();

          expect(
            offeredByUi,
            containsAll([
              PrivacyIDEAAuthenticatorImportFileProcessor,
              AegisImportFileProcessor,
              TwoFasAuthenticatorImportFileProcessor,
              AuthenticatorProImportFileProcessor,
              FreeOtpPlusImportFileProcessor,
            ]),
          );
          expect(registered, containsAll(offeredByUi));
        },
        skip:
            'BUG: token_import_file_processor_interface.dart:50 implementations lists only Aegis and 2FAS, Authenticator Pro, FreeOTP+ and the privacyIDEA backup are missing (the list and processFileByAny have no caller in lib, so no user impact today)',
      );
    });

    group('detects the format', () {
      test('plain Aegis vault', () async {
        final results = await TokenImportFileProcessor.processFileByAny(
          file: _xFile(_aegisPlain()),
        );

        expect(results.length, 2);
        expect(results.every((r) => r.isSuccess), isTrue);
        expect(results[0].asSuccess!.resultData, isA<TOTPToken>());
        expect(results[0].asSuccess!.resultData.label, 'aegis totp');
        expect(results[1].asSuccess!.resultData, isA<HOTPToken>());
        expect(
          results[0].asSuccess!.resultData.origin!.appName,
          TokenImportOrigins.aegisAuthenticator.appName,
        );
      });

      test(
        'plain 2FAS export (the Aegis processor rejects it first)',
        () async {
          final results = await TokenImportFileProcessor.processFileByAny(
            file: _xFile(_twoFasPlain()),
          );

          expect(results.length, 2);
          expect(results.every((r) => r.isSuccess), isTrue);
          expect(results[0].asSuccess!.resultData.label, '2fas totp');
          expect(
            results[0].asSuccess!.resultData.origin!.appName,
            TokenImportOrigins.twoFasAuthenticator.appName,
          );
          expect((results[1].asSuccess!.resultData as HOTPToken).counter, 3);
        },
      );

      test(
        'plain 2FAS export together with a password ignores the password',
        () async {
          final results = await TokenImportFileProcessor.processFileByAny(
            file: _xFile(_twoFasPlain()),
            password: _password,
          );

          expect(results.length, 2);
          expect(results.every((r) => r.isSuccess), isTrue);
        },
      );

      test('encrypted Aegis vault with the correct password', () async {
        final results = await TokenImportFileProcessor.processFileByAny(
          file: _xFile(await _aegisEncrypted()),
          password: _password,
        );

        expect(results.length, 2);
        expect(results.every((r) => r.isSuccess), isTrue);
        expect(results[0].asSuccess!.resultData.label, 'aegis totp');
        expect(
          results[0].asSuccess!.resultData.origin!.appName,
          TokenImportOrigins.aegisAuthenticator.appName,
        );
      });

      test(
        'encrypted 2FAS export with the correct password (the Aegis processor rejects it first)',
        () async {
          final results = await TokenImportFileProcessor.processFileByAny(
            file: _xFile(await _twoFasEncrypted()),
            password: _password,
          );

          expect(results.length, 2);
          expect(results.every((r) => r.isSuccess), isTrue);
          expect(results[0].asSuccess!.resultData.label, '2fas totp');
          expect(
            results[0].asSuccess!.resultData.origin!.appName,
            TokenImportOrigins.twoFasAuthenticator.appName,
          );
        },
      );

      test(
        'failed entries of the first matching processor are returned, not swallowed',
        () async {
          final vault = _aegisPlain();
          ((vault['db'] as Map)['entries'] as List).add({
            'type': 'motp',
            'uuid': '11111111-2222-3333-4444-555555555553',
            'name': 'unsupported',
            'issuer': '',
            'info': {
              'secret': _secretA,
              'algo': 'SHA1',
              'digits': 6,
              'period': 30,
            },
          });

          final results = await TokenImportFileProcessor.processFileByAny(
            file: _xFile(vault),
          );

          expect(results.map((r) => r.isSuccess), [true, true, false]);
        },
      );
    });

    group('no processor matches', () {
      test('non json content returns an empty list', () async {
        final results = await TokenImportFileProcessor.processFileByAny(
          file: _xFile('plain text, no json'),
        );

        expect(results, isEmpty);
      });

      test('an empty file returns an empty list', () async {
        final results = await TokenImportFileProcessor.processFileByAny(
          file: _xFile(''),
        );

        expect(results, isEmpty);
      });

      test('json of an unknown format returns an empty list', () async {
        final results = await TokenImportFileProcessor.processFileByAny(
          file: _xFile({'hello': 'world'}),
          password: _password,
        );

        expect(results, isEmpty);
      });

      test('a json list returns an empty list', () async {
        final results = await TokenImportFileProcessor.processFileByAny(
          file: _xFile('[1, 2, 3]'),
        );

        expect(results, isEmpty);
      });
    });

    group('wrong password is distinguishable from an invalid file', () {
      test(
        'encrypted Aegis vault with a wrong password throws BadDecryptionPasswordException',
        () async {
          final file = _xFile(await _aegisEncrypted());

          await expectLater(
            TokenImportFileProcessor.processFileByAny(
              file: file,
              password: 'wrong password',
            ),
            throwsA(isA<BadDecryptionPasswordException>()),
          );
        },
        skip:
            'BUG: token_import_file_processor_interface.dart:64 catch (e) swallows BadDecryptionPasswordException and the method returns [], the same result as for an invalid file',
      );

      test(
        'encrypted 2FAS export with a wrong password throws BadDecryptionPasswordException',
        () async {
          final file = _xFile(await _twoFasEncrypted());

          await expectLater(
            TokenImportFileProcessor.processFileByAny(
              file: file,
              password: 'wrong password',
            ),
            throwsA(isA<BadDecryptionPasswordException>()),
          );
        },
        skip:
            'BUG: token_import_file_processor_interface.dart:64 catch (e) swallows BadDecryptionPasswordException and the method returns [], the same result as for an invalid file',
      );

      test(
        'encrypted 2FAS export without a password throws BadDecryptionPasswordException',
        () async {
          final file = _xFile(await _twoFasEncrypted());

          await expectLater(
            TokenImportFileProcessor.processFileByAny(file: file),
            throwsA(isA<BadDecryptionPasswordException>()),
          );
        },
        skip:
            'BUG: token_import_file_processor_interface.dart:64 catch (e) swallows BadDecryptionPasswordException and the method returns [], the same result as for an invalid file',
      );

      test(
        'a wrong password and an invalid file currently give the same result (documents the ambiguity)',
        () async {
          final wrongPassword = await TokenImportFileProcessor.processFileByAny(
            file: _xFile(await _twoFasEncrypted()),
            password: 'wrong password',
          );
          final invalidFile = await TokenImportFileProcessor.processFileByAny(
            file: _xFile('garbage'),
            password: 'wrong password',
          );

          expect(wrongPassword, isEmpty);
          expect(invalidFile, isEmpty);
          expect(wrongPassword, equals(invalidFile));
        },
      );
    });

    test(
      'is consistent with the processor the UI would pick for the same file',
      () async {
        for (final file in [_xFile(_aegisPlain()), _xFile(_twoFasPlain())]) {
          final viaAny = await TokenImportFileProcessor.processFileByAny(
            file: file,
          );
          final direct = [
            for (final processor in TokenImportFileProcessor.implementations)
              if (await processor.fileIsValid(file)) processor,
          ];

          expect(
            direct,
            hasLength(1),
            reason: 'exactly one registered processor may claim a file',
          );
          final viaDirect = await direct.single.processFile(file);
          expect(
            viaAny.map((r) => r.asSuccess!.resultData.label),
            viaDirect.map((r) => r.asSuccess!.resultData.label),
          );
        }
      },
    );
  });
}
