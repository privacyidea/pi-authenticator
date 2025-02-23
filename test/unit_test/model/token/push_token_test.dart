import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/push_token_rollout_state.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';

PushToken get pushToken => PushToken(
      serial: 'serial',
      expirationDate: DateTime(2017, 9, 7, 17, 30),
      label: 'label',
      issuer: 'issuer',
      id: 'id',
      sslVerify: true,
      enrollmentCredentials: 'enrollmentCredentials',
      url: Uri.parse('http://www.example.com'),
      publicServerKey: 'publicServerKey',
      publicTokenKey: 'publicTokenKey',
      privateTokenKey: 'privateTokenKey',
      isRolledOut: true,
      rolloutState: PushTokenRollOutState.rolloutNotStarted,
      sortIndex: 0,
      tokenImage: 'example.png',
      folderId: 0,
      isLocked: true,
      pin: true,
    );
void main() {
  _testPushToken();
}

void _testPushToken() {
  group('Push Token creation', () {
    test('constructor', () {
      expect(pushToken.serial, 'serial');
      expect(pushToken.expirationDate, DateTime(2017, 9, 7, 17, 30));
      expect(pushToken.label, 'label');
      expect(pushToken.issuer, 'issuer');
      expect(pushToken.id, 'id');
      expect(pushToken.sslVerify, true);
      expect(pushToken.enrollmentCredentials, 'enrollmentCredentials');
      expect(pushToken.url, Uri.parse('http://www.example.com'));
      expect(pushToken.publicServerKey, 'publicServerKey');
      expect(pushToken.publicTokenKey, 'publicTokenKey');
      expect(pushToken.privateTokenKey, 'privateTokenKey');
      expect(pushToken.isRolledOut, true);
      expect(pushToken.rolloutState, PushTokenRollOutState.rolloutNotStarted);
      expect(pushToken.type, 'PIPUSH');
      expect(pushToken.sortIndex, 0);
      expect(pushToken.tokenImage, 'example.png');
      expect(pushToken.folderId, 0);
      expect(pushToken.isLocked, true);
      expect(pushToken.pin, true);
    });
    test('copyWith', () {
      final copy = pushToken.copyWith(
        serial: 'serialCopy',
        expirationDate: DateTime(2016, 8, 6, 16, 29),
        label: 'labelCopy',
        issuer: 'issuerCopy',
        id: 'idCopy',
        sslVerify: false,
        enrollmentCredentials: 'enrollmentCredentialsCopy',
        url: Uri.parse('http://www.example.com/copy'),
        publicServerKey: 'publicServerKeyCopy',
        publicTokenKey: 'publicTokenKeyCopy',
        privateTokenKey: 'privateTokenKeyCopy',
        isRolledOut: false,
        rolloutState: PushTokenRollOutState.rolloutComplete,
        sortIndex: 1,
        tokenImage: 'exampleCopy.png',
        folderId: () => 1,
        isLocked: false,
        pin: false,
      );
      expect(copy.serial, 'serialCopy');
      expect(copy.expirationDate, DateTime(2016, 8, 6, 16, 29));
      expect(copy.label, 'labelCopy');
      expect(copy.issuer, 'issuerCopy');
      expect(copy.id, 'idCopy');
      expect(copy.sslVerify, false);
      expect(copy.enrollmentCredentials, 'enrollmentCredentialsCopy');
      expect(copy.url, Uri.parse('http://www.example.com/copy'));
      expect(copy.publicServerKey, 'publicServerKeyCopy');
      expect(copy.publicTokenKey, 'publicTokenKeyCopy');
      expect(copy.privateTokenKey, 'privateTokenKeyCopy');
      expect(copy.isRolledOut, false);
      expect(copy.rolloutState, PushTokenRollOutState.rolloutComplete);
      expect(copy.sortIndex, 1);
      expect(copy.tokenImage, 'exampleCopy.png');
      expect(copy.folderId, 1);
      expect(copy.isLocked, false);
      expect(copy.pin, false);
    });
  });
  group('serialization', () {
    test('fromJson', () {
      final json = <String, dynamic>{
        "label": "label",
        "issuer": "issuer",
        "id": "id",
        "isLocked": true,
        "pin": true,
        "tokenImage": "example.png",
        "folderId": 0,
        "sortIndex": 0,
        "type": "type",
        "expirationDate": "2017-09-07T17:30:00.000",
        "serial": "serial",
        "sslVerify": true,
        "enrollmentCredentials": "enrollmentCredentials",
        "url": "http://www.example.com",
        "isRolledOut": true,
        "rolloutState": "generatingRSAKeyPair",
        "publicServerKey": "publicServerKey",
        "privateTokenKey": "privateTokenKey",
        "publicTokenKey": "publicTokenKey",
      };
      final token = PushToken.fromJson(json);
      expect(token.label, 'label');
      expect(token.issuer, 'issuer');
      expect(token.id, 'id');
      expect(token.isLocked, true);
      expect(token.pin, true);
      expect(token.tokenImage, 'example.png');
      expect(token.folderId, 0);
      expect(token.sortIndex, 0);
      expect(token.type, 'PIPUSH');
      expect(token.expirationDate.toString(), DateTime(2017, 9, 7, 17, 30).toString());
      expect(token.serial, 'serial');
      expect(token.sslVerify, true);
      expect(token.enrollmentCredentials, 'enrollmentCredentials');
      expect(token.url, Uri.parse('http://www.example.com'));
      expect(token.isRolledOut, true);
      expect(token.rolloutState,
          PushTokenRollOutState.generatingRSAKeyPairFailed); // When loading from json, an processing state should be converted to a failed state.
      expect(token.publicServerKey, 'publicServerKey');
      expect(token.privateTokenKey, 'privateTokenKey');
      expect(token.publicTokenKey, 'publicTokenKey');
    });
    test('toJson', () {
      final tokenJson = pushToken.toJson();
      final json = <String, dynamic>{
        "checkedContainer": [],
        "containerSerial": null,
        "label": "label",
        "issuer": "issuer",
        "id": "id",
        "pin": true,
        "isLocked": true,
        "isHidden": false,
        "tokenImage": "example.png",
        "folderId": 0,
        "sortIndex": 0,
        "origin": null,
        "type": "PIPUSH",
        "expirationDate": "2017-09-07T17:30:00.000",
        "serial": "serial",
        "fbToken": null,
        "sslVerify": true,
        "enrollmentCredentials": "enrollmentCredentials",
        "url": "http://www.example.com",
        "isRolledOut": true,
        "rolloutState": "rolloutNotStarted",
        "publicServerKey": "publicServerKey",
        "privateTokenKey": "privateTokenKey",
        "publicTokenKey": "publicTokenKey"
      };
      for (final key in json.keys) {
        expect(tokenJson[key], json[key]);
      }
    });
    group('fromUriMap', () {
      test('with full map', () {
        final uriMap = <String, dynamic>{
          Token.TOKENTYPE_OTPAUTH: 'PIPUSH',
          Token.LABEL: 'label',
          Token.ISSUER: 'issuer',
          Token.SERIAL: 'serial',
          PushToken.SSL_VERIFY: 'False',
          PushToken.ENROLLMENT_CREDENTIAL: 'enrollmentCredentials',
          PushToken.ROLLOUT_URL: 'http://www.example.com',
          PushToken.TTL_MINUTES: '10',
          PushToken.VERSION: '1',
        };
        final token = PushToken.fromOtpAuthMap(uriMap);
        expect(token.type, 'PIPUSH');
        expect(token.label, 'label');
        expect(token.issuer, 'issuer');
        expect(token.serial, 'serial');
        expect(token.sslVerify, false);
        expect(token.enrollmentCredentials, 'enrollmentCredentials');
        expect(token.url, Uri.parse('http://www.example.com'));
      });
      test('with empty map', () {
        final uriMap = <String, dynamic>{};
        expect(() => PushToken.fromOtpAuthMap(uriMap), throwsA(isA<ArgumentError>()));
      });
    });

    test('toUriMap', () {
      final token = PushToken(
        serial: 'serial',
        expirationDate: DateTime(2017, 9, 7, 17, 30),
        label: 'label',
        issuer: 'issuer',
        id: 'id',
        sslVerify: true,
        enrollmentCredentials: 'enrollmentCredentials',
        url: Uri.parse('http://www.example.com'),
        publicServerKey: 'publicServerKey',
        publicTokenKey: 'publicTokenKey',
        privateTokenKey: 'privateTokenKey',
        isRolledOut: true,
        rolloutState: PushTokenRollOutState.rolloutNotStarted,
        sortIndex: 0,
        tokenImage: 'example.png',
        folderId: 0,
        isLocked: true,
        pin: true,
      );
      final uriMap = token.toOtpAuthMap();
      expect(uriMap[Token.TOKENTYPE_OTPAUTH], 'PIPUSH');
      expect(uriMap[Token.LABEL], 'label');
      expect(uriMap[Token.ISSUER], 'issuer');
      expect(uriMap[Token.SERIAL], 'serial');
      expect(uriMap[PushToken.SSL_VERIFY], '1');
      expect(uriMap[PushToken.ENROLLMENT_CREDENTIAL], 'enrollmentCredentials');
      expect(uriMap[PushToken.ROLLOUT_URL], 'http://www.example.com');
      expect(uriMap[PushToken.VERSION], '1');
    });
    test('fromJson', () {
      final json = {
        'label': 'label',
        'issuer': 'issuer',
        'id': 'id',
        'isLocked': true,
        'pin': true,
        'tokenImage': 'example.png',
        'folderId': 0,
        'sortIndex': 0,
        'type': 'PIPUSH',
        'expirationDate': '2017-09-07T17:30:00.000',
        'serial': 'serial',
        'sslVerify': true,
        'enrollmentCredentials': 'enrollmentCredentials',
        'url': 'http://www.example.com',
        'isRolledOut': true,
        'rolloutState': 'generatingRSAKeyPair',
        'publicServerKey': 'publicServerKey',
        'privateTokenKey': 'privateTokenKey',
        'publicTokenKey': 'publicTokenKey',
      };
      final token = PushToken.fromJson(json);
      expect(token.label, 'label');
      expect(token.issuer, 'issuer');
      expect(token.id, 'id');
      expect(token.isLocked, true);
      expect(token.pin, true);
      expect(token.tokenImage, 'example.png');
      expect(token.folderId, 0);
      expect(token.sortIndex, 0);
      expect(token.type, 'PIPUSH');
      expect(token.expirationDate.toString(), DateTime(2017, 9, 7, 17, 30).toString());
      expect(token.serial, 'serial');
      expect(token.sslVerify, true);
      expect(token.enrollmentCredentials, 'enrollmentCredentials');
      expect(token.url, Uri.parse('http://www.example.com'));
      expect(token.isRolledOut, true);
      expect(token.rolloutState,
          PushTokenRollOutState.generatingRSAKeyPairFailed); // When loading from json, an processing state should be converted to a failed state.
      expect(token.publicServerKey, 'publicServerKey');
      expect(token.privateTokenKey, 'privateTokenKey');
      expect(token.publicTokenKey, 'publicTokenKey');
    });
    test('toJson', () {
      final tokenJson = pushToken.toJson();
      final json = {
        "checkedContainer": [],
        "containerSerial": null,
        "label": "label",
        "issuer": "issuer",
        "id": "id",
        "pin": true,
        "isLocked": true,
        "isHidden": false,
        "tokenImage": "example.png",
        "folderId": 0,
        "sortIndex": 0,
        "origin": null,
        "type": "PIPUSH",
        "expirationDate": "2017-09-07T17:30:00.000",
        "serial": "serial",
        "fbToken": null,
        "sslVerify": true,
        "enrollmentCredentials": "enrollmentCredentials",
        "url": "http://www.example.com",
        "isRolledOut": true,
        "rolloutState": "rolloutNotStarted",
        "publicServerKey": "publicServerKey",
        "privateTokenKey": "privateTokenKey",
        "publicTokenKey": "publicTokenKey"
      };
      for (final key in json.keys) {
        expect(tokenJson[key], json[key]);
      }
    });
  });
  group('isSameTokenAs', () {
    test('same serial | different id | different parameters', () {
      // Different id, different parameters. Should recognize by serial
      final pushToken = PushToken(
        serial: 'serial',
        id: 'id',
        privateTokenKey: 'privateTokenKey',
      );

      expect(pushToken.isSameTokenAs(pushToken.copyWith(id: 'id2', privateTokenKey: 'privateTokenKey2')), true);
    });
    test('different serial | same id | different parameters', () {
      // Different serial, different parameters. Should recognize by id
      final pushToken = PushToken(
        serial: 'serial',
        id: 'id',
        privateTokenKey: 'privateTokenKey',
      );

      expect(pushToken.isSameTokenAs(pushToken.copyWith(serial: 'serial2', privateTokenKey: 'privateTokenKey2')), true);
    });
    test('different serial | different id | same parameters', () {
      // Different serial, different id. Should NOT recognize by parameters
      final pushToken = PushToken(
        serial: 'serial',
        id: 'id',
        privateTokenKey: 'privateTokenKey',
      );

      expect(pushToken.isSameTokenAs(pushToken.copyWith(serial: 'serial2', id: 'id2')), false);
    });
  });
}
