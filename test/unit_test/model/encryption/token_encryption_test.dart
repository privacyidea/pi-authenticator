import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/encryption/token_encryption.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';

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
      print(encrypted);
    });
    test('decrypt', () {});
    test('generateQrCodeUri', () {});
    test('fromQrCodeUri', () {});
  });
}
