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

import 'dart:convert';

import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result_detail.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result_value.dart';
import 'package:privacyidea_authenticator/model/container_policies.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:test/test.dart';

void main() {
  _testPiServerResult();
  _testPiServerResultValues();
  _testPiServerResultDetail();
}

void _testPiServerResult() {
  group('PiServerResult.fromResultMap', () {
    // jsonDecode returns _Map<String, dynamic> at runtime, which must be
    // accepted by the error field validator (was broken with Map<String, Object>).
    test('parses error from JSON-decoded map (_Map<String, dynamic>)', () {
      final json = jsonDecode(
        '{"status": false, "error": {"code": 3002, "message": "ERR3002: Could not verify signature!"}}',
      ) as Map<String, dynamic>;

      final result =
          PiServerResult<ContainerFinalizationResponse>.fromResultMap(json);

      expect(result.status, false);
      expect(result.error, isNotNull);
      expect(result.error!.code, 3002);
      expect(result.error!.message, contains('Could not verify signature'));
      expect(result.value, isNull);
    });

    test('error is null when status is false and no error field present', () {
      final json = jsonDecode('{"status": false}') as Map<String, dynamic>;

      final result =
          PiServerResult<ContainerFinalizationResponse>.fromResultMap(json);

      expect(result.status, false);
      expect(result.error, isNull);
      expect(result.value, isNull);
    });

    test('parses containerNotFound error code 601', () {
      final json = jsonDecode(
        '{"status": false, "error": {"code": 601, "message": "Unable to find container with serial SMPH001."}}',
      ) as Map<String, dynamic>;

      final result =
          PiServerResult<ContainerFinalizationResponse>.fromResultMap(json);

      expect(result.status, false);
      expect(result.error, isNotNull);
      expect(result.error!.code, 601);
    });

    test('parses containerNotRegistered error code 3001', () {
      final json = jsonDecode(
        '{"status": false, "error": {"code": 3001, "message": "Container is not registered."}}',
      ) as Map<String, dynamic>;

      final result =
          PiServerResult<ContainerFinalizationResponse>.fromResultMap(json);

      expect(result.status, false);
      expect(result.error, isNotNull);
      expect(result.error!.code, 3001);
    });
  });
}

