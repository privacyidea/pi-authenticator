/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/api/impl/privacy_idea_container_api.dart';
import 'package:privacyidea_authenticator/model/container_policies.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/enums/sync_state.dart';
import 'package:privacyidea_authenticator/model/exception_errors/error_codes.dart';
import 'package:privacyidea_authenticator/model/exception_errors/pi_server_result_error.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';

import '../../tests_app_wrapper.mocks.dart';

const _privateClientKey =
    "-----BEGIN EC PRIVATE KEY-----\n"
    "MIGkAgEBBDCleRofxXJwTtc0HUeE/Af8P4depFM0KY7oT4hMQdt3geK5uDWEOZn4\n"
    "DaCMTGrsSP2gBwYFK4EEACKhZANiAATxezSrY8++QiUpNxCQzEwOe//i0fd0OqCU\n"
    "rjZoc3XWhP7AkOfXVwYnlvm667ajB94+A0POVPCErcG/HbHk0Gb8lbO1Q5pYjb3N\n"
    "3ATXIlK0HJJqETYIgZ8pzVF9wBKnn/g=\n"
    "-----END EC PRIVATE KEY-----";
const _publicClientKey =
    "-----BEGIN PUBLIC KEY-----\n"
    "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAE8Xs0q2PPvkIlKTcQkMxMDnv/4tH3dDqg\n"
    "lK42aHN11oT+wJDn11cGJ5b5uuu2owfePgNDzlTwhK3Bvx2x5NBm/JWztUOaWI29\n"
    "zdwE1yJStBySahE2CIGfKc1RfcASp5/4\n"
    "-----END PUBLIC KEY-----";

TokenContainerFinalized _container() => TokenContainerFinalized(
  issuer: 'privacyIDEA',
  nonce: 'b33d3a11c8d1b45f19640035e27944ccf0b2383d',
  timestamp: DateTime(2024, 12, 6, 11, 14, 26, 885, 409),
  serverUrl: Uri.parse('http://example.com'),
  serial: 'SMPH00067A2F',
  ecKeyAlgorithm: EcKeyAlgorithm.secp384r1,
  hashAlgorithm: Algorithms.SHA256,
  sslVerify: false,
  publicClientKey: _publicClientKey,
  privateClientKey: _privateClientKey,
  policies: ContainerPolicies(
    rolloverAllowed: true,
    initialTokenAssignment: true,
    disabledTokenDeletion: false,
    disabledUnregister: false,
  ),
  syncState: SyncState.completed,
  serverName: 'privacyIDEA',
);

String _challengeJson() => jsonEncode({
  'id': 5,
  'jsonrpc': '2.0',
  'result': {
    'status': true,
    'value': {
      'enc_key_algorithm': 'secp384r1',
      'nonce': 'b33d3a11c8d1b45f19640035e27944ccf0b2383d',
      'time_stamp': '2024-12-06T11:14:26.885409+00:00',
    },
  },
  'time': 1.0,
  'version': 'privacyIDEA 3.6.2',
  'versionnumber': '3.6.2',
  'detail': null,
  'signature': 'signature',
});

String _errorJson(int code, String message) => jsonEncode({
  'id': 5,
  'jsonrpc': '2.0',
  'result': {
    'status': false,
    'error': {'message': message, 'code': code},
  },
  'time': 1.0,
  'version': 'privacyIDEA 3.6.2',
  'versionnumber': '3.6.2',
  'detail': null,
  'signature': 'signature',
});

