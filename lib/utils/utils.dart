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
    log('${e.toString()}');
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
        "Can not send request because the [body] contains a null value,"
        " this is not permitted.");
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

Future<Response> doGet(
    {Uri url, Map<String, String> parameters, bool sslVerify = true}) async {

  ArgumentError.checkNotNull(
      sslVerify, 'Parameter [sslVerify] must not be null!');

  IOClient ioClient = IOClient(HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => !sslVerify));
  // TODO Make this more general!
  // TODO Are the parameters the headers?
  String urlWithParameters = '$url?serial=${parameters['serial']}'
      '&timestamp=${parameters['timestamp']}'
      '&signature=${parameters['signature']}';
//  print('$urlWithParameters');
  Response response = await ioClient.get(urlWithParameters);

//  String urlWithParameters = '$url';
//  parameters.forEach((key, value) => urlWithParameters += '&$key=$value');
//  print('$urlWithParameters');
//  Response response = await ioClient.get(urlWithParameters);

  log("Received response",
      name: "utils.dart",
      error: 'Status code: ${response.statusCode}\n Body: ${response.body}');

  ioClient.close();
  return response;
}
