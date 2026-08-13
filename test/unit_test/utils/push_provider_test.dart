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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/enums/biometric_push_key_status.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/enums/push_app_biometric_level.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';

import '../../tests_app_wrapper.dart';
import '../../tests_app_wrapper.mocks.dart';

void main() {
  group('PushProvider.pollForChallenge', () {
    late MockPrivacyideaIOClient mockIOClient;
    late MockRsaUtils mockRsaUtils;
    late PushToken token;

    Future<void> mountCurrentToken(WidgetTester tester) async {
      final tokenRepo = MockTokenRepository();
      when(tokenRepo.loadTokens()).thenAnswer((_) async => [token]);
      when(tokenRepo.saveOrReplaceToken(any)).thenAnswer((_) async => true);
      when(tokenRepo.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
      await tester.pumpWidget(
        TestsAppWrapper(
          wrapInMaterialApp: false,
          overrides: [
            tokenProvider.overrideWith(
              () => TokenNotifier(repoOverride: tokenRepo),
            ),
          ],
          child: const SizedBox(),
        ),
      );
      await globalRef!.read(tokenProvider.future);
    }

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
        mockRsaUtils.trySignWithToken(
          any,
          any,
          onTokenChanged: anyNamed('onTokenChanged'),
        ),
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

    tearDown(() => globalRef = null);

    Map<String, String?> capturedParameters() =>
        verify(
              mockIOClient.doGet(
                url: anyNamed('url'),
                parameters: captureAnyNamed('parameters'),
                sslVerify: anyNamed('sslVerify'),
              ),
            ).captured.last
            as Map<String, String?>;

    testWidgets('sends the parameters the server rebuilds the signature from', (
      tester,
    ) async {
      await mountCurrentToken(tester);
      await PushProvider(
        ioClient: mockIOClient,
        rsaUtils: mockRsaUtils,
      ).pollForChallenge(token);

      final parameters = capturedParameters();
      expect(parameters['serial'], token.serial);
      expect(parameters['timestamp'], isNotNull);
      expect(parameters['signature'], 'signature');
    });

    // privacyidea#5618 phase 2: "Refresh the stored set from the already-signed
    // poll / fbtoken-update channel so it stays current after app upgrades - no
    // new endpoint."
    testWidgets('reports the app capabilities along with the poll', (
      tester,
    ) async {
      await mountCurrentToken(tester);
      await PushProvider(
        ioClient: mockIOClient,
        rsaUtils: mockRsaUtils,
      ).pollForChallenge(token);

      expect(capturedParameters()['capabilities'], '["decline_reason"]');
    });

    testWidgets('does not sign the reported capabilities', (tester) async {
      await mountCurrentToken(tester);
      await PushProvider(
        ioClient: mockIOClient,
        rsaUtils: mockRsaUtils,
      ).pollForChallenge(token);

      // A server that does not know the parameter rebuilds
      // '{serial}|{timestamp}' and has to arrive at the same signature.
      final signed =
          verify(
                mockRsaUtils.trySignWithToken(
                  any,
                  captureAny,
                  onTokenChanged: anyNamed('onTokenChanged'),
                ),
              ).captured.last
              as String;
      expect(signed, '${token.serial}|${capturedParameters()['timestamp']}');
      expect(signed, isNot(contains('decline_reason')));
    });
  });

  test('manual Push polling serializes biometric-capable requests', () async {
    final firstMayFinish = Completer<void>();
    final events = <String>[];

    final polling = runPushPollingRequests<int>(
      [1, 2],
      sequential: true,
      request: (token) async {
        events.add('start-$token');
        if (token == 1) await firstMayFinish.future;
        events.add('end-$token');
      },
    );

    await Future<void>.delayed(Duration.zero);
    expect(events, ['start-1']);
    firstMayFinish.complete();
    await polling;
    expect(events, ['start-1', 'end-1', 'start-2', 'end-2']);
  });

  test('automatic Push polling may run safe requests in parallel', () async {
    final firstMayFinish = Completer<void>();
    final secondStarted = Completer<void>();
    final polling = runPushPollingRequests<int>(
      [1, 2],
      sequential: false,
      request: (token) async {
        if (token == 1) {
          await firstMayFinish.future;
        } else {
          secondStarted.complete();
        }
      },
    );
    await secondStarted.future;
    firstMayFinish.complete();
    await polling;
  });

  group('Dart Push key polling authorization', () {
    final weakToken = PushToken(
      serial: 'PIPU-weak',
      id: 'weak-id',
      forceBiometricOption: ForceBiometricOption.biometric,
      biometricLevel: PushAppBiometricLevel.any,
      invalidateOnBiometricChange: false,
      privateTokenKey: 'private-key',
    );

    test('automatic polling fails closed without opening a prompt', () async {
      var promptCount = 0;
      final authorized = await authorizePushDartKeyUseForPolling(
        weakToken,
        isManually: false,
        authenticate: () async {
          promptCount++;
          return true;
        },
      );
      expect(authorized, isFalse);
      expect(promptCount, 0);
    });

    test('manual polling authenticates once before Dart key use', () async {
      var promptCount = 0;
      final authorized = await authorizePushDartKeyUseForPolling(
        weakToken,
        isManually: true,
        authenticate: () async {
          promptCount++;
          return true;
        },
      );
      expect(authorized, isTrue);
      expect(promptCount, 1);
    });

    test('native protected key bypasses compatibility prompt', () async {
      final nativeToken = PushToken(
        serial: 'PIPU-native',
        id: 'native-id',
        forceBiometricOption: ForceBiometricOption.biometric,
        biometricKeyStatus: BiometricPushKeyStatus.protected,
      );
      var promptCount = 0;
      final authorized = await authorizePushDartKeyUseForPolling(
        nativeToken,
        isManually: true,
        authenticate: () async {
          promptCount++;
          return true;
        },
      );
      expect(authorized, isTrue);
      expect(promptCount, 0);
    });
  });
}
