import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/helpers/log_redaction_helper.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../../../log_file.dart';

void main() {
  // Declared first so that it runs first: Logger keeps one instance per isolate
  // and only the first set up of it takes effect, but the allowlist tests below
  // already make redactedShape log, which creates that instance without a file.
  _testLogRedactionFormats();

  // A stored token carries these next to its configuration. They are on the
  // blocklist, so no allowlist and no caller can put them into the log.
  const blockedValues = {
    'secret': 'JBSWY3DPEHPK3PXP',
    'privateTokenKey': 'MIIEowIBAAKCAQEAprivatekeymaterial',
    'publicTokenKey': 'MIIBIjANBgkqhkiG9wpublickeymaterial',
    'publicServerKey': 'MIIBIjANBgkqhkiG9wserverkeymaterial',
    'enrollmentCredentials': 'enrollmentcredential',
    'fbToken': 'firebase-token-value',
  };

  // These name the account rather than the token configuration. They are not on
  // the blocklist, so only an allowlist keeps them out.
  const identifyingValues = {
    'label': 'alice@example.com',
    'issuer': 'privacyIDEA',
    'serial': 'PIPU0001ABCD',
    'containerSerial': 'CONT0001',
    'tokenImage': 'https://example.com/logo.png',
  };

  Map<String, dynamic> storedToken() => {
    'type': 'pipush',
    'id': 'ffb2c8e0-0000-4000-8000-000000000000',
    'tokenVersion': 'v1.0.0',
    'algorithm': 'SHA1',
    'digits': 6,
    'counter': 42,
    'isRolledOut': true,
    'sortIndex': 3,
    'folderId': null,
    ...blockedValues,
    ...identifyingValues,
    'origin': {'appName': 'privacyIDEA Authenticator', 'source': 'qrScan'},
  };

  group('redactedShape without an allowlist', () {
    test('keeps no blocked value anywhere in the result', () {
      final result = redactedShape(storedToken());

      for (final entry in blockedValues.entries) {
        expect(
          result,
          isNot(contains(entry.value)),
          reason: '${entry.key} must not be logged',
        );
      }
    });

    test('keeps every value that is not blocked', () {
      final result = redactedShape(storedToken());

      expect(result, contains('type: "pipush"'));
      expect(result, contains('digits: 6'));
      // Not on the blocklist, so the permissive default lets these through.
      for (final entry in identifyingValues.entries) {
        expect(result, contains(entry.value));
      }
    });

    test('keeps the names so a missing one is visible', () {
      final result = redactedShape(storedToken());

      for (final name in storedToken().keys) {
        expect(result, contains(name));
      }
    });

    test('tells null apart from a redacted value', () {
      final result = redactedShape({'folderId': null, 'secret': 'abc'});

      expect(result, contains('folderId: <null>'));
      expect(result, contains('secret: <String>'));
    });

    test('reports a list by its length only', () {
      final result = redactedShape({
        'checkedContainer': ['CONT0001', 'CONT0002'],
      });

      expect(result, contains('checkedContainer: <List(2)>'));
      expect(result, isNot(contains('CONT0001')));
    });

    test('describes a value that is not a json object', () {
      expect(redactedShape('a bare string'), '<String>');
      expect(redactedShape(null), '<null>');
      expect(redactedShape([1, 2, 3]), '<List(3)>');
    });
  });

  group('redactedShape with an allowlist', () {
    test('keeps only the values the allowlist names', () {
      final result = redactedShape(
        storedToken(),
        allowedEntryNames: Token.loggableEntryNames,
      );

      expect(result, contains('type: "pipush"'));
      expect(result, contains('digits: 6'));
      expect(result, contains('counter: 42'));
      for (final entry in {...blockedValues, ...identifyingValues}.entries) {
        expect(
          result,
          isNot(contains(entry.value)),
          reason: '${entry.key} is not allowlisted',
        );
      }
    });

    test('reduces a value it does not name to its type', () {
      final result = redactedShape(
        storedToken(),
        allowedEntryNames: Token.loggableEntryNames,
      );

      expect(result, contains('serial: <String>'));
      expect(result, contains('label: <String>'));
    });

    test('redacts a blocked name even when the allowlist permits it', () {
      // The allowlist is the newer and more local list, so the blocklist wins
      // and a warning is logged.
      final result = redactedShape({
        'secret': 'JBSWY3DPEHPK3PXP',
      }, allowedEntryNames: {'secret'});

      expect(result, contains('secret: <String>'));
      expect(result, isNot(contains('JBSWY3DPEHPK3PXP')));
    });

    test('redacts a name that only contains a blocked one', () {
      final result = redactedShape({
        'hasSecret': true,
      }, allowedEntryNames: {'hasSecret'});

      expect(result, contains('hasSecret: <bool>'));
    });

    test('applies to nested entries as well', () {
      final result = redactedShape({
        'origin': {'appName': 'privacyIDEA Authenticator'},
      }, allowedEntryNames: Token.loggableEntryNames);

      expect(result, contains('appName: <String>'));
      expect(result, isNot(contains('privacyIDEA Authenticator')));
    });

    test('an allowlisted name does not leak a nested object', () {
      // 'type' is allowlisted, but a map behind it is still walked entry by
      // entry rather than printed as it is.
      final result = redactedShape({
        'type': {'secret': 'must-not-leak'},
      }, allowedEntryNames: Token.loggableEntryNames);

      expect(result, isNot(contains('must-not-leak')));
    });
  });

  group('filterSensitiveValues', () {
    test('scrubs the value behind a sensitive name', () {
      final result = filterSensitiveValues('secret: JBSWY3DPEHPK3PXP');

      expect(result, isNot(contains('JBSWY3DPEHPK3PXP')));
      expect(result, contains('******'));
    });

    test('scrubs base64 containing a slash', () {
      // The value alphabet used to omit '/', so everything from the first
      // slash on stayed readable.
      const key = 'MIIEow/IBAAKCAQEA/privatekeymaterial';
      final result = filterSensitiveValues('privateTokenKey: $key');

      expect(result, isNot(contains('privatekeymaterial')));
      expect(result, isNot(contains('IBAAKCAQEA')));
    });

    test('covers the key material the old list missed', () {
      const cases = {
        'privateTokenKey': 'MIIEowIBAAKCAQEAaaa',
        'publicTokenKey': 'MIIBIjANBgkqhkiGbbb',
        'publicServerKey': 'MIIBIjANBgkqhkiGccc',
        'privateClientKey': 'MHcCAQEEIddd',
        'publicClientKey': 'MFkwEwYHKoZIeee',
        'enrollment_credential': 'abcdef123456',
        'passphrase': 'hunter2',
      };

      for (final entry in cases.entries) {
        final result = filterSensitiveValues('${entry.key}: ${entry.value}');
        expect(
          result,
          isNot(contains(entry.value)),
          reason: '${entry.key} must be scrubbed',
        );
      }
    });

    test('matches case insensitively and as a substring', () {
      expect(
        filterSensitiveValues('SEND_PASSPHRASE: hunter2'),
        isNot(contains('hunter2')),
      );
      expect(
        filterSensitiveValues('privatetokenkey=MIIEowIBAAK'),
        isNot(contains('MIIEowIBAAK')),
      );
    });

    test('scrubs inside a json shaped line', () {
      final result = filterSensitiveValues('{"secret":"JBSWY3DP","digits":6}');

      expect(result, isNot(contains('JBSWY3DP')));
      expect(result, contains('digits'));
    });

    test('scrubs an object behind a sensitive name as a whole', () {
      // The value used to be looked for behind the name only, so an object
      // there cost its first key and kept everything below it.
      final result = filterSensitiveValues(
        '{"secret":{"value":"JBSWY3DP"},"serial":"PIPU0001"}',
      );

      expect(result, isNot(contains('JBSWY3DP')));
      expect(result, contains('"serial":"PIPU0001"'));
    });

    test('scrubs a nested object with everything below it', () {
      final result = filterSensitiveValues(
        '{"secret":{"outer":{"inner":"JBSWY3DP"}},"serial":"PIPU0001"}',
      );

      expect(result, isNot(contains('JBSWY3DP')));
      expect(result, isNot(contains('inner')));
      expect(result, contains('"serial":"PIPU0001"'));
    });

    test('scrubs a list behind a sensitive name as a whole', () {
      final result = filterSensitiveValues(
        '{"secret":["JBSWY3DP","QRSTUV12"],"digits":6}',
      );

      expect(result, isNot(contains('JBSWY3DP')));
      expect(result, isNot(contains('QRSTUV12')));
      expect(result, contains('"digits":6'));
    });

    test('scrubs a quoted value that contains a space', () {
      final result = filterSensitiveValues(
        '{"passphrase":"correct horse battery","serial":"PIPU0001"}',
      );

      expect(result, isNot(contains('horse')));
      expect(result, contains('"serial":"PIPU0001"'));
    });

    test('scrubs a quoted value that contains an escape', () {
      // A backslash used to end the value, so a json escaped character split
      // the value into a scrubbed and a readable half.
      final result = filterSensitiveValues(r'{"secret":"abc\/def\"ghi"}');

      expect(result, isNot(contains('def')));
      expect(result, isNot(contains('ghi')));
    });

    test('scrubs a value that was cut off with the rest of the line', () {
      final result = filterSensitiveValues('{"secret":{"value":"JBSWY3DP');

      expect(result, isNot(contains('JBSWY3DP')));
    });

    test('ends a value at the entry that follows it', () {
      expect(
        filterSensitiveValues('{secret: JBSWY3DP, serial: PIPU0001}'),
        '{secret: ******, serial: PIPU0001}',
      );
      expect(
        filterSensitiveValues('{"secret":null,"digits":6}'),
        '{"secret":******,"digits":6}',
      );
    });

    test('keeps the quotes of a quoted value', () {
      expect(
        filterSensitiveValues('{"secret":"JBSWY3DP","digits":6}'),
        '{"secret":"******","digits":6}',
      );
    });

    test('leaves a line without a sensitive name alone', () {
      const line = 'Loaded 3/4 tokens from secure storage';
      expect(filterSensitiveValues(line), line);
    });

    test('keeps the name so the line stays readable', () {
      expect(filterSensitiveValues('secret: abc'), contains('secret'));
    });
  });

  group('the allowlists the app passes', () {
    const allowlists = {
      'Token': Token.loggableEntryNames,
      'TokenContainer': TokenContainer.loggableEntryNames,
      'PushRequestState': PushRequestState.loggableEntryNames,
    };

    test('name nothing that the blocklist blocks', () {
      // A blocked name stays redacted and costs a warning, so it is never worth
      // listing. 'sendPassphrase' is the one that is easy to reach for.
      for (final list in allowlists.entries) {
        for (final name in list.value) {
          final result = redactedShape({name: 1}, allowedEntryNames: {name});
          expect(
            result,
            '{$name: 1}',
            reason: '$name of ${list.key} is blocked and stays redacted',
          );
        }
      }
    });

    test('survive the log line filter', () {
      // A name the filter matches is mangled on its way into the log, which
      // makes it useless as an allowlist entry even where it is harmless.
      for (final list in allowlists.entries) {
        for (final name in list.value) {
          expect(
            filterSensitiveValues('$name: 1'),
            '$name: 1',
            reason: '$name of ${list.key} collides with the blocklist',
          );
        }
      }
    });
  });
}

