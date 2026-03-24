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
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';

TOTPToken get totpToken => TOTPToken(
  period: 30,
  label: 'label',
  issuer: 'issuer',
  id: 'id',
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret',
  pin: false,
  tokenImage: 'example.png',
  sortIndex: 0,
  isLocked: false,
  folderId: 0,
);

void main() {
  group('TOTP Token creation', () {
    test('constructor', () {
      final token = totpToken;
      expect(token.period, 30);
      expect(token.label, 'label');
      expect(token.issuer, 'issuer');
      expect(token.id, 'id');
      expect(token.algorithm, Algorithms.SHA1);
      expect(token.digits, 6);
      expect(token.secret, 'secret');
      expect(token.type, 'TOTP');
      expect(token.pin, false);
      expect(token.tokenImage, 'example.png');
      expect(token.sortIndex, 0);
      expect(token.isLocked, false);
      expect(token.folderId, 0);
    });

    test('copyWith', () {
      final totpCopy = totpToken.copyWith(
        period: 60,
        label: 'labelCopy',
        issuer: 'issuerCopy',
        id: 'idCopy',
        algorithm: Algorithms.SHA256,
        digits: 8,
        secret: 'secretCopy',
        pin: true,
        tokenImage: 'exampleCopy.png',
        sortIndex: 1,
        isLocked: true,
        folderId: () => 1,
      );
      expect(totpCopy.period, 60);
      expect(totpCopy.label, 'labelCopy');
      expect(totpCopy.issuer, 'issuerCopy');
      expect(totpCopy.id, 'idCopy');
      expect(totpCopy.algorithm, Algorithms.SHA256);
      expect(totpCopy.digits, 8);
      expect(totpCopy.secret, 'secretCopy');
      expect(totpCopy.pin, true);
      expect(totpCopy.tokenImage, 'exampleCopy.png');
      expect(totpCopy.sortIndex, 1);
      expect(totpCopy.isLocked, true);
      expect(totpCopy.folderId, 1);
    });
  });

  group('serialization', () {
    group('fromUriMap', () {
      test('with full map', () {
        final uriMap = {
          Token.LABEL: 'label',
          Token.ISSUER: 'issuer',
          Token.TOKENTYPE_OTPAUTH: 'totp',
          Token.PIN: Token.PIN_VALUE_FALSE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.DIGITS: '6',
          OTPToken.SECRET_BASE32: Encodings.base32.encode(
            utf8.encode('secret'),
          ),
          TOTPToken.PERIOD_SECONDS: '30',
        };
        final totpFromUriMap = TOTPToken.fromOtpAuthMap(uriMap);
        expect(totpFromUriMap.period, 30);
        expect(totpFromUriMap.label, 'label');
        expect(totpFromUriMap.issuer, 'issuer');
        expect(totpFromUriMap.algorithm, Algorithms.SHA1);
        expect(totpFromUriMap.digits, 6);
        expect(totpFromUriMap.secret, 'ONSWG4TFOQ======');
        expect(totpFromUriMap.type, 'TOTP');
      });

      test('with missing secret throws', () {
        final uriMap = {
          Token.TOKENTYPE_OTPAUTH: 'totp',
          OTPToken.DIGITS: '6',
          TOTPToken.PERIOD_SECONDS: '30',
        };
        expect(() => TOTPToken.fromOtpAuthMap(uriMap), throwsArgumentError);
      });

      test('with zero period throws', () {
        final uriMap = {
          OTPToken.SECRET_BASE32: 'JBSWY3DPEHPK3PXP',
          TOTPToken.PERIOD_SECONDS: '0',
        };
        expect(() => TOTPToken.fromOtpAuthMap(uriMap), throwsArgumentError);
      });

      test('with zero digits throws', () {
        final uriMap = {
          OTPToken.SECRET_BASE32: 'JBSWY3DPEHPK3PXP',
          OTPToken.DIGITS: '0',
        };
        expect(() => TOTPToken.fromOtpAuthMap(uriMap), throwsArgumentError);
      });

      test('with lowercase algorithm', () {
        final uriMap = {
          OTPToken.ALGORITHM: 'sha1',
          OTPToken.SECRET_BASE32: 'JBSWY3DPEHPK3PXP',
        };
        final totpFromUriMap = TOTPToken.fromOtpAuthMap(uriMap);
        expect(totpFromUriMap.algorithm, Algorithms.SHA1);
      });
    });

    test('toUriMap', () {
      final totpUriMap = totpToken.toOtpAuthMap();
      expect(totpUriMap[Token.LABEL], 'label');
      expect(totpUriMap[Token.ISSUER], 'issuer');
      expect(totpUriMap[OTPToken.ALGORITHM], 'SHA1');
      expect(totpUriMap[OTPToken.DIGITS], '6');
      expect(totpUriMap[TOTPToken.PERIOD_SECONDS], '30');
    });

    test('fromJson/toJson consistency', () {
      final totpJson = {
        'period': 11,
        'label': 'label',
        'issuer': 'issuer',
        'id': 'id',
        'algorithm': 'SHA1',
        'digits': 22,
        'secret': 'secret',
        'type': 'totp',
        'pin': true,
        'tokenImage': 'example.png',
        'sortIndex': 33,
        'isLocked': true,
        'folderId': 44,
      };
      final fromJson = TOTPToken.fromJson(totpJson);
      expect(fromJson.period, 11);
      expect(fromJson.digits, 22);
      expect(fromJson.toJson()['period'], 11);
    });
  });

  group('isSameTokenAs', () {
    test('same serial | different id', () {
      final t1 = totpToken.copyWith(serial: 'SN1', id: 'id1');
      final t2 = totpToken.copyWith(serial: 'SN1', id: 'id2');
      expect(t1.isSameTokenAs(t2), isTrue);
    });

    test('no serial | different id | same params', () {
      final t1 = totpToken.copyWith(id: 'id1');
      final t2 = totpToken.copyWith(id: 'id2');
      expect(t1.isSameTokenAs(t2), isTrue);
    });

    test('no serial | different id | different params', () {
      final t1 = totpToken.copyWith(id: 'id1', algorithm: Algorithms.SHA1);
      final t2 = totpToken.copyWith(id: 'id2', algorithm: Algorithms.SHA256);
      expect(t1.isSameTokenAs(t2), isFalse);
    });
  });

  group('Calculate TOTP values (Full Algorithms & Digits)', () {
    final now = DateTime.now();
    final secret = Encodings.base32.encode(utf8.encode('secret'));

    void testTotpVsHotp(int period, int digits, Algorithms algorithm) {
      final counter = (now.millisecondsSinceEpoch / 1000) ~/ period;

      final hotp = HOTPToken(
        id: '',
        algorithm: algorithm,
        digits: digits,
        counter: counter,
        secret: secret,
      );

      final totp = TOTPToken(
        period: period,
        id: '',
        algorithm: algorithm,
        digits: digits,
        secret: secret,
      );

      expect(
        totp.otpFromTime(now),
        hotp.otpValue,
        reason: 'Failed for $algorithm, $digits digits, $period period',
      );
    }

    test('SHA1 - 6 digits - 30s', () => testTotpVsHotp(30, 6, Algorithms.SHA1));
    test('SHA1 - 6 digits - 60s', () => testTotpVsHotp(60, 6, Algorithms.SHA1));
    test('SHA1 - 8 digits - 30s', () => testTotpVsHotp(30, 8, Algorithms.SHA1));
    test(
      'SHA256 - 6 digits - 30s',
      () => testTotpVsHotp(30, 6, Algorithms.SHA256),
    );
    test(
      'SHA512 - 8 digits - 60s',
      () => testTotpVsHotp(60, 8, Algorithms.SHA512),
    );
  });
}
