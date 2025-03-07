/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2025 NetKnights GmbH

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
import 'dart:core';
import 'dart:math' as math;

import 'package:base32/base32.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';

import '../model/enums/encodings.dart';
import '../model/extensions/enums/encodings_extension.dart';

Future<Uint8List> pbkdf2({required Uint8List salt, required int iterations, required int keyLength, required Uint8List password}) async {
  ArgumentError.checkNotNull(salt);
  ArgumentError.checkNotNull(iterations);
  ArgumentError.checkNotNull(keyLength);
  ArgumentError.checkNotNull(password);

  Map<String, dynamic> map = {};
  map['salt'] = salt;
  map['iterations'] = iterations;
  map['keyLength'] = keyLength;

  // Funky converting of password because that is what the server does too.
  map['password'] = utf8.encode(Encodings.hex.encode(password));

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
