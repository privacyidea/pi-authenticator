import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/encryption/token_encryption.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/privacyidea_authenticator_qr_processor.dart';

void main() {
  _testTokenEncryption();
}

void _testTokenEncryption() {
  group('Token Encryption', () {
    test('encrypt', () async {
      final tokensList = [
        HOTPToken(id: 'id1', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret1'),
        TOTPToken(period: 30, id: 'id2', algorithm: Algorithms.SHA256, digits: 8, secret: 'secret2'),
        SteamToken(period: 30, id: 'id3', algorithm: Algorithms.SHA512, secret: 'secret3'),
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
    test('generateQrCodeUri', () {
      final tokensList = [
        HOTPToken(id: 'id1', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret1'),
        TOTPToken(period: 30, id: 'id2', algorithm: Algorithms.SHA256, digits: 8, secret: 'secret2'),
        SteamToken(period: 30, id: 'id3', algorithm: Algorithms.SHA512, secret: 'secret3'),
        DayPasswordToken(period: const Duration(hours: 24), id: 'id4', algorithm: Algorithms.SHA512, digits: 10, secret: 'secret4'),
        PushToken(serial: 'serial', id: 'id5'),
      ];
      const compressedTokensBase64 = [
        'H4sIAAAAAAAACk1PMQ7CMAz8i-cOsDBkY2slJJDgA2nshqhuUiWuBEL8HUelgsnnu7PPfgHbnhgMQAOhlIXyF6PWgHuFc4hgBsuFquWU3Ej4R7QBkX4OSSPFbrKewMSFuYEhMVLucOtLytJFpMdGpBx8zVg7ec46Cu35dtFwy15luU9KXdtjvQfVLQXMQVeRyyQqraCqLi1R6he79wc_WDvI3QAAAA==',
        'H4sIAAAAAAAACk1OzQrCMAx-l5x3kIkivXlbQVDYXqAuWS3L2tF2oIjvbuYcesr3l3x5ApsrMSiAAlxKE8UvRpkOS4Gj86A6w4nmyCm0PeGfUDlE-iVy6MnrwVgC5SfmArrASFHjylOIWXuk-yqE6OzcsbD8GGUVmnNzkXLDVux8G0Sqq2O524uIks8J1EGOURspi7mAz78UXZC27eb1Bgi4xPffAAAA',
        'H4sIAAAAAAAACk2OsQ7CMAxE_8VzB6BiydYBqZFggh8ItRuiukmVpBII8e84lAom3z2fdX4CmysxKIAKXEozxa9GmQ5rkZPzoHrDiUrkGLqB8A-0DpF-iRwG8no0lkD5mbmCPjBS1Lj6FGLWHum-ghCdLR2Ly49JTuF8OTQnaTdsZZ9vY2Fts9_uBCbqImUhi_h8SdEF6ag3rzcEg5Vm1QAAAA==',
        'H4sIAAAAAAAACk1PTQvCMAz9Lznv4GSK7DYY4mAy2UDxOE2cZV072s4PxP9uyhyaS15eXpKXF8j6RBJigACEtQOZL0bOAiOGvVAQX2ppyUtyfW4J_4iNQKSfwumWVNbVDUGsBikDuGiJZDKcaquNyxTSYyK0EY2_MVbu2fMopMlxl1TVoShT9lDLhlXu2nGn2iSLcM4k8pizEIczXkpnQ467I_C-b4LuW41-2T7Js3RdlP4bMkKzl9Uymn3j_QHdQYgrBgEAAA==',
        'H4sIAAAAAAAAClVQwW7CMAz9F5-57tIrO1ANMbSy3VPiIguTVI6DqKb9-5xCOnbK88t7fk_-BnY9MjQAK6CUMsoDe3vJvxgcKUAzOE5YJNt4PKN_IjbkPf4pNJ4xtBd3QmhCZl7BENmjtL7OKYq2weOtElHoVDLuk06jWWHf7j-7jcXjbSRxSjG8Ol2WJhRypfcDWEx_KNGLIPGXfQ3T0gyDROYLBl0LWmU1X6ryLFwhpQ_ToX_PuniLM2btdK5Qx10sjKjdw86Ue6Zjh3JFecOpbhuFrmaauz3Ts_o_-_ML-WVvco4BAAA=',
      ];
      for (var i = 0; tokensList.length > i; i++) {
        final token = tokensList[i];
        final compressed = compressedTokensBase64[i];
        final qrCodeUri = TokenEncryption.generateQrCodeUri(token: token);
        final uriString = qrCodeUri.toString();
        expect(uriString.isNotEmpty, true);
        expect(uriString, '${PrivacyIDEAAuthenticatorQrProcessor.scheme}://${PrivacyIDEAAuthenticatorQrProcessor.host}?data=$compressed');
      }
    });
    test('fromQrCodeUri', () {
      final tokensList = [
        HOTPToken(id: 'id1', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret1'),
        TOTPToken(period: 30, id: 'id2', algorithm: Algorithms.SHA256, digits: 8, secret: 'secret2'),
        SteamToken(period: 30, id: 'id3', algorithm: Algorithms.SHA512, secret: 'secret3'),
        DayPasswordToken(period: const Duration(hours: 24), id: 'id4', algorithm: Algorithms.SHA512, digits: 10, secret: 'secret4'),
        PushToken(serial: 'serial', id: 'id5'),
      ];
      const uriStrings = [
        'pia://qrbackup?data=H4sIAAAAAAAACk1PMQ7CMAz8i-cOsDBkY2slJJDgA2nshqhuUiWuBEL8HUelgsnnu7PPfgHbnhgMQAOhlIXyF6PWgHuFc4hgBsuFquWU3Ej4R7QBkX4OSSPFbrKewMSFuYEhMVLucOtLytJFpMdGpBx8zVg7ec46Cu35dtFwy15luU9KXdtjvQfVLQXMQVeRyyQqraCqLi1R6he79wc_WDvI3QAAAA==',
        'pia://qrbackup?data=H4sIAAAAAAAACk1OzQrCMAx-l5x3kIkivXlbQVDYXqAuWS3L2tF2oIjvbuYcesr3l3x5ApsrMSiAAlxKE8UvRpkOS4Gj86A6w4nmyCm0PeGfUDlE-iVy6MnrwVgC5SfmArrASFHjylOIWXuk-yqE6OzcsbD8GGUVmnNzkXLDVux8G0Sqq2O524uIks8J1EGOURspi7mAz78UXZC27eb1Bgi4xPffAAAA',
        'pia://qrbackup?data=H4sIAAAAAAAACk2OsQ7CMAxE_8VzB6BiydYBqZFggh8ItRuiukmVpBII8e84lAom3z2fdX4CmysxKIAKXEozxa9GmQ5rkZPzoHrDiUrkGLqB8A-0DpF-iRwG8no0lkD5mbmCPjBS1Lj6FGLWHum-ghCdLR2Ly49JTuF8OTQnaTdsZZ9vY2Fts9_uBCbqImUhi_h8SdEF6ag3rzcEg5Vm1QAAAA==',
        'pia://qrbackup?data=H4sIAAAAAAAACk1PTQvCMAz9Lznv4GSK7DYY4mAy2UDxOE2cZV072s4PxP9uyhyaS15eXpKXF8j6RBJigACEtQOZL0bOAiOGvVAQX2ppyUtyfW4J_4iNQKSfwumWVNbVDUGsBikDuGiJZDKcaquNyxTSYyK0EY2_MVbu2fMopMlxl1TVoShT9lDLhlXu2nGn2iSLcM4k8pizEIczXkpnQ467I_C-b4LuW41-2T7Js3RdlP4bMkKzl9Uymn3j_QHdQYgrBgEAAA==',
        'pia://qrbackup?data=H4sIAAAAAAAAClVQwW7CMAz9F5-57tIrO1ANMbSy3VPiIguTVI6DqKb9-5xCOnbK88t7fk_-BnY9MjQAK6CUMsoDe3vJvxgcKUAzOE5YJNt4PKN_IjbkPf4pNJ4xtBd3QmhCZl7BENmjtL7OKYq2weOtElHoVDLuk06jWWHf7j-7jcXjbSRxSjG8Ol2WJhRypfcDWEx_KNGLIPGXfQ3T0gyDROYLBl0LWmU1X6ryLFwhpQ_ToX_PuniLM2btdK5Qx10sjKjdw86Ue6Zjh3JFecOpbhuFrmaauz3Ts_o_-_ML-WVvco4BAAA=',
      ];
      for (var i = 0; uriStrings.length > i; i++) {
        final uri = Uri.parse(uriStrings[i]);
        final token = tokensList[i];
        final decrypted = TokenEncryption.fromQrCodeUri(uri);
        expect(decrypted, token);
      }
    });
  });
}

// const asd = [
//   {
//     "label": "",
//     "issuer": "",
//     "id": "id1",
//     "pin": false,
//     "isLocked": false,
//     "isHidden": false,
//     "tokenImage": null,
//     "folderId": null,
//     "sortIndex": null,
//     "origin": null,
//     "type": "HOTP",
//     "algorithm": "SHA1",
//     "digits": 6,
//     "secret": "secret1",
//     "counter": 0
//   },
//   {
//     "label": "",
//     "issuer": "",
//     "id": "id2",
//     "pin": false,
//     "isLocked": false,
//     "isHidden": false,
//     "tokenImage": null,
//     "folderId": null,
//     "sortIndex": null,
//     "origin": null,
//     "type": "TOTP",
//     "algorithm": "SHA256",
//     "digits": 8,
//     "secret": "secret2",
//     "period": 30
//   },
//   {
//     "label": "",
//     "issuer": "",
//     "id": "id3",
//     "pin": false,
//     "isLocked": false,
//     "isHidden": false,
//     "tokenImage": null,
//     "folderId": null,
//     "sortIndex": null,
//     "origin": null,
//     "type": "STEAM",
//     "algorithm": "SHA512",
//     "secret": "secret3",
//     "period": 30
//   },
//   {
//     "label": "",
//     "issuer": "",
//     "id": "id4",
//     "pin": false,
//     "isLocked": false,
//     "isHidden": false,
//     "tokenImage": null,
//     "folderId": null,
//     "sortIndex": null,
//     "origin": null,
//     "type": "DAYPASSWORD",
//     "algorithm": "SHA512",
//     "digits": 10,
//     "secret": "secret4",
//     "viewMode": "VALIDFOR",
//     "period": 86400000000
//   },
//   {
//     "label": "",
//     "issuer": "",
//     "id": "id5",
//     "pin": false,
//     "isLocked": false,
//     "isHidden": false,
//     "tokenImage": null,
//     "folderId": null,
//     "sortIndex": null,
//     "origin": null,
//     "type": "PIPUSH",
//     "expirationDate": null,
//     "serial": "serial",
//     "fbToken": null,
//     "sslVerify": false,
//     "enrollmentCredentials": null,
//     "url": null,
//     "isRolledOut": false,
//     "rolloutState": "rolloutNotStarted",
//     "publicServerKey": null,
//     "privateTokenKey": null,
//     "publicTokenKey": null
//   }
// ];
