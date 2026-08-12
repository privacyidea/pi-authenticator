import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/helpers/log_redaction_helper.dart';

void main() {
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
