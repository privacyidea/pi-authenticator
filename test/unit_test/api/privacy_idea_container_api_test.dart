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

import 'package:cryptography/cryptography.dart';
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
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
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

  // final privateServerKey =
  //     "35d6e41baa53d43545058e4f89d2644f:dc62c1d9da9fa0a6f2c7229cd12fdf0b0ea863be31d0e7be9433ea57f344b8d2f1f2745cef28120809b7dd24efc4f48ae6040bc11fb5112c5effb9eca4d27a0a6d54bacdadd47056a6f9cd160264002636382e670c4da67bef75a5104ee3b874c1e7af5dec39692c7daddb24fb45e48d8d1c4300c846d0578a5282991010b489e4d7a49ce0fd7d71c313e78740253b80110aa4945c7124e35be094fadace0ba8edf777daae1cde4152a092e0f9310d479a97004443b1fa4950bd5869fbd80bf05969563e6efe05dd41f7f5bf7f6e3792218ff63bd485a6e90a13144ba65f2d63d737fdf146b040b9bdebffbb67433d00dd38df487d7ab815a5249d399aeec37636f13eec6ebd6687eef1180a80c27b2a981821b149fd7cafe4f19b35ec7d8bff5a436802cf68255f84a41db91cc5e09ff1ae58cd4405e30e9ac3c5b5d30320f0";
  final publicServerKey = "-----BEGIN PUBLIC KEY-----\n"
      "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEd7thB7AwR3xgK7etKmFJfn4SrNhCAMB5\n"
      "V1ERqwhYj7QlmBe2pp8k07Ti6vZ1hue0Vf7utqIcTDPAK52qGcZ4fs8mpKkEeNIZ\n"
      "8yUPuPv9weXsVm/h7fBqHYQs82fMnzKz\n"
      "-----END PUBLIC KEY-----";
  final privateClientKey = "-----BEGIN EC PRIVATE KEY-----\n"
      "MIGkAgEBBDCleRofxXJwTtc0HUeE/Af8P4depFM0KY7oT4hMQdt3geK5uDWEOZn4\n"
      "DaCMTGrsSP2gBwYFK4EEACKhZANiAATxezSrY8++QiUpNxCQzEwOe//i0fd0OqCU\n"
      "rjZoc3XWhP7AkOfXVwYnlvm667ajB94+A0POVPCErcG/HbHk0Gb8lbO1Q5pYjb3N\n"
      "3ATXIlK0HJJqETYIgZ8pzVF9wBKnn/g=\n"
      "-----END EC PRIVATE KEY-----";

  final publicClientKey = "-----BEGIN PUBLIC KEY-----\n"
      "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAE8Xs0q2PPvkIlKTcQkMxMDnv/4tH3dDqg\n"
      "lK42aHN11oT+wJDn11cGJ5b5uuu2owfePgNDzlTwhK3Bvx2x5NBm/JWztUOaWI29\n"
      "zdwE1yJStBySahE2CIGfKc1RfcASp5/4\n"
      "-----END PUBLIC KEY-----";

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
      print('');
      final data = await containerApi.finalizeContainer(tokenContainer);
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
    group("sync", () {
      test('add', () async {
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
              '{"serial":"SMPH00067A2F","type":"smartphone","tokens":[{"tokentype":"HOTP","label":"label1","issuer":"privacyIDEA","pin":"False","algorithm":"SHA1","digits":"6","otp":["435986","964213"],"counter":"5"}]}';

          final signMessage2 = '$containerChallengeNonce|'
              '$containerChallengeTimeStamp|'
              '${tokenContainer.serial}|'
              '$invocationUrl|'
              '$publicEncKeyClientB64|'
              '$containerDictClient';

          if (invocationUrl.toString() == 'http://example.com/container/${tokenContainer.serial}/sync' &&
              invocationBody['container_dict_client'] == containerDictClient &&
              EccUtils().validateSignature(tokenContainer.ecPublicClientKey!, invocationBody['signature']!, signMessage2)) {
            return Response(
              jsonEncode({
                'id': 5,
                'jsonrpc': '2.0',
                'result': {
                  'status': true,
                  'value': {
                    'container_dict_server':
                        'oAI8Mq9tdIffSbuX62L8bSN3ZZ7wIGrip_pDCGY59Qz32DziorR4BMZ9vf_Vu5aUeDophX4Hdq_DdK2OJpzlYywSe5mysluVpCepGqr8xsGpTHwU5lPjIAN-OFCNO1_u2QH3dgwbZDVoHyPKfwICkULXqoIHmtb6BOtWzpMtC2Sd8v0ytA5HY7dgpO5MldidXrhI6RBdqfjJoknwnC7girLqZj0otDjZvfQrz3RFtCBdTqa6e4gxsnIEE8c1UTohvEN_LNvkP4sx7xpO3uI048ZXg8YxJMZThdAK5ai36cEGKmRuQVbM01DVeJHQHXwgacHIGKTTNgoUJb-g-7Qf-TJdhsrAH9S6eEiJLv8N_S2eRNfXubPlO9trK9HRsEra6I3f1Epw8-GRHB9CW5Yd6U_e9-ndaNKMGXkbUUaGF_wLDTqPnLSzgiNgDlAZtfaTHJRYqm-pBqDXHUZe7mgvLUqOhTHKIuBrQxW2t8TZ5VWU1psVT70D4J4RR9MInmZvUDcO__AqnAXQsHiaoWF-z2QSmX9I5Em8jpF5fQSgHNJBM3UEzBHJEE_D6dxnoz5M1O314qz3YIy5JphBssRjfBYhxdRPB5nYBp2EpSvBvAYHrbu5Iv431JG05nLbb_4AgOsJDm1RhGjqCcjbvDYKpyN6ewoUP--q0L-eZPxUlRGeITuqMmNpIVXlCiPiJ9u2L1zQNdPv0OEvhkOtd1vFm492sZ7Mr9nyzJ13f5Ca86smHK1sDDYczjqHlxpevqtoDxlpgCQqTv_XzF6DjXRHPtNB6hiAuP-jIzCTL5RYokj5nv28Ih3dCRCVRfU8CVcz8KiRVBSo6WTQ_Q7DzL_ZqcmK2xnlwGdmoWVhTXUp75ed1YjSwGaVQ6D5w50ZgWNP5YYiJIUpN27WS3akEIDrwpm7h0ZctP8Kvlj46VRxd2Urhi_6NafWBnX4M8Jo6AWsp2hoFl6i2WoSa9c2kOi-OvVg8PzHFknNiFSjHTvytm-Q6zxpm--6kia1xbdRdEDoCD4YW901GJXoZOKtfUAA7soODoI5mNJT9D_ZXBuAJcDqjEkKpZWMWyYkfOwrTqlsrSKtYue4tQ4INBnhfwTZk2ppTwlRFp6jOjHTgsSdcfCKOzresp75u8My30dbIhzRIYgFp6jwcRikAlBbwXBVBT7iR_6Nrw==',
                    'encryption_algorithm': 'AES',
                    'encryption_params': {
                      'algorithm': 'AES',
                      'mode': 'GCM',
                      'init_vector': 'Q3f4NMAuDFrdI9R3uZ7DHA==',
                      'tag': 'iThLozfTiK4twnPXnvF0nA==',
                    },
                    'policies': {
                      'container_client_rollover': false,
                      'container_initial_token_transfer': false,
                      'client_token_deletable': true,
                      'client_container_unregister': true,
                    },
                    'public_server_key': 'AMc1nbpqrEOgQLe1-nR2ExnqE1IM8qMDETYw65IU6wQ=',
                    'server_url': 'http://example.com/container/${tokenContainer.serial}/sync',
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

        final type = X25519().keyPairType;
        final publicSimpleKeyPair = SimpleKeyPairData(
          base64Decode("mJp57a9lmpXXpT9bTUDLz1/Kcngtzmz/yodWlIw7UXo="),
          publicKey: SimplePublicKey(base64Decode("sGSaA8sawDbkglDHYRJPwgKoSghTvJz1ejlJe4USrDA="), type: type),
          type: type,
        );

        // Act
        final result = await containerApi.sync(tokenContainer, tokenState, withX25519Key: publicSimpleKeyPair);
        // Asserta
        expect(result, isNotNull);
        final newPolicies = result.newPolicies;
        expect(newPolicies.initialTokenTransfer, false);
        expect(newPolicies.rolloverAllowed, false);
        expect(newPolicies.tokensDeletable, true);
        expect(newPolicies.unregisterAllowed, true);
        final updatedTokens = result.updatedTokens;
        expect(updatedTokens.length, 2);
        final token0 = updatedTokens[0];
        final token1 = updatedTokens[1];
        expect(token0, isA<HOTPToken>());
        expect((token0 as HOTPToken).label, 'OATH00068B93');
        expect(token0.issuer, 'privacyIDEA');
        expect(token0.counter, 1);
        expect(token0.algorithm, Algorithms.SHA1);
        expect(token0.digits, 6);
        expect(token0.secret, 'CDLDLKLUMPDR2IJJZJHF5XKFKBABU4XR');
        expect(token1, isA<TOTPToken>());
        expect((token1 as TOTPToken).label, 'TOTP00011B1F');
        expect(token1.issuer, 'privacyIDEA');
        expect(token1.period, 30);
        expect(token1.algorithm, Algorithms.SHA1);
        expect(token1.digits, 6);
        expect(token1.secret, 'XH5COUO6JSL5PE6VKOC3XNVENJHXCHIP');
      });
      test('update unlinked token (with serial)', () async {
        // Arrange
        final mockIoClient = MockPrivacyideaIOClient();
        final containerApi = PiContainerApi(ioClient: mockIoClient);
        final tokenContainer = getFinalizedTokenContainer();
        final tokenState = TokenState(
          tokens: [
            HOTPToken(
              label: "OATH00068B93",
              serial: "OATH00068B93",
              issuer: "privacyIDEA",
              counter: 1,
              id: 'id1',
              algorithm: Algorithms.SHA1,
              digits: 6,
              secret: 'CDLDLKLUMPDR2IJJZJHF5XKFKBABU4XR',
            ),
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
              '{"serial":"SMPH00067A2F","type":"smartphone","tokens":[{"serial":"OATH00068B93","tokentype":"HOTP","label":"OATH00068B93","issuer":"privacyIDEA","pin":"False","algorithm":"SHA1","digits":"6","counter":"1"}]}';

          final signMessage2 = '$containerChallengeNonce|'
              '$containerChallengeTimeStamp|'
              '${tokenContainer.serial}|'
              '$invocationUrl|'
              '$publicEncKeyClientB64|'
              '$containerDictClient';

          if (invocationUrl.toString() == 'http://example.com/container/${tokenContainer.serial}/sync' &&
              invocationBody['container_dict_client'] == containerDictClient &&
              EccUtils().validateSignature(tokenContainer.ecPublicClientKey!, invocationBody['signature']!, signMessage2)) {
            return Response(
              jsonEncode({
                'id': 5,
                'jsonrpc': '2.0',
                'result': {
                  'status': true,
                  'value': {
                    'container_dict_server':
                        'uo6_1Uu0vn6ejoDwGZu3-SOAKmE5YpcVPm97VFlu1HGcRRembvvSaZAqxyMX00p-CBZhiNTwsfkiUjDdXH9zNA3WyyitkRSxvpbeR_7VwEe5vzo5okddX_G6VaGLO8oDRZu5jDzz_ngwDCiqW5_MDRxbncFFPY4EK265_hcNb1kYreEZcfLiEWmGczXIV2vULxWPBgtx8yCcvgb053NJvkndtRkbqo2NEdXNQfCuFZjV_P97izYWqBsc8iADQtg4oyndnRVELW_U47kh7VXN1pWOnUnPK13i3K4F3dwuBcT5li4fZIDiE6pZAhdjkICQFfRekh8Oe6j1jkMm7psly9SjgoAIsuF64Ew20X4tlmIUSFm9HKwVWFxVyA2EEpmzNYJQbEn8CF2Fr0BD_FnPvin1v3SlnNBRwiAIxE7691kq3pTMsQoMYuDZMsLCcWBnHtVhuIS0Sr0B8jEVJHNWRvCdVqGWXO-WtJHij4Mc9fzz9WDjp1jHOzryV5gO7Vv0x6VJ53AW29DNkfV0uERq2sySGdLQu3SA1qPTR2XqYUXmMc5jRDPn0RaMeYXlDO5iqLdiq2wDZ3RHFzz9TI0BOKWZ92OP-xlp1xNX7NYQ1hTW471l2o2lFP3C_P9lwbDuOTOwpSsnup9XBEImIgrhE5F7JUWuAYTzpKaUsFAWleRtvOLFmJe8GKdvbHYlWlM1ulYiRiByhIcvb9zSxKofgT1E5BwVIP_QF1nsOPRTVS7DQsiVb6iwlbjCvPoePwpK_FLsvZbsai265jMDJfLYba6h6wKLrB9SLHx-or4OcFPrevQ8VjM8T1jKKt1--yc-GmHjqY6HKjs9ekgk0wuBYRsE_FX4ChVoDe9YNzRnQSI-nRNoiIRSigrF0YMKYsPMo3IPzGL8ChiTxx8-oeJ2LmG4sW5r0VJl9bWKGNjwEAB2PDRsgbEyCeRvTOBztfP2GrW-bw-tlouO8sUIFlQ5q10-fgeg8rCOzPcobrILzfWmfTD_KC_hcAmGVL1O9O627BnnhHIViaXFhFJw9GNgmOnRWmJ4tWpkhQzaU7RYXQ0eWXTuoFkFyvQSSBMuJJY6Vq0053AqrjJ9J-Q5sFB8P-X2rbiQKXc92XmYEFyiqwbXRBA5aGhtpKmb3M7wvaCIRzNSEHED6Go6QiBdLKEgM2uYLVKpRPOyktb6LercICxdqaiUy9iwV3c6AF67-gapZ5d3hfNAPGRpbuhd-I-i5_20Tg2sxwbxsO2xizPxY_ppPDaLNqSF2R4aIGXyDTgBSFSqPpefxcryjceTu8W6hUvK7bqicxr0smrg5RR53a4mtpPFKqaYergGHrvPV9k6UzR9f2cKGVTSpovZmJnl4ssjmJZGpH4UfdG_sjXuWDF1AHpHmz8Qmjd0q46J7UCDffDDv6sIkt1DZI0MfYbqpJ6Z3Bg7OyFmRVrOHl6QFX4ZWjbNqDzlgSZicpPr',
                    'encryption_algorithm': 'AES',
                    'encryption_params': {
                      'algorithm': 'AES',
                      'mode': 'GCM',
                      'init_vector': 'oVOCbmI9mdvIDJQ7m5Kvyg==',
                      'tag': 'bGIenivUR2QS5T1H37rJQg==',
                    },
                    'policies': {
                      'container_client_rollover': false,
                      'container_initial_token_transfer': false,
                      'client_token_deletable': true,
                      'client_container_unregister': true,
                    },
                    'public_server_key': '4HUJxDV2j1dguSOUGmupScPqjNJL-sATSvmYujP3STo=',
                    'server_url': 'http://example.com/container/${tokenContainer.serial}/sync',
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

        final type = X25519().keyPairType;
        final publicSimpleKeyPair = SimpleKeyPairData(
          base64Decode("2NEmGL31xJBYWSQ72+oqeMvwn+liM3Nwq6qG4NzRd04="),
          publicKey: SimplePublicKey(base64Decode("+4KfIuxEB8z6CDlXjbFpirmJ3tNuTIzhCV6L21lxkw8="), type: type),
          type: type,
        );

        // Act
        final result = await containerApi.sync(tokenContainer, tokenState, withX25519Key: publicSimpleKeyPair);
        // Asserta
        expect(result, isNotNull);
        final newPolicies = result.newPolicies;
        expect(newPolicies.initialTokenTransfer, false);
        expect(newPolicies.rolloverAllowed, false);
        expect(newPolicies.tokensDeletable, true);
        expect(newPolicies.unregisterAllowed, true);
        final updatedTokens = result.updatedTokens;
        final deleteTokenSerials = result.deleteTokenSerials;
        expect(deleteTokenSerials.length, 0);
        expect(updatedTokens.length, 2);
        final token0 = updatedTokens[0];
        final token1 = updatedTokens[1];
        expect(token0, isA<HOTPToken>());
        expect((token0 as HOTPToken).label, 'OATH00068B93');
        expect(token0.issuer, 'privacyIDEA');
        expect(token0.counter, 0);
        expect(token0.algorithm, Algorithms.SHA1);
        expect(token0.digits, 6);
        expect(token0.secret, 'CDLDLKLUMPDR2IJJZJHF5XKFKBABU4XR');
        expect(token1, isA<TOTPToken>());
        expect((token1 as TOTPToken).label, 'TOTP00011B1F');
        expect(token1.issuer, 'privacyIDEA');
        expect(token1.period, 30);
        expect(token1.algorithm, Algorithms.SHA1);
        expect(token1.digits, 6);
        expect(token1.secret, '3LTZKAYTNIK5DUE4SLIGTKOC6ZK36E2G');
      });
      test('update unlinked token (without serial)', () async {
        // Arrange
        final mockIoClient = MockPrivacyideaIOClient();
        final containerApi = PiContainerApi(ioClient: mockIoClient);
        final tokenContainer = getFinalizedTokenContainer();
        final tokenState = TokenState(
          tokens: [
            TOTPToken(
              label: 'TOTP00011B1F',
              serial: 'TOTP00011B1F',
              issuer: 'privacyIDEA',
              period: 30,
              id: 'id0',
              algorithm: Algorithms.SHA1,
              digits: 6,
              secret: 'CDLDLKLUMPDR2IJJZJHF5XKFKBABU4XR',
            ),
            HOTPToken(
              label: "OATH00166051",
              issuer: "privacyIDEA",
              counter: 1,
              id: 'id1',
              algorithm: Algorithms.SHA1,
              digits: 6,
              secret: 'KWS3LTJ2L7NW4KGHL5W5OABWR4PLJIDL',
            ),
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
              '{"serial":"SMPH00067A2F","type":"smartphone","tokens":[{"serial":"TOTP00011B1F","tokentype":"TOTP","label":"TOTP00011B1F","issuer":"privacyIDEA","pin":"False","algorithm":"SHA1","digits":"6","period":"30"},{"tokentype":"HOTP","label":"OATH00166051","issuer":"privacyIDEA","pin":"False","algorithm":"SHA1","digits":"6","otp":["079447","501895"],"counter":"1"}]}';

          final signMessage2 = '$containerChallengeNonce|'
              '$containerChallengeTimeStamp|'
              '${tokenContainer.serial}|'
              '$invocationUrl|'
              '$publicEncKeyClientB64|'
              '$containerDictClient';

          if (invocationUrl.toString() == 'http://example.com/container/${tokenContainer.serial}/sync' &&
              invocationBody['container_dict_client'] == containerDictClient &&
              EccUtils().validateSignature(tokenContainer.ecPublicClientKey!, invocationBody['signature']!, signMessage2)) {
            return Response(
              jsonEncode({
                'id': 5,
                'jsonrpc': '2.0',
                'result': {
                  'status': true,
                  'value': {
                    'container_dict_server':
                        'jeOQQ05zabAlDb3inp4DFplsZ_K9BW1MjhLIrM7CTD48D9bcxjA6C0FZm7rUGMqP8ZjwAIVaVkv6tTW5-Ycfez3o8RW-TtWq68xgPHCYEGp9IPWAymY58eF8Cpvy5r7ykDlGeekqnap6TwjS8KqlW54RZNwKSe7pcFd0Z0SX2TByx6CkmPguNOIjx_3eQSx87P9GuGn3-9wKpZykWJbNJgUyzMH2d4Qz55fwQ1IXI6nfbUk6sd67YmGWK1hc4tW43LHFaIIjKwzL4BkJnyPKi4gGeDRw0UxUfquc4KYqyqFmeCZj_Jc5OL9igUqBbIS4yhgsk39K6ldAYM79gY78ihcOHIJPafcFu8C4ie-yOeEPcxnN1m4vyebHAC_nQNEEXxI7k1A4MwAFak8daUdO5axNEwpJWOVfEaPDjcaeuudsrc90nOkhiZ1GAxrlb9j549sVCbx9zLUEAu90OCiu3tyuUYIAR9-YvYbyY3g6Kp8qtSmZDXnN5mPbX1ikxgg8kaez87fLkP9-wcWaaALGxx07Jlt4l2os7HOqP1w7HZbEcZze3ndoGygw18wEqYOl2BXyOfAVfIDzA1jawuFeZ2UctnprzMdI1FYNEw5po-Tz209dJYMvtihuF9PCGyluqBOTn1lT5kIQXatSb1G7D0esfMc4xhhbHTQY04B9o7I2epNWCkFqZhklNm-pW7HQPJEY0ob3z2f9uzVU5e1YZd5JQrw60--vuECTcdU1en5fkPoV1sC0dFmjVIUu8xJuyytnRY6HxiUSabBIWpIcuZrPkBc4gE4fGk9fpxVJXsf6P8Ki9hb1IWZslCaiPnt_bkhsFygaEhxG3Kp1kp8BkiofAZB3rB_hx06lXptuWjmG6Kcm1WUBL5HAL5bwBXgsRw6EBSGARs5vBRq7KBwpEkDjqFhgbpTZlVvTk11rG2tMMVX1vdF4_yjSkFu2WE4bmPSR6dYsN7KjNswtIUA26y9KWYIFcoK8oYbT_pUVAa1Pb81Y3obJDtX95iSdKvrht0xRhCoEegoYLwq57IUc1y3jL0OoPKJUD-MSO4YXvwxP4ZErIBz8HCNp2NqtMsyYHcZfaqJtvHScZI_Z28HndMrlPQMBxDsX4U8mD1Ev5QZAadAF2qQQVka9QUJP86nOi53l2WQsW9gMDqMjaG235veAM1mh4a_vrsJYAngAdCC1Jlw6dgplIg4P_iJmMpvrlKeeFw5-Dh_fGVnM_mK9vaF9Nuhk6yU07weS78GV5oD9XQ-YviZXCg-FWq_lXCVUC4TEsrnNyBJxA8Otpymj7NHv-1Xt3LzOYihvzD1XgGc6wELQGhhTp826BOm1u8OidC1gNR0uAcoP5ChZvOrYYgTsS--0hZKG4XZ75mNZgb1JkVdyjkp8g1w7YEZ-HABk55_aBbK_2nt5UKvDx459KyGNyJbi-sbs5Ap1BaI7PDu6dKeNVPPMk892zmw8GjT8zqjfnt6qHJp3lxUId8gwz5SCRMCgF1CeZJZSlXbxb6BxpiCHQeSOhFms3sWewwLYnzW-H-GokiHtkLXwOSkgECHs4lxKFQ14IOIBDCpMRfLlGA4QbOTIkcFnT9QMcUzs27c39cKZhjBXGKtIg3cWwoxyCJZpoc5_rg6_PHRTkkfSzUuBFA-0i5RTbieZqqZlRjfzkK-sz9vJ0zmEWSQQlAOuHCSg68dBUwjHn-FLaVunGWUbRvGPSdp9pIoIdDQ8XSpTmjtYiArbDcVzZEJmEdRtwmYL-Ygv-15D3OLylm-mx2fX5GUIK4czrJJlE34GYykGuWnG_AL-res8zF0vbGzyIhsW_MxNIGViQjDy5nmiJ55XPVVufCFGOgVioGdwcd3OFjopLL5cVx2Qiw==',
                    'encryption_algorithm': 'AES',
                    'encryption_params': {
                      'algorithm': 'AES',
                      'mode': 'GCM',
                      'init_vector': 'AZbBMH7imo5q-uFrPbVhTw==',
                      'tag': 'HIWDZ6mXNdWA9zYLJa9-WA==',
                    },
                    'policies': {
                      'container_client_rollover': false,
                      'container_initial_token_transfer': false,
                      'client_token_deletable': true,
                      'client_container_unregister': true,
                    },
                    'public_server_key': 'aK_oH0ycoKrXoIMbTlQ7_adxUe7JVAuPCbcoOUBKYBY=',
                    'server_url': 'http://example.com/container/${tokenContainer.serial}/sync',
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

        final type = X25519().keyPairType;
        final publicSimpleKeyPair = SimpleKeyPairData(
          base64Decode("uCyfofJSNWX08K8omYeR43nwoPUE++niUrxDB43noVc="),
          publicKey: SimplePublicKey(base64Decode("4/d5K2gycwPxeIVHuHQvlq6tb7BDQ7HkQ/g8JBBmVHw="), type: type),
          type: type,
        );

        // Act
        final result = await containerApi.sync(tokenContainer, tokenState, withX25519Key: publicSimpleKeyPair);
        // Asserta
        expect(result, isNotNull);
        final newPolicies = result.newPolicies;
        expect(newPolicies.initialTokenTransfer, false);
        expect(newPolicies.rolloverAllowed, false);
        expect(newPolicies.tokensDeletable, true);
        expect(newPolicies.unregisterAllowed, true);
        final updatedTokens = result.updatedTokens;
        final deleteTokenSerials = result.deleteTokenSerials;
        expect(deleteTokenSerials.length, 0);
        expect(updatedTokens.length, 2);
        final token0 = updatedTokens[0];
        final token1 = updatedTokens[1];
        expect(token0, isA<HOTPToken>());
        expect((token0 as HOTPToken).label, 'OATH00166051');
        expect(token0.issuer, 'privacyIDEA');
        expect(token0.counter, 0);
        expect(token0.algorithm, Algorithms.SHA1);
        expect(token0.digits, 6);
        expect(token0.secret, 'KWS3LTJ2L7NW4KGHL5W5OABWR4PLJIDL');
        expect(token1, isA<TOTPToken>());
        expect((token1 as TOTPToken).label, 'TOTP00011B1F');
        expect(token1.issuer, 'privacyIDEA');
        expect(token1.period, 30);
        expect(token1.algorithm, Algorithms.SHA1);
        expect(token1.digits, 6);
        expect(token1.secret, 'CDLDLKLUMPDR2IJJZJHF5XKFKBABU4XR');
      });
      test('sync with unknown tokens (with serial)', () async {
        // Arrange
        final mockIoClient = MockPrivacyideaIOClient();
        final containerApi = PiContainerApi(ioClient: mockIoClient);
        final tokenContainer = getFinalizedTokenContainer();
        final tokenState = TokenState(
          tokens: [
            TOTPToken(
              label: 'TOTP00011B1F',
              serial: 'TOTP00011B1F',
              issuer: 'privacyIDEA',
              period: 30,
              id: 'id0',
              algorithm: Algorithms.SHA1,
              digits: 6,
              secret: 'CDLDLKLUMPDR2IJJZJHF5XKFKBABU4XR',
            ),
            HOTPToken(
              label: "OATH00166051",
              serial: "OATH00166051",
              issuer: "privacyIDEA",
              counter: 1,
              id: 'id1',
              algorithm: Algorithms.SHA1,
              digits: 6,
              secret: 'KWS3LTJ2L7NW4KGHL5W5OABWR4PLJIDL',
            ),
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
              '{"serial":"SMPH00067A2F","type":"smartphone","tokens":[{"serial":"TOTP00011B1F","tokentype":"TOTP","label":"TOTP00011B1F","issuer":"privacyIDEA","pin":"False","algorithm":"SHA1","digits":"6","period":"30"},{"serial":"OATH00166051","tokentype":"HOTP","label":"OATH00166051","issuer":"privacyIDEA","pin":"False","algorithm":"SHA1","digits":"6","counter":"1"}]}';

          final signMessage2 = '$containerChallengeNonce|'
              '$containerChallengeTimeStamp|'
              '${tokenContainer.serial}|'
              '$invocationUrl|'
              '$publicEncKeyClientB64|'
              '$containerDictClient';

          if (invocationUrl.toString() == 'http://example.com/container/${tokenContainer.serial}/sync' &&
              invocationBody['container_dict_client'] == containerDictClient &&
              EccUtils().validateSignature(tokenContainer.ecPublicClientKey!, invocationBody['signature']!, signMessage2)) {
            return Response(
              jsonEncode({
                'id': 5,
                'jsonrpc': '2.0',
                'result': {
                  'status': true,
                  'value': {
                    'container_dict_server':
                        'GKgkhASAEDYmXRJo2f-ixn6RsnWTuOjzK3mvBmJu9alQhbkcXIRf135wMI9YsErJI_soNDiP2ySR3lHdumEYxmcjW1r1ZbxM-KfMqUPaM56b7oet2MQh5TdlIBKib-UhSyxZ5SpKK26tHIYMjxw3IJMKADMzI5NVrj-F0KCburg_54v4GkJh_gWb5_F6pDw45O_AoEm1d6ANk-QHjg4_10-WFSEdKU6_LsixqIGjQPuRY9YBO5lxav_hWPzJw76UC80D8LpVi5IgJASU0uyo65PN3enczq6OOGmsc2IWP8Wl544qEpQaPGXnw0MvJxs139NIMMZLEyU-tRATIlWNYlLeN2SYW3xFyMB19pSpqIO3GFOChIhfsa_E6w-AMUR2I3s0e9vlbUPYsIpJ_wG7pS-PdWCkaJpvV1i7G_z73R-27tfmeKPaMVA2elGl-XIP8gnqMh0Igx2EtmkR2rQhGWf5XaU7fSGGbuNA81mR8dEJhiMHooIEqrPRzlRy0lwMapfe8lBiGBRFf6bpFEaT18--gh4qMWOLS1DK_q16b1tuNNnFmgafGkBsLDuvU6T23nOM14FqPD-GJGHJ0ju5ItWODUn2gCGPYmnolWorRqpeTDYylKJdNEl5r76WSVz1W9KpTjnq6-e6OkZC6w1VpzfFG_tOWmVKZ5wb8QDGDaF37d-LTAcykSRRa-0EfHS_uDWr94oiv7YjUnyD7C9zuiZe9qkgoeQdSYK-Kyw9lkkZc85ANcK3fQHOc08E3dt-OTVEjFlU750zCxs7xt06TTBS_dXdzyTdu2rHvosOvvCSwGM3h_942B9IAdcm2MkRtTpi2OlGgl7j8IGNxojCEO0Y03-H4GSoiaNfa7DGbka4QOTP6Gv9S1r4qzSN1oSnHwtN3_x7obh229rYoGjz3NfjnWLDjM_HLAqSWVabredReNpoX-uBzP5LzkAMusPJ34HCufm8Ka4mhpW-BRZXXWwwtStpdNKlrgr_QDEatJBe9ZdU9SL5JTHe3ICyJIjOmyN-qwC2IwhkxGx6rq1RcUNDwgeCMXO2peicQ8uWJiqmot-a-40y7Hwr49grjmRNFM-iIoMr1PaAvAhLkeaTGiZvoRN2a3jNx0YTGTQ_xIPuiizPKVJBBghVjfFJoMvrl0bLDjHnSqMbR-FQ1etu5lVqRt1t7RXpROvBj41WqaJQG3yDyOk8JKE4yhZ-FFFr6usgQudNhglKe1IJl05X5wAHIRMacMz9cuWS-FDoNSdsOx9QjqVsVYPg2NXaTj_75I8Obuxh6kLRlAZMPVQRHhb_NkF5rOrnuhOZWbCCDqEiSI7FW3Ixsx1vQ0swipATYoU=',
                    'encryption_algorithm': 'AES',
                    'encryption_params': {
                      'algorithm': 'AES',
                      'mode': 'GCM',
                      'init_vector': '7gDUfdpZm15ew5jJqzISTA==',
                      'tag': 'lnAF6Md0EkSq8bKt5eetpg==',
                    },
                    'policies': {
                      'container_client_rollover': false,
                      'container_initial_token_transfer': false,
                      'client_token_deletable': true,
                      'client_container_unregister': true,
                    },
                    'public_server_key': 'Od5nNdvC3iVYTK5aA5e-c1-f3FhSe4MH4apaNDRkSQA=',
                    'server_url': 'http://example.com/container/${tokenContainer.serial}/sync',
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

        final type = X25519().keyPairType;
        final publicSimpleKeyPair = SimpleKeyPairData(
          base64Decode("YIgUiisLPu5dq3KQUMksNVEq12NG2mIM32E13UkQwWQ="),
          publicKey: SimplePublicKey(base64Decode("ScZtrNZ3Zay12x+eQDyz4a2wafvZqk7BVzBNTchXc2w="), type: type),
          type: type,
        );

        // Act
        final result = await containerApi.sync(tokenContainer, tokenState, withX25519Key: publicSimpleKeyPair);
        // Asserta
        expect(result, isNotNull);
        final newPolicies = result.newPolicies;
        expect(newPolicies.initialTokenTransfer, false);
        expect(newPolicies.rolloverAllowed, false);
        expect(newPolicies.tokensDeletable, true);
        expect(newPolicies.unregisterAllowed, true);
        final updatedTokens = result.updatedTokens;
        final deleteTokenSerials = result.deleteTokenSerials;
        expect(deleteTokenSerials.length, 0);
        expect(updatedTokens.length, 1);
        final token0 = updatedTokens[0];
        expect(token0, isA<TOTPToken>());
        expect((token0 as TOTPToken).label, 'TOTP00011B1F');
        expect(token0.issuer, 'privacyIDEA');
        expect(token0.period, 30);
        expect(token0.id, 'id0');
        expect(token0.algorithm, Algorithms.SHA1);
        expect(token0.digits, 6);
        expect(token0.secret, 'CDLDLKLUMPDR2IJJZJHF5XKFKBABU4XR');
        expect(token0.serial, 'TOTP00011B1F');
      });
      test('sync with unknown tokens (without serial)', () async {
        // Arrange
        final mockIoClient = MockPrivacyideaIOClient();
        final containerApi = PiContainerApi(ioClient: mockIoClient);
        final tokenContainer = getFinalizedTokenContainer();
        final tokenState = TokenState(
          tokens: [
            TOTPToken(
              label: 'TOTP00011B1F',
              serial: 'TOTP00011B1F',
              issuer: 'privacyIDEA',
              period: 30,
              id: 'id0',
              algorithm: Algorithms.SHA1,
              digits: 6,
              secret: 'CDLDLKLUMPDR2IJJZJHF5XKFKBABU4XR',
            ),
            HOTPToken(
              label: "OATH00166051",
              issuer: "privacyIDEA",
              counter: 1,
              id: 'id1',
              algorithm: Algorithms.SHA1,
              digits: 6,
              secret: 'KWS3LTJ2L7NW4KGHL5W5OABWR4PLJIDL',
            ),
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
              '{"serial":"SMPH00067A2F","type":"smartphone","tokens":[{"serial":"TOTP00011B1F","tokentype":"TOTP","label":"TOTP00011B1F","issuer":"privacyIDEA","pin":"False","algorithm":"SHA1","digits":"6","period":"30"},{"tokentype":"HOTP","label":"OATH00166051","issuer":"privacyIDEA","pin":"False","algorithm":"SHA1","digits":"6","otp":["079447","501895"],"counter":"1"}]}';

          final signMessage2 = '$containerChallengeNonce|'
              '$containerChallengeTimeStamp|'
              '${tokenContainer.serial}|'
              '$invocationUrl|'
              '$publicEncKeyClientB64|'
              '$containerDictClient';

          if (invocationUrl.toString() == 'http://example.com/container/${tokenContainer.serial}/sync' &&
              invocationBody['container_dict_client'] == containerDictClient &&
              EccUtils().validateSignature(tokenContainer.ecPublicClientKey!, invocationBody['signature']!, signMessage2)) {
            return Response(
              jsonEncode({
                'id': 5,
                'jsonrpc': '2.0',
                'result': {
                  'status': true,
                  'value': {
                    'container_dict_server':
                        'GKgkhASAEDYmXRJo2f-ixn6RsnWTuOjzK3mvBmJu9alQhbkcXIRf135wMI9YsErJI_soNDiP2ySR3lHdumEYxmcjW1r1ZbxM-KfMqUPaM56b7oet2MQh5TdlIBKib-UhSyxZ5SpKK26tHIYMjxw3IJMKADMzI5NVrj-F0KCburg_54v4GkJh_gWb5_F6pDw45O_AoEm1d6ANk-QHjg4_10-WFSEdKU6_LsixqIGjQPuRY9YBO5lxav_hWPzJw76UC80D8LpVi5IgJASU0uyo65PN3enczq6OOGmsc2IWP8Wl544qEpQaPGXnw0MvJxs139NIMMZLEyU-tRATIlWNYlLeN2SYW3xFyMB19pSpqIO3GFOChIhfsa_E6w-AMUR2I3s0e9vlbUPYsIpJ_wG7pS-PdWCkaJpvV1i7G_z73R-27tfmeKPaMVA2elGl-XIP8gnqMh0Igx2EtmkR2rQhGWf5XaU7fSGGbuNA81mR8dEJhiMHooIEqrPRzlRy0lwMapfe8lBiGBRFf6bpFEaT18--gh4qMWOLS1DK_q16b1tuNNnFmgafGkBsLDuvU6T23nOM14FqPD-GJGHJ0ju5ItWODUn2gCGPYmnolWorRqpeTDYylKJdNEl5r76WSVz1W9KpTjnq6-e6OkZC6w1VpzfFG_tOWmVKZ5wb8QDGDaF37d-LTAcykSRRa-0EfHS_uDWr94oiv7YjUnyD7C9zuiZe9qkgoeQdSYK-Kyw9lkkZc85ANcK3fQHOc08E3dt-OTVEjFlU750zCxs7xt06TTBS_dXdzyTdu2rHvosOvvCSwGM3h_942B9IAdcm2MkRtTpi2OlGgl7j8IGNxojCEO0Y03-H4GSoiaNfa7DGbka4QOTP6Gv9S1r4qzSN1oSnHwtN3_x7obh229rYoGjz3NfjnWLDjM_HLAqSWVabredReNpoX-uBzP5LzkAMusPJ34HCufm8Ka4mhpW-BRZXXWwwtStpdNKlrgr_QDEatJBe9ZdU9SL5JTHe3ICyJIjOmyN-qwC2IwhkxGx6rq1RcUNDwgeCMXO2peicQ8uWJiqmot-a-40y7Hwr49grjmRNFM-iIoMr1PaAvAhLkeaTGiZvoRN2a3jNx0YTGTQ_xIPuiizPKVJBBghVjfFJoMvrl0bLDjHnSqMbR-FQ1etu5lVqRt1t7RXpROvBj41WqaJQG3yDyOk8JKE4yhZ-FFFr6usgQudNhglKe1IJl05X5wAHIRMacMz9cuWS-FDoNSdsOx9QjqVsVYPg2NXaTj_75I8Obuxh6kLRlAZMPVQRHhb_NkF5rOrnuhOZWbCCDqEiSI7FW3Ixsx1vQ0swipATYoU=',
                    'encryption_algorithm': 'AES',
                    'encryption_params': {
                      'algorithm': 'AES',
                      'mode': 'GCM',
                      'init_vector': '7gDUfdpZm15ew5jJqzISTA==',
                      'tag': 'lnAF6Md0EkSq8bKt5eetpg==',
                    },
                    'policies': {
                      'container_client_rollover': false,
                      'container_initial_token_transfer': false,
                      'client_token_deletable': true,
                      'client_container_unregister': true,
                    },
                    'public_server_key': 'Od5nNdvC3iVYTK5aA5e-c1-f3FhSe4MH4apaNDRkSQA=',
                    'server_url': 'http://example.com/container/${tokenContainer.serial}/sync',
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

        final type = X25519().keyPairType;
        final publicSimpleKeyPair = SimpleKeyPairData(
          base64Decode("YIgUiisLPu5dq3KQUMksNVEq12NG2mIM32E13UkQwWQ="),
          publicKey: SimplePublicKey(base64Decode("ScZtrNZ3Zay12x+eQDyz4a2wafvZqk7BVzBNTchXc2w="), type: type),
          type: type,
        );

        // Act
        final result = await containerApi.sync(tokenContainer, tokenState, withX25519Key: publicSimpleKeyPair);
        // Asserta
        expect(result, isNotNull);
        final newPolicies = result.newPolicies;
        expect(newPolicies.initialTokenTransfer, false);
        expect(newPolicies.rolloverAllowed, false);
        expect(newPolicies.tokensDeletable, true);
        expect(newPolicies.unregisterAllowed, true);
        final updatedTokens = result.updatedTokens;
        final deleteTokenSerials = result.deleteTokenSerials;
        expect(deleteTokenSerials.length, 0);
        expect(updatedTokens.length, 1);
        final token0 = updatedTokens[0];
        expect(token0, isA<TOTPToken>());
        expect((token0 as TOTPToken).label, 'TOTP00011B1F');
        expect(token0.issuer, 'privacyIDEA');
        expect(token0.period, 30);
        expect(token0.id, 'id0');
        expect(token0.algorithm, Algorithms.SHA1);
        expect(token0.digits, 6);
        expect(token0.secret, 'CDLDLKLUMPDR2IJJZJHF5XKFKBABU4XR');
        expect(token0.serial, 'TOTP00011B1F');
      });
    });
  });
  group('Unallowed', () {
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
