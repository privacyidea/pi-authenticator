/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

Future<Uint8List> pbkdf2(
    {Uint8List salt, int iterations, int keyLength, Uint8List password}) async {
  ArgumentError.checkNotNull(salt);
  ArgumentError.checkNotNull(iterations);
  ArgumentError.checkNotNull(keyLength);
  ArgumentError.checkNotNull(password);

  Map<String, dynamic> map = new Map();
  map["salt"] = salt;
  map["iterations"] = iterations;
  map["keyLength"] = keyLength;

  // Funky converting of password because that is what the server does too.
  map["password"] = utf8.encode(encodeAsHex(password));

  return compute(_pbkdfIsolate, map);
}

Uint8List _pbkdfIsolate(Map<String, dynamic> arguments) {
  // Setup algorithm (PBKDF2 - HMAC - SHA1).
  PBKDF2KeyDerivator keyDerivator = KeyDerivator('SHA-1/HMAC/PBKDF2');

  Pbkdf2Parameters pbkdf2parameters = Pbkdf2Parameters(
      arguments["salt"], arguments["iterations"], arguments["keyLength"]);
  keyDerivator.init(pbkdf2parameters);

  return keyDerivator.process(arguments["password"]);
}

Future<String> generatePhoneChecksum({Uint8List phonePart}) async {
  // 1. Generate SHA1 the of salt.
  Uint8List hash = Digest("SHA-1").process(phonePart);

  // 2. Trim SHA1 result to first four bytes.
  Uint8List checksum = hash.sublist(0, 4);

  // Use List<int> for combining because Uint8List does not work somehow.
  List<int> toEncode = List();
  toEncode..addAll(checksum)..addAll(phonePart);

  // 3. Return checksum + salt as BASE32 String without '='.
  return base32.encode(Uint8List.fromList(toEncode)).replaceAll('=', '');
}

Uint8List generateSalt(int length) {
  Uint8List list = Uint8List(length);
  math.Random rand = math.Random.secure();

  for (int i = 0; i < length; i++) {
    list[i] = rand.nextInt(1 << 8); // Generate next random byte.
  }

  return list;
}

Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>>
    generateRSAKeyPair() async {
  log("Start generating RSA key pair", name: "crypto_utils.dart");
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair =
      await compute(_generateRSAKeyPair, 4096);
  log("Finished generating RSA key pair", name: "crypto_utils.dart");
  return keyPair;
}

/// Computationally costly method to be run in an isolate.
AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _generateRSAKeyPair(
    int bitLength) {
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
        exampleSecureRandom()));

  final pair = keyGen.generateKeyPair();

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey, pair.privateKey);
}

//  TODO what are the alternatives
SecureRandom exampleSecureRandom() {
  final secureRandom = FortunaRandom();

  final seedSource = math.Random.secure();
  final seeds = <int>[];
  for (int i = 0; i < 32; i++) {
    seeds.add(seedSource.nextInt(255));
  }
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

  return secureRandom;
}
