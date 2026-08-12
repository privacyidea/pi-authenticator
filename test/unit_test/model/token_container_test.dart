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
import 'package:privacyidea_authenticator/model/container_policies.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/enums/rollout_state.dart';
import 'package:privacyidea_authenticator/model/enums/sync_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';

void main() {
  _testTokenContainerFromUriMap();
  _testTokenContainerUrls();
  _testTokenContainerExpirationDate();
  _testTokenContainerFinalize();
  _testTokenContainerCopyWith();
}

TokenContainerUnfinalized buildUnfinalized({
  String serial = 'SMPH001',
  String nonce = 'nonce123',
  String issuer = 'privacyIDEA',
  Duration ttl = const Duration(minutes: 10),
  String? publicClientKey,
  String? privateClientKey,
}) => TokenContainerUnfinalized(
  issuer: issuer,
  ttl: ttl,
  nonce: nonce,
  timestamp: DateTime.now(),
  serverUrl: Uri.parse('https://example.com'),
  serial: serial,
  ecKeyAlgorithm: EcKeyAlgorithm.secp384r1,
  hashAlgorithm: Algorithms.SHA256,
  sslVerify: true,
  publicClientKey: publicClientKey,
  privateClientKey: privateClientKey,
);

TokenContainerFinalized buildFinalized({
  String serial = 'SMPH001',
  SyncState syncState = SyncState.notStarted,
  ContainerPolicies? policies,
}) => TokenContainerFinalized(
  issuer: 'privacyIDEA',
  nonce: 'nonce123',
  timestamp: DateTime.now(),
  serverUrl: Uri.parse('https://example.com'),
  serial: serial,
  ecKeyAlgorithm: EcKeyAlgorithm.secp384r1,
  hashAlgorithm: Algorithms.SHA256,
  sslVerify: true,
  publicClientKey: 'pubKey',
  privateClientKey: 'privKey',
  syncState: syncState,
  policies: policies ?? ContainerPolicies.defaultSetting,
);

void _testTokenContainerFromUriMap() {
  group('TokenContainer.fromUriMap', () {
    test('parses valid map into TokenContainerUnfinalized', () {
      final map = {
        TokenContainer.ISSUER: 'privacyIDEA',
        TokenContainer.TTL_MINUTES: Duration(minutes: 10),
        TokenContainer.NONCE: 'abc123',
        TokenContainer.TIMESTAMP: DateTime.parse('2024-12-06T11:14:26Z'),
        TokenContainer.FINALIZATION_URL: Uri.parse('https://example.com'),
        TokenContainer.SERIAL: 'SMPH001',
        TokenContainer.EC_KEY_ALGORITHM: EcKeyAlgorithm.secp384r1,
        TokenContainer.HASH_ALGORITHM: Algorithms.SHA256,
        TokenContainer.SSL_VERIFY: true,
        TokenContainer.PASSPHRASE_QUESTION: 'Your pet name?',
      };
      final result = TokenContainer.fromUriMap(map);
      expect(result, isA<TokenContainerUnfinalized>());
      final c = result as TokenContainerUnfinalized;
      expect(c.issuer, 'privacyIDEA');
      expect(c.ttl, const Duration(minutes: 10));
      expect(c.nonce, 'abc123');
      expect(c.serial, 'SMPH001');
      expect(c.ecKeyAlgorithm, EcKeyAlgorithm.secp384r1);
      expect(c.hashAlgorithm, Algorithms.SHA256);
      expect(c.sslVerify, isTrue);
      expect(c.passphraseQuestion, 'Your pet name?');
    });

    test('uses default policies when POLICIES key absent', () {
      final map = {
        TokenContainer.ISSUER: 'privacyIDEA',
        TokenContainer.TTL_MINUTES: Duration(minutes: 5),
        TokenContainer.NONCE: 'n',
        TokenContainer.TIMESTAMP: DateTime.now(),
        TokenContainer.FINALIZATION_URL: Uri.parse('https://example.com'),
        TokenContainer.SERIAL: 'S',
        TokenContainer.EC_KEY_ALGORITHM: EcKeyAlgorithm.secp384r1,
        TokenContainer.HASH_ALGORITHM: Algorithms.SHA256,
        TokenContainer.SSL_VERIFY: false,
      };
      final result =
          TokenContainer.fromUriMap(map) as TokenContainerUnfinalized;
      expect(result.policies, equals(ContainerPolicies.defaultSetting));
    });

    test('throws on missing required field (nonce)', () {
      final map = {
        TokenContainer.ISSUER: 'privacyIDEA',
        TokenContainer.TTL_MINUTES: Duration(minutes: 10),
        TokenContainer.TIMESTAMP: DateTime.now(),
        TokenContainer.FINALIZATION_URL: Uri.parse('https://example.com'),
        TokenContainer.SERIAL: 'S',
        TokenContainer.EC_KEY_ALGORITHM: EcKeyAlgorithm.secp384r1,
        TokenContainer.HASH_ALGORITHM: Algorithms.SHA256,
        TokenContainer.SSL_VERIFY: true,
      };
      expect(() => TokenContainer.fromUriMap(map), throwsA(anything));
    });
  });
}

