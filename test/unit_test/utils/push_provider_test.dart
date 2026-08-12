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

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  group('PushProvider.pollForChallenge', () {
    late MockPrivacyideaIOClient mockIOClient;
    late MockRsaUtils mockRsaUtils;
    late PushToken token;

    setUp(() {
      PushProvider.instance = null;
      mockIOClient = MockPrivacyideaIOClient();
      mockRsaUtils = MockRsaUtils();
      token = PushToken(
        serial: 'PIPU0001',
        id: 'id',
        isRolledOut: true,
        url: Uri.parse('https://example.com/ttype/push'),
      );

      when(
        mockRsaUtils.trySignWithToken(any, any),
      ).thenAnswer((_) async => 'signature');
      when(
        mockIOClient.doGet(
          url: anyNamed('url'),
          parameters: anyNamed('parameters'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).thenAnswer(
        (_) async => Response('{"result": {"status": true, "value": []}}', 200),
      );
    });

    Map<String, String?> capturedParameters() =>
        verify(
              mockIOClient.doGet(
                url: anyNamed('url'),
                parameters: captureAnyNamed('parameters'),
                sslVerify: anyNamed('sslVerify'),
              ),
            ).captured.last
            as Map<String, String?>;

    test(
      'sends the parameters the server rebuilds the signature from',
      () async {
        await PushProvider(
          ioClient: mockIOClient,
          rsaUtils: mockRsaUtils,
        ).pollForChallenge(token);

        final parameters = capturedParameters();
        expect(parameters['serial'], token.serial);
        expect(parameters['timestamp'], isNotNull);
        expect(parameters['signature'], 'signature');
      },
    );

    // privacyidea#5618 phase 2: "Refresh the stored set from the already-signed
    // poll / fbtoken-update channel so it stays current after app upgrades - no
    // new endpoint."
    test('reports the app capabilities along with the poll', () async {
      await PushProvider(
        ioClient: mockIOClient,
        rsaUtils: mockRsaUtils,
      ).pollForChallenge(token);

      expect(capturedParameters()['capabilities'], '["decline_reason"]');
    });

    test('does not sign the reported capabilities', () async {
      await PushProvider(
        ioClient: mockIOClient,
        rsaUtils: mockRsaUtils,
      ).pollForChallenge(token);

      // A server that does not know the parameter rebuilds
      // '{serial}|{timestamp}' and has to arrive at the same signature.
      final signed =
          verify(mockRsaUtils.trySignWithToken(any, captureAny)).captured.last
              as String;
      expect(signed, '${token.serial}|${capturedParameters()['timestamp']}');
      expect(signed, isNot(contains('decline_reason')));
    });
  });
}