/// The formats a secret reaches the log in, other than the quoted json and the
/// `name: value` entries that the groups above cover.
///
/// A test that is skipped with a BUG reason states the behaviour the filter
/// should have. It fails today, because the filter looks for a sensitive name
/// and takes what follows it up to the next separator as the value.
void _testLogRedactionFormats() {
  group('log redaction formats', () {
    const secret = 'JBSWY3DPEHPK3PXP';

    late LogFile logFile;
    late File file;

    /// Empties the log file and returns once that happened.
    ///
    /// The clear of the harness returns before it took the lock, so a warning
    /// that is logged right after it can be wiped by it on a busy machine. A
    /// marker that the clear has to remove tells when it is through.
    Future<void> resetLog() async {
      await file.writeAsString('marker', flush: true);
      Logger.clearErrorLog();
      while (await file.length() != 0) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      await Logger.getErrorLog();
    }

    setUpAll(() async {
      logFile = await LogFile.setUp();
      final directory = await getApplicationSupportDirectory();
      file = File('${directory.path}/logfile.txt');
      // The clear of the set up is still on its way to the file.
      while (!file.existsSync()) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      await Logger.getErrorLog();
    });

    tearDownAll(() => logFile.tearDown());

    group('the query of an otpauth uri', () {
      test('loses the secret when it is the first parameter', () {
        final result = filterSensitiveValues(
          'otpauth://totp/Example:alice?secret=$secret&issuer=Example&digits=6',
        );

        expect(result, isNot(contains(secret)));
        expect(result, contains('otpauth://totp/Example:alice?secret='));
      });

      test('loses the secret when it is the last parameter', () {
        final result = filterSensitiveValues(
          'otpauth://totp/Example:alice?issuer=Example&secret=$secret',
        );

        expect(result, isNot(contains(secret)));
        expect(result, contains('issuer=Example'));
      });

      test('loses the secret when it is in the middle', () {
        final result = filterSensitiveValues(
          'otpauth://totp/x?algorithm=SHA1&secret=$secret&period=30',
        );

        expect(result, isNot(contains(secret)));
        expect(result, contains('algorithm=SHA1'));
      });

      test('keeps the parameters in front of the secret', () {
        expect(
          filterSensitiveValues('otpauth://totp/x?issuer=I&secret=ABC'),
          'otpauth://totp/x?issuer=I&secret=******',
        );
      });

      test('loses a secret that is a parameter of another url', () {
        // The deeplink of a login page can carry the whole token uri along.
        const encoded =
            'https://example.com/redirect?target=otpauth%3A%2F%2Ftotp%2Fx'
            '%3Fsecret%3D$secret%26issuer%3DI';

        expect(filterSensitiveValues(encoded), isNot(contains(secret)));
      });

      test('loses the secret of a Uri that is interpolated into a message', () {
        final uri = Uri.parse('otpauth://totp/x?secret=$secret&issuer=I');

        final result = filterSensitiveValues('Got token uri: $uri');

        expect(result, isNot(contains(secret)));
        expect(result, startsWith('Got token uri: otpauth://totp/x'));
      });

      // The value of a bare entry ends at a space, a comma, a semicolon or a
      // bracket but not at '&'. Everything behind the secret of a query is
      // therefore taken as part of it, which is safe but costs the log the
      // issuer, the digits and the period of the token.
      test('the secret is gone although the parameters behind it are not safe '
          'to keep', () {
        final result = filterSensitiveValues(
          'otpauth://totp/x?secret=ABC&issuer=I&digits=6',
        );

        expect(result, isNot(contains('ABC')));
        expect(result, contains('secret=******'));
      });

      test(
        'keeps the parameters behind the secret',
        () {
          final result = filterSensitiveValues(
            'otpauth://totp/x?secret=$secret&issuer=Example&digits=6',
          );

          expect(result, isNot(contains(secret)));
          expect(result, contains('issuer=Example'));
          expect(result, contains('digits=6'));
        },
        skip:
            "BUG: '&' does not end a bare value in log_redaction_helper.dart "
            '(_bareValueEnders), so issuer and digits behind the secret are '
            'swallowed (usability only, the secret is removed)',
      );
    });

    group('a value that is not quoted and contains a space', () {
      // Map.toString does not quote its strings, so this is how a map that holds
      // a passphrase or a secret with a space in it reaches the log.
      test('is what Map.toString writes', () {
        expect({'secret': 'AB CD'}.toString(), '{secret: AB CD}');
      });

      test(
        'is scrubbed as a whole in a map',
        () {
          final result = filterSensitiveValues({'secret': 'AB CD'}.toString());

          expect(result, isNot(contains('AB')));
          expect(result, isNot(contains('CD')));
        },
        skip:
            'BUG: log_redaction_helper.dart _valueRange ends a bare value at the '
            "first space, so '{secret: AB CD}' becomes '{secret: ****** CD}' "
            'and the rest of the secret stays in the log',
      );

      test(
        'is scrubbed as a whole in a map with other entries',
        () {
          final result = filterSensitiveValues(
            {
              'serial': 'PIPU0001',
              'passphrase': 'correct horse battery staple',
              'digits': 6,
            }.toString(),
          );

          for (final word in ['correct', 'horse', 'battery', 'staple']) {
            expect(result, isNot(contains(word)), reason: '$word leaked');
          }
          expect(result, contains('PIPU0001'));
        },
        skip:
            'BUG: log_redaction_helper.dart _valueRange ends a bare value at the '
            'first space, so only the first word of a passphrase is scrubbed',
      );

      test(
        'is scrubbed as a whole in a plain line',
        () {
          final result = filterSensitiveValues('passphrase: my pass phrase');

          expect(result, isNot(contains('my')));
          expect(result, isNot(contains('pass phrase')));
        },
        skip:
            'BUG: log_redaction_helper.dart _valueRange ends a bare value at the '
            "first space, so 'passphrase: my pass phrase' keeps 'pass phrase'",
      );

      test('a word before the first space is scrubbed at least', () {
        final result = filterSensitiveValues('{secret: ABCD EFGH}');

        expect(result, startsWith('{secret: ******'));
        expect(result, isNot(contains('ABCD')));
      });
    });

    group('the uri of a Google Authenticator export', () {
      // What the QR code of "Export accounts" holds: every secret of the account
      // in one base64 encoded protobuf, behind a query that has no sensitive name.
      const payload =
          'CjEKCkhlbGxvId6tvu8SFEV4YW1wbGU6YWxpY2VAZ21haWwuY29tGgdFeGFtcGxlIAEoATACEAEYASAA';
      const uri = 'otpauth-migration://offline?data=$payload';

      // Both ends are checked so that a half scrubbed payload is noticed.
      void expectPayloadGone(String result) {
        expect(result, isNot(contains(payload)));
        expect(result, isNot(contains(payload.substring(0, 12))));
        expect(result, isNot(contains(payload.substring(payload.length - 12))));
      }

      test(
        'is scrubbed',
        () => expectPayloadGone(filterSensitiveValues(uri)),
        skip:
            'BUG: log_redaction_helper.dart has no rule for the data parameter of '
            'otpauth-migration://, so every secret of an export reaches the log',
      );

      test(
        'is scrubbed in the line the deeplink notifier writes for a new uri',
        () => expectPayloadGone(
          filterSensitiveValues(
            'DeeplinkNotifier got new incoming uri: ${Uri.parse(uri)}',
          ),
        ),
        skip:
            'BUG: log_redaction_helper.dart has no rule for the data parameter of '
            'otpauth-migration://, deeplink_notifier.dart logs the whole uri',
      );

      test(
        'is scrubbed in the line the deeplink notifier writes for the initial uri',
        () => expectPayloadGone(
          filterSensitiveValues('Got initial uri from intent: ${Uri.parse(uri)}'),
        ),
        skip:
            'BUG: log_redaction_helper.dart has no rule for the data parameter of '
            'otpauth-migration://, deeplink_notifier.dart logs the whole uri',
      );

      test(
        'is scrubbed when the base64 characters are percent encoded',
        () {
          final encoded = Uri(
            scheme: 'otpauth-migration',
            host: 'offline',
            queryParameters: {'data': '$payload+/=='},
          ).toString();
          expect(encoded, contains('%2B'), reason: 'the uri is percent encoded');

          expectPayloadGone(filterSensitiveValues('incoming uri: $encoded'));
        },
        skip:
            'BUG: log_redaction_helper.dart has no rule for the data parameter of '
            'otpauth-migration://, so every secret of an export reaches the log',
      );

      test('the scheme of the uri is not mistaken for a secret', () {
        // Guards the tests above against passing for the wrong reason: a filter
        // that dropped the whole line would remove the payload as well.
        expect(
          filterSensitiveValues('opened otpauth-migration://offline'),
          'opened otpauth-migration://offline',
        );
      });
    });

    group('raw key bytes', () {
      test(
        'in the shared key line of the container api are scrubbed',
        () {
          // privacy_idea_container_api.dart logs the bytes of the key it derived,
          // as the list that Uint8List.toString makes of them.
          final bytes = Uint8List.fromList([12, 200, 33, 4, 255, 17, 99, 7]);

          final result = filterSensitiveValues('Shared key: $bytes');

          expect(result, isNot(contains('200, 33')));
          expect(result, isNot(contains('255, 17')));
        },
        skip:
            'BUG: log_redaction_helper.dart knows no name for the shared key, so '
            "privacy_idea_container_api.dart:509 'Shared key: [...]' puts the key "
            'bytes into the log file when verbose logging is on (debug builds)',
      );
    });

    group('json that is escaped inside a json string', () {
      test(
        'is scrubbed',
        () {
          // An error that quotes the body of a request holds the token as a
          // string of json, so the quotes around its names are escaped.
          final line = jsonEncode({
            'body': jsonEncode({'secret': secret, 'digits': 6}),
          });
          expect(line, contains(r'\"secret\"'), reason: 'the quotes are escaped');

          expect(filterSensitiveValues(line), isNot(contains(secret)));
        },
        skip:
            'BUG: log_redaction_helper.dart _valueRange does not see through the '
            r'backslash of \"secret\":\"..\", the name is followed by a backslash '
            'that is taken as the whole value and the real value stays readable',
      );
    });

    group('a name that holds only part of a sensitive one', () {
      test('has its value scrubbed and keeps its whole name', () {
        expect(
          filterSensitiveValues('hasSecretFlag: true'),
          'hasSecretFlag: ******',
        );
      });

      test('is not taken for the value when the name ends in a flag', () {
        // 'Flag' is the rest of the name behind 'Secret', not the value.
        expect(
          filterSensitiveValues('{"hasSecretFlag":true,"digits":6}'),
          '{"hasSecretFlag":******,"digits":6}',
        );
        expect(
          filterSensitiveValues('{hasSecretFlag: true, digits: 6}'),
          '{hasSecretFlag: ******, digits: 6}',
        );
      });
    });

    group('a line with several sensitive names', () {
      test('has the value of every one of them scrubbed', () {
        expect(
          filterSensitiveValues(
            'secret: AAA, serial: S1, secret: BBB, privateTokenKey: CCC',
          ),
          'secret: ******, serial: S1, secret: ******, privateTokenKey: ******',
        );
      });

      test('mixes names and part names', () {
        expect(
          filterSensitiveValues(
            'hasSecretFlag: true, secret: $secret, hasSecretFlag: false',
          ),
          'hasSecretFlag: ******, secret: ******, hasSecretFlag: ******',
        );
      });

      test('scrubs a name inside a scrubbed value only once', () {
        // The inner name is part of the value that was already replaced, so it
        // costs no second replacement and nothing of it is left behind.
        expect(
          filterSensitiveValues('{"secret":{"secret":"X"},"digits":6}'),
          '{"secret":******,"digits":6}',
        );
      });

      test('keeps what is between the names', () {
        final result = filterSensitiveValues(
          'before secret: AAA middle passphrase=hunter2; after',
        );

        expect(result, contains('before'));
        expect(result, contains('middle'));
        expect(result, contains('after'));
        expect(result, isNot(contains('AAA')));
        expect(result, isNot(contains('hunter2')));
      });

      test('leaves a sensitive name at the end of a line alone', () {
        // Nothing follows it, so there is no value to scrub.
        expect(filterSensitiveValues('there is no secret'), 'there is no secret');
      });
    });

    group('the conflict warning of redactedShape', () {
      const warning =
          'An allowed entry name is blocked as well and stays '
          'redacted: ';

      setUp(() async => await resetLog());

      test('keeps the value redacted', () {
        final result = redactedShape(
          {'conflictRedactedSecretKey': secret},
          allowedEntryNames: {'conflictRedactedSecretKey'},
        );

        expect(result, '{conflictRedactedSecretKey: <String>}');
      });

      test('is logged once however often the name shows up', () async {
        const name = 'conflictOnceSecretKey';

        for (var i = 0; i < 3; i++) {
          redactedShape({name: 'value$i'}, allowedEntryNames: {name});
        }
        // A storage full of tokens hands over the same name token after token,
        // here nested and next to another allowlist.
        redactedShape(
          {
            'a': {name: 1},
            'b': {name: 2},
          },
          allowedEntryNames: {'a', 'b', name},
        );

        final warnings = await logFile.entriesContaining('$warning$name');
        expect(warnings, hasLength(1));
        expect(warnings.single, startsWith('[WARNING]'));
      });

      test('is logged without verbose logging being on', () async {
        redactedShape(
          {'conflictVerboseSecretKey': 1},
          allowedEntryNames: {'conflictVerboseSecretKey'},
        );

        expect(
          await logFile.entriesContaining('${warning}conflictVerboseSecretKey'),
          hasLength(1),
        );
      });

      test('is logged once for every name on its own', () async {
        const names = ['conflictFirstSecretKey', 'conflictSecondSecretKey'];

        for (var i = 0; i < 2; i++) {
          for (final name in names) {
            redactedShape({name: 1}, allowedEntryNames: {name});
          }
        }

        final warnings = await logFile.entriesContaining(warning);
        expect(warnings, hasLength(2));
        for (final name in names) {
          expect(
            warnings.where((entry) => entry.contains(name)),
            hasLength(1),
            reason: '$name is reported once',
          );
        }
      });

      test('does not repeat in a later test of the same run', () async {
        // The names already warned about are kept for as long as the app runs.
        const name = 'conflictLaterSecretKey';
        redactedShape({name: 1}, allowedEntryNames: {name});
        expect(await logFile.entriesContaining('$warning$name'), hasLength(1));

        await resetLog();
        redactedShape({name: 1}, allowedEntryNames: {name});

        expect(await logFile.entriesContaining('$warning$name'), isEmpty);
      });

      test('is not logged when there is no conflict', () async {
        // Not allowed, so the blocklist is not what keeps it out.
        redactedShape({'noConflictSecretKey': 1}, allowedEntryNames: {'other'});
        // No allowlist, the blocklist is all there is.
        redactedShape({'noConflictSecretKey': 1});
        // Allowed and harmless.
        redactedShape(
          {'noConflictSerial': 1},
          allowedEntryNames: {'noConflictSerial'},
        );

        expect(await logFile.read(), isEmpty);
      });
    });
  });
}
