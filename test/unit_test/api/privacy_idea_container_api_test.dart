/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/api/impl/privacy_idea_container_api.dart';
import 'package:privacyidea_authenticator/model/container_policies.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/enums/rollout_state.dart';
import 'package:privacyidea_authenticator/model/enums/sync_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:test/test.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  _testPrivacyIdeaContainerApi();
}

void _testPrivacyIdeaContainerApi() {
  final exampleError = {
    'id': 5,
    'jsonrpc': '2.0',
    'result': {
      'status': false,
      'error': {
        'message': 'Error message',
        'code': 400,
      },
    },
    'time': 1.0,
    'version': 'privacyIDEA 3.6.2',
    'versionnumber': '3.6.2',
    'detail': null,
    'signature': 'signature',
  };

  final containerChallengeNonce = 'b33d3a11c8d1b45f19640035e27944ccf0b2383d';
  final containerChallengeTimeStamp = '2024-12-06T11:14:26.885409+00:00';
  final containerChallengeResponse = Response(
    jsonEncode({
      'id': 5,
      'jsonrpc': '2.0',
      'result': {
        'status': true,
        'value': {
          'enc_key_algorithm': 'secp384r1',
          'nonce': 'b33d3a11c8d1b45f19640035e27944ccf0b2383d',
          'time_stamp': '2024-12-06T11:14:26.885409+00:00',
        }
      },
      'time': 1.0,
      'version': 'privacyIDEA 3.6.2',
      'versionnumber': '3.6.2',
      'detail': null,
      'signature': 'signature',
    }),
    200,
  );

  final publicServerKey = '-----BEGIN PUBLIC KEY-----\n'
      'MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEr5dFYneCv+m3a8oRjp7vdDslT+VPiLVW\n'
      'apxWTv1vf/LLmwfRAcmwTzFHDrHS77yVU2Sa4h9UEicIbpkSZKla7EAQYosCsvl7\n'
      '/3wxx9pCWKZm+dygmKARfmzVoZ2KsYgG\n'
      '-----END PUBLIC KEY-----';
  final privateClientKey = '-----BEGIN EC PRIVATE KEY-----\n'
      'MIGkAgEBBDDK5sxOyduuSYwxwHFbAOcFZP2LHh/x5fi/Z6jENzXoKHEVWUNh3wqa\n'
      '8Y5f7iNN7c6gBwYFK4EEACKhZANiAAR8ZnmJ78AaRXcLmKbXSwXqieo2Wr0vq6MV\n'
      'siFdT04cydzB51P6kMU7QuRjSVMI/2/NuP1pw8UWKMkuEo5Znmqs+A9Sva+jUL8o\n'
      'U2V+vfX0bMjKhlBLBhOtn6jcQWQ/B/s=\n'
      '-----END EC PRIVATE KEY-----';

  final publicClientKey = '-----BEGIN PUBLIC KEY-----\n'
      'MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEfGZ5ie/AGkV3C5im10sF6onqNlq9L6uj\n'
      'FbIhXU9OHMncwedT+pDFO0LkY0lTCP9vzbj9acPFFijJLhKOWZ5qrPgPUr2vo1C/\n'
      'KFNlfr319GzIyoZQSwYTrZ+o3EFkPwf7\n'
      '-----END PUBLIC KEY-----';

  TokenContainerUnfinalized getNewTokenContainer({
    String? withIssuer,
    String? withNonce,
    DateTime? withTimestamp,
    Uri? withServerUrl,
    String? withSerial,
    EcKeyAlgorithm? withEcKeyAlgorithm,
    Algorithms? withHashAlgorithm,
    bool? withSslVerify,
    String? withPassphraseQuestion,
    String? withPublicServerKey,
    String? withPublicClientKey,
    String? withPrivateClientKey,
    ContainerPolicies? withPolicies,
    SyncState? withSyncState,
    String? withServerName,
    Duration? withTtl,
    bool? addDeviceInfos,
    FinalizationState? withFinalizationState,
  }) =>
      TokenContainerUnfinalized(
        issuer: withIssuer ?? 'privacyIDEA',
        nonce: withNonce ?? 'b33d3a11c8d1b45f19640035e27944ccf0b2383d',
        timestamp: withTimestamp ?? DateTime(2024, 12, 6, 11, 14, 26, 885, 409),
        serverUrl: withServerUrl ?? Uri.parse('http://example.com'),
        serial: withSerial ?? 'SMPH00067A2F',
        ecKeyAlgorithm: withEcKeyAlgorithm ?? EcKeyAlgorithm.secp384r1,
        hashAlgorithm: withHashAlgorithm ?? Algorithms.SHA256,
        sslVerify: withSslVerify ?? false,
        passphraseQuestion: withPassphraseQuestion,
        publicServerKey: publicServerKey,
        publicClientKey: publicClientKey,
        privateClientKey: privateClientKey,
        policies: withPolicies ??
            ContainerPolicies(
              rolloverAllowed: true,
              initialTokenTransfer: true,
              tokensDeletable: true,
              unregisterAllowed: true,
            ),
        serverName: withServerName ?? 'privacyIDEA',
        ttl: withTtl ?? Duration(minutes: 10),
        addDeviceInfos: addDeviceInfos ?? false,
        finalizationState: withFinalizationState ?? FinalizationState.notStarted,
      );

  TokenContainerFinalized getFinalizedTokenContainer({
    String? withIssuer,
    String? withNonce,
    DateTime? withTimestamp,
    Uri? withServerUrl,
    String? withSerial,
    EcKeyAlgorithm? withEcKeyAlgorithm,
    Algorithms? withHashAlgorithm,
    bool? withSslVerify,
    String? withPassphraseQuestion,
    String? withPublicServerKey,
    String? withPublicClientKey,
    String? withPrivateClientKey,
    ContainerPolicies? withPolicies,
    SyncState? withSyncState,
    String? withServerName,
  }) =>
      TokenContainerFinalized(
        issuer: withIssuer ?? 'privacyIDEA',
        nonce: withNonce ?? 'b33d3a11c8d1b45f19640035e27944ccf0b2383d',
        timestamp: withTimestamp ?? DateTime(2024, 12, 6, 11, 14, 26, 885, 409),
        serverUrl: withServerUrl ?? Uri.parse('http://example.com'),
        serial: withSerial ?? 'SMPH00067A2F',
        ecKeyAlgorithm: withEcKeyAlgorithm ?? EcKeyAlgorithm.secp384r1,
        hashAlgorithm: withHashAlgorithm ?? Algorithms.SHA256,
        sslVerify: withSslVerify ?? false,
        passphraseQuestion: withPassphraseQuestion,
        publicServerKey: publicServerKey,
        publicClientKey: publicClientKey,
        privateClientKey: privateClientKey,
        policies: withPolicies ??
            ContainerPolicies(
              rolloverAllowed: true,
              initialTokenTransfer: true,
              tokensDeletable: true,
              unregisterAllowed: true,
            ),
        syncState: withSyncState ?? SyncState.completed,
        serverName: withServerName ?? 'privacyIDEA',
      );
  group('PrivacyIdeaContainerApi', () {
    test('finalizeContainer', () async {
      final tokenContainer = getNewTokenContainer();

      final message = '${tokenContainer.nonce}'
          '|${tokenContainer.timestamp.toIso8601String().replaceFirst('Z', '+00:00')}'
          '|${tokenContainer.serial}'
          '|${tokenContainer.registrationUrl}';

      final EccUtils eccUtils = EccUtils();
      final signature = eccUtils.signWithPrivateKey(tokenContainer.ecPrivateClientKey!, message);
      final body = {
        'container_serial': tokenContainer.serial,
        'public_client_key': tokenContainer.publicClientKey,
        'signature': signature,
      };

      // Arrange
      final mockIoClient = MockPrivacyideaIOClient();
      final containerApi = PiContainerApi(ioClient: mockIoClient);
      when(mockIoClient.doPost(url: anyNamed('url'), body: anyNamed('body'), sslVerify: anyNamed('sslVerify'))).thenAnswer((invocation) async {
        final invocationUrl = invocation.namedArguments[Symbol('url')];
        final invocationBody = invocation.namedArguments[Symbol('body')];
        Logger.info('Body: $invocationBody');
        if (invocationUrl.toString() == tokenContainer.registrationUrl.toString() &&
            invocationBody['container_serial'] == body['container_serial'] &&
            invocationBody['public_client_key'] == body['public_client_key'] &&
            eccUtils.validateSignature(tokenContainer.ecPublicClientKey!, invocationBody['signature'], message)) {
          final exampleSuccess = {
            'id': 5,
            'jsonrpc': '2.0',
            'result': {
              'status': true,
              'value': {
                'public_server_key': publicServerKey,
                'policies': {
                  'container_client_rollover': false,
                  'container_initial_token_transfer': false,
                  'client_token_deletable': true,
                  'client_container_unregister': true,
                },
              },
            },
            'time': 1.0,
            'version': 'privacyIDEA 3.6.2',
            'versionnumber': '3.6.2',
            'detail': null,
            'signature': 'signature',
          };

          return Response(jsonEncode(exampleSuccess), 200);
        }

        final exampleError = {
          'id': 5,
          'jsonrpc': '2.0',
          'result': {
            'status': false,
            'error': {
              'message': 'Error message',
              'code': 400,
            },
          },
          'time': 1.0,
          'version': 'privacyIDEA 3.6.2',
          'versionnumber': '3.6.2',
          'detail': null,
          'signature': 'signature',
        };

        return Response(jsonEncode(exampleError), 400);
      });
      // Act
      final data = await containerApi.finalizeContainer(tokenContainer, EccUtils());
      final policies = data.policies;
      final responsePublicServerKey = data.publicServerKey;
      // Assert
      expect(policies, isA<ContainerPolicies>());
      expect(policies.rolloverAllowed, false);
      expect(policies.initialTokenTransfer, false);
      expect(policies.tokensDeletable, true);
      expect(policies.unregisterAllowed, true);
      expect(eccUtils.serializeECPublicKey(responsePublicServerKey), publicServerKey);
    });
    test('getRolloverQrData', () async {
      // Arrange
      final qrCodeDescription = "This should be the data for the QR code";
      final qrCodeDataValue = "qrCodeDataValue";
      final mockIoClient = MockPrivacyideaIOClient();
      final containerApi = PiContainerApi(ioClient: mockIoClient);
      final tokenContainer = getFinalizedTokenContainer();
      when(mockIoClient.doPost(url: anyNamed('url'), body: anyNamed('body'), sslVerify: anyNamed('sslVerify'))).thenAnswer((invocation) async {
        final Uri invocationUrl = invocation.namedArguments[Symbol('url')];
        final Map<String, String?> invocationBody = invocation.namedArguments[Symbol('body')];
        Logger.info('Body: $invocationBody');

        if (invocationUrl.toString() == 'http://example.com/container/${tokenContainer.serial}/challenge' &&
            invocationBody['scope'] == 'http://example.com/container/${tokenContainer.serial}/rollover') {
          return containerChallengeResponse;
        }

        final signMessage = '$containerChallengeNonce|$containerChallengeTimeStamp|${tokenContainer.serial}|$invocationUrl';
        if (invocationUrl.toString() == 'http://example.com/container/${tokenContainer.serial}/rollover' &&
            invocationBody['scope'] == 'http://example.com/container/${tokenContainer.serial}/rollover' &&
            EccUtils().validateSignature(tokenContainer.ecPublicClientKey!, invocationBody['signature']!, signMessage)) {
          return Response(
            jsonEncode({
              'id': 5,
              'jsonrpc': '2.0',
              'result': {
                'status': true,
                'value': {
                  'container_url': {
                    'description': qrCodeDescription,
                    'value': qrCodeDataValue,
                  }
                }
              },
              'time': 1.0,
              'version': 'privacyIDEA 3.6.2',
              'versionnumber': '3.6.2',
              'detail': null,
              'signature': 'signature',
            }),
            200,
          );
        }

        return Response(jsonEncode(exampleError), 400);
      });
      // // Act
      final responseTransferQrData = await containerApi.getRolloverQrData(tokenContainer);
      // // Assert
      expect(responseTransferQrData.description, qrCodeDescription);
      expect(responseTransferQrData.value, qrCodeDataValue);
    });
    test('unregister', () async {
      // Arrange
      final mockIoClient = MockPrivacyideaIOClient();
      final containerApi = PiContainerApi(ioClient: mockIoClient);
      final tokenContainer = getFinalizedTokenContainer();

      when(mockIoClient.doPost(url: anyNamed('url'), body: anyNamed('body'), sslVerify: anyNamed('sslVerify'))).thenAnswer((invocation) async {
        final Uri invocationUrl = invocation.namedArguments[Symbol('url')];
        final Map<String, String?> invocationBody = invocation.namedArguments[Symbol('body')];
        Logger.info('Body: $invocationBody');
        if (invocationUrl.toString() == 'http://example.com/container/${tokenContainer.serial}/challenge' &&
            invocationBody['scope'] == 'http://example.com/container/register/${tokenContainer.serial}/terminate/client') {
          return containerChallengeResponse;
        }
        final signMessage = '$containerChallengeNonce|$containerChallengeTimeStamp|${tokenContainer.serial}|$invocationUrl';
        if (invocationUrl.toString() == 'http://example.com/container/register/${tokenContainer.serial}/terminate/client' &&
            invocationBody['scope'] == 'http://example.com/container/register/${tokenContainer.serial}/terminate/client' &&
            EccUtils().validateSignature(tokenContainer.ecPublicClientKey!, invocationBody['signature']!, signMessage)) {
          return Response(
            jsonEncode({
              'id': 5,
              'jsonrpc': '2.0',
              'result': {
                'status': true,
                'value': {
                  'success': true,
                }
              },
              'time': 1.0,
              'version': 'privacyIDEA 3.6.2',
              'versionnumber': '3.6.2',
              'detail': null,
              'signature': 'signature',
            }),
            200,
          );
        }
        return Response(jsonEncode(exampleError), 400);
      });

      // Act
      final result = await containerApi.unregister(tokenContainer);
      // Assert
      expect(result.success, true);
    });

    test('sync', () async {
      // Arrange
      final mockIoClient = MockPrivacyideaIOClient();
      final containerApi = PiContainerApi(ioClient: mockIoClient);
      final tokenContainer = getFinalizedTokenContainer();
      final tokenState = TokenState(
        tokens: [
          HOTPToken(label: "label1", issuer: "privacyIDEA", counter: 5, id: 'id1', algorithm: Algorithms.SHA1, digits: 6, secret: 'AAAAAAAA'),
        ],
      );
      when(mockIoClient.doPost(url: anyNamed('url'), body: anyNamed('body'), sslVerify: anyNamed('sslVerify'))).thenAnswer((invocation) async {
        final Uri invocationUrl = invocation.namedArguments[Symbol('url')];
        final Map<String, String?> invocationBody = invocation.namedArguments[Symbol('body')];
        Logger.info('Body: $invocationBody');
        if (invocationUrl.toString() == 'http://example.com/container/${tokenContainer.serial}/challenge' &&
            invocationBody['scope'] == 'http://example.com/container/${tokenContainer.serial}/sync') {
          return containerChallengeResponse;
        }
        final publicEncKeyClientB64 = invocationBody['public_enc_key_client'];
        final containerDictClient =
            '{"serial":"SMPH00067A2F","type":"smartphone","tokens":[{"type":"HOTP","label":"label1","issuer":"privacyIDEA","pin":"False","algorithm":"SHA1","digits":"6","otp":["435986","964213"],"counter":"5"}]}';
        final signMessage =
            '$containerChallengeNonce|$containerChallengeTimeStamp|${tokenContainer.serial}|$invocationUrl|$publicEncKeyClientB64|$containerDictClient}';
        final publicEncKeyClientuint8list = base64.decode(publicEncKeyClientB64!);

        //    final encKeyPair = await X25519().newKeyPair();
        final crypto.SimplePublicKey publicEncKeyClient = crypto.SimplePublicKey(publicEncKeyClientuint8list, type: crypto.KeyPairType.x25519);
        final signature = invocationBody['signature']!;
        final isVeryfied = await crypto.Ed25519().verify(
          utf8.encode(signMessage),
          signature: crypto.Signature(base64.decode(signature), publicKey: publicEncKeyClient),
        );
        if (invocationUrl.toString() == 'http://example.com/container/${tokenContainer.serial}/sync' &&
            invocationBody['container_dict_client'] == containerDictClient &&
            isVeryfied) {
          return Response(
            jsonEncode({
              'id': 5,
              'jsonrpc': '2.0',
              'result': {
                'status': true,
                'value': {
                  'success': true,
                }
              },
              'time': 1.0,
              'version': 'privacyIDEA 3.6.2',
              'versionnumber': '3.6.2',
              'detail': null,
              'signature': 'signature',
            }),
            200,
          );
        }
        return Response(jsonEncode(exampleError), 400);
      });

      // Act
      final result = await containerApi.sync(tokenContainer, tokenState);
      // Assert
      expect(result, isNull);
    });
  });
  group('Unallowed', () {
    test('rollover', () {});
    test('finalizeContainer', () {
      // Arrange
      final containerApi = PiContainerApi(ioClient: MockPrivacyideaIOClient());
      final tokenContainer = getNewTokenContainer(
        withPolicies: ContainerPolicies(
          rolloverAllowed: true,
          initialTokenTransfer: true,
          tokensDeletable: true,
          unregisterAllowed: false,
        ),
      );
      // Act & Assert
      expect(() => containerApi.finalizeContainer(tokenContainer), throwsA(isA<Exception>()));
    });
    test('rollover', () {
      // Arrange
      final containerApi = PiContainerApi(ioClient: MockPrivacyideaIOClient());
      final tokenContainer = getFinalizedTokenContainer(
        withPolicies: ContainerPolicies(
          rolloverAllowed: false,
          initialTokenTransfer: true,
          tokensDeletable: true,
          unregisterAllowed: true,
        ),
      );
      // Act & Assert
      expect(() => containerApi.getRolloverQrData(tokenContainer), throwsA(isA<Exception>()));
    });

    test('unregister', () {
      // Arrange
      final containerApi = PiContainerApi(ioClient: MockPrivacyideaIOClient());
      final tokenContainer = getFinalizedTokenContainer(
        withPolicies: ContainerPolicies(
          rolloverAllowed: true,
          initialTokenTransfer: true,
          tokensDeletable: true,
          unregisterAllowed: false,
        ),
      );
      // Act & Assert
      expect(() => containerApi.unregister(tokenContainer), throwsA(isA<Exception>()));
    });
  });
}
        // when(mockIoClient.doPost(url: anyNamed('url'), body: anyNamed('body'), sslVerify: anyNamed('sslVerify'))).thenAnswer((invocation) async {
        //   final Uri invocationUrl = invocation.namedArguments[Symbol('url')];
        //   final Map<String, String?> invocationBody = invocation.namedArguments[Symbol('body')];
        //   Logger.info('Body: $invocationBody');
        //   if (invocationUrl.toString() == 'http://example.com/container/${tokenContainer.serial}/challenge' &&
        //       invocationBody['scope'] == 'http://example.com/container/register/${tokenContainer.serial}/terminate/client') {
        //     return containerChallengeResponse;
        //   }
        //   final signMessage = '$containerChallengeNonce|$containerChallengeTimeStamp|${tokenContainer.serial}|$invocationUrl';
        //   if (invocationUrl.toString() == 'http://example.com/container/register/${tokenContainer.serial}/terminate/client' &&
        //       invocationBody['scope'] == 'http://example.com/container/register/${tokenContainer.serial}/terminate/client' &&
        //       EccUtils().validateSignature(tokenContainer.ecPublicClientKey!, invocationBody['signature']!, signMessage)) {
        //     return Response(
        //       jsonEncode({
        //         'id': 5,
        //         'jsonrpc': '2.0',
        //         'result': {
        //           'status': true,
        //           'value': {
        //             'success': true,
        //           }
        //         },
        //         'time': 1.0,
        //         'version': 'privacyIDEA 3.6.2',
        //         'versionnumber': '3.6.2',
        //         'detail': null,
        //         'signature': 'signature',
        //       }),
        //       200,
        //     );
        //   }
        //   return Response(jsonEncode(exampleError), 400);
        // });

        // Act