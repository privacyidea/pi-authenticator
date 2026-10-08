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

/// Tests for the dispatch of [PushRequestFactory], from the data of an incoming
/// push message (`fromMessageData`) and from the stored json (`fromJson`).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/push_request/decline_reason.dart';
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart';

/// The fields every push message carries.
Map<String, dynamic> baseData({String nonce = 'nonce-1'}) => {
  'title': 'Login',
  'question': 'Do you want to login?',
  'url': 'https://example.com/ttype/push',
  'nonce': nonce,
  'sslverify': '1',
  'serial': 'PIPU0001',
  'signature': 'MZXW6YTB',
};

void main() {
  group('PushRequestFactory.fromMessageData', () {
    test('a message without extra fields is a PushDefaultRequest', () {
      final request = PushRequestFactory.fromMessageData(baseData());

      expect(request, isA<PushDefaultRequest>());
      expect(request, isNot(isA<PushChoiceRequest>()));
      expect(request.runtimeType, PushDefaultRequest);
      expect(request.type, PushDefaultRequest.TYPE);
    });

    test('the fields of the message end up in the request', () {
      final before = DateTime.now();
      final request = PushRequestFactory.fromMessageData(baseData());
      final after = DateTime.now();

      expect(request.title, 'Login');
      expect(request.question, 'Do you want to login?');
      expect(request.uri, Uri.parse('https://example.com/ttype/push'));
      expect(request.nonce, 'nonce-1');
      expect(request.serial, 'PIPU0001');
      expect(request.signature, 'MZXW6YTB');
      expect(request.sslVerify, isTrue);
      expect(request.signedCapabilities, isNull);
      expect(request.accepted, isNull);
      expect(request.declineReason, isNull);
      // "expirationDate: now + 2 minutes"
      expect(
        request.expirationDate.isBefore(before.add(const Duration(minutes: 2))),
        isFalse,
      );
      expect(
        request.expirationDate.isAfter(after.add(const Duration(minutes: 2))),
        isFalse,
      );
    });

    test('require_presence makes it a PushChoiceRequest', () {
      final request = PushRequestFactory.fromMessageData({
        ...baseData(),
        'require_presence': '12,34,56',
        'version': '2',
      });

      expect(request, isA<PushChoiceRequest>());
      expect(request.type, PushChoiceRequest.TYPE);
      expect((request as PushChoiceRequest).possibleAnswers, [
        '12',
        '34',
        '56',
      ]);
      expect(request.selectedAnswer, isNull);
    });

    test('display_code makes it a PushCodeToPhoneRequest', () {
      final request = PushRequestFactory.fromMessageData({
        ...baseData(),
        'display_code': '123456',
      });

      expect(request, isA<PushCodeToPhoneRequest>());
      expect(request.type, PushCodeToPhoneRequest.TYPE);
      expect((request as PushCodeToPhoneRequest).displayCode, '123456');
    });

    test('a single require_presence answer is a choice with one answer', () {
      final request =
          PushRequestFactory.fromMessageData({
                ...baseData(),
                'require_presence': '7',
              })
              as PushChoiceRequest;

      expect(request.possibleAnswers, ['7']);
    });

    test('if both are present, require_presence wins over display_code', () {
      // The order of the checks in the factory decides, choice comes first.
      // The signature of the server only covers one of the two, so the other
      // interpretation could never verify anyway.
      final request = PushRequestFactory.fromMessageData({
        ...baseData(),
        'require_presence': '1,2,3',
        'display_code': '123456',
      });

      expect(request, isA<PushChoiceRequest>());
      expect(request, isNot(isA<PushCodeToPhoneRequest>()));
      expect(request.signedData, endsWith('|1,2,3'));
      expect(request.signedData, isNot(contains('123456')));
    });

    test('an empty require_presence is a choice with one empty answer', () {
      // Pins the current behaviour: the key only has to be a String. A server
      // that does not want presence options leaves the key out, so this does
      // not happen with the privacyIDEA server.
      final request = PushRequestFactory.fromMessageData({
        ...baseData(),
        'require_presence': '',
      });

      expect(request, isA<PushChoiceRequest>());
      expect((request as PushChoiceRequest).possibleAnswers, ['']);
      // The signed data is still self consistent: the server would sign the
      // trailing separator the same way.
      expect(request.signedData, endsWith('|1|'));
    });

    test('an empty display_code is still a PushCodeToPhoneRequest', () {
      final request = PushRequestFactory.fromMessageData({
        ...baseData(),
        'display_code': '',
      });

      expect(request, isA<PushCodeToPhoneRequest>());
      expect((request as PushCodeToPhoneRequest).displayCode, isEmpty);
    });

    test('a require_presence that is not a String is ignored', () {
      for (final value in <Object?>[
        ['1', '2'],
        12,
        true,
        null,
      ]) {
        final request = PushRequestFactory.fromMessageData({
          ...baseData(),
          'require_presence': value,
        });

        expect(
          request.runtimeType,
          PushDefaultRequest,
          reason: 'require_presence: $value',
        );
      }
    });

    test('a display_code that is not a String is ignored', () {
      for (final value in <Object?>[123456, true, null]) {
        final request = PushRequestFactory.fromMessageData({
          ...baseData(),
          'display_code': value,
        });

        expect(
          request.runtimeType,
          PushDefaultRequest,
          reason: 'display_code: $value',
        );
      }
    });

    test('unknown extra fields do not change the type', () {
      final request = PushRequestFactory.fromMessageData({
        ...baseData(),
        'type': 'something_new',
        'version': '3',
        'new_feature': 'x',
      });

      expect(request.runtimeType, PushDefaultRequest);
      // The `type` of the message is not taken over, the type of the request
      // is decided by the keys alone.
      expect(request.type, PushDefaultRequest.TYPE);
    });

    test('sslverify is only true for the string 1', () {
      bool sslVerifyOf(Object? value) => PushRequestFactory.fromMessageData({
        ...baseData(),
        'sslverify': value,
      }).sslVerify;

      // verifyMessageData requires a String, so only strings can get here.
      expect(sslVerifyOf('1'), isTrue);
      expect(sslVerifyOf('0'), isFalse);
      expect(sslVerifyOf('true'), isFalse);
      expect(sslVerifyOf(''), isFalse);
      expect(() => sslVerifyOf(1), throwsArgumentError);
    });

    test('capabilities of the message are attached to the request', () {
      final request = PushRequestFactory.fromMessageData({
        ...baseData(),
        'capabilities': '{"decline_reason":true}',
        'capabilities_signature': 'MZXW6YTB',
      });

      expect(request.signedCapabilities, isNotNull);
      expect(request.signedCapabilities!.signature, 'MZXW6YTB');
    });

    group('rejects data that no request type can handle', () {
      const requiredKeys = [
        'title',
        'question',
        'url',
        'nonce',
        'sslverify',
        'serial',
        'signature',
      ];

      for (final key in requiredKeys) {
        test('without $key', () {
          final data = baseData()..remove(key);

          expect(
            () => PushRequestFactory.fromMessageData(data),
            throwsArgumentError,
          );
        });

        test('with $key that is not a String', () {
          final data = baseData()..[key] = 42;

          expect(
            () => PushRequestFactory.fromMessageData(data),
            throwsArgumentError,
          );
        });
      }

      test('empty data', () {
        expect(
          () => PushRequestFactory.fromMessageData({}),
          throwsArgumentError,
        );
      });

      test('a url that is not a valid Uri', () {
        final data = baseData()..['url'] = 'http://[::1';

        expect(Uri.tryParse(data['url']), isNull);
        expect(
          () => PushRequestFactory.fromMessageData(data),
          throwsArgumentError,
        );
      });

      test('missing required keys are rejected even with extra fields', () {
        final data = baseData()
          ..remove('serial')
          ..['require_presence'] = '1,2'
          ..['display_code'] = '123456';

        expect(
          () => PushRequestFactory.fromMessageData(data),
          throwsArgumentError,
        );
      });

      test('the message is part of the error', () {
        expect(
          () => PushRequestFactory.fromMessageData({'nonce': 'n'}),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Unsupported push request data'),
            ),
          ),
        );
      });
    });
  });

  group('PushRequestFactory.fromJson', () {
    final expirationDate = DateTime.utc(2026, 1, 1, 12);

    final requests = <PushRequest>[
      PushDefaultRequest(
        title: 'Login',
        question: 'Do you want to login?',
        nonce: 'nonce-d',
        serial: 'PIPU0001',
        signature: 'MZXW6YTB',
        expirationDate: expirationDate,
        uri: Uri.parse('https://example.com/ttype/push'),
        sslVerify: true,
        accepted: false,
        declineReason: DeclineReason.cancelled,
      ),
      PushChoiceRequest(
        title: 'Login',
        question: 'Do you want to login?',
        nonce: 'nonce-c',
        serial: 'PIPU0001',
        signature: 'MZXW6YTB',
        expirationDate: expirationDate,
        uri: Uri.parse('https://example.com/ttype/push'),
        sslVerify: false,
        possibleAnswers: const ['1', '2', '3'],
        selectedAnswer: '2',
        accepted: true,
      ),
      PushCodeToPhoneRequest(
        title: 'Login',
        question: 'Do you want to login?',
        nonce: 'nonce-p',
        serial: 'PIPU0001',
        signature: 'MZXW6YTB',
        expirationDate: expirationDate,
        uri: Uri.parse('https://example.com/ttype/push'),
        sslVerify: true,
        displayCode: '123456',
      ),
    ];

    for (final request in requests) {
      test('${request.runtimeType} survives a json round trip', () {
        final json = request.toJson();
        final restored = PushRequestFactory.fromJson(json);

        expect(json['type'], request.type);
        expect(restored.runtimeType, request.runtimeType);
        expect(restored.type, request.type);
        expect(restored.title, request.title);
        expect(restored.question, request.question);
        expect(restored.nonce, request.nonce);
        expect(restored.serial, request.serial);
        expect(restored.signature, request.signature);
        expect(restored.uri, request.uri);
        expect(restored.sslVerify, request.sslVerify);
        expect(restored.expirationDate, request.expirationDate);
        expect(restored.accepted, request.accepted);
        expect(restored.declineReason, request.declineReason);
        expect(restored.signedData, request.signedData);
      });

      test(
        '${request.runtimeType} is also restored by PushRequest.fromJson',
        () {
          final restored = PushRequest.fromJson(request.toJson());

          expect(restored.runtimeType, request.runtimeType);
          expect(restored.nonce, request.nonce);
        },
      );
    }

    test('subtype specific fields survive the round trip', () {
      final choice =
          PushRequestFactory.fromJson(requests[1].toJson())
              as PushChoiceRequest;
      final code =
          PushRequestFactory.fromJson(requests[2].toJson())
              as PushCodeToPhoneRequest;

      expect(choice.possibleAnswers, ['1', '2', '3']);
      expect(choice.selectedAnswer, '2');
      expect(code.displayCode, '123456');
    });

    test('an explicit type default is a PushDefaultRequest', () {
      final json = {...requests[0].toJson(), 'type': 'default'};

      expect(PushRequestFactory.fromJson(json).runtimeType, PushDefaultRequest);
    });

    group('type is missing, which is a request stored by an older version', () {
      Map<String, dynamic> withoutType() =>
          requests[0].toJson()..remove('type');

      test('a missing type is a PushDefaultRequest', () {
        final json = withoutType();

        expect(json.containsKey('type'), isFalse);
        final restored = PushRequestFactory.fromJson(json);

        expect(restored.runtimeType, PushDefaultRequest);
        expect(restored.type, PushDefaultRequest.TYPE);
        expect(restored.nonce, 'nonce-d');
      });

      test('a type that is null is a PushDefaultRequest', () {
        final json = withoutType()..['type'] = null;

        final restored = PushRequestFactory.fromJson(json);

        expect(restored.runtimeType, PushDefaultRequest);
        expect(restored.type, PushDefaultRequest.TYPE);
      });

      test(
        'the json of the app before the type was introduced is restored',
        () {
          // The model of version 4.7: it had an int id, answers inside the one
          // request class and no type.
          final legacy = <String, dynamic>{
            'title': 'Login',
            'question': 'Do you want to login?',
            'id': 'nonce-old'.hashCode,
            'uri': 'https://example.com/ttype/push',
            'nonce': 'nonce-old',
            'sslVerify': true,
            'expirationDate': expirationDate.toIso8601String(),
            'serial': 'PIPU0001',
            'signature': 'MZXW6YTB',
            'accepted': null,
            'possibleAnswers': null,
            'selectedAnswer': null,
          };

          final restored = PushRequestFactory.fromJson(legacy);

          expect(restored.runtimeType, PushDefaultRequest);
          expect(restored.nonce, 'nonce-old');
          // The id was derived from the nonce back then, too.
          expect(restored.id, legacy['id']);
        },
      );

      test(
        'answers of an old choice request are not restored (lossy but harmless, it expires after 2 minutes)',
        () {
          final legacy = <String, dynamic>{
            ...withoutType(),
            'possibleAnswers': ['1', '2', '3'],
          };

          final restored = PushRequestFactory.fromJson(legacy);

          expect(restored.runtimeType, PushDefaultRequest);
          expect(restored, isNot(isA<PushChoiceRequest>()));
        },
      );
    });

    group('type is unknown', () {
      for (final type in [
        'unknown',
        'Default',
        'CHOICE',
        '',
        'code-to-phone',
      ]) {
        test('"$type" is rejected', () {
          final json = {...requests[0].toJson(), 'type': type};

          expect(
            () => PushRequestFactory.fromJson(json),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                'Unsupported push request type: $type',
              ),
            ),
          );
        });
      }

      test('a type that is not a String is rejected', () {
        final json = {...requests[0].toJson(), 'type': 5};

        expect(
          () => PushRequestFactory.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });

      test('PushRequest.fromJson rejects it as well', () {
        final json = {...requests[0].toJson(), 'type': 'unknown'};

        expect(() => PushRequest.fromJson(json), throwsArgumentError);
      });
    });

    test('a subtype with missing data is not restored', () {
      final json = requests[1].toJson()..remove('possibleAnswers');

      expect(
        () => PushRequestFactory.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('PushRequestExtension.dynamicCopyWith (explicit extension call)', () {
    // PushRequest declares an abstract member of the same name, so a call on a
    // PushRequest always reaches the member of the subtype. The extension can
    // only be reached by applying it explicitly.
    final base = baseData();

    test('passes selectedAnswer on to a PushChoiceRequest', () {
      final choice =
          PushRequestFactory.fromMessageData({
                ...base,
                'require_presence': '1,2',
              })
              as PushChoiceRequest;

      final updated = PushRequestExtension(choice)
          .dynamicCopyWith<PushChoiceRequest>(
            accepted: () => true,
            selectedAnswer: '2',
          );

      expect(updated.accepted, isTrue);
      expect(updated.selectedAnswer, '2');
      expect(updated.nonce, choice.nonce);
    });

    test('ignores selectedAnswer for other requests', () {
      final request = PushRequestFactory.fromMessageData(base);

      final updated = PushRequestExtension(request)
          .dynamicCopyWith<PushDefaultRequest>(
            accepted: () => false,
            selectedAnswer: '2',
          );

      expect(updated.runtimeType, PushDefaultRequest);
      expect(updated.accepted, isFalse);
    });
  });
}
