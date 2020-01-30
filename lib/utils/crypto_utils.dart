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

import 'dart:math';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:steel_crypt/PointyCastleN/export.dart';

Future<Uint8List> pbkdf2(
    {Uint8List salt, int iterations, int keyLength, Uint8List password}) async {
  ArgumentError.checkNotNull(salt);
  ArgumentError.checkNotNull(iterations);
  ArgumentError.checkNotNull(keyLength);
  ArgumentError.checkNotNull(password);

  // Setup algorithm (PBKDF2 - HMAC - SHA1).
  String algorithm = 'SHA-1/HMAC/PBKDF2';
  KeyDerivator keyDerivator = KeyDerivator(algorithm);

  Pbkdf2Parameters pbkdf2parameters =
      Pbkdf2Parameters(salt, iterations, keyLength);
  keyDerivator.init(pbkdf2parameters);

  return keyDerivator.process(password);
}

Future<String> generatePhoneChecksum({Uint8List phonePart}) async {
  // 1. Generate SHA1 the of salt.
  String type = "SHA-1";
  Uint8List hash = Digest(type).process(phonePart);

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
  Random rand = Random.secure();

  for (int i = 0; i < length; i++) {
    list[i] = rand.nextInt(1 << 8); // Generate next random byte.
  }

  return list;
}
