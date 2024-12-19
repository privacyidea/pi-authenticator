import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/encodings.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';

SteamToken get steamToken => SteamToken(
      label: 'label',
      issuer: 'issuer',
      id: 'id',
      secret: 'secret',
      pin: false,
      tokenImage: 'example.png',
      sortIndex: 0,
      isLocked: false,
      folderId: 0,
    );
void main() {
  _testSteamToken();
}

void _testSteamToken() {
  group('Steam Token', () {
    group('TOTP Token creation', () {
      test('constructor', () {
        expect(steamToken.period, 30); // default period
        expect(steamToken.label, 'label');
        expect(steamToken.issuer, 'issuer');
        expect(steamToken.id, 'id');
        expect(steamToken.algorithm, Algorithms.SHA1); // default algorithm
        expect(steamToken.digits, 5); // default digits
        expect(steamToken.secret, 'secret');
        expect(steamToken.type, 'STEAM');
        expect(steamToken.pin, false);
        expect(steamToken.tokenImage, 'example.png');
        expect(steamToken.sortIndex, 0);
        expect(steamToken.isLocked, false);
        expect(steamToken.folderId, 0);
      });
      test('copyWith', () {
        final totpCopy = steamToken.copyWith(
          period: 60, // Should not affect the period because steam tokens always have 30 seconds period
          label: 'labelCopy',
          issuer: 'issuerCopy',
          id: 'idCopy',
          algorithm: Algorithms.SHA256, // Should not affect the algorithm because steam tokens always have SHA1 algorithm
          digits: 8, // Should not affect the digits because steam tokens always have 5 digits
          secret: 'secretCopy',
          pin: true,
          tokenImage: 'exampleCopy.png',
          sortIndex: 1,
          isLocked: true,
          folderId: () => 1,
        );
        expect(totpCopy.period, 30);
        expect(totpCopy.label, 'labelCopy');
        expect(totpCopy.issuer, 'issuerCopy');
        expect(totpCopy.id, 'idCopy');
        expect(totpCopy.algorithm, Algorithms.SHA1);
        expect(totpCopy.digits, 5);
        expect(totpCopy.secret, 'secretCopy');
        expect(totpCopy.type, 'STEAM');
        expect(totpCopy.pin, true);
        expect(totpCopy.tokenImage, 'exampleCopy.png');
        expect(totpCopy.sortIndex, 1);
        expect(totpCopy.isLocked, true);
        expect(totpCopy.folderId, 1);
      });
    });
    group('Serialization', () {
      group('fromUriMap', () {
        test('with full map', () {
          final uriMap = {
            Token.LABEL: 'label',
            Token.ISSUER: 'issuer',
            Token.OTPAUTH_TYPE: 'totp',
            Token.PIN: Token.PIN_VALUE_FALSE,
            Token.IMAGE: 'example.png',
            OTPToken.SECRET_BASE32: Encodings.base32.encode(utf8.encode('secret')),
          };
          final totpFromUriMap = SteamToken.fromOtpAuthMap(uriMap);
          expect(totpFromUriMap.period, 30);
          expect(totpFromUriMap.label, 'label');
          expect(totpFromUriMap.issuer, 'issuer');
          expect(totpFromUriMap.algorithm, Algorithms.SHA1);
          expect(totpFromUriMap.digits, 5);
          expect(totpFromUriMap.secret, 'ONSWG4TFOQ======');
          expect(totpFromUriMap.type, 'STEAM');
          expect(totpFromUriMap.pin, false);
          expect(totpFromUriMap.tokenImage, 'example.png');
        });
        test('with missing secret', () {
          final uriMap = {
            Token.LABEL: 'label',
            Token.ISSUER: 'issuer',
            Token.OTPAUTH_TYPE: 'totp',
            Token.PIN: Token.PIN_VALUE_FALSE,
            Token.IMAGE: 'example.png',
          };
          expect(() => SteamToken.fromOtpAuthMap(uriMap), throwsA(isA<ArgumentError>()));
        });
        test('with empty map', () {
          final uriMap = <String, dynamic>{};
          expect(() => TOTPToken.fromOtpAuthMap(uriMap), throwsA(isA<ArgumentError>()));
        });
      });
      test('toUriMap', () {
        final totpUriMap = steamToken.toOtpAuthMap();
        expect(totpUriMap[Token.LABEL], 'label');
        expect(totpUriMap[Token.ISSUER], 'issuer');
        expect(totpUriMap[Token.OTPAUTH_TYPE], 'STEAM');
        expect(totpUriMap[Token.PIN], false);
        expect(totpUriMap[Token.IMAGE], 'example.png');
        expect(totpUriMap[OTPToken.SECRET_BASE32], 'ONSWG4TFOQ======');
      });
      test('fromJson', () {
        final steamJson = {
          'label': 'label',
          'issuer': 'issuer',
          'id': 'id',
          'secret': 'secret',
          'type': 'STEAM',
          'pin': true,
          'tokenImage': 'example.png',
          'sortIndex': 33,
          'isLocked': true,
          'folderId': 44,
        };
        final steamFromJson = SteamToken.fromJson(steamJson);
        expect(steamFromJson.period, 30);
        expect(steamFromJson.label, 'label');
        expect(steamFromJson.issuer, 'issuer');
        expect(steamFromJson.id, 'id');
        expect(steamFromJson.algorithm, Algorithms.SHA1);
        expect(steamFromJson.digits, 5);
        expect(steamFromJson.secret, 'secret');
        expect(steamFromJson.type, 'STEAM');
        expect(steamFromJson.pin, true);
        expect(steamFromJson.tokenImage, 'example.png');
        expect(steamFromJson.sortIndex, 33);
        expect(steamFromJson.isLocked, true);
        expect(steamFromJson.folderId, 44);
      });
      test('toJson', () {
        final totpJson = steamToken.toJson();
        expect(totpJson['label'], 'label');
        expect(totpJson['issuer'], 'issuer');
        expect(totpJson['id'], 'id');
        expect(totpJson['secret'], 'secret');
        expect(totpJson['type'], 'STEAM');
        expect(totpJson['pin'], false);
        expect(totpJson['tokenImage'], 'example.png');
        expect(totpJson['sortIndex'], 0);
        expect(totpJson['isLocked'], false);
        expect(totpJson['folderId'], 0);
      });
    });
    group('isSameTokenAs', () {
      test('no serial | same id | same parameters', () {
        // No serial. Should recognize by id or parameters
        final steamToken = SteamToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          secret: 'secret',
        );

        expect(steamToken.isSameTokenAs(steamToken.copyWith()), isTrue);
      });
      test('no serial | same id | different parameters', () {
        // No serial. Should recognize by id
        final steamToken = SteamToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          secret: 'secret',
        );

        expect(steamToken.isSameTokenAs(steamToken.copyWith(secret: 'secret2')), isTrue);
      });
      test('no serial | different id | same parameters', () {
        // No serial, different id. Should recognize by parameters
        final steamToken = SteamToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          secret: 'secret',
        );

        expect(steamToken.isSameTokenAs(steamToken.copyWith(id: 'id2')), isTrue);
      });
      test('no serial | different id | different parameters', () {
        // No serial, different id, different parameters. Should not recognize
        final steamToken = SteamToken(
          label: 'label',
          issuer: 'issuer',
          id: 'id',
          secret: 'secret',
        );

        expect(steamToken.isSameTokenAs(steamToken.copyWith(id: 'id2', secret: 'secret2')), isFalse);
      });
    });
    test('otpValue', () {
      final time = DateTime.fromMillisecondsSinceEpoch(1712666212056);

      final steamToken = SteamToken(
        label: '',
        issuer: '',
        id: '',
        secret: 'SECRETA=',
      );
      final otp = steamToken.otpFromTime(time);
      final otpNow = steamToken.otpFromTime(DateTime.now());
      expect(otp, equals('JGPCJ')); // Checks if the otpOfTime works correctly
      expect(steamToken.otpValue, equals(otpNow)); // Checks if the otpValue delivers the same value as the otpOfTime method
    });
  });
}
