import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';

void main() {
  _testHotpToken();
}

void _testHotpToken() {
  group('HOTP Token creation/method', () {
    final hotpToken = HOTPToken(
      counter: 1,
      label: 'label',
      issuer: 'issuer',
      id: 'id',
      algorithm: Algorithms.SHA1,
      digits: 6,
      secret: 'secret',
      type: 'type',
      pin: true,
      tokenImage: 'example.png',
      sortIndex: 0,
      isLocked: false,
      folderId: 0,
    );
    test('constructor', () {
      expect(hotpToken.counter, 1);
      expect(hotpToken.label, 'label');
      expect(hotpToken.issuer, 'issuer');
      expect(hotpToken.id, 'id');
      expect(hotpToken.algorithm, Algorithms.SHA1);
      expect(hotpToken.digits, 6);
      expect(hotpToken.secret, 'secret');
      expect(hotpToken.type, 'HOTP');
      expect(hotpToken.pin, true);
      expect(hotpToken.tokenImage, 'example.png');
      expect(hotpToken.sortIndex, 0);
      expect(hotpToken.isLocked, true);
      expect(hotpToken.folderId, 0);
    });
    test('withNextCounter', () {
      final withNextCounter = hotpToken.withNextCounter();
      expect(withNextCounter.counter, 2);
    });
    test('copyWith', () {
      final hotpCopy = hotpToken.copyWith(
        counter: 5,
        label: 'labelCopy',
        issuer: 'issuerCopy',
        id: 'idCopy',
        algorithm: Algorithms.SHA256,
        digits: 8,
        secret: 'secretCopy',
        pin: false,
        tokenImage: 'exampleCopy.png',
        sortIndex: 1,
        isLocked: true,
        folderId: () => 1,
      );
      expect(hotpCopy.counter, 5);
      expect(hotpCopy.label, 'labelCopy');
      expect(hotpCopy.issuer, 'issuerCopy');
      expect(hotpCopy.label, 'idCopy');
      expect(hotpCopy.algorithm, Algorithms.SHA256);
      expect(hotpCopy.digits, 8);
      expect(hotpCopy.secret, 'secretCopy');
      expect(hotpCopy.type, 'HOTP');
      expect(hotpCopy.pin, false);
      expect(hotpCopy.tokenImage, 'exampleCopy.png');
      expect(hotpCopy.sortIndex, 1);
      expect(hotpCopy.isLocked, true);
      expect(hotpCopy.folderId, 1);
    });
    group('fromUriMap', () {
      test('with full map', () {
        final uriMap = {
          'URI_COUNTER': 10,
          'URI_LABEL': 'label',
          'URI_ISSUER': 'issuer',
          'URI_ALGORITHM': 'SHA1',
          'URI_SECRET': Uint8List.fromList(utf8.encode('secret')),
          'URI_DIGITS': 6,
          'URI_TYPE': 'HOTP',
          'URI_PIN': true,
          'URI_IMAGE': 'example.png',
        };
        final hotpFromUriMap = HOTPToken.fromUriMap(uriMap);
        expect(hotpFromUriMap.counter, 10);
        expect(hotpFromUriMap.label, 'label');
        expect(hotpFromUriMap.issuer, 'issuer');
        expect(hotpFromUriMap.algorithm, Algorithms.SHA1);
        expect(hotpFromUriMap.secret, 'ONSWG4TFOQ======');
        expect(hotpFromUriMap.digits, 6);
        expect(hotpFromUriMap.type, 'HOTP');
        expect(hotpFromUriMap.pin, true);
        expect(hotpFromUriMap.tokenImage, 'example.png');
      });
      test('without secret', () {
        final uriMap = {
          'URI_COUNTER': 10,
          'URI_LABEL': 'label',
          'URI_ISSUER': 'issuer',
          'URI_ALGORITHM': 'SHA1',
          'URI_DIGITS': 6,
          'URI_TYPE': 'HOTP',
          'URI_PIN': true,
          'URI_IMAGE': 'example.png',
        };
        expect(() => HOTPToken.fromUriMap(uriMap), throwsArgumentError);
      });
      test('digits is zero', () {
        final uriMap = {
          'URI_COUNTER': 10,
          'URI_LABEL': 'label',
          'URI_ISSUER': 'issuer',
          'URI_ALGORITHM': 'SHA1',
          'URI_SECRET': Uint8List.fromList(utf8.encode('secret')),
          'URI_DIGITS': 0,
          'URI_TYPE': 'HOTP',
          'URI_PIN': true,
          'URI_IMAGE': 'example.png',
        };
        expect(() => HOTPToken.fromUriMap(uriMap), throwsArgumentError);
      });
      test('with empty map', () {
        final uriMap = <String, dynamic>{};
        expect(() => HOTPToken.fromUriMap(uriMap), throwsArgumentError);
      });
    });
  });
  group('Calculate hotp values', () {
    group('different couters 6 digits', () {
      // We need to use different tokens here, because simply incrementing the
      // counter between all method calls leads to a race condition
      test('OTP for counter == 0', () {
        HOTPToken token0 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 0,
        );
        expect(token0.otpValue, '814628');
      });

      test('OTP for counter == 1', () {
        HOTPToken token1 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 1,
        );
        expect(token1.otpValue, '533881');
      });

      test('OTP for counter == 2', () {
        HOTPToken token2 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 2,
        );
        expect(token2.otpValue, '720111');
      });

      test('OTP for counter == 8', () {
        HOTPToken token8 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 8,
        );
        expect(token8.otpValue, '963685');
      });
    });
    group('different couters 8 digits', () {
      // We need to use different tokens here, because simply incrementing the
      // counter between all method calls leads to a race condition

      test('OTP for counter == 0', () {
        HOTPToken token0 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 0,
        );
        expect(token0.otpValue, '31814628');
      });

      test('OTP for counter == 1', () {
        HOTPToken token1 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 1,
        );
        expect(token1.otpValue, '28533881');
      });

      test('OTP for counter == 2', () {
        HOTPToken token2 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 2,
        );
        expect(token2.otpValue, '31720111');
      });

      test('OTP for counter == 8', () {
        HOTPToken token8 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 8,
        );
        expect(token8.otpValue, '15963685');
      });
    });
    group('different algorithms 6 digits', () {
      // We need to use different tokens here, because simply incrementing the
      // counter between all method calls leads to a race condition

      test('OTP for sha1', () {
        HOTPToken token0 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('Secret') as Uint8List, Encodings.base32),
          counter: 0,
        );
        expect(token0.otpValue, '292574');
      });

      test('OTP for sha256', () {
        HOTPToken token1 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA256,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('Secret') as Uint8List, Encodings.base32),
          counter: 0,
        );
        expect(token1.otpValue, '203782');
      });

      test('OTP for sha512', () {
        HOTPToken token2 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA512,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('Secret') as Uint8List, Encodings.base32),
          counter: 0,
        );
        expect(token2.otpValue, '636350');
      });
    });
    group('different algorithms 8 digits', () {
      // We need to use different tokens here, because simply incrementing the
      // counter between all method calls leads to a race condition
      test('OTP for sha1', () {
        HOTPToken token0 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('Secret') as Uint8List, Encodings.base32),
          counter: 0,
        );
        expect(token0.otpValue, '25292574');
      });

      test('OTP for sha256', () {
        HOTPToken token1 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA256,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('Secret') as Uint8List, Encodings.base32),
          counter: 0,
        );
        expect(token1.otpValue, '25203782');
      });

      test('OTP for sha512', () {
        HOTPToken token2 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA512,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('Secret') as Uint8List, Encodings.base32),
          counter: 0,
        );
        expect(token2.otpValue, '99636350');
      });
    });
  });
}
