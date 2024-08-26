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

import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';

import '../../utils/logger.dart';

part 'container_credentials.freezed.dart';
part 'container_credentials.g.dart';

// issuer=privacyIDEA
// &serial=SMPH00134123
// &nonce=887197025f5fa59b50f33c15196eb97ee651a5d1
// &time=2024-08-21T07%3A43%3A07.086670%2B00%3A00
// &url="http://127.0.0.1:5000/container/register/finalize"
// &key_algorithm=secp384r1
// &hash_algorithm=SHA256
// &passphrase=Enter%20your%20passphrase

@freezed
class ContainerCredential with _$ContainerCredential {
  static const eccUtils = EccUtils();
  const ContainerCredential._();
  factory ContainerCredential.fromUriMap(Map<String, dynamic> uriMap) {
    validateMap(uriMap, {
      URI_ISSUER: const TypeMatcher<String>(),
      URI_NONCE: const TypeMatcher<String>(),
      URI_TIMESTAMP: const TypeMatcher<DateTime>(),
      URI_FINALIZATION_URL: const TypeMatcher<Uri>(),
      URI_SERIAL: const TypeMatcher<String>(),
      URI_KEY_ALGORITHM: const TypeMatcher<EcKeyAlgorithm>(),
      URI_HASH_ALGORITHM: const TypeMatcher<Algorithms>(),
    });
    return ContainerCredential.unfinalized(
      issuer: uriMap[URI_ISSUER],
      nonce: uriMap[URI_NONCE],
      timestamp: uriMap[URI_TIMESTAMP],
      finalizationUrl: uriMap[URI_FINALIZATION_URL],
      serial: uriMap[URI_SERIAL],
      ecKeyAlgorithm: uriMap[URI_KEY_ALGORITHM],
      hashAlgorithm: uriMap[URI_HASH_ALGORITHM],
    );
  }

  const factory ContainerCredential.unfinalized({
    required String issuer,
    required String nonce,
    required DateTime timestamp,
    required Uri finalizationUrl,
    required String serial,
    required EcKeyAlgorithm ecKeyAlgorithm,
    required Algorithms hashAlgorithm,
    @Default(ContainerFinalizationState.uninitialized) ContainerFinalizationState finalizationState,
    String? passphrase,
    String? publicServerKey,
    String? publicClientKey,
    String? privateClientKey,
  }) = ContainerCredentialUnfinalized;

  const factory ContainerCredential.finalized({
    required String issuer,
    required String nonce,
    required DateTime timestamp,
    required Uri finalizationUrl,
    required String serial,
    required EcKeyAlgorithm ecKeyAlgorithm,
    required Algorithms hashAlgorithm,
    @Default(ContainerFinalizationState.finalized) ContainerFinalizationState finalizationState,
    String? passphrase,
    required String publicServerKey,
    required String publicClientKey,
    required String privateClientKey,
  }) = ContainerCredentialFinalized;
  ContainerCredentialFinalized? finalize({
    ECPublicKey? publicServerKey,
    AsymmetricKeyPair<ECPublicKey, ECPrivateKey>? clientKeyPair,
  }) {
    if (this is ContainerCredentialFinalized) return this as ContainerCredentialFinalized;
    if (publicServerKey == null && this.publicServerKey == null) {
      Logger.warning('Unable to finalize without public server key');
      return null;
    }
    assert(publicServerKey != null || this.publicServerKey != null, 'Unable to finalize without public server key');
    if (clientKeyPair == null && (publicClientKey == null || privateClientKey == null)) {
      Logger.warning('Unable to finalize without client key pair');
      return null;
    }
    return ContainerCredentialFinalized(
      issuer: issuer,
      nonce: nonce,
      timestamp: timestamp,
      finalizationUrl: finalizationUrl,
      serial: serial,
      ecKeyAlgorithm: ecKeyAlgorithm,
      hashAlgorithm: hashAlgorithm,
      passphrase: passphrase,
      finalizationState: ContainerFinalizationState.finalized,
      publicServerKey: this.publicServerKey ?? eccUtils.serializeECPublicKey(publicServerKey!),
      publicClientKey: publicClientKey ?? eccUtils.serializeECPublicKey(clientKeyPair!.publicKey),
      privateClientKey: privateClientKey ?? eccUtils.serializeECPrivateKey(clientKeyPair!.privateKey),
    );
  }

