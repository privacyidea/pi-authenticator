// ignore_for_file: constant_identifier_names

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

import 'package:basic_utils/basic_utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../../model/enums/algorithms.dart';
import '../../../../../../../model/extensions/enums/ec_key_algorithm_extension.dart';
import '../../../../../../../model/tokens/token.dart';
import '../../../../../../../utils/identifiers.dart';
import '../utils/ecc_utils.dart';
import '../utils/logger.dart';
import '../utils/object_validator.dart';
import 'container_policies.dart';
import 'enums/ec_key_algorithm.dart';
import 'enums/rollout_state.dart';
import 'enums/sync_state.dart';
import 'enums/token_origin_source_type.dart';
import 'token_import/token_origin_data.dart';

part 'token_container.freezed.dart';
part 'token_container.g.dart';

@Freezed(toStringOverride: false, addImplicitFinal: true, toJson: true, fromJson: true)
class TokenContainer with _$TokenContainer {
  static const SERIAL = 'serial';
  static const eccUtils = EccUtils();
  const TokenContainer._();

  Uri get registrationUrl => serverUrl.replace(path: '/container/register/finalize');
  Uri get challengeUrl => serverUrl.replace(path: '/container/$serial/challenge');
  Uri get syncUrl => serverUrl.replace(path: '/container/$serial/sync');
  Uri get transferUrl => serverUrl.replace(path: '/container/$serial/rollover');
  Uri get unregisterUrl => serverUrl.replace(path: '/container/register/$serial/terminate/client');

  // example: pia://container/SMPH00134123
  // ?issuer=privacyIDEA
  // &nonce=887197025f5fa59b50f33c15196eb97ee651a5d1
  // &time=2024-08-21T07%3A43%3A07.086670%2B00%3A00
  // &url=http://127.0.0.1:5000/container/register/initialize
  // &serial=SMPH00134123
  // &key_algorithm=secp384r1
  // &hash_algorithm=SHA256
  // &passphrase=Enter%20your%20passphrase
  factory TokenContainer.fromUriMap(Map<String, dynamic> uriMap) {
    uriMap = validateMap(
      map: uriMap,
      validators: {
        CONTAINER_ISSUER: const ObjectValidator<String>(),
        CONTAINER_NONCE: const ObjectValidator<String>(),
        CONTAINER_TIMESTAMP: ObjectValidator<DateTime>(transformer: (v) => DateTime.parse(v)),
        CONTAINER_FINALIZATION_URL: stringToUrivalidator,
        CONTAINER_SERIAL: const ObjectValidator<String>(),
        CONTAINER_EC_KEY_ALGORITHM: ObjectValidator<EcKeyAlgorithm>(transformer: (v) => EcKeyAlgorithm.values.byCurveName(v)),
        CONTAINER_HASH_ALGORITHM: stringToAlgorithmsValidator,
        CONTAINER_PASSPHRASE_QUESTION: const ObjectValidatorNullable<String>(),
        CONTAINER_SSL_VERIFY: boolValidator,
        CONTAINER_POLICIES: ObjectValidatorNullable<ContainerPolicies>(transformer: (value) => ContainerPolicies.fromUriMap(value)),
      },
      name: 'Container',
    );
    return TokenContainer.unfinalized(
      issuer: uriMap[CONTAINER_ISSUER],
      nonce: uriMap[CONTAINER_NONCE],
      timestamp: uriMap[CONTAINER_TIMESTAMP],
      serverUrl: uriMap[CONTAINER_FINALIZATION_URL],
      serial: uriMap[CONTAINER_SERIAL],
      ecKeyAlgorithm: uriMap[CONTAINER_EC_KEY_ALGORITHM],
      hashAlgorithm: uriMap[CONTAINER_HASH_ALGORITHM],
      sslVerify: uriMap[CONTAINER_SSL_VERIFY],
      passphraseQuestion: uriMap[CONTAINER_PASSPHRASE_QUESTION],
      policies: uriMap[CONTAINER_POLICIES] ?? ContainerPolicies.defaultSetting,
    );
  }

  const factory TokenContainer.unfinalized({
    required String issuer,
    required String nonce,
    required DateTime timestamp,
    required Uri serverUrl,
    required String serial,
    required EcKeyAlgorithm ecKeyAlgorithm,
    required Algorithms hashAlgorithm,
    required bool sslVerify,
    @Default('privacyIDEA') String serverName,
    @Default(RolloutState.completed) RolloutState finalizationState,
    @Default(ContainerPolicies.defaultSetting) ContainerPolicies policies,
    bool? addDeviceInfos,
    String? passphraseQuestion,
    String? publicServerKey,
    String? publicClientKey,
    String? privateClientKey,
  }) = TokenContainerUnfinalized;

