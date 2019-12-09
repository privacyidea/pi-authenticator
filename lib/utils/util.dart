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
import 'package:hex/hex.dart' as HexConverter;
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:uuid/uuid.dart';

import 'identifiers.dart';

List<int> decodeSecretToUint8(String secret, String encoding) {
  ArgumentError.checkNotNull(secret, "secret");
  ArgumentError.checkNotNull(encoding, "encoding");

  switch (encoding) {
    case NONE:
      return utf8.encode(secret);
      break;
    case HEX:
      return HexConverter.HEX.decode(secret);
      break;
    case BASE32:
      return Base32Converter.base32.decode(secret);
      break;
    default:
      throw ArgumentError.value(
          encoding, "encoding", "The encoding is unknown and not supported!");
  }
}

bool isValidEncoding(String secret, String encoding) {
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

OTPLibrary.OTPAlgorithm _mapAlgorithms(String algorithmName) {
  ArgumentError.checkNotNull(algorithmName, "algorithmName");

  switch (algorithmName) {
    case SHA1:
      return OTPLibrary.OTPAlgorithm.SHA1;
    case SHA256:
      return OTPLibrary.OTPAlgorithm.SHA256;
    case SHA512:
      return OTPLibrary.OTPAlgorithm.SHA512;
    default:
      throw ArgumentError.value(algorithmName, "algorithmName",
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
  // TODO throw some exceptions
  // TODO check if the uri is valid

//  ArgumentError.checkNotNull(uri, "uri");
//  if (uri.isEmpty) {
//    throw ArgumentError.value(uri, "uri", "Otpauth uri must not ne empty.");
//  }

  Uri parse = Uri.parse(uri);
  log(
    "Barcode is valid Uri:",
    name: "util.dart",
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
  if (type != HOTP.toLowerCase() && type != TOTP.toLowerCase()) {
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
  String algorithm =
      parse.queryParameters["algorithm"] ?? SHA1; // Optional parameter

  if (algorithm != SHA1 && algorithm != SHA256 && algorithm != SHA512) {
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
  if (!isValidEncoding(secretAsString, BASE32)) {
    throw ArgumentError.value(
      uri,
      "uri",
      "[$BASE32] is not a valid encoding for [$secretAsString].",
    );
  }

  List<int> secret =
      decodeSecretToUint8(parse.queryParameters["secret"], BASE32);

  String serial = Uuid().v4();

// uri.host -> totp or hotp
  if (type == "hotp") {
    String counterAsString = parse.queryParameters["counter"];
    try {
      int counter = int.parse(counterAsString);

      return HOTPToken(
        label,
        serial,
        algorithm,
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
      algorithm,
      digits,
      secret,
      int.parse(periodAsString), // Optional parameter
    );
  }
}
