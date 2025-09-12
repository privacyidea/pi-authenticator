/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

@Freezed(
  toStringOverride: false,
  addImplicitFinal: true,
  toJson: true,
  fromJson: true,
)
sealed class TokenContainer with _$TokenContainer {
  static const String CONTAINER_SERIAL = 'container_serial';

  // Container finalization:
  static const String FINALIZE_PUBLIC_CLIENT_KEY = 'public_client_key';
  static const String FINALIZE_DEVICE_BRAND = 'device_brand';
  static const String FINALIZE_DEVICE_MODEL = 'device_model';
  static const String FINALIZE_SIGNATURE = 'signature';
  static const String FINALIZE_PASSPHRASE = 'passphrase';

  // Container sync:
  static const String SYNC_PUBLIC_CLIENT_KEY = 'public_enc_key_client';
  static const String SYNC_DICT_SERVER = 'container_dict_server';
  static const String SYNC_DICT_CLIENT = 'container_dict_client';
  static const String SYNC_ENC_ALGORITHM = 'encryption_algorithm';
  static const String SYNC_ENC_PARAMS = 'encryption_params';
  static const String SYNC_POLICIES = 'policies';
  static const String SYNC_PUBLIC_SERVER_KEY = 'public_server_key';

  // Container Mapping:
  static const String DICT_CONTAINER = 'container';
  static const String DICT_TYPE = 'type';
  static const String DICT_TYPE_SMARTPHONE = 'smartphone';
  static const String DICT_TOKENS = 'tokens';
  static const String DICT_TOKENS_ADD = 'add';
  static const String DICT_TOKENS_UPDATE = 'update';

  // Container registration:
  static const String ISSUER = 'issuer';
  static const String TTL_MINUTES = 'ttl';
  static const String NONCE = 'nonce';
  static const String TIMESTAMP = 'time';
  static const String FINALIZATION_URL = 'url';
  static const String EC_KEY_ALGORITHM = 'key_algorithm';
  static const String SERIAL = 'serial';
  static const String HASH_ALGORITHM = 'hash_algorithm';
  static const String PASSPHRASE_QUESTION = 'passphrase';
  static const String SSL_VERIFY = 'ssl_verify';
  static const String SERVER_URL = 'container_sync_url';
  static const String SCOPE = 'scope';
  static const String POLICIES = 'info';
  static const String SEND_PASSPHRASE = 'send_passphrase';

  static const eccUtils = EccUtils();

  const TokenContainer._();

  Uri get registrationUrl =>
      serverUrl.replace(path: '/container/register/finalize');
  Uri get challengeUrl => serverUrl.replace(path: '/container/challenge');
  Uri get syncUrl => serverUrl.replace(path: '/container/synchronize');
  Uri get transferUrl => serverUrl.replace(path: '/container/rollover');
  Uri get unregisterUrl =>
      serverUrl.replace(path: '/container/register/terminate/client');

  DateTime? get expirationDate => this is TokenContainerUnfinalized
      ? timestamp.add((this as TokenContainerUnfinalized).ttl)
      : null;

  // example: "pia://container/SMPH00067A2F"
  // "?issuer=privacyIDEA"
  // "&ttl=10"
  // "&nonce=b33d3a11c8d1b45f19640035e27944ccf0b2383d"
  // "&time=2024-12-06T11%3A14%3A26.885409%2B00%3A00"
  // "&url=http://192.168.0.230:5000/"
  // "&serial=SMPH00067A2F"
  // "&key_algorithm=secp384r1"
  // "&hash_algorithm=SHA256"
  // "&ssl_verify=False"
  // "&passphrase=Enter%20your%20password"
  // "&send_passphrase=False"
  factory TokenContainer.fromUriMap(Map<String, dynamic> uriMap) {
    uriMap = validateMap(
      map: uriMap,
      validators: {
        ISSUER: const ObjectValidator<String>(),
        TTL_MINUTES: minutesDurationValidator.withDefault(
          const Duration(minutes: 10),
        ),
        NONCE: const ObjectValidator<String>(),
        TIMESTAMP: ObjectValidator<DateTime>(
          transformer: (v) => DateTime.parse(v),
        ),
        FINALIZATION_URL: uriValidator,
        SERIAL: const ObjectValidator<String>(),
        EC_KEY_ALGORITHM: ObjectValidator<EcKeyAlgorithm>(
          transformer: (v) => EcKeyAlgorithm.values.byCurveName(v),
        ),
        HASH_ALGORITHM: stringToAlgorithmsValidator,
        PASSPHRASE_QUESTION: const ObjectValidatorNullable<String>(),
        SSL_VERIFY: boolValidator,
        POLICIES: ObjectValidatorNullable<ContainerPolicies>(
          transformer: (value) => ContainerPolicies.fromUriMap(value),
        ),
        SEND_PASSPHRASE: boolValidatorNullable,
      },
      name: 'Container',
    );
    return TokenContainer.unfinalized(
      issuer: uriMap[ISSUER],
      ttl: uriMap[TTL_MINUTES],
      nonce: uriMap[NONCE],
      timestamp: uriMap[TIMESTAMP],
      serverUrl: uriMap[FINALIZATION_URL],
      serial: uriMap[SERIAL],
      ecKeyAlgorithm: uriMap[EC_KEY_ALGORITHM],
      hashAlgorithm: uriMap[HASH_ALGORITHM],
      sslVerify: uriMap[SSL_VERIFY],
      passphraseQuestion: uriMap[PASSPHRASE_QUESTION],
      policies: uriMap[POLICIES] ?? ContainerPolicies.defaultSetting,
      sendPassphrase: uriMap[SEND_PASSPHRASE] ?? false,
    );
  }

