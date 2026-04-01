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

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/encodings.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';

HOTPToken get hotpToken => HOTPToken(
  counter: 1,
  label: 'label',
  issuer: 'issuer',
  id: 'id',
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret',
  pin: true,
  tokenImage: 'example.png',
  sortIndex: 0,
  isLocked: true,
  folderId: 0,
);

void main() {
  _testHotpToken();
}

void _testHotpToken() {
  group('HOTP Token creation', () {
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
        isLocked: false,
        folderId: () => 1,
      );
      expect(hotpCopy.counter, 5);
      expect(hotpCopy.label, 'labelCopy');
      expect(hotpCopy.issuer, 'issuerCopy');
      expect(hotpCopy.id, 'idCopy');
      expect(hotpCopy.algorithm, Algorithms.SHA256);
      expect(hotpCopy.digits, 8);
      expect(hotpCopy.secret, 'secretCopy');
      expect(hotpCopy.pin, false);
      expect(hotpCopy.tokenImage, 'exampleCopy.png');
      expect(hotpCopy.sortIndex, 1);
      expect(hotpCopy.isLocked, false);
      expect(hotpCopy.folderId, 1);
    });

    test('copyWith handles folderId null reset', () {
      final tokenWithFolder = hotpToken.copyWith(folderId: () => 5);
      final resetToken = tokenWithFolder.copyWith(folderId: () => null);
      expect(resetToken.folderId, isNull);
    });
  });

  group('serialization', () {
    group('fromUriMap', () {
      test('with full map', () {
        final uriMap = {
          Token.LABEL: 'label',
          Token.ISSUER: 'issuer',
          Token.TOKENTYPE_OTPAUTH: 'HOTP',
          Token.PIN: Token.PIN_VALUE_TRUE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.SECRET_BASE32: Encodings.base32.encode(
            utf8.encode('secret'),
          ),
          OTPToken.DIGITS: '6',
          HOTPToken.COUNTER: '10',
        };
        final hotpFromUriMap = HOTPToken.fromOtpAuthMap(uriMap);
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
          Token.LABEL: 'label',
          Token.TOKENTYPE_OTPAUTH: 'HOTP',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.DIGITS: '6',
          HOTPToken.COUNTER: '10',
        };
        expect(() => HOTPToken.fromOtpAuthMap(uriMap), throwsArgumentError);
      });

      test('digits is zero', () {
        final uriMap = {
          OTPToken.SECRET_BASE32: Encodings.base32.encode(
            utf8.encode('secret'),
          ),
          OTPToken.DIGITS: '0',
        };
        expect(() => HOTPToken.fromOtpAuthMap(uriMap), throwsArgumentError);
      });

      test('invalid counter format defaults to 0', () {
        final uriMap = {
          OTPToken.SECRET_BASE32: 'JBSWY3DPEHPK3PXP',
          HOTPToken.COUNTER: 'abc',
        };
        final token = HOTPToken.fromOtpAuthMap(uriMap);
        expect(token.counter, 0);
      });

      test('with lowercase algorithm', () {
        final uriMap = {
          OTPToken.ALGORITHM: 'sha1',
          OTPToken.SECRET_BASE32: Encodings.base32.encode(
            utf8.encode('secret'),
          ),
        };
        final hotpFromUriMap = HOTPToken.fromOtpAuthMap(uriMap);
        expect(hotpFromUriMap.algorithm, Algorithms.SHA1);
      });
    });

    test('toUriMap', () {
      final uriMap = hotpToken.toOtpAuthMap();
      expect(uriMap[Token.LABEL], 'label');
      expect(uriMap[OTPToken.ALGORITHM], 'SHA1');
      expect(uriMap[HOTPToken.COUNTER], '1');
    });

    test('fromJson/toJson', () {
      final json = hotpToken.toJson();
      final fromJson = HOTPToken.fromJson(json);
      expect(fromJson.counter, hotpToken.counter);
      expect(fromJson.secret, hotpToken.secret);
    });
  });

  group('isSameTokenAs', () {
    test('same id | same parameters', () {
      final token = hotpToken;
      expect(token.isSameTokenAs(token), true);
    });

    test('different id | same parameters', () {
      final t1 = hotpToken;
      final t2 = t1.copyWith(id: 'other-id');
      expect(t1.isSameTokenAs(t2), true);
    });

    test('same serial | different parameters', () {
      final t1 = HOTPToken(
        id: '1',
        secret: 's1',
        serial: 'SER1',
        algorithm: Algorithms.SHA1,
        digits: 6,
      );
      final t2 = HOTPToken(
        id: '2',
        secret: 's2',
        counter: 5,
        serial: 'SER1',
        algorithm: Algorithms.SHA1,
        digits: 6,
      );
      expect(t1.isSameTokenAs(t2), true);
    });
  });

  group('Calculate HOTP values (Legacy & RFC Vectors)', () {
    group('different counters 6 digits', () {
      test('OTP for counter == 0', () {
        HOTPToken token0 = HOTPToken(
          id: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(token0.otpValue, '814628');
      });
      test('OTP for counter == 1', () {
        HOTPToken token1 = HOTPToken(
          id: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: 1,
        );
        expect(token1.otpValue, '533881');
      });
    });

    group('different counters 8 digits', () {
      test('OTP for counter == 0', () {
        HOTPToken token0 = HOTPToken(
          id: '',
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(token0.otpValue, '31814628');
      });
    });

    group('different algorithms 6 digits', () {
      test('OTP for sha256', () {
        HOTPToken token1 = HOTPToken(
          id: '',
          algorithm: Algorithms.SHA256,
          digits: 6,
          secret: Encodings.base32.encode(utf8.encode('Secret')),
        );
        expect(token1.otpValue, '203782');
      });
      test('OTP for sha512', () {
        HOTPToken token2 = HOTPToken(
          id: '',
          algorithm: Algorithms.SHA512,
          digits: 6,
          secret: Encodings.base32.encode(utf8.encode('Secret')),
        );
        expect(token2.otpValue, '636350');
      });
    });
  });
}