/// Answers the challenge request with a valid challenge (unless
/// [challengeResponse] is given) and every other request with [actionResponse].
MockPrivacyideaIOClient _clientWith(
  Response actionResponse, {
  Response? challengeResponse,
}) {
  final mockIoClient = MockPrivacyideaIOClient();
  when(
    mockIoClient.doPost(
      url: anyNamed('url'),
      body: anyNamed('body'),
      sslVerify: anyNamed('sslVerify'),
      expectedErrorStatusCodes: anyNamed('expectedErrorStatusCodes'),
    ),
  ).thenAnswer((invocation) async {
    final url = invocation.namedArguments[const Symbol('url')] as Uri;
    if (url.path == '/container/challenge') {
      return challengeResponse ?? Response(_challengeJson(), 200);
    }
    return actionResponse;
  });
  return mockIoClient;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PiContainerApi reports server errors as PiServerResultError', () {
    test(
      'getRolloverQrData: non-JSON 200 body throws PiServerResultError (jsonParseError)',
      () async {
        final api = PiContainerApi(
          ioClient: _clientWith(Response('Bad Gateway', 200)),
        );
        await expectLater(
          api.getRolloverQrData(_container()),
          throwsA(
            isA<PiServerResultError>()
                .having((e) => e.code, 'code', InAppErrorCodes.jsonParseError)
                .having((e) => e.message, 'message', 'Bad Gateway'),
          ),
        );
      },
    );

    test(
      'getRolloverQrData: empty 502 body throws PiServerResultError, not a null check error',
      () async {
        final api = PiContainerApi(ioClient: _clientWith(Response('', 502)));
        await expectLater(
          api.getRolloverQrData(_container()),
          throwsA(
            isA<PiServerResultError>().having(
              (e) => e.message,
              'message',
              'Empty response body (HTTP 502)',
            ),
          ),
        );
      },
    );

    test(
      'getRolloverQrData: privacyIDEA error JSON throws the server error code',
      () async {
        final api = PiContainerApi(
          ioClient: _clientWith(
            Response(_errorJson(3000, 'Rollover denied'), 200),
          ),
        );
        await expectLater(
          api.getRolloverQrData(_container()),
          throwsA(
            isA<PiServerResultError>()
                .having((e) => e.code, 'code', 3000)
                .having((e) => e.message, 'message', 'Rollover denied'),
          ),
        );
      },
    );

    test(
      'unregister: non-JSON body after challenge throws PiServerResultError',
      () async {
        final api = PiContainerApi(
          ioClient: _clientWith(Response('<html>oops</html>', 200)),
        );
        await expectLater(
          api.unregister(_container()),
          throwsA(
            isA<PiServerResultError>()
                .having((e) => e.code, 'code', InAppErrorCodes.jsonParseError)
                .having(
                  (e) => e.message,
                  'message',
                  'Invalid server response (HTTP 200)',
                ),
          ),
        );
      },
    );

    test(
      'unregister: server error JSON with HTTP 200 throws the server error',
      () async {
        final api = PiContainerApi(
          ioClient: _clientWith(Response(_errorJson(3001, 'Nope'), 200)),
        );
        await expectLater(
          api.unregister(_container()),
          throwsA(
            isA<PiServerResultError>().having((e) => e.code, 'code', 3001),
          ),
        );
      },
    );
  });

  group('PiContainerApi challenge request', () {
    test('passes notFound as expected error status code', () async {
      final mockIoClient = _clientWith(
        Response('', 200),
        challengeResponse: Response(_errorJson(3002, 'Gone'), 404),
      );
      final api = PiContainerApi(ioClient: mockIoClient);
      await expectLater(
        api.getRolloverQrData(_container()),
        throwsA(isA<PiServerResultError>()),
      );
      final captured = verify(
        mockIoClient.doPost(
          url: anyNamed('url'),
          body: anyNamed('body'),
          sslVerify: anyNamed('sslVerify'),
          expectedErrorStatusCodes: captureAnyNamed('expectedErrorStatusCodes'),
        ),
      ).captured;
      expect(captured.first as Set<int>, contains(404));
    });

    test(
      '404 with privacyIDEA error JSON yields the server error code',
      () async {
        final api = PiContainerApi(
          ioClient: _clientWith(
            Response('', 200),
            challengeResponse: Response(_errorJson(3002, 'Gone'), 404),
          ),
        );
        await expectLater(
          api.getRolloverQrData(_container()),
          throwsA(
            isA<PiServerResultError>()
                .having((e) => e.code, 'code', 3002)
                .having((e) => e.message, 'message', 'Gone'),
          ),
        );
      },
    );

    test('404 with non-JSON body yields resourceNotFound', () async {
      final api = PiContainerApi(
        ioClient: _clientWith(
          Response('', 200),
          challengeResponse: Response('Not Found', 404),
        ),
      );
      await expectLater(
        api.getRolloverQrData(_container()),
        throwsA(
          isA<PiServerResultError>().having(
            (e) => e.code,
            'code',
            PiServerResultErrorCodes.resourceNotFound,
          ),
        ),
      );
    });
  });
}
