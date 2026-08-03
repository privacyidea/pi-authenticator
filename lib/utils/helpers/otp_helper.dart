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
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'base32_helper.dart';

/// Self contained replacement for the RFC 4226 / RFC 6238 code generation of
/// the `otp` package (`OTP.generateTOTPCodeString`/`OTP.generateHOTPCodeString`).

/// Hashing algorithm used to generate one time password codes.
enum OtpHashAlgorithm { sha1, sha256, sha512 }

/// Generates a time based one time password code as a zero padded string.
///
/// [time] is the current time in milliseconds, [interval] is the step size in
/// seconds. If [isGoogle] is true the secret is decoded as base32, otherwise
/// it is decoded as utf8.
String generateTOTPCodeString({
  required String secret,
  required int time,
  required int length,
  required int interval,
  required OtpHashAlgorithm algorithm,
  bool isGoogle = true,
}) {
  final counter = ((time ~/ 1000) ~/ interval);
  final code = _generateCode(secret, counter, length, algorithm, isGoogle: isGoogle);
  return '$code'.padLeft(length, '0');
}

/// Generates a counter based one time password code as a zero padded string.
///
/// If [isGoogle] is true the secret is decoded as base32, otherwise it is
/// decoded as utf8.
String generateHOTPCodeString({
  required String secret,
  required int counter,
  required int length,
  required OtpHashAlgorithm algorithm,
  bool isGoogle = true,
}) {
  final code = _generateCode(secret, counter, length, algorithm, isHOTP: true, isGoogle: isGoogle);
  return '$code'.padLeft(length, '0');
}

int _generateCode(
  String secret,
  int time,
  int length,
  OtpHashAlgorithm algorithm, {
  bool isHOTP = false,
  bool isGoogle = false,
}) {
  length = (length > 0) ? length : 6;

  var secretList = Uint8List.fromList(utf8.encode(secret));
  if (isGoogle) {
    secretList = base32Decode(secret.toUpperCase());
  }

  // TOTP pads the secret to the algorithm block size, HOTP does not (matching
  // the otp package default of useTOTPPaddingForHOTP = false).
  if (!isGoogle && !isHOTP) {
    secretList = _padSecret(secretList, _algorithmByteLength(algorithm));
  }

  final timebytes = _int2bytes(time);

  final hmac = Hmac(_hash(algorithm), secretList);
  final digest = hmac.convert(timebytes).bytes;

  final offset = digest[digest.length - 1] & 0x0f;

  final binary = ((digest[offset] & 0x7f) << 24) |
      ((digest[offset + 1] & 0xff) << 16) |
      ((digest[offset + 2] & 0xff) << 8) |
      (digest[offset + 3] & 0xff);

  return binary % pow(10, length).toInt();
}

Hash _hash(OtpHashAlgorithm algorithm) => switch (algorithm) {
      OtpHashAlgorithm.sha1 => sha1,
      OtpHashAlgorithm.sha256 => sha256,
      OtpHashAlgorithm.sha512 => sha512,
    };

int _algorithmByteLength(OtpHashAlgorithm algorithm) => switch (algorithm) {
      OtpHashAlgorithm.sha1 => 20,
      OtpHashAlgorithm.sha256 => 32,
      OtpHashAlgorithm.sha512 => 64,
    };

Uint8List _int2bytes(int long) {
  // we want to represent the input as a 8-bytes array
  final byteArray = Uint8List(8);

  for (var index = byteArray.length - 1; index >= 0; index--) {
    final byte = long & 0xff;
    byteArray[index] = byte;
    long = (long - byte) ~/ 256;
  }
  return byteArray;
}

Uint8List _padSecret(Uint8List secret, int length) {
  if (secret.length >= length) return secret;
  if (secret.isEmpty) return secret;
  final newList = <int>[];
  for (var i = 0; i * secret.length < length; i++) {
    newList.addAll(secret);
  }
  return Uint8List.fromList(newList.sublist(0, length));
}
