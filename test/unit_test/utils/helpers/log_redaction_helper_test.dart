import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/helpers/log_redaction_helper.dart';

void main() {
  // A stored token carries these next to its configuration. None of them may
  // end up in the log, because the log file is attached to error reports.
  const secretValues = {
    'secret': 'JBSWY3DPEHPK3PXP',
    'privateTokenKey': 'MIIEowIBAAKCAQEAprivatekeymaterial',
    'publicTokenKey': 'MIIBIjANBgkqhkiG9wpublickeymaterial',
    'publicServerKey': 'MIIBIjANBgkqhkiG9wserverkeymaterial',
    'enrollmentCredentials': 'enrollmentcredential',
    'fbToken': 'firebase-token-value',
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
    ...secretValues,
    'origin': {'appName': 'privacyIDEA Authenticator', 'source': 'qrScan'},
  };

  group('redactedShape', () {
    test('keeps no secret value anywhere in the result', () {
      final result = redactedShape(storedToken());

      for (final entry in secretValues.entries) {
        expect(
          result,
          isNot(contains(entry.value)),
          reason: '${entry.key} must not be logged',
        );
      }
    });

    test('keeps the names so a missing one is visible', () {
      final result = redactedShape(storedToken());

      for (final name in storedToken().keys) {
        expect(result, contains(name));
      }
    });

    test('keeps the values that describe the configuration', () {
      final result = redactedShape(storedToken());

      expect(result, contains('type: "pipush"'));
      expect(result, contains('algorithm: "SHA1"'));
      expect(result, contains('digits: 6'));
      expect(result, contains('counter: 42'));
      expect(result, contains('isRolledOut: true'));
    });

    test('reduces a redacted value to its type', () {
      final result = redactedShape(storedToken());

      expect(result, contains('secret: <String>'));
      expect(result, contains('serial: <String>'));
    });

    test('tells null apart from a redacted value', () {
      final result = redactedShape({'folderId': null, 'secret': 'abc'});

      expect(result, contains('folderId: <null>'));
      expect(result, contains('secret: <String>'));
    });

    test('redacts nested entries as well', () {
      final result = redactedShape({
        'origin': {'appName': 'privacyIDEA Authenticator'},
      });

      expect(result, contains('appName: <String>'));
      expect(result, isNot(contains('privacyIDEA Authenticator')));
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

    test('an allowlisted name does not leak a nested object', () {
      // 'type' is allowlisted, but a map behind it is still walked entry by
      // entry rather than printed as it is.
      final result = redactedShape({
        'type': {'secret': 'must-not-leak'},
      });

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

    test('leaves a line without a sensitive name alone', () {
      const line = 'Loaded 3/4 tokens from secure storage';
      expect(filterSensitiveValues(line), line);
    });

    test('keeps the name so the line stays readable', () {
      expect(filterSensitiveValues('secret: abc'), contains('secret'));
    });
  });
}
