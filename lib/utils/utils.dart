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
import 'dart:io';
import 'dart:typed_data';

import 'package:base32/base32.dart' as Base32Converter;
import 'package:hex/hex.dart' as HexConverter;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:otp/otp.dart' as OTPLibrary;
import 'package:privacyidea_authenticator/model/tokens.dart';

import 'identifiers.dart';

Uint8List decodeSecretToUint8(String secret, Encodings encoding) {
  ArgumentError.checkNotNull(secret, "secret");
  ArgumentError.checkNotNull(encoding, "encoding");

  switch (encoding) {
    case Encodings.none:
      return Uint8List.fromList(utf8.encode(secret));
      break;
    case Encodings.hex:
      return Uint8List.fromList(HexConverter.HEX.decode(secret));
      break;
    case Encodings.base32:
      return Uint8List.fromList(Base32Converter.base32.decode(secret));
      break;
    default:
      throw ArgumentError.value(
          encoding, "encoding", "The encoding is unknown and not supported!");
  }
}

String encodeSecretAs(Uint8List secret, Encodings encoding) {
  ArgumentError.checkNotNull(secret, "secret");
  ArgumentError.checkNotNull(encoding, "encoding");

  switch (encoding) {
    case Encodings.none:
      return utf8.decode(secret);
      break;
    case Encodings.hex:
      return HexConverter.HEX.encode(secret);
      break;
    case Encodings.base32:
      return Base32Converter.base32.encode(secret);
      break;
    default:
      throw ArgumentError.value(
          encoding, "encoding", "The encoding is unknown and not supported!");
  }
}

String encodeAsHex(Uint8List secret) {
  return encodeSecretAs(secret, Encodings.hex);
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
  Uint8List binarySecret = decodeSecretToUint8(token.secret, Encodings.base32);
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
  Uint8List binarySecret = decodeSecretToUint8(token.secret, Encodings.base32);
  String base32Secret = Base32Converter.base32.encode(binarySecret);
  return "${OTPLibrary.OTP.generateTOTPCode(
    base32Secret,
    DateTime.now().millisecondsSinceEpoch,
    length: token.digits,
    algorithm: _mapAlgorithms(token.algorithm),
    interval: token.period,
  )}";
}

