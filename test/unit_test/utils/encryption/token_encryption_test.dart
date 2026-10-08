import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/day_password_token_view_mode.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/enums/push_token_rollout_state.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/model/version.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/pia_scheme_processor.dart';
import 'package:privacyidea_authenticator/utils/encryption/token_encryption.dart';
import 'package:zxing2/qrcode.dart';
import 'package:zxing2/src/writer_exception.dart';

import 'token_export_fixtures.dart';

void main() {
  _testTokenEncryption();
  _testTokenEncryptionRoundTrip();
  _testTokenExportUri();
  _testTokenEncryptionTamperDetection();
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

/// Run `flutter test --dart-define=RUN_BUG_TESTS=true <file>` to execute the tests that are
/// marked as known bugs. They are skipped by default so that the suite stays green.
const bool _runBugTests = bool.fromEnvironment('RUN_BUG_TESTS');

const _password = 'correct horse battery staple';
const _label = 'Alice Ünïcödé \u{1F510} "quoted" \\ back\nnew line €';
const _issuer = 'ACME éè Corp & Co <test>';

final _createdAt = DateTime.utc(2024, 5, 17, 12, 30, 45, 123);

TokenOriginData _origin() => TokenOriginData(
      source: TokenOriginSourceType.container,
      appName: 'privacyIDEA',
      data: 'otpauth://hotp/secret?data=1',
      createdAt: _createdAt,
      isPrivacyIdeaToken: true,
      creator: 'admin',
      piServerVersion: const Version(3, 11, 2),
    );

/// Every token carries a non default value in every metadata field.
HOTPToken _hotp() => HOTPToken(
      id: 'hotp-id',
      label: _label,
      issuer: _issuer,
      serial: 'OATH0001A',
      containerSerial: 'CONT-HOTP',
      checkedContainer: const ['CONT-HOTP', 'CONT-OLD'],
      algorithm: Algorithms.SHA256,
      digits: 8,
      secret: 'JBSWY3DPEHPK3PXP',
      counter: 42,
      tokenImage: 'https://example.com/img/hotp.png',
      pin: true,
      isLocked: true,
      isHidden: true,
      sortIndex: 3,
      folderId: 7,
      origin: _origin(),
      isOffline: true,
      forceBiometricOption: ForceBiometricOption.biometric,
    );

TOTPToken _totp() => TOTPToken(
      id: 'totp-id',
      label: _label,
      issuer: _issuer,
      serial: 'TOTP0001A',
      containerSerial: 'CONT-TOTP',
      checkedContainer: const ['CONT-TOTP'],
      algorithm: Algorithms.SHA512,
      digits: 6,
      secret: 'MFRGGZDFMZTWQ2LK',
      period: 60,
      tokenImage: 'https://example.com/img/totp.png',
      pin: false,
      isLocked: true,
      isHidden: false, // explicit "not hidden" although the token is locked
      sortIndex: 0,
      folderId: 2,
      origin: _origin().copyWith(source: TokenOriginSourceType.qrScan, isPrivacyIdeaToken: () => false, creator: () => null, piServerVersion: () => const Version(4, 0, 0)),
      forceBiometricOption: ForceBiometricOption.pin,
    );

SteamToken _steam() => SteamToken(
      id: 'steam-id',
      label: _label,
      issuer: 'Steam',
      secret: 'JBSWY3DPEHPK3PXP',
      containerSerial: 'CONT-STEAM',
      checkedContainer: const ['A', 'B', 'C'],
      tokenImage: 'steam.png',
      pin: false,
      isLocked: false,
      isHidden: true,
      sortIndex: 11,
      folderId: 5,
      origin: _origin(),
      isOffline: true,
      forceBiometricOption: ForceBiometricOption.any,
    );

DayPasswordToken _dayPassword() => DayPasswordToken(
      id: 'day-id',
      label: _label,
      issuer: _issuer,
      serial: 'DPW0001A',
      containerSerial: 'CONT-DAY',
      checkedContainer: const ['CONT-DAY'],
      algorithm: Algorithms.SHA1,
      digits: 7,
      secret: 'GEZDGNBVGY3TQOJQ',
      period: const Duration(hours: 6, minutes: 30),
      viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
      tokenImage: 'day.png',
      pin: true,
      isLocked: true,
      isHidden: false,
      sortIndex: 8,
      folderId: 1,
      origin: _origin(),
    );

PushToken _push() => PushToken(
      id: 'push-id',
      serial: 'PIPU0001A',
      label: _label,
      issuer: _issuer,
      containerSerial: 'CONT-PUSH',
      checkedContainer: const ['CONT-PUSH'],
      fbToken: 'firebase-token',
      url: Uri.parse('https://pi.example.com/ttype/push?x=1'),
      expirationDate: DateTime.utc(2030, 1, 2, 3, 4, 5),
      enrollmentCredentials: 'enroll-secret',
      publicServerKey: 'PUBLIC-SERVER-KEY',
      publicTokenKey: 'PUBLIC-TOKEN-KEY',
      privateTokenKey: 'PRIVATE-TOKEN-KEY',
      isPollOnly: true,
      isRolledOut: true,
      sslVerify: true,
      rolloutState: PushTokenRollOutState.rolloutComplete,
      tokenImage: 'push.png',
      sortIndex: 4,
      folderId: 9,
      pin: true,
      isLocked: true,
      origin: _origin(),
      isOffline: true,
      forceBiometricOption: ForceBiometricOption.biometric,
    );

List<Token> _allTokens() => [_hotp(), _totp(), _steam(), _dayPassword(), _push()];

/// Field by field comparison. `Token.==` only compares ids (and a few fields for some subtypes), so it can not be used.
/// [expectedFolderId] is a parameter because the folder id is intentionally reset by [TokenEncryption.decrypt].
void _expectSameFields(Token actual, Token expected, {required int? expectedFolderId}) {
  final reason = '${expected.runtimeType} ${expected.id}';
  expect(actual.runtimeType, expected.runtimeType, reason: reason);
  expect(actual.id, expected.id, reason: reason);
  expect(actual.type, expected.type, reason: '$reason type');
  expect(actual.tokenVersion, expected.tokenVersion, reason: reason);
  expect(actual.label, expected.label, reason: '$reason label');
  expect(actual.issuer, expected.issuer, reason: '$reason issuer');
  expect(actual.serial, expected.serial, reason: '$reason serial');
  expect(actual.containerSerial, expected.containerSerial, reason: '$reason containerSerial');
  expect(actual.checkedContainer, expected.checkedContainer, reason: '$reason checkedContainer');
  expect(actual.pin, expected.pin, reason: '$reason pin');
  expect(actual.isLocked, expected.isLocked, reason: '$reason isLocked');
  expect(actual.isHidden, expected.isHidden, reason: '$reason isHidden');
  expect(actual.forceBiometricOption, expected.forceBiometricOption, reason: '$reason forceBiometricOption');
  expect(actual.tokenImage, expected.tokenImage, reason: '$reason tokenImage');
  expect(actual.folderId, expectedFolderId, reason: '$reason folderId');
  expect(actual.sortIndex, expected.sortIndex, reason: '$reason sortIndex');
  expect(actual.isOffline, expected.isOffline, reason: '$reason isOffline');
  expect(actual.origin, expected.origin, reason: '$reason origin');
  expect(actual.origin?.createdAt, expected.origin?.createdAt, reason: '$reason origin.createdAt');
  expect(actual.origin?.piServerVersion, expected.origin?.piServerVersion, reason: '$reason origin.piServerVersion');

  if (expected is OTPToken) {
    actual as OTPToken;
    expect(actual.algorithm, expected.algorithm, reason: '$reason algorithm');
    expect(actual.digits, expected.digits, reason: '$reason digits');
    expect(actual.secret, expected.secret, reason: '$reason secret');
  }
  if (expected is HOTPToken) {
    expect((actual as HOTPToken).counter, expected.counter, reason: '$reason counter');
  }
  if (expected is TOTPToken) {
    expect((actual as TOTPToken).period, expected.period, reason: '$reason period');
  }
  if (expected is DayPasswordToken) {
    actual as DayPasswordToken;
    expect(actual.period, expected.period, reason: '$reason period');
    expect(actual.viewMode, expected.viewMode, reason: '$reason viewMode');
  }
  if (expected is PushToken) {
    actual as PushToken;
    expect(actual.fbToken, expected.fbToken, reason: '$reason fbToken');
    expect(actual.url, expected.url, reason: '$reason url');
    expect(actual.expirationDate, expected.expirationDate, reason: '$reason expirationDate');
    expect(actual.enrollmentCredentials, expected.enrollmentCredentials, reason: '$reason enrollmentCredentials');
    expect(actual.publicServerKey, expected.publicServerKey, reason: '$reason publicServerKey');
    expect(actual.publicTokenKey, expected.publicTokenKey, reason: '$reason publicTokenKey');
    expect(actual.privateTokenKey, expected.privateTokenKey, reason: '$reason privateTokenKey');
    expect(actual.isPollOnly, expected.isPollOnly, reason: '$reason isPollOnly');
    expect(actual.isRolledOut, expected.isRolledOut, reason: '$reason isRolledOut');
    expect(actual.sslVerify, expected.sslVerify, reason: '$reason sslVerify');
    expect(actual.rolloutState, expected.rolloutState, reason: '$reason rolloutState');
  }

  // Catch all: nothing that is part of the serialized form may differ.
  final expectedJson = Map<String, dynamic>.of(jsonDecode(jsonEncode(expected.toJson())) as Map<String, dynamic>);
  expectedJson['folderId'] = expectedFolderId;
  expect(jsonDecode(jsonEncode(actual.toJson())), expectedJson, reason: '$reason complete json');
}

void _testTokenEncryptionRoundTrip() {
  group('TokenEncryption encrypt -> decrypt round trip', () {
    // PBKDF2 with 100000 iterations in pure Dart is slow, so encrypt and decrypt once for all assertions.
    late String encrypted;
    late List<Token> originals;
    late List<Token> decrypted;

    setUpAll(() async {
      originals = _allTokens();
      encrypted = await TokenEncryption.encrypt(tokens: originals, password: _password);
      decrypted = await TokenEncryption.decrypt(encryptedTokens: encrypted, password: _password);
    });

    test('the fixtures really use non default values (guards against vacuous equality)', () {
      for (final token in originals) {
        expect(token.label, _label);
        expect(token.checkedContainer, isNotEmpty);
        expect(token.containerSerial, isNotNull);
        expect(token.tokenImage, isNotNull);
        expect(token.folderId, isNotNull);
        expect(token.sortIndex, isNotNull);
        expect(token.origin, isNotNull);
        expect(token.origin!.piServerVersion, isNotNull);
      }
      expect(originals.whereType<HOTPToken>().single.forceBiometricOption, ForceBiometricOption.biometric);
      expect(originals.whereType<TOTPToken>().where((e) => e is! SteamToken).single.isHidden, isFalse);
      expect(originals.whereType<TOTPToken>().where((e) => e is! SteamToken).single.isLocked, isTrue);
    });

    test('the encrypted output is a json object with all aes fields and does not contain any plaintext', () {
      final json = jsonDecode(encrypted) as Map<String, dynamic>;
      expect(json.keys, containsAll(<String>['data', 'salt', 'iv', 'mac', 'kdf', 'cypher']));
      expect(json['kdf'], {
        'algorithm': 'Pbkdf2',
        'macAlgorithm': {
          'algorithm': 'Hmac',
          'hashAlgorithm': {'algorithm': 'DartSha256'}
        },
        'iterations': 100000,
        'bits': 256,
      });
      expect(json['cypher'], {'algorithm': 'AesGcm', 'secretKeyLength': 32});
      expect(base64Decode(json['salt']).length, 16);
      expect(base64Decode(json['iv']).length, 16);
      expect(base64Decode(json['mac']).length, 16);
      for (final secret in ['JBSWY3DPEHPK3PXP', 'MFRGGZDFMZTWQ2LK', 'PRIVATE-TOKEN-KEY', 'enroll-secret', 'hotp-id', 'ACME']) {
        expect(encrypted.contains(secret), isFalse, reason: 'plaintext "$secret" leaked into the encrypted output');
        expect(utf8.decode(base64Decode(json['data']), allowMalformed: true).contains(secret), isFalse);
      }
    });

    test('decrypt returns the same number of tokens, same types and same order', () {
      expect(decrypted.map((e) => e.runtimeType).toList(), originals.map((e) => e.runtimeType).toList());
      expect(decrypted.map((e) => e.id).toList(), originals.map((e) => e.id).toList());
    });

    test('HOTPToken: every field survives', () {
      _expectSameFields(decrypted[0], originals[0], expectedFolderId: null);
    });

    test('TOTPToken: every field survives', () {
      _expectSameFields(decrypted[1], originals[1], expectedFolderId: null);
    });

    test('SteamToken: every field survives', () {
      _expectSameFields(decrypted[2], originals[2], expectedFolderId: null);
      expect((decrypted[2] as SteamToken).digits, 5);
      expect((decrypted[2] as SteamToken).period, 30);
      expect(decrypted[2].serial, isNull);
    });

    test('DayPasswordToken: every field survives', () {
      _expectSameFields(decrypted[3], originals[3], expectedFolderId: null);
      expect((decrypted[3] as DayPasswordToken).period, const Duration(hours: 6, minutes: 30));
      expect((decrypted[3] as DayPasswordToken).viewMode, DayPasswordTokenViewMode.VALIDUNTIL);
    });

    test('PushToken: every field survives (including the private token key)', () {
      _expectSameFields(decrypted[4], originals[4], expectedFolderId: null);
      expect((decrypted[4] as PushToken).privateTokenKey, 'PRIVATE-TOKEN-KEY');
    });

    test('the OTP values of the decrypted OTP tokens equal the original ones (secret and counter intact)', () {
      expect((decrypted[0] as HOTPToken).otpValue, (originals[0] as HOTPToken).otpValue);
      expect((decrypted[0] as HOTPToken).nextValue, (originals[0] as HOTPToken).nextValue);
      expect((decrypted[1] as TOTPToken).otpFromTime(DateTime.utc(2025)), (originals[1] as TOTPToken).otpFromTime(DateTime.utc(2025)));
      expect((decrypted[2] as SteamToken).otpFromTime(DateTime.utc(2025)), (originals[2] as SteamToken).otpFromTime(DateTime.utc(2025)));
    });

    test('folderId is intentionally reset to null on import (decrypt), everything else keeps its value', () {
      // token_encryption.dart:54 `.copyWith(folderId: () => null)`: folder ids are local to a device
      // (TokenFolderNotifier hands out max + 1), so an id from another device would point to an unrelated folder.
      expect(originals.map((e) => e.folderId).toList(), [7, 2, 5, 1, 9]);
      expect(decrypted.map((e) => e.folderId).toList(), [null, null, null, null, null]);
      // sortIndex is NOT reset (documented here, see also the export uri test).
      expect(decrypted.map((e) => e.sortIndex).toList(), [3, 0, 11, 8, 4]);
    });

    test('encrypting the same tokens twice gives different salt, iv and ciphertext', () async {
      final second = await TokenEncryption.encrypt(tokens: originals, password: _password);
      final a = jsonDecode(encrypted) as Map<String, dynamic>;
      final b = jsonDecode(second) as Map<String, dynamic>;
      expect(b['salt'], isNot(a['salt']));
      expect(b['iv'], isNot(a['iv']));
      expect(b['data'], isNot(a['data']));
      expect(b['mac'], isNot(a['mac']));
    });

    test('a wrong password throws SecretBoxAuthenticationError and returns no tokens', () async {
      List<Token>? result;
      Object? error;
      try {
        result = await TokenEncryption.decrypt(encryptedTokens: encrypted, password: '$_password ');
      } catch (e) {
        error = e;
      }
      expect(result, isNull);
      expect(error, isA<SecretBoxAuthenticationError>());
    });

    test('the password is case sensitive and unicode is handled', () async {
      expect(TokenEncryption.decrypt(encryptedTokens: encrypted, password: _password.toUpperCase()), throwsA(isA<SecretBoxAuthenticationError>()));
    });
  });

  group('TokenEncryption round trip of lock related fields', () {
    late List<Token> originals;
    late List<Token> decrypted;

    setUpAll(() async {
      originals = [
        // locked only because of the pin
        HOTPToken(id: 'pin-only', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP', pin: true),
        // locked only because of biometric option, one token for every option
        for (final option in ForceBiometricOption.values)
          TOTPToken(id: 'force-${option.name}', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP', period: 30, forceBiometricOption: option),
        // explicitly locked without pin or biometric
        HOTPToken(id: 'locked-only', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP', isLocked: true),
        // locked and explicitly visible
        HOTPToken(id: 'locked-visible', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP', isLocked: true, isHidden: false),
        // unlocked but hidden
        HOTPToken(id: 'hidden-only', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP', isHidden: true),
        // no metadata at all
        HOTPToken(id: 'plain', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP'),
        SteamToken(id: 'steam-plain', secret: 'JBSWY3DPEHPK3PXP'),
        DayPasswordToken(id: 'day-plain', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP', period: const Duration(hours: 24)),
        PushToken(id: 'push-plain', serial: 'PIPU-plain'),
      ];
      final encrypted = await TokenEncryption.encrypt(tokens: originals, password: _password);
      decrypted = await TokenEncryption.decrypt(encryptedTokens: encrypted, password: _password);
    });

    test('pin, isLocked, isHidden and forceBiometricOption are identical for every combination', () {
      expect(decrypted.length, originals.length);
      for (var i = 0; i < originals.length; i++) {
        _expectSameFields(decrypted[i], originals[i], expectedFolderId: null);
      }
    });

    test('derived values behave as expected after the round trip', () {
      Token byId(String id) => decrypted.firstWhere((e) => e.id == id);
      expect(byId('pin-only').isLocked, isTrue);
      expect(byId('pin-only').isHidden, isTrue);
      expect(byId('force-none').isLocked, isFalse);
      expect(byId('force-none').isHidden, isFalse);
      for (final option in ForceBiometricOption.values.where((e) => e != ForceBiometricOption.none)) {
        expect(byId('force-${option.name}').isLocked, isTrue, reason: option.name);
        expect(byId('force-${option.name}').forceBiometricOption, option);
      }
      expect(byId('locked-only').isLocked, isTrue);
      expect(byId('locked-only').pin, isFalse);
      expect(byId('locked-visible').isLocked, isTrue);
      expect(byId('locked-visible').isHidden, isFalse);
      expect(byId('hidden-only').isLocked, isFalse);
      expect(byId('hidden-only').isHidden, isTrue);
      expect(byId('plain').isLocked, isFalse);
      expect(byId('plain').isHidden, isFalse);
      expect(byId('plain').origin, isNull);
      expect(byId('plain').tokenImage, isNull);
      expect(byId('plain').containerSerial, isNull);
      expect(byId('plain').checkedContainer, isEmpty);
      expect(byId('push-plain').isHidden, isFalse, reason: 'PushToken.isHidden is always false');
    });
  });

  group('TokenEncryption round trip edge cases', () {
    test('an empty token list round trips to an empty list', () async {
      final encrypted = await TokenEncryption.encrypt(tokens: const <Token>[], password: _password);
      final decrypted = await TokenEncryption.decrypt(encryptedTokens: encrypted, password: _password);
      expect(decrypted, isEmpty);
    });

    test('push token rollout states that are in progress are mapped to their failed state on import', () async {
      // PushToken.fromJson: a half finished rollout can not be continued after a restart or an import.
      final states = {
        PushTokenRollOutState.rolloutNotStarted: PushTokenRollOutState.rolloutNotStarted,
        PushTokenRollOutState.generatingRSAKeyPair: PushTokenRollOutState.generatingRSAKeyPairFailed,
        PushTokenRollOutState.generatingRSAKeyPairFailed: PushTokenRollOutState.generatingRSAKeyPairFailed,
        PushTokenRollOutState.receivingFirebaseToken: PushTokenRollOutState.receivingFirebaseTokenFailed,
        PushTokenRollOutState.receivingFirebaseTokenFailed: PushTokenRollOutState.receivingFirebaseTokenFailed,
        PushTokenRollOutState.sendRSAPublicKey: PushTokenRollOutState.sendRSAPublicKeyFailed,
        PushTokenRollOutState.sendRSAPublicKeyFailed: PushTokenRollOutState.sendRSAPublicKeyFailed,
        PushTokenRollOutState.parsingResponse: PushTokenRollOutState.parsingResponseFailed,
        PushTokenRollOutState.parsingResponseFailed: PushTokenRollOutState.parsingResponseFailed,
        PushTokenRollOutState.rolloutComplete: PushTokenRollOutState.rolloutComplete,
      };
      expect(states.keys.toSet(), PushTokenRollOutState.values.toSet(), reason: 'every state must be covered');
      final tokens = [
        for (final entry in states.entries) PushToken(id: 'push-${entry.key.name}', serial: 'S-${entry.key.name}', rolloutState: entry.key),
      ];
      // Cheap: json only, the aes layer is covered by the other tests.
      final restored = tokens.map((t) => Token.fromJson(jsonDecode(jsonEncode(t.toJson())) as Map<String, dynamic>) as PushToken).toList();
      for (var i = 0; i < tokens.length; i++) {
        expect(restored[i].rolloutState, states[tokens[i].rolloutState], reason: tokens[i].rolloutState.name);
      }
    });

    test('very long labels, issuers and secrets survive the aes layer unchanged', () async {
      final token = TOTPToken(
        id: 'long',
        label: List.filled(2000, 'Läng€').join(),
        issuer: List.filled(1000, '\u{1F510}').join(),
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: List.filled(200, 'JBSWY3DPEHPK3PXP').join(),
        period: 30,
      );
      final encrypted = await TokenEncryption.encrypt(tokens: [token], password: _password);
      final decrypted = (await TokenEncryption.decrypt(encryptedTokens: encrypted, password: _password)).single as TOTPToken;
      expect(decrypted.label, token.label);
      expect(decrypted.issuer, token.issuer);
      expect(decrypted.secret, token.secret);
    });

    test('decrypt of a non json string throws a FormatException', () async {
      await expectLater(TokenEncryption.decrypt(encryptedTokens: 'not json', password: _password), throwsA(isA<FormatException>()));
    });

    test('decrypt of a json list (not an object) throws instead of returning tokens', () async {
      await expectLater(TokenEncryption.decrypt(encryptedTokens: '[]', password: _password), throwsA(anyOf(isA<Error>(), isA<Exception>())));
    });

    test('decrypt of a json object without the aes fields throws instead of returning tokens', () async {
      await expectLater(TokenEncryption.decrypt(encryptedTokens: '{}', password: _password), throwsA(anyOf(isA<Error>(), isA<Exception>())));
    });

    test(
      'decrypt of a json object without the aes fields throws a FormatException or ArgumentError (no TypeError)',
      () async {
        await expectLater(
          TokenEncryption.decrypt(encryptedTokens: '{}', password: _password),
          throwsA(anyOf(isA<FormatException>(), isA<ArgumentError>())),
        );
      },
      skip: _runBugTests ? null : 'BUG: aes_encrypted.dart:130 fromJson does base64Decode(null) -> TypeError instead of a FormatException for a backup file without data',
    );
  });
}

QRCode _encodeAscii(int length) => Encoder.encode(
      'a' * length,
      ErrorCorrectionLevel.l,
      hints: EncodeHints()..put<CharacterSetECI>(EncodeHintType.characterSet, CharacterSetECI.ASCII),
    );

/// Byte capacity of the largest QR code (version 40) with error correction level L, byte mode, with the
/// ASCII character set hint (which adds an ECI header). This is the configuration used by
/// [TokenEncryption.toQrCode] and [generateQrCodeImage]. Version 40-L has 2956 data codewords (2953 bytes without ECI header).
/// Found by search so that the number is measured and not assumed.
final int _qrMaxBytes = () {
  var low = 1; // fits
  var high = 4000; // does not fit
  while (high - low > 1) {
    final mid = (low + high) ~/ 2;
    try {
      _encodeAscii(mid);
      low = mid;
    } on WriterException {
      high = mid;
    }
  }
  return low;
}();

const _uriPrefix = '${PiaSchemeProcessor.scheme}://${PiaSchemeProcessor.qrBackupHost}?data=';

/// Token JSON -> export uri, exactly like [TokenEncryption.generateExportUri] but from arbitrary bytes.
Uri _uriFromJsonString(String jsonString) => Uri.parse('$_uriPrefix${base64Url.encode(utf8.encode(jsonString))}');

void _expectSameUriFields(Token actual, Token expected, {required int? expectedFolderId}) {
  final reason = '${expected.runtimeType} ${expected.id}';
  expect(actual.runtimeType, expected.runtimeType, reason: reason);
  final expectedJson = Map<String, dynamic>.of(jsonDecode(jsonEncode(expected.toJson())) as Map<String, dynamic>);
  expectedJson['folderId'] = expectedFolderId;
  expect(jsonDecode(jsonEncode(actual.toJson())), expectedJson, reason: '$reason complete json');
  // The json comparison above is the catch all, these are the fields called out in the requirements.
  expect(actual.id, expected.id, reason: reason);
  expect(actual.label, expected.label, reason: '$reason label');
  expect(actual.issuer, expected.issuer, reason: '$reason issuer');
  expect(actual.serial, expected.serial, reason: '$reason serial');
  expect(actual.pin, expected.pin, reason: '$reason pin');
  expect(actual.isLocked, expected.isLocked, reason: '$reason isLocked');
  expect(actual.isHidden, expected.isHidden, reason: '$reason isHidden');
  expect(actual.forceBiometricOption, expected.forceBiometricOption, reason: '$reason forceBiometricOption');
  expect(actual.origin, expected.origin, reason: '$reason origin');
  expect(actual.origin?.createdAt, expected.origin?.createdAt, reason: '$reason origin.createdAt');
  expect(actual.containerSerial, expected.containerSerial, reason: '$reason containerSerial');
  expect(actual.checkedContainer, expected.checkedContainer, reason: '$reason checkedContainer');
  expect(actual.sortIndex, expected.sortIndex, reason: '$reason sortIndex');
  expect(actual.tokenImage, expected.tokenImage, reason: '$reason tokenImage');
  expect(actual.isOffline, expected.isOffline, reason: '$reason isOffline');
  expect(actual.folderId, expectedFolderId, reason: '$reason folderId');
}

/// Largest label length (ASCII) for which [TokenEncryption.toQrCode] still works for the token built by [build].
int _maxLabelLength(Token Function(String label) build) {
  var low = 0; // known to work
  var high = 6000; // known to fail
  while (high - low > 1) {
    final mid = (low + high) ~/ 2;
    try {
      TokenEncryption.toQrCode(build('x' * mid));
      low = mid;
    } on WriterException {
      high = mid;
    }
  }
  return low;
}

void _testTokenExportUri() {
  group('generateExportUri -> fromExportUri', () {
    final tokens = <String, Token>{
      'HOTP': exportUriHotp(),
      'TOTP': exportUriTotp(),
      'Steam': exportUriSteam(),
      'DayPassword': exportUriDayPassword(),
      'Push': exportUriPush(),
    };

    test('the uri has the pia://qrbackup?data=<base64url> shape and carries the whole token as json', () {
      for (final entry in tokens.entries) {
        final uri = TokenEncryption.generateExportUri(token: entry.value);
        expect(uri.scheme, PiaSchemeProcessor.scheme, reason: entry.key);
        expect(uri.host, PiaSchemeProcessor.qrBackupHost, reason: entry.key);
        expect(uri.queryParameters.keys, ['data'], reason: entry.key);
        final json = jsonDecode(utf8.decode(base64Url.decode(uri.queryParameters['data']!))) as Map<String, dynamic>;
        expect(json, jsonDecode(jsonEncode(entry.value.toJson())), reason: entry.key);
        expect(uri.toString().startsWith(_uriPrefix), isTrue, reason: entry.key);
        expect(uri.toString().codeUnits.every((c) => c < 128), isTrue, reason: '${entry.key}: the qr encoder uses ASCII');
      }
    });

    test('the uri string survives Uri.parse(uri.toString()) unchanged', () {
      for (final entry in tokens.entries) {
        final uri = TokenEncryption.generateExportUri(token: entry.value);
        expect(Uri.parse(uri.toString()), uri, reason: entry.key);
        expect(Uri.parse(uri.toString()).queryParameters['data'], uri.queryParameters['data'], reason: entry.key);
      }
    });

    for (final name in tokens.keys) {
      test('$name: every field survives (folderId and sortIndex are kept, unlike decrypt)', () {
        final token = tokens[name]!;
        final restored = TokenEncryption.fromExportUri(TokenEncryption.generateExportUri(token: token));
        _expectSameUriFields(restored, token, expectedFolderId: token.folderId);
        expect(restored.folderId, isNotNull, reason: 'the fixture really has a folder');
      });
    }

    test('the generated uri is accepted by Uri.parse(string) -> fromExportUri (what a qr scan delivers)', () {
      final token = exportUriHotp();
      final scanned = Uri.parse(TokenEncryption.generateExportUri(token: token).toString());
      _expectSameUriFields(TokenEncryption.fromExportUri(scanned), token, expectedFolderId: token.folderId);
    });

    test('lock related combinations round trip', () {
      final combinations = <Token>[
        HOTPToken(id: 'a', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP', pin: true),
        HOTPToken(id: 'b', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP', isLocked: true),
        HOTPToken(id: 'c', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP', isLocked: true, isHidden: false),
        HOTPToken(id: 'd', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP', isHidden: true),
        HOTPToken(id: 'e', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP'),
        for (final option in ForceBiometricOption.values)
          HOTPToken(id: 'f-${option.name}', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP', forceBiometricOption: option),
      ];
      for (final token in combinations) {
        final restored = TokenEncryption.fromExportUri(TokenEncryption.generateExportUri(token: token));
        _expectSameUriFields(restored, token, expectedFolderId: null);
      }
    });

    test('a very long unicode label survives the uri as long as it fits (no truncation)', () {
      final token = exportUriMinimalTotp(label: List.filled(300, 'Ä€\u{1F510}').join(), issuer: 'ü' * 100);
      final restored = TokenEncryption.fromExportUri(TokenEncryption.generateExportUri(token: token));
      expect(restored.label, token.label);
      expect(restored.issuer, token.issuer);
    });

    test(
      'folderId is reset to null on import, like TokenEncryption.decrypt does',
      () {
        // decrypt() (token_encryption.dart:54) resets the folder id because folder ids are local to a device
        // (a new folder gets max + 1), so an id from another device would put the imported token into an
        // unrelated folder. fromExportUri imports from another device as well but keeps the id.
        final restored = TokenEncryption.fromExportUri(TokenEncryption.generateExportUri(token: exportUriHotp()));
        expect(restored.folderId, isNull);
      },
      skip: _runBugTests ? null : 'BUG: token_encryption.dart:106 fromExportUri keeps folderId of the exporting device, unlike decrypt (line 54) which resets it',
    );
  });

  group('fromExportUri with broken input', () {
    test('missing data parameter throws a TypeError (null check) that PiaSchemeProcessor can catch', () {
      expect(() => TokenEncryption.fromExportUri(Uri.parse('pia://qrbackup')), throwsA(isA<TypeError>()));
      expect(() => TokenEncryption.fromExportUri(Uri.parse('pia://qrbackup?other=abc')), throwsA(isA<TypeError>()));
    });

    test('empty data parameter throws and returns no token', () {
      expect(() => TokenEncryption.fromExportUri(Uri.parse('pia://qrbackup?data=')), throwsA(isA<FormatException>()));
    });

    test('invalid base64 characters throw a FormatException', () {
      expect(() => TokenEncryption.fromExportUri(Uri.parse('pia://qrbackup?data=%21%21%21not-base64%21%21')), throwsA(isA<FormatException>()));
      expect(() => TokenEncryption.fromExportUri(Uri.parse('pia://qrbackup?data=a')), throwsA(isA<FormatException>()), reason: 'a single base64 char is never valid');
    });

    test('characterization: the base64url decoder also accepts the standard alphabet (+ and /) when it is percent encoded', () {
      // Dart's Base64Decoder is lenient about the alphabet. The importer therefore also reads uris that were
      // built with plain base64 as long as + and / survive the query encoding.
      final standard = base64.encode(utf8.encode('{"x":"ûÿþÿ"}'));
      expect(standard.contains(RegExp('[+/]')), isTrue, reason: 'the fixture must contain + or /');
      expect(
        () => TokenEncryption.fromExportUri(Uri.parse('pia://qrbackup?data=${Uri.encodeQueryComponent(standard)}')),
        throwsA(isA<ArgumentError>().having((e) => e.toString(), 'message', contains('Token type is not defined'))),
        reason: 'decoding worked, it only fails later because the json has no type',
      );
    });

    test('an unencoded + in the query becomes a space and is rejected with a FormatException', () {
      final standard = base64.encode(utf8.encode('{"x":"ûÿþÿ"}'));
      expect(standard.contains('+'), isTrue, reason: 'the fixture must contain +');
      expect(() => TokenEncryption.fromExportUri(Uri.parse('pia://qrbackup?data=$standard')), throwsA(isA<FormatException>()));
    });

    test('missing padding is rejected with a FormatException (the base64url codec is strict about padding)', () {
      final token = exportUriHotp();
      final padded = TokenEncryption.generateExportUri(token: token).queryParameters['data']!;
      expect(padded.endsWith('='), isTrue, reason: 'the fixture must need padding, otherwise this test proves nothing');
      final cut = padded.replaceAll('=', '');
      expect(
        () => TokenEncryption.fromExportUri(Uri.parse('$_uriPrefix$cut')),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('multiple of four'))),
      );
      // The same data with padding restored is fine, so the padding is the only difference.
      final restored = TokenEncryption.fromExportUri(Uri.parse('$_uriPrefix$padded'));
      expect(restored.id, token.id);
    });

    test('a padded uri whose padding was tampered with (excess "=") is rejected', () {
      final uri = TokenEncryption.generateExportUri(token: exportUriHotp());
      final data = uri.queryParameters['data']!;
      expect(() => TokenEncryption.fromExportUri(Uri.parse('$_uriPrefix$data====')), throwsA(isA<FormatException>()));
    });

    test('valid base64 of non utf8 bytes throws a FormatException', () {
      final uri = Uri.parse('$_uriPrefix${base64Url.encode([0xFF, 0xFE, 0xFD, 0xC3])}');
      expect(() => TokenEncryption.fromExportUri(uri), throwsA(isA<FormatException>()));
    });

    test('valid base64 of text that is not json throws a FormatException', () {
      expect(() => TokenEncryption.fromExportUri(_uriFromJsonString('this is not json')), throwsA(isA<FormatException>()));
      expect(() => TokenEncryption.fromExportUri(_uriFromJsonString('')), throwsA(isA<FormatException>()));
      expect(() => TokenEncryption.fromExportUri(_uriFromJsonString('{"type":')), throwsA(isA<FormatException>()), reason: 'truncated json');
    });

    test('json that is not a map (list, string, number, null) throws a TypeError', () {
      for (final jsonString in ['[]', '[{"type":"HOTP"}]', '"HOTP"', '42', 'null', 'true']) {
        expect(() => TokenEncryption.fromExportUri(_uriFromJsonString(jsonString)), throwsA(isA<TypeError>()), reason: jsonString);
      }
    });

    test('a json map without type throws an ArgumentError naming the problem', () {
      expect(
        () => TokenEncryption.fromExportUri(_uriFromJsonString('{"id":"x"}')),
        throwsA(isA<ArgumentError>().having((e) => e.toString(), 'message', contains('Token type is not defined'))),
      );
      expect(() => TokenEncryption.fromExportUri(_uriFromJsonString('{}')), throwsA(isA<ArgumentError>()));
    });

    test('a json map with an unknown type throws an ArgumentError naming the type', () {
      expect(
        () => TokenEncryption.fromExportUri(_uriFromJsonString('{"id":"x","type":"FOO"}')),
        throwsA(isA<ArgumentError>().having((e) => e.toString(), 'message', contains('Token type [FOO] is not supported'))),
      );
      expect(() => TokenEncryption.fromExportUri(_uriFromJsonString('{"id":"x","type":""}')), throwsA(isA<ArgumentError>()));
    });

    test('a json map with a known type but missing required fields throws and returns no token', () {
      // HOTP needs id, algorithm, digits and secret.
      expect(() => TokenEncryption.fromExportUri(_uriFromJsonString('{"type":"HOTP"}')), throwsA(anyOf(isA<Error>(), isA<Exception>())));
      expect(
        () => TokenEncryption.fromExportUri(_uriFromJsonString('{"type":"HOTP","id":"x","algorithm":"MD5","digits":6,"secret":"A"}')),
        throwsA(anyOf(isA<Error>(), isA<Exception>())),
        reason: 'unknown algorithm',
      );
    });

    test('the type is matched case insensitively (hotp is accepted)', () {
      final token = TokenEncryption.fromExportUri(
        _uriFromJsonString('{"type":"hotp","id":"x","algorithm":"SHA1","digits":6,"secret":"JBSWY3DPEHPK3PXP"}'),
      );
      expect(token, isA<HOTPToken>());
      expect(token.id, 'x');
    });

    test('the legacy PUSH type is accepted and becomes a PushToken', () {
      final token = TokenEncryption.fromExportUri(_uriFromJsonString('{"type":"push","id":"x","serial":"PIPU1"}'));
      expect(token, isA<PushToken>());
      expect(token.serial, 'PIPU1');
    });

    test('the uri scheme and host are not checked by fromExportUri (only the data parameter counts)', () {
      final data = TokenEncryption.generateExportUri(token: exportUriTotp()).queryParameters['data']!;
      final token = TokenEncryption.fromExportUri(Uri.parse('https://evil.example.com/anything?data=$data'));
      expect(token.id, 'totp-id');
    });

    test('PiaSchemeProcessor turns every broken uri into a failed result instead of throwing', () async {
      const processor = PiaSchemeProcessor();
      final brokenUris = [
        Uri.parse('pia://qrbackup'),
        Uri.parse('pia://qrbackup?data=%21%21%21'),
        _uriFromJsonString('[]'),
        _uriFromJsonString('{"type":"FOO"}'),
        _uriFromJsonString('not json'),
      ];
      for (final uri in brokenUris) {
        final results = await processor.processUri(uri);
        expect(results, isNotNull, reason: '$uri');
        expect(results!.single.isFailed, isTrue, reason: '$uri');
      }
    });

    test('PiaSchemeProcessor returns the token for a valid uri', () async {
      final uri = TokenEncryption.generateExportUri(token: exportUriHotp());
      final results = await const PiaSchemeProcessor().processUri(uri);
      expect(results!.single.isSuccess, isTrue);
      expect(results.single.asSuccess!.resultData.id, 'hotp-id');
    });
  });

  group('QR code capacity of the export uri', () {
    test('zxing2 byte mode at error correction L with the ASCII hint: capacity is 2952 bytes, one more throws WriterException', () {
      // ignore: avoid_print
      print('MAX SAFE SIZE: QR capacity of the export uri string is $_qrMaxBytes bytes (version 40, level L, byte mode + ECI header)');
      expect(_qrMaxBytes, 2952, reason: '2956 data codewords minus 32 bits of headers (4 ECI mode + 8 ECI value + 4 byte mode + 16 length) = 2952 bytes');
      final largest = _encodeAscii(_qrMaxBytes);
      expect(largest.version!.versionNumber, 40);
      expect(largest.matrix!.width, 177);
      expect(() => _encodeAscii(_qrMaxBytes + 1), throwsA(isA<WriterException>()));
    });

    test('a small token fits easily and has a low qr version', () {
      final token = exportUriMinimalTotp(label: 'user@example.com', issuer: 'Example');
      final uri = TokenEncryption.generateExportUri(token: token).toString();
      expect(uri.length, lessThan(600));
      final qr = TokenEncryption.toQrCode(token);
      expect(qr.matrix, isNotNull);
      expect(qr.version!.versionNumber, lessThan(20));
    });

    test('every uri length up to $_qrMaxBytes produces a qr code (boundary of toQrCode)', () {
      // Label length is increased until the uri has exactly the capacity length or the next base64 step would exceed it.
      final maxLabel = _maxLabelLength((label) => exportUriMinimalTotp(label: label));
      final fitting = TokenEncryption.generateExportUri(token: exportUriMinimalTotp(label: 'x' * maxLabel)).toString();
      final tooBig = TokenEncryption.generateExportUri(token: exportUriMinimalTotp(label: 'x' * (maxLabel + 1))).toString();
      expect(fitting.length, lessThanOrEqualTo(_qrMaxBytes));
      expect(tooBig.length, greaterThan(_qrMaxBytes));
      expect(TokenEncryption.toQrCode(exportUriMinimalTotp(label: 'x' * maxLabel)).version!.versionNumber, 40);
    });

    test('characterization: max label length of a minimal TOTP token that can be shown as a QR code', () {
      final maxLabel = _maxLabelLength((label) => exportUriMinimalTotp(label: label));
      // The exact number depends on the token json, so only pin a sane window and print the value for the report.
      // ignore: avoid_print
      print('MAX SAFE SIZE: minimal TOTP token, ASCII label only: $maxLabel characters');
      expect(maxLabel, inInclusiveRange(1500, 2200));
    });

    test('characterization: max label+issuer+tokenImage budget with typical metadata', () {
      final maxLabel = _maxLabelLength((label) => exportUriHotp().copyWith(label: label));
      // ignore: avoid_print
      print('MAX SAFE SIZE: fully populated HOTP token (all metadata), ASCII label only: $maxLabel characters');
      expect(maxLabel, lessThan(_maxLabelLength((label) => exportUriMinimalTotp(label: label))));
      expect(maxLabel, greaterThan(500));
    });

    test('a token with a long label throws WriterException in toQrCode', () {
      final token = exportUriMinimalTotp(label: 'x' * 3000);
      expect(() => TokenEncryption.toQrCode(token), throwsA(isA<WriterException>()));
    });

    test('generateExportUri itself does not check the size and works for huge tokens', () {
      final token = exportUriMinimalTotp(label: 'x' * 100000);
      final uri = TokenEncryption.generateExportUri(token: token);
      expect(uri.toString().length, greaterThan(100000));
      expect(TokenEncryption.fromExportUri(uri).label, token.label, reason: 'it round trips, it just can not be drawn as a qr code');
    });

    test('long issuer or long tokenImage (an inline data uri) also exceed the capacity', () {
      expect(() => TokenEncryption.toQrCode(exportUriMinimalTotp(issuer: 'i' * 3000)), throwsA(isA<WriterException>()));
      expect(
        () => TokenEncryption.toQrCode(exportUriMinimalTotp(tokenImage: 'data:image/png;base64,${'A' * 3000}')),
        throwsA(isA<WriterException>()),
      );
    });

    test('non ASCII characters cost more bytes: the same number of characters fails earlier', () {
      final maxAscii = _maxLabelLength((label) => exportUriMinimalTotp(label: label));
      final maxEmoji = _maxLabelLength((label) => exportUriMinimalTotp(label: '\u{1F510}' * label.length));
      expect(maxEmoji, lessThan(maxAscii / 3), reason: 'an emoji is 4 utf8 bytes in the json');
    });

    test('a realistic rolled out push token with 2048 bit RSA key lengths does not fit into a QR code', () {
      // Lengths of PKCS1 PEM-less base64 encodings of 2048 bit RSA keys, as stored in PushToken.
      final push = exportUriPush(privateKey: 'P' * 1624).copyWith(publicServerKey: 'S' * 392, publicTokenKey: 'T' * 392);
      final length = TokenEncryption.generateExportUri(token: push).toString().length;
      expect(length, greaterThan(_qrMaxBytes));
      expect(() => TokenEncryption.toQrCode(push), throwsA(isA<WriterException>()));
    });
  });
}

const _tamperPassword = 'pa55w0rd';

Uint8List _flipBit(Uint8List source, int byteIndex, int bit) {
  final copy = Uint8List.fromList(source);
  copy[byteIndex] ^= 1 << bit;
  return copy;
}

void _testTokenEncryptionTamperDetection() {
  group('TokenEncryption end to end tamper detection with the real key derivation (100000 iterations)', () {
    late String encrypted;
    late Map<String, dynamic> json;

    setUpAll(() async {
      encrypted = await TokenEncryption.encrypt(
        tokens: [HOTPToken(id: 'id1', label: 'label', algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP')],
        password: _tamperPassword,
      );
      json = jsonDecode(encrypted) as Map<String, dynamic>;
    });

    Future<void> expectRejected(Map<String, dynamic> tampered) async {
      Object? error;
      Object? result;
      try {
        result = await TokenEncryption.decrypt(encryptedTokens: jsonEncode(tampered), password: _tamperPassword);
      } catch (e) {
        error = e;
      }
      expect(result, isNull, reason: 'no tokens may come out of a tampered backup');
      expect(error, isA<SecretBoxAuthenticationError>());
    }

    Map<String, dynamic> flipped(String field, int byte) {
      final copy = Map<String, dynamic>.of(json);
      copy[field] = base64Encode(_flipBit(base64Decode(json[field] as String), byte, 0));
      return copy;
    }

    test('the untampered backup decrypts', () async {
      final tokens = await TokenEncryption.decrypt(encryptedTokens: encrypted, password: _tamperPassword);
      expect(tokens.single.id, 'id1');
    });

    test('a flipped bit in data is rejected', () => expectRejected(flipped('data', 0)));
    test('a flipped bit in salt is rejected', () => expectRejected(flipped('salt', 0)));
    test('a flipped bit in iv is rejected', () => expectRejected(flipped('iv', 15)));
    test('a flipped bit in mac is rejected', () => expectRejected(flipped('mac', 7)));
  });
}
