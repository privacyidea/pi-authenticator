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

import 'dart:typed_data';

Future<Uint8List> pbkdf2() async {
  // TODO 1. Generate random bytes

  // TODO 2. Generate secret with PBKDF2 - HMAC - SHA1

  print('Generate secret');
  await Future.delayed(Duration(seconds: 3));

  // TODO 3. Return secret
  return Uint8List.fromList([5, 4, 3, 2, 1]);
}

Future<String> generatePhonePart() async {
  // TODO 1. Generate SHA1 the of salt

  // TODO 2. Trim SHA1 result to first four bytes -> This is used as the checksum

  print('Generate phone part');
  await Future.delayed(Duration(seconds: 1));

  // TODO 3. Return checksum + salt as BASE32 String without '='
  return "This could be your checksum.";
}