  const factory TokenContainer.finalized({
    required String issuer,
    required String nonce,
    required DateTime timestamp,
    required Uri serverUrl,
    required String serial,
    required EcKeyAlgorithm ecKeyAlgorithm,
    required Algorithms hashAlgorithm,
    required bool sslVerify,
    @Default('privacyIDEA') String serverName,
    @Default(RolloutState.completed) RolloutState finalizationState,
    @Default(SyncState.notStarted) SyncState syncState,
    @Default(ContainerPolicies.defaultSetting) ContainerPolicies policies,
    String? passphraseQuestion,
    required String publicServerKey,
    required String publicClientKey,
    required String privateClientKey,
  }) = TokenContainerFinalized;

  TokenContainerFinalized? finalize({
    ECPublicKey? publicServerKey,
    AsymmetricKeyPair<ECPublicKey, ECPrivateKey>? clientKeyPair,
  }) {
    if (this is TokenContainerFinalized) return this as TokenContainerFinalized;
    if (publicServerKey == null && this.publicServerKey == null) {
      Logger.warning('Unable to finalize without public server key');
      return null;
    }
    if (clientKeyPair == null && (publicClientKey == null || privateClientKey == null)) {
      Logger.warning('Unable to finalize without client key pair');
      return null;
    }

    return TokenContainerFinalized(
      issuer: issuer,
      nonce: nonce,
      timestamp: timestamp,
      serial: serial,
      serverUrl: serverUrl,
      ecKeyAlgorithm: ecKeyAlgorithm,
      hashAlgorithm: hashAlgorithm,
      sslVerify: sslVerify,
      passphraseQuestion: passphraseQuestion,
      finalizationState: RolloutState.completed,
      serverName: serverName,
      policies: policies,
      syncState: SyncState.notStarted,
      publicServerKey: this.publicServerKey ?? eccUtils.serializeECPublicKey(publicServerKey!),
      publicClientKey: publicClientKey ?? eccUtils.serializeECPublicKey(clientKeyPair!.publicKey),
      privateClientKey: privateClientKey ?? eccUtils.serializeECPrivateKey(clientKeyPair!.privateKey),
    );
  }

  ECPublicKey? get ecPublicServerKey => publicServerKey == null ? null : eccUtils.deserializeECPublicKey(publicServerKey!);
  TokenContainer withPublicServerKey(ECPublicKey publicServerKey) => copyWith(publicServerKey: eccUtils.serializeECPublicKey(publicServerKey));
  ECPublicKey? get ecPublicClientKey => publicClientKey == null ? null : eccUtils.deserializeECPublicKey(publicClientKey!);
  ECPrivateKey? get ecPrivateClientKey => privateClientKey == null ? null : eccUtils.deserializeECPrivateKey(privateClientKey!);
  AsymmetricKeyPair<ECPublicKey, ECPrivateKey>? get clientKeyPair =>
      ecPublicClientKey == null || ecPrivateClientKey == null ? null : AsymmetricKeyPair(ecPublicClientKey!, ecPrivateClientKey!);

  /// Add client key pair and set finalization state to generatingKeyPairCompleted
  TokenContainer withClientKeyPair(AsymmetricKeyPair<ECPublicKey, ECPrivateKey> keyPair) => copyWith(
        publicClientKey: eccUtils.serializeECPublicKey(keyPair.publicKey),
        privateClientKey: eccUtils.serializeECPrivateKey(keyPair.privateKey),
        finalizationState: RolloutState.generatingKeyPairCompleted,
      );

  factory TokenContainer.fromJson(Map<String, dynamic> json) => json["runtimeType"] == "finalized"
      ? (_$TokenContainerFromJson(json) as TokenContainerFinalized)
          .copyWith(syncState: json["syncState"] == "syncing" ? SyncState.failed : SyncState.values.byName(json["syncState"]))
      : _$TokenContainerFromJson(json);

  @override
  String toString() => '$runtimeType('
      'issuer: $issuer, '
      'nonce: $nonce, '
      'timestamp: $timestamp, '
      'serverUrl: $serverUrl, '
      'serial: $serial, '
      'ecKeyAlgorithm: $ecKeyAlgorithm, '
      'hashAlgorithm: $hashAlgorithm, '
      'finalizationState: $finalizationState, '
      '${(this is TokenContainerFinalized) ? 'syncState: ${(this as TokenContainerFinalized).syncState}, ' : ''}'
      'passphraseQuestion: $passphraseQuestion, '
      'publicServerKey: $publicServerKey, '
      'publicClientKey: $publicClientKey)';

  String signMessage(String msg) {
    assert(ecPrivateClientKey != null, 'Unable to sign without private client key');
    return eccUtils.signWithPrivateKey(ecPrivateClientKey!, msg);
  }

  String? trySignMessage(String msg) => ecPrivateClientKey == null ? null : eccUtils.signWithPrivateKey(ecPrivateClientKey!, msg);

  Token addOriginToToken({required Token token, String? tokenData}) => token.copyWith(
        containerSerial: () => serial,
        origin: token.origin == null
            ? TokenOriginData.fromContainer(container: this, tokenData: tokenData ?? '')
            : token.origin!.copyWith(
                source: TokenOriginSourceType.container,
                isPrivacyIdeaToken: () => true,
                data: token.origin!.data.isEmpty ? tokenData : token.origin!.data,
              ),
      );
}
