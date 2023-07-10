/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:base32/base32.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'identifiers.dart';

Future<Uint8List> pbkdf2({required Uint8List salt, required int iterations, required int keyLength, required Uint8List password}) async {
  ArgumentError.checkNotNull(salt);
  ArgumentError.checkNotNull(iterations);
  ArgumentError.checkNotNull(keyLength);
  ArgumentError.checkNotNull(password);

  Map<String, dynamic> map = new Map();
  map['salt'] = salt;
  map['iterations'] = iterations;
  map['keyLength'] = keyLength;

  // Funky converting of password because that is what the server does too.
  map['password'] = utf8.encode(encodeAsHex(password));

  return compute(_pbkdfIsolate, map);
}

/// Computationally costly method to be run in an isolate.
Uint8List _pbkdfIsolate(Map<String, dynamic> arguments) {
  // Setup algorithm (PBKDF2 - HMAC - SHA1).
  PBKDF2KeyDerivator keyDerivator = KeyDerivator('SHA-1/HMAC/PBKDF2') as PBKDF2KeyDerivator;

  Pbkdf2Parameters pbkdf2parameters = Pbkdf2Parameters(arguments['salt'], arguments['iterations'], arguments['keyLength']);
  keyDerivator.init(pbkdf2parameters);

  return keyDerivator.process(arguments['password']);
}

Future<String> generatePhoneChecksum({required Uint8List phonePart}) async {
  // 1. Generate SHA1 the of salt.
  Uint8List hash = Digest('SHA-1').process(phonePart);

  // 2. Trim SHA1 result to first four bytes.
  Uint8List checksum = hash.sublist(0, 4);

  // Use List<int> for combining because Uint8List does not work somehow.
  List<int> toEncode = [];
  toEncode
    ..addAll(checksum)
    ..addAll(phonePart);

  // 3. Return checksum + salt as BASE32 String without '='.
  return base32.encode(Uint8List.fromList(toEncode)).replaceAll('=', '');
}

Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> generateRSAKeyPair() async {
  Logger.info('Start generating RSA key pair', name: 'crypto_utils.dart#generateRSAKeyPair');
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair = await compute(_generateRSAKeyPairIsolate, 4096);
  Logger.info('Finished generating RSA key pair', name: 'crypto_utils.dart#generateRSAKeyPair');
  return keyPair;
}

/// Computationally costly method to be run in an isolate.
AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _generateRSAKeyPairIsolate(int bitLength) {
  final keyGen = RSAKeyGenerator()..init(ParametersWithRandom(RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64), secureRandom()));

  final pair = keyGen.generateKeyPair();

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(pair.publicKey as RSAPublicKey, pair.privateKey as RSAPrivateKey);
}

/// Provides a secure random number generator.
SecureRandom secureRandom() {
  final secureRandom = FortunaRandom();

  final seedSource = math.Random.secure();
  final seeds = <int>[];
  for (int i = 0; i < 32; i++) {
    seeds.add(seedSource.nextInt(256));
  }
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

  return secureRandom;
}

/// signedMessage is what was allegedly signed, signature gets validated
bool verifyRSASignature(RSAPublicKey publicKey, Uint8List signedMessage, Uint8List signature) {
  RSASigner signer = Signer(SIGNING_ALGORITHM) as RSASigner; // Get algorithm from registry
  signer.init(false, PublicKeyParameter<RSAPublicKey>(publicKey)); // false to validate

  bool isVerified = false;
  try {
    isVerified = signer.verifySignature(signedMessage, RSASignature(signature));
  } on ArgumentError catch (e) {
    Logger.warning('Verifying signature failed due to ${e.name}', name: 'crypto_utils.dart#verifyRSASignature', error: e);
  }

  return isVerified;
}

String createBase32Signature(RSAPrivateKey privateKey, Uint8List dataToSign) {
  return base32.encode(createRSASignature(privateKey, dataToSign));
}

Uint8List createRSASignature(RSAPrivateKey privateKey, Uint8List dataToSign) {
  RSASigner signer = Signer(SIGNING_ALGORITHM) as RSASigner; // Get algorithm from registry
  signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey)); // true to sign

  return signer.generateSignature(dataToSign).bytes;
}

/// Tries to sign the [message] with the private key of the [token]. If the token is a
/// legacy token (enrolled prior to v3), the Legacy plugin will be used for that operation.
/// If an error occurs during the operation of the legacy plugin, a dialog will be shown
/// if a [context] is provided, telling the users that it might be better to enroll a new
/// push token so that the app can directly access the private key.
/// Returns the signature on success and null on failure.
Future<String?> trySignWithToken(PushToken token, String message, BuildContext? context) async {
  String? signature;
  if (token.privateTokenKey == null) {
    // It is a legacy token so the operation could cause an exception
    try {
      signature = await Legacy.sign(token.serial, message);
    } catch (error) {
      if (context != null) {
        Widget okButton = TextButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        );

        AlertDialog alert = AlertDialog(
          title: Text("Error"),
          content: Text("An error occured while using the legacy token ${token.label}. "
              "The token was enrolled in a old version of this app, which may cause trouble"
              " using it. It is suggested to enroll a new push token if the problems persist!"),
          actions: [
            okButton,
          ],
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }

      log("Failed to create signature with legacy token ${token.label}!", name: 'crypto_utils.dart#trySignWithToken');
      return null;
    }
  } else {
    signature = createBase32Signature(token.getPrivateTokenKey()!, utf8.encode(message) as Uint8List);
  }

  return signature;
}
