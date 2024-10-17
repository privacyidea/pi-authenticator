import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/utils/encryption/token_encryption.dart';
import 'package:zxing2/qrcode.dart';

void main() {
  _testTokenEncryption();
}

void _testTokenEncryption() {
  group('Token Encryption', () {
    test('encrypt', () async {
      final tokensList = [
        HOTPToken(id: 'id1', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret1'),
        TOTPToken(period: 30, id: 'id2', algorithm: Algorithms.SHA256, digits: 8, secret: 'secret2'),
        SteamToken(id: 'id3', secret: 'secret3'),
        DayPasswordToken(period: const Duration(hours: 24), id: 'id4', algorithm: Algorithms.SHA512, digits: 10, secret: 'secret4'),
        PushToken(serial: 'serial', id: 'id5'),
      ];
      final encrypted = await TokenEncryption.encrypt(tokens: tokensList, password: 'password');
      expect(encrypted.isNotEmpty, true);
      expect(encrypted.contains('"data":"'), true);
    });
    test('decrypt', () async {
      const encrypted =
          '{"data":"jW5TJIY5dApfjZwYxJO7U5TYoV8JDbSHqlD2iPVDri8KrrisYRFy0ewg+YmU8XH9SS+TzEppAc4tbC69ZLXt5FLbQFprnJgP3eHEIw3ok1aHAaALtClyLnCNW265IjSrdqYdXm4DSHGG3Ol+9SyuCNjKwgdmkRO4Oqa2PimL0oOyjMLwVp908PY65lckBPAvX9CeAuLwglMCmg36tr2u0lKiPDqmYexPlpuriZOuzpBN4x+hWU75hBeo8hAJNIpnEBLCBufnOFCfFxgpr2mx4AsMh79AIeTENSTE2k327CKPpnJYXKfCdTVwVKtreeWyp4tN++9ACjmDx7QCRzAuDLHucyP4cE4gQ3uDkhhLtAOhaBlkTHWfQ0KP0dq3O5zQE6IwXRaMhN8kBiwqkQALjEtwhbWqtJPVK6fTYpGFb+gNg5dqwig4jx5h90drUUtlWWWvHCtAxFxNVgLtJIoAcHTrJy1rHU3gO85EaUClLYOQIx17gyA3FhO97VwRkk+8b8+kurjnEk+CVH3CTsBSEOKHMQDr2euoTlLukADm9qrJcXkprPfHLUnSCKAJ+9cDMvD13+Fa+xK7ybBnGnG13PkeNJplpwxNprITrvzq8QDpLBmAIaTeEbev9+qpuUOkS1UsDiXaYw/0tsRmsI0vc+864amfXMHiKl1VaAdL58/GjkveCu+nteers2Mubk48qWVyiw1MFR8c1gxDrL+V0WFD/YACNOjFUnUVP43XosbdM+7DRtW5m08uIcrap2SF7+Fzg9ye3WLSLCzAg5v6oNijHnaxNiWNaaX88vjLbCJAj00OX3xZGqefVMF4hV5l2SkTICEBh9Q21ZMJvA1WVs0LsYK2i9DHKVQohvhpjqCyn9xEGEvEOHOOYWNiBhLdEEQojfkdzmGOAw17Qi/7Ttd5bboMmUg6lIbkiDlfnkB6B2XtEmj/tASQJkWcWtamds+5VYu1j7L12Yk+133CeBXRYzHtUj4Ks7OCBilHS67kEJxJc2fcJvuQhJ7i1fZh4BB1/wCAjhRhoEmB8BXlD6xQeLcqSk/bvs4wbTf7AejfQpb4+yOW4sn6v00QrSDN52OFuTB0cDnFlNMQEAwaPgynkWafP5ibLerXd0EHzPpgioT70scgAV0WTVSItyAhuxixmp3Zr90g3hx0GfL3knCfHX3OwPOb7LGhqKQYcqG6MewDucHVftCAaUt6xg8tHTci9Zvv4d1mF/XZ8JLw/5IhRw4VxkqSsHWPQMGRNGFttHCCjwje4jEd9PZISK4dSA1TybTCvNek9dfrSLFDhpEXN9zrLHFYsYfHOhegFxdnFr9f8wZPeP1z1agoQXL9tKjrADPD0HmEBxBQtq/ihGRAggDK89BBufApj7IqSayBvS7JA/On22FGtIqKcnMeozNXGFGKeTRlQd7Rb+nBQuubNVx4qNjPrGRU5pZS1qAUNM4viK+8iZE1ZhObMf6hkFYOn8YcJx+PYsW83i6m9XqA/LbBUCKZOYhx101xLwsid1U2lftlwfVbmEyw095UnTLLSM5QDub0gZOpGWZ3YSPg6eteBBwlkiAnmmuT4li37BDxCDOGtCHY6c+LXOELZxTcTkwH7B7ODJxR5RS1+f+3AOekaNGaTBgN/7B6wKq6SG5y/BUrXebfAyyMofXFReLUHImJWxwKF1oVgf69ioN57xvbjbmLmeySlkZaIehrx5AEmMxW6PRzPbyEctOKesDBvlLT4LO7YBqYRLb9V0Ul0U1Gecbd4Uxi","salt":"68nMAFVeqzS5L9zaK3Rfrw==","iv":"z/3ZYNKTiwuDLzW9dfn9Kg==","mac":"Neo3ZresLNiEiM3Zs0F+tg==","kdf":{"algorithm":"Pbkdf2","macAlgorithm":{"algorithm":"Hmac","hashAlgorithm":{"algorithm":"DartSha256"}},"iterations":100000,"bits":256},"cypher":{"algorithm":"AesGcm","secretKeyLength":32}}';
      final decrypted = await TokenEncryption.decrypt(encryptedTokens: encrypted, password: 'password');

      expect(decrypted.isNotEmpty, true);
      expect(decrypted.length, 5);
      expect(decrypted.whereType<HOTPToken>().length, 1);
      expect(decrypted.whereType<TOTPToken>().length, 2); // TOTP and Steam
      expect(decrypted.whereType<SteamToken>().length, 1);
      expect(decrypted.whereType<DayPasswordToken>().length, 1);
      expect(decrypted.whereType<PushToken>().length, 1);
    });
    test('generateExportUri', () {
      final tokensList = [
        HOTPToken(id: 'id1', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret1'),
        TOTPToken(period: 30, id: 'id2', algorithm: Algorithms.SHA256, digits: 8, secret: 'secret2'),
        SteamToken(id: 'id3', secret: 'secret3'),
        DayPasswordToken(period: const Duration(hours: 24), id: 'id4', algorithm: Algorithms.SHA512, digits: 10, secret: 'secret4'),
        PushToken(serial: 'serial', id: 'id5'),
      ];

      for (var i = 0; tokensList.length > i; i++) {
        final token = tokensList[i];
        final qrCodeUri = TokenEncryption.generateExportUri(token: token);
        final uriString = qrCodeUri.toString();
        Token? decoded;
        expect(uriString.isNotEmpty, true);
        expect(() => decoded = TokenEncryption.fromExportUri(qrCodeUri), returnsNormally);
        expect(decoded.runtimeType, tokensList[i].runtimeType);
      }
    });

    test('toQrCode', () {
      final tokensList = [
        HOTPToken(id: 'id1', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret1'),
        TOTPToken(period: 30, id: 'id2', algorithm: Algorithms.SHA256, digits: 8, secret: 'secret2'),
        SteamToken(id: 'id3', secret: 'secret3'),
        DayPasswordToken(period: const Duration(hours: 24), id: 'id4', algorithm: Algorithms.SHA512, digits: 10, secret: 'secret4'),
        PushToken(serial: 'serial', id: 'id5'),
      ];
      for (var i = 0; tokensList.length > i; i++) {
        final token = tokensList[i];
        QRCode? qrCode;
        try {
          qrCode = TokenEncryption.toQrCode(token);
        } catch (e) {
          qrCode = null;
        }
        expect(qrCode, isNotNull);
      }
    });
    test('fromQrCodeUri', () {
      final tokensList = [
        HOTPToken(id: 'id1', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret1'),
        TOTPToken(period: 30, id: 'id2', algorithm: Algorithms.SHA256, digits: 8, secret: 'secret2'),
        SteamToken(id: 'id3', secret: 'secret3'),
        DayPasswordToken(period: const Duration(hours: 24), id: 'id4', algorithm: Algorithms.SHA512, digits: 10, secret: 'secret4'),
        PushToken(serial: 'serial', id: 'id5'),
      ];
      const uriStrings = [
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQxIiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IkhPVFAiLCJhbGdvcml0aG0iOiJTSEExIiwiZGlnaXRzIjo2LCJzZWNyZXQiOiJzZWNyZXQxIiwiY291bnRlciI6MH0=',
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQyIiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IlRPVFAiLCJhbGdvcml0aG0iOiJTSEEyNTYiLCJkaWdpdHMiOjgsInNlY3JldCI6InNlY3JldDIiLCJwZXJpb2QiOjMwfQ==',
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQzIiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IlNURUFNIiwic2VjcmV0Ijoic2VjcmV0MyJ9',
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQ0IiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IkRBWVBBU1NXT1JEIiwiYWxnb3JpdGhtIjoiU0hBNTEyIiwiZGlnaXRzIjoxMCwic2VjcmV0Ijoic2VjcmV0NCIsInZpZXdNb2RlIjoiVkFMSURGT1IiLCJwZXJpb2QiOjg2NDAwMDAwMDAwfQ==',
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQ1IiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IlBJUFVTSCIsImV4cGlyYXRpb25EYXRlIjpudWxsLCJzZXJpYWwiOiJzZXJpYWwiLCJmYlRva2VuIjpudWxsLCJzc2xWZXJpZnkiOmZhbHNlLCJlbnJvbGxtZW50Q3JlZGVudGlhbHMiOm51bGwsInVybCI6bnVsbCwiaXNSb2xsZWRPdXQiOmZhbHNlLCJyb2xsb3V0U3RhdGUiOiJyb2xsb3V0Tm90U3RhcnRlZCIsInB1YmxpY1NlcnZlcktleSI6bnVsbCwicHJpdmF0ZVRva2VuS2V5IjpudWxsLCJwdWJsaWNUb2tlbktleSI6bnVsbH0=',
      ];
      for (var i = 0; uriStrings.length > i; i++) {
        final uri = Uri.parse(uriStrings[i]);
        final token = tokensList[i];
        final decrypted = TokenEncryption.fromExportUri(uri);
        expect(decrypted, token);
      }
    });
  });
}