  ECPublicKey? get ecPublicServerKey => publicServerKey == null ? null : eccUtils.deserializeECPublicKey(publicServerKey!);
  ContainerCredential withPublicServerKey(ECPublicKey publicServerKey) => copyWith(publicServerKey: eccUtils.serializeECPublicKey(publicServerKey));
  ECPublicKey? get ecPublicClientKey => publicClientKey == null ? null : eccUtils.deserializeECPublicKey(publicClientKey!);
  ECPrivateKey? get ecPrivateClientKey => privateClientKey == null ? null : eccUtils.deserializeECPrivateKey(privateClientKey!);

  /// Add client key pair and set finalization state to generatingKeyPairCompleted
  ContainerCredential withClientKeyPair(AsymmetricKeyPair<ECPublicKey, ECPrivateKey> keyPair) => copyWith(
        publicClientKey: eccUtils.serializeECPublicKey(keyPair.publicKey),
        privateClientKey: eccUtils.serializeECPrivateKey(keyPair.privateKey),
        finalizationState: ContainerFinalizationState.generatingKeyPairCompleted,
      );

  factory ContainerCredential.fromJson(Map<String, dynamic> json) => _$ContainerCredentialFromJson(json);

  // // Sign with private client key
  // String signMessage(String message) {
  //   final signer = Signer(hashAlgorithm.name);
  //   signer.init(true, PrivateKey(ecPrivateClientKey!.d, ecPrivateClientKey!.parameters));
  //   return signer.signMessage(message);
  // };
}

enum ContainerFinalizationState {
  uninitialized,
  generatingKeyPair,
  generatingKeyPairFailed,
  generatingKeyPairCompleted,
  sendingPublicKey,
  sendingPublicKeyFailed,
  sendingPublicKeyCompleted,
  parsingResponse,
  parsingResponseFailed,
  parsingResponseCompleted,
  finalized,
}

/// The following curves are supported:

enum EcKeyAlgorithm {
  brainpoolp160r1,
  brainpoolp160t1,
  brainpoolp192r1,
  brainpoolp192t1,
  brainpoolp224r1,
  brainpoolp224t1,
  brainpoolp256r1,
  brainpoolp256t1,
  brainpoolp320r1,
  brainpoolp320t1,
  brainpoolp384r1,
  brainpoolp384t1,
  brainpoolp512r1,
  brainpoolp512t1,
  GostR3410_2001_CryptoPro_A,
  GostR3410_2001_CryptoPro_B,
  GostR3410_2001_CryptoPro_C,
  GostR3410_2001_CryptoPro_XchA,
  GostR3410_2001_CryptoPro_XchB,
  prime192v1,
  prime192v2,
  prime192v3,
  prime239v1,
  prime239v2,
  prime239v3,
  prime256v1,
  secp112r1,
  secp112r2,
  secp128r1,
  secp128r2,
  secp160k1,
  secp160r1,
  secp160r2,
  secp192k1,
  secp192r1,
  secp224k1,
  secp224r1,
  secp256k1,
  secp256r1,
  secp384r1,
  secp521r1,
}