void _testTokenContainerUrls() {
  group('TokenContainer URL properties', () {
    final base = Uri.parse('https://pi.example.com');
    final container = buildUnfinalized().copyWith(serverUrl: base);

    test('registrationUrl replaces path correctly', () {
      expect(container.registrationUrl.path, '/container/register/finalize');
      expect(container.registrationUrl.host, 'pi.example.com');
    });

    test('challengeUrl replaces path correctly', () {
      expect(container.challengeUrl.path, '/container/challenge');
    });

    test('syncUrl replaces path correctly', () {
      expect(container.syncUrl.path, '/container/synchronize');
    });

    test('unregisterUrl replaces path correctly', () {
      expect(
        container.unregisterUrl.path,
        '/container/register/terminate/client',
      );
    });

    test('transferUrl replaces path correctly', () {
      expect(container.transferUrl.path, '/container/rollover');
    });
  });
}

void _testTokenContainerExpirationDate() {
  group('TokenContainer.expirationDate', () {
    test('is timestamp + ttl for unfinalized container', () {
      final ts = DateTime(2024, 1, 1, 12);
      final c = buildUnfinalized(
        ttl: const Duration(minutes: 30),
      ).copyWith(timestamp: ts);
      expect(c.expirationDate, equals(ts.add(const Duration(minutes: 30))));
    });

    test('is null for finalized container', () {
      expect(buildFinalized().expirationDate, isNull);
    });
  });
}

void _testTokenContainerFinalize() {
  group('TokenContainer.finalize', () {
    const pubKey =
        "-----BEGIN PUBLIC KEY-----\n"
        "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAE8Xs0q2PPvkIlKTcQkMxMDnv/4tH3dDqg\n"
        "lK42aHN11oT+wJDn11cGJ5b5uuu2owfePgNDzlTwhK3Bvx2x5NBm/JWztUOaWI29\n"
        "zdwE1yJStBySahE2CIGfKc1RfcASp5/4\n"
        "-----END PUBLIC KEY-----";
    const privKey =
        "-----BEGIN EC PRIVATE KEY-----\n"
        "MIGkAgEBBDCleRofxXJwTtc0HUeE/Af8P4depFM0KY7oT4hMQdt3geK5uDWEOZn4\n"
        "DaCMTGrsSP2gBwYFK4EEACKhZANiAATxezSrY8++QiUpNxCQzEwOe//i0fd0OqCU\n"
        "rjZoc3XWhP7AkOfXVwYnlvm667ajB94+A0POVPCErcG/HbHk0Gb8lbO1Q5pYjb3N\n"
        "3ATXIlK0HJJqETYIgZ8pzVF9wBKnn/g=\n"
        "-----END EC PRIVATE KEY-----";

    test('returns null when no key pair and no serialized keys', () {
      final c = buildUnfinalized();
      expect(c.finalize(), isNull);
    });

    test(
      'returns TokenContainerFinalized when serialized keys are present',
      () {
        final c = buildUnfinalized(
          publicClientKey: pubKey,
          privateClientKey: privKey,
        );
        final result = c.finalize();
        expect(result, isA<TokenContainerFinalized>());
        expect(result!.serial, c.serial);
        expect(result.issuer, c.issuer);
        expect(result.publicClientKey, pubKey);
        expect(result.privateClientKey, privKey);
        expect(result.finalizationState, FinalizationState.completed);
      },
    );

    test('returns self when already finalized', () {
      final c = buildFinalized();
      final result = c.finalize();
      expect(result, same(c));
    });

    test('finalize with generated key pair', () {
      final c = buildUnfinalized(serial: 'SMPH002');
      const eccUtils = EccUtils();
      final keyPair = eccUtils.generateKeyPair(EcKeyAlgorithm.secp384r1);
      final result = c.finalize(clientKeyPair: keyPair);
      expect(result, isA<TokenContainerFinalized>());
      expect(result!.publicClientKey, isNotEmpty);
      expect(result.privateClientKey, isNotEmpty);
    });
  });
}

void _testTokenContainerCopyWith() {
  group('TokenContainer.copyWith', () {
    test('unfinalized copyWith changes issuer', () {
      final original = buildUnfinalized(issuer: 'original');
      final copy = original.copyWith(issuer: 'updated');
      expect(copy.issuer, 'updated');
      expect(copy.serial, original.serial);
    });

    test('finalized copyWith changes syncState', () {
      final original = buildFinalized();
      final copy = original.copyWith(syncState: SyncState.completed);
      expect(copy.syncState, SyncState.completed);
      expect(copy.serial, original.serial);
    });

    test('finalized copyWith changes policies', () {
      final original = buildFinalized(
        policies: ContainerPolicies(
          rolloverAllowed: false,
          initialTokenAssignment: false,
          disabledTokenDeletion: false,
          disabledUnregister: false,
        ),
      );
      final copy = original.copyWith(
        policies: ContainerPolicies(
          rolloverAllowed: true,
          initialTokenAssignment: true,
          disabledTokenDeletion: true,
          disabledUnregister: true,
        ),
      );
      expect(copy.policies.disabledUnregister, isTrue);
      expect(copy.policies.rolloverAllowed, isTrue);
    });
  });
}
