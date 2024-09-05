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

class EccUtils {
  const EccUtils();

  String serializeECPublicKey(ECPublicKey publicKey) => CryptoUtils.encodeEcPublicKeyToPem(publicKey);
  ECPublicKey deserializeECPublicKey(String ecPublicKey) => CryptoUtils.ecPublicKeyFromPem(ecPublicKey);
  String serializeECPrivateKey(ECPrivateKey ecPrivateKey) => CryptoUtils.encodeEcPrivateKeyToPem(ecPrivateKey);
  ECPrivateKey deserializeECPrivateKey(String ecPrivateKey) => CryptoUtils.ecPrivateKeyFromPem(ecPrivateKey);

  String trySignWithPrivateKey(ECPrivateKey privateKey, String message) {
    final ecSignature = CryptoUtils.ecSign(privateKey, Uint8List.fromList(message.codeUnits), algorithmName: 'SHA-256/ECDSA');
    String signatureBase64 = CryptoUtils.ecSignatureToBase64(ecSignature);
    return signatureBase64;
  }
}