void _testPiServerResultValues() {
  group('ContainerChallenge.fromUriMap', () {
    test('parses valid map', () {
      final map = {
        ContainerChallenge.KEY_ALGORITHM: 'secp384r1',
        ContainerChallenge.NONCE: 'abc123',
        ContainerChallenge.TIMESTAMP: '2024-12-06T11:14:26.885409+00:00',
      };
      final result = ContainerChallenge.fromUriMap(map);
      expect(result.keyAlgorithm, 'secp384r1');
      expect(result.nonce, 'abc123');
      expect(result.timeStamp, '2024-12-06T11:14:26.885409+00:00');
      expect(result.timeAsDatetime, DateTime.parse('2024-12-06T11:14:26.885409+00:00'));
    });

    test('throws on missing required field', () {
      final map = {
        ContainerChallenge.KEY_ALGORITHM: 'secp384r1',
        // NONCE missing
        ContainerChallenge.TIMESTAMP: '2024-12-06T11:14:26.885409+00:00',
      };
      expect(() => ContainerChallenge.fromUriMap(map), throwsA(anything));
    });
  });

  group('ContainerFinalizationResponse.fromUriMap', () {
    test('parses valid map with policies', () {
      final map = {
        TokenContainer.SYNC_POLICIES: {
          ContainerPolicies.ROLLOVER_ALLOWED: true,
          ContainerPolicies.INITIAL_TOKEN_ASSIGNMENT: false,
          ContainerPolicies.DISABLED_TOKEN_DELETION: true,
          ContainerPolicies.DISABLED_UNREGISTER: false,
        },
      };
      final result = ContainerFinalizationResponse.fromUriMap(map);
      expect(result.policies.rolloverAllowed, isTrue);
      expect(result.policies.initialTokenAssignment, isFalse);
      expect(result.policies.disabledTokenDeletion, isTrue);
      expect(result.policies.disabledUnregister, isFalse);
    });
  });

  group('UnregisterContainerResult.fromUriMap', () {
    test('parses success: true', () {
      final map = {UnregisterContainerResult.KEY_SUCCESS: true};
      final result = UnregisterContainerResult.fromUriMap(map);
      expect(result.success, isTrue);
    });

    test('parses success: false', () {
      final map = {UnregisterContainerResult.KEY_SUCCESS: false};
      final result = UnregisterContainerResult.fromUriMap(map);
      expect(result.success, isFalse);
    });

    test('throws on missing success field', () {
      expect(() => UnregisterContainerResult.fromUriMap({}), throwsA(anything));
    });
  });

  group('TransferQrData.fromUriMap', () {
    test('parses valid map', () {
      final map = {
        TransferQrData.KEY_CONTAINER_URL: {
          TransferQrData.KEY_DESCRIPTION: 'Test description',
          TransferQrData.KEY_VALUE: 'pia://container/...',
        },
      };
      final result = TransferQrData.fromUriMap(map);
      expect(result.description, 'Test description');
      expect(result.value, 'pia://container/...');
    });
  });

  group('PushResultValue', () {
    test('fromResultValue wraps bool correctly', () {
      expect(PushResultValue.fromResultValue(true).value, isTrue);
      expect(PushResultValue.fromResultValue(false).value, isFalse);
    });
  });

  group('PiServerResultValue.fromResultValue dispatch', () {
    test('dispatches to UnregisterContainerResult', () {
      final map = {UnregisterContainerResult.KEY_SUCCESS: true};
      final result = PiServerResultValue.fromResultValue<UnregisterContainerResult>(map);
      expect(result, isA<UnregisterContainerResult>());
      expect(result!.success, isTrue);
    });

    test('dispatches to ContainerChallenge', () {
      final map = {
        ContainerChallenge.KEY_ALGORITHM: 'secp384r1',
        ContainerChallenge.NONCE: 'nonce',
        ContainerChallenge.TIMESTAMP: '2024-12-06T11:14:26Z',
      };
      final result = PiServerResultValue.fromResultValue<ContainerChallenge>(map);
      expect(result, isA<ContainerChallenge>());
    });

    test('returns null for base PiServerResultValue type', () {
      final result = PiServerResultValue.fromResultValue<PiServerResultValue>({});
      expect(result, isNull);
    });
  });
}

void _testPiServerResultDetail() {
  group('PushResultDetail.fromUriMap', () {
    test('parses full map with all fields', () {
      final map = {
        PushResultDetail.DISPLAY_CODE: '1234',
        PushResultDetail.THREAD_ID: 42,
        PushResultDetail.MESSAGE: 'Login request',
      };
      final result = PushResultDetail.fromUriMap(map);
      expect(result.displayCode, '1234');
      expect(result.threadId, 42);
      expect(result.message, 'Login request');
    });

    test('parses map with only optional fields missing', () {
      final map = <String, dynamic>{
        PushResultDetail.DISPLAY_CODE: null,
        PushResultDetail.THREAD_ID: null,
      };
      final result = PushResultDetail.fromUriMap(map);
      expect(result.displayCode, isNull);
      expect(result.threadId, isNull);
      expect(result.message, isNull);
    });
  });

  group('PiServerResultDetail.fromResultDetail dispatch', () {
    test('returns PushResultDetail for PushResultDetail type', () {
      final map = {
        PushResultDetail.DISPLAY_CODE: '5678',
        PushResultDetail.THREAD_ID: 1,
        PushResultDetail.MESSAGE: 'msg',
      };
      final result = PiServerResultDetail.fromResultDetail<PushResultDetail>(map);
      expect(result, isA<PushResultDetail>());
      expect(result!.displayCode, '5678');
    });

    test('returns null for null input', () {
      final result = PiServerResultDetail.fromResultDetail<PushResultDetail>(null);
      expect(result, isNull);
    });

    test('returns null for unimplemented type', () {
      final result = PiServerResultDetail.fromResultDetail<EmptyResultDetail>({});
      expect(result, isNull);
    });
  });
}
