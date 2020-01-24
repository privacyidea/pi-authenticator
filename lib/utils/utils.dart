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
import 'package:hex/hex.dart' as HexConverter;
import 'package:otp/otp.dart' as OTPLibrary;
import 'package:privacyidea_authenticator/model/tokens.dart';

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
  } on Exception catch (e) {
    print('${e.toString()}');
    return false;
  }

  return true;
}

String calculateHotpValue(HOTPToken token) {
  Uint8List binarySecret = Uint8List.fromList(token.secret);
  String base32Secret = Base32Converter.base32.encode(binarySecret);
  return "${OTPLibrary.OTP.generateHOTPCode(
    base32Secret,
    token.counter,
    length: token.digits,
    algorithm: _mapAlgorithms(token.algorithm),
  )}";
}

// TODO test this method, may use mockito for 'faking' the system time
String calculateTotpValue(TOTPToken token) {
  Uint8List binarySecret = Uint8List.fromList(token.secret);
  String base32Secret = Base32Converter.base32.encode(binarySecret);
  return "${OTPLibrary.OTP.generateTOTPCode(
    base32Secret,
    DateTime.now().millisecondsSinceEpoch,
    length: token.digits,
    algorithm: _mapAlgorithms(token.algorithm),
    interval: token.period,
  )}";
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

OTPLibrary.Algorithm _mapAlgorithms(Algorithms algorithm) {
  ArgumentError.checkNotNull(algorithm, "algorithmName");

  switch (algorithm) {
    case Algorithms.SHA1:
      return OTPLibrary.Algorithm.SHA1;
    case Algorithms.SHA256:
      return OTPLibrary.Algorithm.SHA256;
    case Algorithms.SHA512:
      return OTPLibrary.Algorithm.SHA512;
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
// TODO rename this method
Map<String, dynamic> parseQRCodeToToken(String uri) {
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

  Map<String, dynamic> uriMap = Map();

  // parse.host -> Type totp or hotp
  String type = parse.host;
  if (!equalsIgnoreCase(type, enumAsString(TokenTypes.HOTP)) &&
      !equalsIgnoreCase(type, enumAsString(TokenTypes.TOTP))) {
    throw ArgumentError.value(
      uri,
      "uri",
      "The token type [$type] is not supported.",
    );
  }

  uriMap[URI_TYPE] = type;

// parse.path.substring(1) -> Label
  print("Key: [..] | Value: [..]");
  parse.queryParameters.forEach((key, value) {
    print("  $key | $value");
  });

  String label = parse.path.substring(1);
  uriMap[URI_LABEL] = label;

  String algorithm = parse.queryParameters["algorithm"] ??
      enumAsString(Algorithms.SHA1); // Optional parameter

  if (!equalsIgnoreCase(algorithm, enumAsString(Algorithms.SHA1)) &&
      !equalsIgnoreCase(algorithm, enumAsString(Algorithms.SHA256)) &&
      !equalsIgnoreCase(algorithm, enumAsString(Algorithms.SHA512))) {
    throw ArgumentError.value(
      uri,
      "uri",
      "The algorithm [$algorithm] is not supported",
    );
  }

  uriMap[URI_ALGORITHM] = algorithm;

  // Parse digits.
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

  uriMap[URI_DIGITS] = digits;

  // Parse secret.
  String secretAsString = parse.queryParameters["secret"];

  // This is a fix for omitted padding in base32 encoded secrets.
  //
  // According to https://github.com/google/google-authenticator/wiki/Key-Uri-Format,
  // the padding can be omitted, but the libraries for base32 do not allow this.
  if (secretAsString != null && secretAsString.length % 2 == 1) {
    secretAsString += "=";
  }

  if (!isValidEncoding(secretAsString, Encodings.base32)) {
    throw ArgumentError.value(
      uri,
      "uri",
      "[${enumAsString(Encodings.base32)}] is not a valid encoding for [$secretAsString].",
    );
  }

  List<int> secret = decodeSecretToUint8(secretAsString, Encodings.base32);

  uriMap[URI_SECRET] = secret;

  if (type == "hotp") {
    // Parse counter.
    String counterAsString = parse.queryParameters["counter"];
    try {
      uriMap[URI_COUNTER] = int.parse(counterAsString);
    } on FormatException {
      throw ArgumentError.value(
        uri,
        "uri",
        "[$counterAsString] is not a valid value for the parameter [counter]",
      );
    }
  }

  if (type == "totp") {
    // Parse period.
    String periodAsString = parse.queryParameters["period"] ?? "30";
    if (periodAsString != "30" && periodAsString != "60") {
      throw ArgumentError.value(
        uri,
        "uri",
        "[$periodAsString] is not a valid value for the paramerter [period].",
      );
    }

    uriMap[URI_PERIOD] = int.parse(periodAsString);
  }

  if (is2StepURI(parse)) {
    // Parse for 2 step roll out.
    String saltLengthAsString = parse.queryParameters["2step_salt"] ?? "10";
    String outputLengthInByteAsString =
        parse.queryParameters["2step_output"] ?? "20";
    String iterationsAsString =
        parse.queryParameters["2step_difficulty"] ?? "10000";

    // Parse parameters
    try {
      uriMap[URI_SALT_LENGTH] = int.parse(saltLengthAsString);
    } on FormatException {
      throw ArgumentError.value(
        uri,
        "uri",
        "[$saltLengthAsString] is not a valid value for parameter [2step_salt].",
      );
    }
    try {
      uriMap[URI_OUTPUT_LENGTH_IN_BYTES] =
          int.parse(outputLengthInByteAsString);
    } on FormatException {
      throw ArgumentError.value(
        uri,
        "uri",
        "[$outputLengthInByteAsString] is not a valid value for parameter [2step_output].",
      );
    }
    try {
      uriMap[URI_ITERATIONS] = int.parse(iterationsAsString);
    } on FormatException {
      throw ArgumentError.value(
        uri,
        "uri",
        "[$iterationsAsString] is not a valid value for parameter [2step_difficulty].",
      );
    }
  }

  return uriMap;
}

bool is2StepURI(Uri uri) {
  return uri.queryParameters["2step_salt"] != null ||
      uri.queryParameters["2step_output"] != null ||
      uri.queryParameters["2step_difficulty"] != null;
}

Algorithms mapStringToAlgorithm(String algoAsString) {
  for (Algorithms alg in Algorithms.values) {
    if (equalsIgnoreCase(enumAsString(alg), algoAsString)) {
      return alg;
    }
  }

  throw ArgumentError.value(algoAsString, "algorAsString",
      "$algoAsString cannot be mapped to $Algorithms");
}

/// This implementation is taken from the library
/// [foundation](https://api.flutter.dev/flutter/foundation/describeEnum.html).
/// That library sadly depends on [dart.ui] and thus cannot be used in tests.
/// Therefor only using this code enables us to use this library ([utils.dart])
/// in tests.
String enumAsString(Object enumEntry) {
  final String description = enumEntry.toString();
  final int indexOfDot = description.indexOf('.');
  assert(indexOfDot != -1 && indexOfDot < description.length - 1);
  return description.substring(indexOfDot + 1);
}

bool equalsIgnoreCase(String s1, String s2) {
  return s1.toLowerCase() == s2.toLowerCase();
}
