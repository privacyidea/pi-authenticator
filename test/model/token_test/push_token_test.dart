import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/push_request_queue.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/custom_int_buffer.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';

void main() {
  _testPushToken();
}

void _testPushToken() {
  group('Push Token creation/method', () {
    final pr = PushRequest(
      title: 'title',
      question: 'question',
      uri: Uri.parse('http://www.example.com'),
      nonce: 'nonce',
      sslVerify: false,
      id: 0,
      expirationDate: DateTime(2017, 9, 7, 17, 30),
    );
    final pushToken = PushToken(
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
      pushRequests: PushRequestQueue(),
      knownPushRequests: CustomIntBuffer(),
      type: 'type',
      sortIndex: 0,
      tokenImage: 'example.png',
      folderId: 0,
      isLocked: true,
      pin: true,
    );
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
      expect(pushToken.pushRequests, PushRequestQueue());
      expect(pushToken.knownPushRequests.list, CustomIntBuffer().list);
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
        pushRequests: PushRequestQueue()..add(pr),
        knownPushRequests: CustomIntBuffer()..put(0),
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
      expect(copy.label, 'idCopy');
      expect(copy.sslVerify, false);
      expect(copy.enrollmentCredentials, 'enrollmentCredentialsCopy');
      expect(copy.url, Uri.parse('http://www.example.com/copy'));
      expect(copy.publicServerKey, 'publicServerKeyCopy');
      expect(copy.publicTokenKey, 'publicTokenKeyCopy');
      expect(copy.privateTokenKey, 'privateTokenKeyCopy');
      expect(copy.isRolledOut, false);
      expect(copy.rolloutState, PushTokenRollOutState.rolloutComplete);
      expect(copy.pushRequests.list, [pr]);
      expect(copy.knownPushRequests.list, [0]);
      expect(copy.sortIndex, 1);
      expect(copy.tokenImage, 'exampleCopy.png');
      expect(copy.folderId, 1);
      expect(copy.isLocked, false);
      expect(copy.pin, false);
    });
    test('withPushRequest', () {
      final tokenWithPr = PushToken(
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
        pushRequests: PushRequestQueue(),
        knownPushRequests: CustomIntBuffer(),
        type: 'type',
        sortIndex: 0,
        tokenImage: 'example.png',
        folderId: 0,
        isLocked: true,
        pin: true,
      ).withPushRequest(pr);
      expect(tokenWithPr.pushRequests.list, [pr]);
      expect(tokenWithPr.knownPushRequests.list, [0]);
    });
    test('withoutPushrequest', () {
      final tokenWithPr = PushToken(
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
        pushRequests: PushRequestQueue()..add(pr),
        knownPushRequests: CustomIntBuffer()..put(0),
        type: 'type',
        sortIndex: 0,
        tokenImage: 'example.png',
        folderId: 0,
        isLocked: true,
        pin: true,
      );
      final tokenWithoutPr = tokenWithPr.withoutPushRequest(pr);
      expect(tokenWithoutPr.pushRequests.list, []);
      expect(tokenWithoutPr.knownPushRequests.list, [0]);
    });
    test('knowsRequestWithId', () {
      final tokenWithPr = PushToken(
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
        pushRequests: PushRequestQueue()..add(pr),
        knownPushRequests: CustomIntBuffer()..put(0),
        type: 'type',
        sortIndex: 0,
        tokenImage: 'example.png',
        folderId: 0,
        isLocked: true,
        pin: true,
      );
      expect(tokenWithPr.knowsRequestWithId(0), true);
    });
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
        "pushRequests": {"list": []},
        "knownPushRequests": {"list": []}
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
          PushTokenRollOutState.generateingRSAKeyPairFailed); // When loading from json, an processing state should be converted to a failed state.
      expect(token.publicServerKey, 'publicServerKey');
      expect(token.privateTokenKey, 'privateTokenKey');
      expect(token.publicTokenKey, 'publicTokenKey');
      expect(token.pushRequests.list, []);
      expect(token.knownPushRequests.list, []);
    });
    test('toJson', () {
      final tokenJson = pushToken.toJson();
      final json = <String, dynamic>{
        "label": "label",
        "issuer": "issuer",
        "id": "id",
        "isLocked": true,
        "pin": true,
        "tokenImage": "example.png",
        "folderId": 0,
        "sortIndex": 0,
        "type": "PIPUSH",
        "expirationDate": "2017-09-07T17:30:00.000",
        "serial": "serial",
        "sslVerify": true,
        "enrollmentCredentials": "enrollmentCredentials",
        "url": "http://www.example.com",
        "isRolledOut": true,
        "rolloutState": "rolloutNotStarted",
        "publicServerKey": "publicServerKey",
        "privateTokenKey": "privateTokenKey",
        "publicTokenKey": "publicTokenKey",
        "pushRequests": {"list": []},
        "knownPushRequests": {"list": []}
      };
      expect(jsonEncode(tokenJson), jsonEncode(json));
    });
    group('fromUriMap', () {
      test('with full map', () {
        final uriMap = <String, dynamic>{
          'URI_TYPE': 'PIPUSH',
          'URI_LABEL': 'label',
          'URI_ISSUER': 'issuer',
          'URI_SERIAL': 'serial',
          'URI_SSL_VERIFY': false,
          'URI_ENROLLMENT_CREDENTIALS': 'enrollmentCredentials',
          'URI_ROLLOUT_URL': Uri.parse('http://www.example.com'),
          'URI_TTL': 10,
        };
        final token = PushToken.fromUriMap(uriMap);
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
        expect(PushToken.fromUriMap(uriMap), isA<PushToken>());
      });
    });
  });
}