  const factory TokenContainer.unfinalized({
    required String issuer,
    required Duration ttl,
    required String nonce,
    required DateTime timestamp,
    required Uri serverUrl,
    required String serial,
    required EcKeyAlgorithm ecKeyAlgorithm,
    required Algorithms hashAlgorithm,
    required bool sslVerify,
    @Default('privacyIDEA') String serverName,
    @Default(FinalizationState.notStarted) FinalizationState finalizationState,
    @Default(ContainerPolicies.defaultSetting) ContainerPolicies policies,
    bool? addDeviceInfos,
    String? passphraseQuestion,
    String? publicClientKey,
    String? privateClientKey,
    @Default(false) bool sendPassphrase,
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
    @Default(FinalizationState.completed) FinalizationState finalizationState,
    @Default(SyncState.notStarted) SyncState syncState,
    @Default(ContainerPolicies.defaultSetting) ContainerPolicies policies,
    @Default(false) bool initSynced,
    String? passphraseQuestion,
    required String publicClientKey,
    required String privateClientKey,
  }) = TokenContainerFinalized;

  TokenContainerFinalized? finalize({
    AsymmetricKeyPair<ECPublicKey, ECPrivateKey>? clientKeyPair,
  }) {
    if (this is TokenContainerFinalized) return this as TokenContainerFinalized;
    if (clientKeyPair == null &&
        (publicClientKey == null || privateClientKey == null)) {
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
      finalizationState: FinalizationState.completed,
      serverName: serverName,
      policies: policies,
      syncState: SyncState.notStarted,
      publicClientKey:
          publicClientKey ??
          eccUtils.serializeECPublicKey(clientKeyPair!.publicKey),
      privateClientKey:
          privateClientKey ??
          eccUtils.serializeECPrivateKey(clientKeyPair!.privateKey),
    );
  }

  ECPublicKey? get ecPublicClientKey => publicClientKey == null
      ? null
      : eccUtils.deserializeECPublicKey(publicClientKey!);
  ECPrivateKey? get ecPrivateClientKey => privateClientKey == null
      ? null
      : eccUtils.deserializeECPrivateKey(privateClientKey!);
  AsymmetricKeyPair<ECPublicKey, ECPrivateKey>? get clientKeyPair =>
      ecPublicClientKey == null || ecPrivateClientKey == null
      ? null
      : AsymmetricKeyPair(ecPublicClientKey!, ecPrivateClientKey!);

  /// Add client key pair and set finalization state to generatingKeyPairCompleted
  TokenContainer withClientKeyPair(
    AsymmetricKeyPair<ECPublicKey, ECPrivateKey> keyPair,
  ) => copyWith(
    publicClientKey: eccUtils.serializeECPublicKey(keyPair.publicKey),
    privateClientKey: eccUtils.serializeECPrivateKey(keyPair.privateKey),
    finalizationState: FinalizationState.generatingKeyPairCompleted,
  );

  factory TokenContainer.fromJson(Map<String, dynamic> json) =>
      _$TokenContainerFromJson(json);
  @override
  String toString() =>
      '$runtimeType('
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
      'publicClientKey: $publicClientKey)';

  String signMessage(String msg) {
    assert(
      ecPrivateClientKey != null,
      'Unable to sign without private client key',
    );
    return eccUtils.signWithPrivateKey(ecPrivateClientKey!, msg);
  }

  String? trySignMessage(String msg) => ecPrivateClientKey == null
      ? null
      : eccUtils.signWithPrivateKey(ecPrivateClientKey!, msg);

  Token addOriginToToken({required Token token, String? tokenData}) =>
      token.copyWith(
        containerSerial: () => serial,
        origin: token.origin == null
            ? TokenOriginData.fromContainer(
                container: this,
                tokenData: tokenData ?? '',
              )
            : token.origin!.copyWith(
                source: TokenOriginSourceType.container,
                isPrivacyIdeaToken: () => true,
                data: token.origin!.data.isEmpty
                    ? tokenData
                    : token.origin!.data,
              ),
      );
}
