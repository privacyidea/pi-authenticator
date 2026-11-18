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
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart' show CryptoUtils;
import 'package:pointycastle/export.dart';

import '../model/enums/ec_key_algorithm.dart';
import 'ecc_utils.dart';
import 'helpers/base32_helper.dart';
import 'logger.dart';
import 'rsa_utils.dart';

/// The ECDSA P-256 keys a push token uses instead of RSA 4096 when
/// `secp256r1` is the first entry of the `key_algorithm` list in the
/// enrollment link that this app knows.
///
/// Wire format, the same in both directions:
/// * public keys: SubjectPublicKeyInfo DER, base64 without PEM header,
/// * signatures: SHA-256/ECDSA, DER encoded, then base32 like the RSA ones.
class PushKeyUtils {
  const PushKeyUtils();

  /// The only curve push tokens use.
  static const EcKeyAlgorithm ecKeyAlgorithm = EcKeyAlgorithm.secp256r1;

  static const String _signingAlgorithm = 'SHA-256/ECDSA';

  /// The names P-256 goes by (SEC 2 and X9.62), as a decoded key reports its
  /// curve.
  static const Set<String> _p256Names = {'secp256r1', 'prime256v1'};

  AsymmetricKeyPair<ECPublicKey, ECPrivateKey> generateKeyPair() =>
      const EccUtils().generateKeyPair(ecKeyAlgorithm);

  /// [publicKey] as SubjectPublicKeyInfo DER, base64 without header or line
  /// breaks.
  String encodePublicKey(ECPublicKey publicKey) => base64.encode(
    CryptoUtils.getBytesFromPEMString(
      CryptoUtils.encodeEcPublicKeyToPem(publicKey),
    ),
  );

  /// Reads a base64 SubjectPublicKeyInfo DER. Throws an [ArgumentError] if it
  /// is not a P-256 key.
  ECPublicKey decodePublicKey(String base64Spki) {
    final ECPublicKey key;
    try {
      key = CryptoUtils.ecPublicKeyFromDerBytes(
        base64.decode(base64Spki.replaceAll(RegExp(r'\s'), '')),
      );
    } on ArgumentError {
      rethrow;
    } catch (e) {
      throw ArgumentError.value(
        base64Spki,
        'publicKey',
        'Not an EC SubjectPublicKeyInfo: $e',
      );
    }
    final curve = key.parameters?.domainName;
    if (!_p256Names.contains(curve)) {
      throw ArgumentError.value(curve, 'curve', 'Push tokens use P-256 keys');
    }
    return key;
  }

  /// SHA-256/ECDSA signature of [message], DER encoded.
  Uint8List sign(ECPrivateKey privateKey, Uint8List message) {
    final signature = CryptoUtils.ecSign(
      privateKey,
      message,
      algorithmName: _signingAlgorithm,
    );
    return base64.decode(CryptoUtils.ecSignatureToBase64(signature));
  }

  String createBase32Signature(ECPrivateKey privateKey, Uint8List message) =>
      base32Encode(sign(privateKey, message));

  /// Whether [derSignature] is a SHA-256/ECDSA signature of [message] by
  /// [publicKey]. False for anything that is not a DER signature.
  bool verify(ECPublicKey publicKey, Uint8List message, Uint8List derSignature) {
    final ECSignature signature;
    try {
      signature = CryptoUtils.ecSignatureFromDerBytes(derSignature);
    } catch (e, s) {
      Logger.warning(
        'Verifying signature failed: it is not a DER encoded ECDSA signature.',
        error: e,
        stackTrace: s,
      );
      return false;
    }
    return CryptoUtils.ecVerify(
      publicKey,
      message,
      signature,
      algorithm: _signingAlgorithm,
    );
  }
}

/// Checks a signature of the server with the algorithm of [publicKey]: ECDSA
/// for a P-256 key, RSA through [rsaUtils] otherwise.
bool verifyServerSignature(
  PublicKey publicKey,
  Uint8List message,
  Uint8List signature, {
  required RsaUtils rsaUtils,
  PushKeyUtils pushKeyUtils = const PushKeyUtils(),
}) => switch (publicKey) {
  ECPublicKey() => pushKeyUtils.verify(publicKey, message, signature),
  RSAPublicKey() => rsaUtils.verifyRSASignature(publicKey, message, signature),
  _ => false,
};
