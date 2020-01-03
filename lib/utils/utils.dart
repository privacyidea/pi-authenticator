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
import 'dart:core';
import 'dart:developer';
import 'dart:typed_data';

import 'package:base32/base32.dart' as Base32Converter;
import 'package:dart_otp/dart_otp.dart' as OTPLibrary;
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart' as HexConverter;
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:uuid/uuid.dart';

import 'identifiers.dart';

List<int> decodeSecretToUint8(String secret, Encodings encoding) {
  ArgumentError.checkNotNull(secret, "secret");
  ArgumentError.checkNotNull(encoding, "encoding");

  switch (encoding) {
    case Encodings.none:
      return utf8.encode(secret);
      break;
    case Encodings.hex:
      return HexConverter.HEX.decode(secret);
      break;
    case Encodings.base32:
      return Base32Converter.base32.decode(secret);
      break;
    default:
      throw ArgumentError.value(
          encoding, "encoding", "The encoding is unknown and not supported!");
  }
}

bool isValidEncoding(String secret, Encodings encoding) {
  try {
    decodeSecretToUint8(secret, encoding);
  } on Exception catch (_) {
    return false;
  }

  return true;
}

String calculateHotpValue(HOTPToken token) {
  Uint8List binarySecret = Uint8List.fromList(token.secret);
  String base32Secret = Base32Converter.base32.encode(binarySecret);
  return OTPLibrary.HOTP(
    counter: token.counter,
    digits: token.digits,
    secret: base32Secret,
    algorithm: _mapAlgorithms(token.algorithm),
  ).at(counter: token.counter);
}

// TODO test this method, may use mockito for 'faking' the system time
String calculateTotpValue(TOTPToken token) {
  Uint8List binarySecret = Uint8List.fromList(token.secret);
  String base32Secret = Base32Converter.base32.encode(binarySecret);
  return OTPLibrary.TOTP(
          interval: token.period,
          digits: token.digits,
          secret: base32Secret,
          algorithm: _mapAlgorithms(token.algorithm))
      .now();
}

String calculateOtpValue(Token token) {
  if (token is HOTPToken) {
    return calculateHotpValue(token);
  } else if (token is TOTPToken) {
    return calculateTotpValue(token);
  }

  throw ArgumentError.value(token, "token",
      "The token kind of $token is not supported by this method");
}

OTPLibrary.OTPAlgorithm _mapAlgorithms(Algorithms algorithm) {
  ArgumentError.checkNotNull(algorithm, "algorithmName");

  switch (algorithm) {
    case Algorithms.SHA1:
      return OTPLibrary.OTPAlgorithm.SHA1;
    case Algorithms.SHA256:
      return OTPLibrary.OTPAlgorithm.SHA256;
    case Algorithms.SHA512:
      return OTPLibrary.OTPAlgorithm.SHA512;
    default:
      throw ArgumentError.value(algorithm, "algorithmName",
          "This algortihm is unknown and not supported!");
  }
}

/// Inserts [char] at the position [pos] in the given String ([str]), and returns the resulting String.
///
/// Example: insertCharAt("ABCD", " ", 2) --> "AB CD"
String insertCharAt(String str, String char, int pos) {
  return str.substring(0, pos) + char + str.substring(pos, str.length);
}

/// This method parses otpauth uris according to https://github.com/google/google-authenticator/wiki/Key-Uri-Format.
/// The method returns an hotp or an totp token.
Token parseQRCodeToToken(String uri) {
  Uri parse = Uri.parse(uri);
  log(
    "Barcode is valid Uri:",
    name: "utils.dart",
    error: "$parse",
  );

  // otpauth://TYPE/LABEL?PARAMETERS

  if (parse.scheme != "otpauth") {
    throw ArgumentError.value(
      uri,
      "uri",
      "The uri is not a valid otpauth uri but a(n) [${parse.scheme}] uri instead.",
    );
  }

//  parse.host -> Type totp or hotp
  String type = parse.host;
  if (type != describeEnum(TokenTypes.HOTP).toLowerCase() &&
      type != describeEnum(TokenTypes.TOTP).toLowerCase()) {
    throw ArgumentError.value(
      uri,
      "uri",
      "The token type [$type] is not supported",
    );
  }

// parse.path.substring(1) -> Label
  parse.queryParameters.forEach((key, value) {
    print("Key: $key | Value: $value");
  });

  String label = parse.path.substring(1);
  String algorithm = parse.queryParameters["algorithm"] ??
      describeEnum(Algorithms.SHA1); // Optional parameter

  if (algorithm != describeEnum(Algorithms.SHA1) &&
      algorithm != describeEnum(Algorithms.SHA256) &&
      algorithm != describeEnum(Algorithms.SHA512)) {
    throw ArgumentError.value(
      uri,
      "uri",
      "The algorithm [$algorithm] is not supported",
    );
  }

  String digitsAsString =
      parse.queryParameters["digits"] ?? "6"; // Optional parameter

  if (digitsAsString != "6" && digitsAsString != "8") {
    throw ArgumentError.value(
      uri,
      "uri",
      "[$digitsAsString] is not a valid number of digits",
    );
  }

  int digits = int.parse(digitsAsString);

  // parse secret
  String secretAsString = parse.queryParameters["secret"];
  if (!isValidEncoding(secretAsString, Encodings.base32)) {
    throw ArgumentError.value(
      uri,
      "uri",
      "[${describeEnum(Encodings.base32)}] is not a valid encoding for [$secretAsString].",
    );
  }

  List<int> secret =
      decodeSecretToUint8(parse.queryParameters["secret"], Encodings.base32);

  String serial = Uuid().v4();

// uri.host -> totp or hotp
  if (type == "hotp") {
    String counterAsString = parse.queryParameters["counter"];
    try {
      int counter = int.parse(counterAsString);

      return HOTPToken(
        label,
        serial,
        mapStringToAlgorithm(algorithm),
        digits,
        secret,
        counter: counter,
      );
    } on FormatException {
      throw ArgumentError.value(
        uri,
        "uri",
        "[$counterAsString] is not a valid value for the parameter [counter]",
      );
    }
  } else if (type == "totp") {
    String periodAsString = parse.queryParameters["period"] ?? "30";
    if (periodAsString != "30" && periodAsString != "60") {
      throw ArgumentError.value(
        uri,
        "uri",
        "[$periodAsString] is not a valid value for the paramerter [period].",
      );
    }

    return TOTPToken(
      label,
      serial,
      mapStringToAlgorithm(algorithm),
      digits,
      secret,
      int.parse(periodAsString), // Optional parameter
    );
  } else {
    throw ArgumentError.value(
        uri, "uri", "[$type] is not a supported type of token");
  }
}

Algorithms mapStringToAlgorithm(String algoAsString) {
  for (Algorithms alg in Algorithms.values) {
    if (describeEnum(alg) == algoAsString) {
      return alg;
    }
  }

  throw ArgumentError.value(algoAsString, "algorAsString",
      "$algoAsString cannot be mapped to $Algorithms");
}
