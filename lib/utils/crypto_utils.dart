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

import 'package:asn1lib/asn1lib.dart';
import 'package:base32/base32.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

import 'identifiers.dart';

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

// TODO move all that to parsing utils?
// TODO write description
RSAPublicKey convertDERToPublicKey(String der) {
  //    RSAPublicKey ::= SEQUENCE {
  //    modulus           INTEGER,  -- n
  //    publicExponent    INTEGER   -- e
  //    }

  ASN1Sequence asn1sequence = _parseASN1Sequence(base64.decode(der));
  BigInt modulus = (asn1sequence.elements[0] as ASN1Integer).valueAsBigInteger;
  BigInt exponent = (asn1sequence.elements[1] as ASN1Integer).valueAsBigInteger;

  return RSAPublicKey(modulus, exponent);
}

// TODO remove this method
ASN1Sequence _parseASN1Sequence(Uint8List bytes) {
  return ASN1Parser(bytes).nextObject() as ASN1Sequence;
}

// TODO write description
String convertPublicKeyToDER(RSAPublicKey publicKey) {
  ASN1Sequence s = ASN1Sequence()
    ..add(ASN1Integer(publicKey.modulus))
    ..add(ASN1Integer(publicKey.exponent));
  Uint8List bytes = s.encodedBytes;

  return base64.encode(bytes);
}

// TODO rename methods and add documentation
// TODO describe
RSAPublicKey derComplicatedToKey(String key) {
  var baseSequence =
      ASN1Parser(base64.decode(key)).nextObject() as ASN1Sequence;

  var encodedAlgorithm = baseSequence.elements[0];

  var algorithm = ASN1Parser(encodedAlgorithm.contentBytes()).nextObject()
      as ASN1ObjectIdentifier;

//  print(algorithm.identifier); // TODO check if identifier fits rsaEncryption!

  var encodedKey = baseSequence.elements[1];

  var asn1sequence =
      ASN1Parser(encodedKey.contentBytes()).nextObject() as ASN1Sequence;

  BigInt modulus = (asn1sequence.elements[0] as ASN1Integer).valueAsBigInteger;
  BigInt exponent = (asn1sequence.elements[1] as ASN1Integer).valueAsBigInteger;

  return RSAPublicKey(modulus, exponent);
}

// TODO describe
String derComplicatedToString(RSAPublicKey key) {
  ASN1ObjectIdentifier.registerFrequentNames();
  ASN1Sequence algorithm = ASN1Sequence()
    ..add(ASN1ObjectIdentifier.fromName('rsaEncryption'))
    ..add(ASN1Null());

  var keySequence = ASN1Sequence() // THIS MUST BE A BIT STRING
    ..add(ASN1Integer(key.modulus))
    ..add(ASN1Integer(key.exponent));

  var publicKey = ASN1BitString(keySequence.encodedBytes);

  var asn1sequence = ASN1Sequence()..add(algorithm)..add(publicKey);
  return base64.encode(asn1sequence.encodedBytes);
}

/// signedMessage is what was allegedly signed, signature gets validated
bool validateSignature(
    RSAPublicKey publicKey, Uint8List signedMessage, Uint8List signature) {
  RSASigner signer = Signer(SIGNING_ALGORITHM); // Get algorithm from registry
  signer.init(
      false, PublicKeyParameter<RSAPublicKey>(publicKey)); // false to validate

  bool isVerified = false;
  try {
    isVerified = signer.verifySignature(signedMessage, RSASignature(signature));
  } on ArgumentError catch (e) {
    log('Verifying signature failed do to ${e.name}',
        name: 'crypto_utils.dart', error: e);
  }

  return isVerified;
}

String createBase32Signature(RSAPrivateKey privateKey, Uint8List dataToSign) {
  return base32.encode(createSignature(privateKey, dataToSign));
}

Uint8List createSignature(RSAPrivateKey privateKey, Uint8List dataToSign) {
  RSASigner signer = Signer(SIGNING_ALGORITHM); // Get algorithm from registry

  signer.init(
      true, PrivateKeyParameter<RSAPrivateKey>(privateKey)); // true to sign

  return signer.generateSignature(dataToSign).bytes;
}