extension EcKeyAlgorithmList on List<EcKeyAlgorithm> {
  EcKeyAlgorithm byCurveName(String domainName) => switch (domainName) {
        'brainpoolp160r1' => EcKeyAlgorithm.brainpoolp160r1,
        'brainpoolp160t1' => EcKeyAlgorithm.brainpoolp160t1,
        'brainpoolp192r1' => EcKeyAlgorithm.brainpoolp192r1,
        'brainpoolp192t1' => EcKeyAlgorithm.brainpoolp192t1,
        'brainpoolp224r1' => EcKeyAlgorithm.brainpoolp224r1,
        'brainpoolp224t1' => EcKeyAlgorithm.brainpoolp224t1,
        'brainpoolp256r1' => EcKeyAlgorithm.brainpoolp256r1,
        'brainpoolp256t1' => EcKeyAlgorithm.brainpoolp256t1,
        'brainpoolp320r1' => EcKeyAlgorithm.brainpoolp320r1,
        'brainpoolp320t1' => EcKeyAlgorithm.brainpoolp320t1,
        'brainpoolp384r1' => EcKeyAlgorithm.brainpoolp384r1,
        'brainpoolp384t1' => EcKeyAlgorithm.brainpoolp384t1,
        'brainpoolp512r1' => EcKeyAlgorithm.brainpoolp512r1,
        'brainpoolp512t1' => EcKeyAlgorithm.brainpoolp512t1,
        'GostR3410-2001-CryptoPro-A' => EcKeyAlgorithm.GostR3410_2001_CryptoPro_A,
        'GostR3410-2001-CryptoPro-B' => EcKeyAlgorithm.GostR3410_2001_CryptoPro_B,
        'GostR3410-2001-CryptoPro-C' => EcKeyAlgorithm.GostR3410_2001_CryptoPro_C,
        'GostR3410-2001-CryptoPro-XchA' => EcKeyAlgorithm.GostR3410_2001_CryptoPro_XchA,
        'GostR3410-2001-CryptoPro-XchB' => EcKeyAlgorithm.GostR3410_2001_CryptoPro_XchB,
        'prime192v1' => EcKeyAlgorithm.prime192v1,
        'prime192v2' => EcKeyAlgorithm.prime192v2,
        'prime192v3' => EcKeyAlgorithm.prime192v3,
        'prime239v1' => EcKeyAlgorithm.prime239v1,
        'prime239v2' => EcKeyAlgorithm.prime239v2,
        'prime239v3' => EcKeyAlgorithm.prime239v3,
        'prime256v1' => EcKeyAlgorithm.prime256v1,
        'secp112r1' => EcKeyAlgorithm.secp112r1,
        'secp112r2' => EcKeyAlgorithm.secp112r2,
        'secp128r1' => EcKeyAlgorithm.secp128r1,
        'secp128r2' => EcKeyAlgorithm.secp128r2,
        'secp160k1' => EcKeyAlgorithm.secp160k1,
        'secp160r1' => EcKeyAlgorithm.secp160r1,
        'secp160r2' => EcKeyAlgorithm.secp160r2,
        'secp192k1' => EcKeyAlgorithm.secp192k1,
        'secp192r1' => EcKeyAlgorithm.secp192r1,
        'secp224k1' => EcKeyAlgorithm.secp224k1,
        'secp224r1' => EcKeyAlgorithm.secp224r1,
        'secp256k1' => EcKeyAlgorithm.secp256k1,
        'secp256r1' => EcKeyAlgorithm.secp256r1,
        'secp384r1' => EcKeyAlgorithm.secp384r1,
        'secp521r1' => EcKeyAlgorithm.secp521r1,
        _ => throw ArgumentError('Unknown domain name: $domainName'),
      };
}