String calculateOtpValue(OTPToken token) {
  if (token is HOTPToken) {
    return calculateHotpValue(token).padLeft(token.digits, '0');
  } else if (token is TOTPToken) {
    return calculateTotpValue(token).padLeft(token.digits, '0');
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

/// Inserts [char] at the position [pos] in the given String ([str]),
/// and returns the resulting String.
///
/// Example: insertCharAt("ABCD", " ", 2) --> "AB CD"
String insertCharAt(String str, String char, int pos) {
  return str.substring(0, pos) + char + str.substring(pos, str.length);
}

/// Inserts [' '] after every [period] characters in [str].
/// Trims leading and trailing whitespaces. Returns the resulting String.
///
/// Example: "ABCD", 1 --> "A B C D"
/// Example: "ABCD", 2 --> "AB CD"
String splitPeriodically(String str, int period) {
  String result = "";
  for (int i = 0; i < str.length; i++) {
    i % 4 == 0 ? result += " ${str[i]}" : result += str[i];
  }

  return result.trim();
}

/// The method returns a map that contains all the uri parameters.
Map<String, dynamic> parseQRCodeToMap(String uriAsString) {
  Uri uri = Uri.parse(uriAsString);
  log(
    "Barcode is valid Uri:",
    name: "utils.dart",
    error: uri,
  );

  if (uri.scheme != "otpauth") {
    throw ArgumentError.value(
      uri,
      "uri",
      "The uri is not a valid otpauth uri but a(n) [${uri.scheme}] uri instead.",
    );
  }

  String type = uri.host;
  if (equalsIgnoreCase(type, enumAsString(TokenTypes.HOTP)) ||
      equalsIgnoreCase(type, enumAsString(TokenTypes.TOTP))) {
    return parseOtpAuth(uri);
  } else if (equalsIgnoreCase(type, enumAsString(TokenTypes.PIPUSH))) {
    return parsePiAuth(uri);
  }

  throw ArgumentError.value(
    uri,
    "uri",
    "The token type [$type] is not supported",
  );
}

Map<String, dynamic> parsePiAuth(Uri uri) {
  // otpauth://pipush/LABELTEXT?
  // url=https://privacyidea.org/enroll/this/token
  // &ttl=120
  // &serial=PIPU0006EF87
  // &projectid=test-d1231
  // &appid=1:0123456789012:android:0123456789abcdef
  // &apikey=AIzaSyBeFSjwJ8aEcHQaj4-isT-sLAX6lmSrvbb
  // &projectnumber=850240559999
  // &enrollment_credential=9311ee50678983c0f29d3d843f86e39405e2b427
  // &apikeyios=AIzaSyBeFSjwJ8aEcHQaj4-isT-sLAX6lmSrvbb
  // &appidios=1:0123456789012:ios:0123456789abcdef

  Map<String, dynamic> uriMap = Map();

  uriMap[URI_TYPE] = uri.host;
  uriMap[URI_ISSUER] = uri.queryParameters['issuer'];

  // If we do not support the version of this piauth url, we can stop here.
  String pushVersionAsString = uri.queryParameters["v"];
  try {
    int pushVersion = int.parse(pushVersionAsString);

    print('VERSION: $pushVersion');

    if (pushVersion > 1) {
      throw ArgumentError.value(
          uri,
          "uri",
          "The piauth version [$pushVersionAsString] "
              "is not supported by this version of the app.");
    }
  } on FormatException {
    throw ArgumentError.value(uri, "uri",
        "[$pushVersionAsString] is not a valid value for parameter [v].");
  }

  uriMap[URI_LABEL] = _parseLabel(uri);

  uriMap[URI_SERIAL] = uri.queryParameters["serial"];
  ArgumentError.checkNotNull(uriMap[URI_SERIAL], "serial");

  uriMap[URI_PROJECT_ID] = uri.queryParameters["projectid"];
  ArgumentError.checkNotNull(uriMap[URI_PROJECT_ID], "projectid");

  uriMap[URI_APP_ID] = uri.queryParameters["appid"];
  ArgumentError.checkNotNull(uriMap[URI_APP_ID], "appid");

  uriMap[URI_APP_ID_IOS] = uri.queryParameters["appidios"];
  ArgumentError.checkNotNull(uriMap[URI_APP_ID_IOS], "appidios");

  uriMap[URI_API_KEY] = uri.queryParameters["apikey"];
  ArgumentError.checkNotNull(uriMap[URI_API_KEY], "apikey");

  uriMap[URI_API_KEY_IOS] = uri.queryParameters["apikeyios"];
  ArgumentError.checkNotNull(uriMap[URI_API_KEY_IOS], "apikeyios");

  uriMap[URI_PROJECT_NUMBER] = uri.queryParameters["projectnumber"];
  ArgumentError.checkNotNull(uriMap[URI_PROJECT_NUMBER], "projectnumber");

  // TODO what happens if Uri.parse fails?
  uriMap[URI_ROLLOUT_URL] = Uri.parse(uri.queryParameters["url"]);
  ArgumentError.checkNotNull(uriMap[URI_ROLLOUT_URL], "url");

  String ttlAsString = uri.queryParameters["ttl"] ?? "10";
  try {
    uriMap[URI_TTL] = int.parse(ttlAsString);
  } on FormatException {
    throw ArgumentError.value(
        uri, "uri", "[$ttlAsString] is not a valid value for parameter [ttl].");
  }

  uriMap[URI_ENROLLMENT_CREDENTIAL] =
      uri.queryParameters["enrollment_credential"];
  ArgumentError.checkNotNull(
      uriMap[URI_ENROLLMENT_CREDENTIAL], "enrollment_credential");

  uriMap[URI_SSL_VERIFY] = (uri.queryParameters["sslverify"] ?? "1") == "1";

  return uriMap;
}

/// This method parses otpauth uris according
/// to https://github.com/google/google-authenticator/wiki/Key-Uri-Format.
Map<String, dynamic> parseOtpAuth(Uri uri) {
  // otpauth://TYPE/LABEL?PARAMETERS

  Map<String, dynamic> uriMap = Map();

  // parse.host -> Type totp or hotp
  uriMap[URI_TYPE] = uri.host;
  uriMap[URI_ISSUER] = uri.queryParameters['issuer'];

// parse.path.substring(1) -> Label
  print("Key: [..] | Value: [..]");
  uri.queryParameters.forEach((key, value) {
    print("  $key | $value");
  });

  uriMap[URI_LABEL] = _parseLabel(uri);

  String algorithm = uri.queryParameters["algorithm"] ??
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
      uri.queryParameters["digits"] ?? "6"; // Optional parameter

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
  String secretAsString = uri.queryParameters["secret"];

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

  Uint8List secret = decodeSecretToUint8(secretAsString, Encodings.base32);

  uriMap[URI_SECRET] = secret;

  if (uriMap[URI_TYPE] == "hotp") {
    // Parse counter.
    String counterAsString = uri.queryParameters["counter"];
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

  if (uriMap[URI_TYPE] == "totp") {
    // Parse period.
    String periodAsString = uri.queryParameters["period"] ?? "30";
    if (periodAsString != "30" && periodAsString != "60") {
      throw ArgumentError.value(
        uri,
        "uri",
        "[$periodAsString] is not a valid value for the paramerter [period].",
      );
    }

    uriMap[URI_PERIOD] = int.parse(periodAsString);
  }

  if (is2StepURI(uri)) {
    // Parse for 2 step roll out.
    String saltLengthAsString = uri.queryParameters["2step_salt"] ?? "10";
    String outputLengthInByteAsString =
        uri.queryParameters["2step_output"] ?? "20";
    String iterationsAsString =
        uri.queryParameters["2step_difficulty"] ?? "10000";

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

String _parseLabel(Uri uri) {
  return uri.path.substring(1);
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

bool equalsIgnoreCase(String s1, String s2) =>
    s1.toLowerCase() == s2.toLowerCase();

/// Custom POST request allows to not verify certificates
Future<Response> doPost(
    {bool sslVerify, Uri url, Map<String, String> body}) async {
  log("Sending post request",
      name: "utils.dart",
      error: "URI: $url, SSLVerify: $sslVerify, Body: $body");

  if (body.entries.any((element) => element.value == null)) {
    throw ArgumentError(
        "The parameter [body] contains a null value, this will cause an "
        "exception and thus is not permitted.");
  }

  IOClient ioClient = IOClient(HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => !sslVerify));

  Response response = await ioClient.post(url, body: body);

  log("Received response",
      name: "utils.dart",
      error: 'Status code: ${response.statusCode}\n Body: ${response.body}');

  ioClient.close();

  return response;
}