extension EcKeyAlgorithmX on EcKeyAlgorithm {
  String get curveName => switch (this) {
        EcKeyAlgorithm.brainpoolp160r1 => 'brainpoolp160r1',
        EcKeyAlgorithm.brainpoolp160t1 => 'brainpoolp160t1',
        EcKeyAlgorithm.brainpoolp192r1 => 'brainpoolp192r1',
        EcKeyAlgorithm.brainpoolp192t1 => 'brainpoolp192t1',
        EcKeyAlgorithm.brainpoolp224r1 => 'brainpoolp224r1',
        EcKeyAlgorithm.brainpoolp224t1 => 'brainpoolp224t1',
        EcKeyAlgorithm.brainpoolp256r1 => 'brainpoolp256r1',
        EcKeyAlgorithm.brainpoolp256t1 => 'brainpoolp256t1',
        EcKeyAlgorithm.brainpoolp320r1 => 'brainpoolp320r1',
        EcKeyAlgorithm.brainpoolp320t1 => 'brainpoolp320t1',
        EcKeyAlgorithm.brainpoolp384r1 => 'brainpoolp384r1',
        EcKeyAlgorithm.brainpoolp384t1 => 'brainpoolp384t1',
        EcKeyAlgorithm.brainpoolp512r1 => 'brainpoolp512r1',
        EcKeyAlgorithm.brainpoolp512t1 => 'brainpoolp512t1',
        EcKeyAlgorithm.GostR3410_2001_CryptoPro_A => 'GostR3410-2001-CryptoPro-A',
        EcKeyAlgorithm.GostR3410_2001_CryptoPro_B => 'GostR3410-2001-CryptoPro-B',
        EcKeyAlgorithm.GostR3410_2001_CryptoPro_C => 'GostR3410-2001-CryptoPro-C',
        EcKeyAlgorithm.GostR3410_2001_CryptoPro_XchA => 'GostR3410-2001-CryptoPro-XchA',
        EcKeyAlgorithm.GostR3410_2001_CryptoPro_XchB => 'GostR3410-2001-CryptoPro-XchB',
        EcKeyAlgorithm.prime192v1 => 'prime192v1',
        EcKeyAlgorithm.prime192v2 => 'prime192v2',
        EcKeyAlgorithm.prime192v3 => 'prime192v3',
        EcKeyAlgorithm.prime239v1 => 'prime239v1',
        EcKeyAlgorithm.prime239v2 => 'prime239v2',
        EcKeyAlgorithm.prime239v3 => 'prime239v3',
        EcKeyAlgorithm.prime256v1 => 'prime256v1',
        EcKeyAlgorithm.secp112r1 => 'secp112r1',
        EcKeyAlgorithm.secp112r2 => 'secp112r2',
        EcKeyAlgorithm.secp128r1 => 'secp128r1',
        EcKeyAlgorithm.secp128r2 => 'secp128r2',
        EcKeyAlgorithm.secp160k1 => 'secp160k1',
        EcKeyAlgorithm.secp160r1 => 'secp160r1',
        EcKeyAlgorithm.secp160r2 => 'secp160r2',
        EcKeyAlgorithm.secp192k1 => 'secp192k1',
        EcKeyAlgorithm.secp192r1 => 'secp192r1',
        EcKeyAlgorithm.secp224k1 => 'secp224k1',
        EcKeyAlgorithm.secp224r1 => 'secp224r1',
        EcKeyAlgorithm.secp256k1 => 'secp256k1',
        EcKeyAlgorithm.secp256r1 => 'secp256r1',
        EcKeyAlgorithm.secp384r1 => 'secp384r1',
        EcKeyAlgorithm.secp521r1 => 'secp521r1',
      };
}

class EccUtils {
  final String algorithmName = 'EC';

  const EccUtils();

  String serializeECPublicKey(ECPublicKey publicKey) => CryptoUtils.encodeEcPublicKeyToPem(publicKey);
  ECPublicKey deserializeECPublicKey(String ecPublicKey) => CryptoUtils.ecPublicKeyFromPem(ecPublicKey);
  String serializeECPrivateKey(ECPrivateKey ecPrivateKey) => CryptoUtils.encodeEcPrivateKeyToPem(ecPrivateKey);
  ECPrivateKey deserializeECPrivateKey(String ecPrivateKey) => CryptoUtils.ecPrivateKeyFromPem(ecPrivateKey);

  String trySignWithPrivateKey(ECPrivateKey privateKey, String message) {
    final ecSignature = CryptoUtils.ecSign(privateKey, Uint8List.fromList(message.codeUnits));
    String signatureBase64 = CryptoUtils.ecSignatureToBase64(ecSignature);
    return signatureBase64;
  }
}
