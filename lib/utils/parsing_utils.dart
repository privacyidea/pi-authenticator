/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

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
import 'dart:developer';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

import 'identifiers.dart';

/// Extract RSA-Public-Keys from DER structure that is a BASE64 encoded Strings.
/// According to the PKCS#1 format:
///
/// RSAPublicKey ::= SEQUENCE {
///     modulus           INTEGER,  -- n
///     publicExponent    INTEGER   -- e
/// }
RSAPublicKey deserializeRSAPublicKeyPKCS1(String keyStr) {
  ASN1Sequence asn1sequence =
      ASN1Parser(base64.decode(keyStr)).nextObject() as ASN1Sequence;
  BigInt modulus = (asn1sequence.elements[0] as ASN1Integer).valueAsBigInteger!;
  BigInt exponent =
      (asn1sequence.elements[1] as ASN1Integer).valueAsBigInteger!;

  return RSAPublicKey(modulus, exponent);
}

/// Convert an RSA-Public-Key to a DER structure as a BASE64 encoded String.
/// According to the PKCS#1 format:
///
/// RSAPublicKey ::= SEQUENCE {
///     modulus           INTEGER,  -- n
///     publicExponent    INTEGER   -- e
/// }
String serializeRSAPublicKeyPKCS1(RSAPublicKey publicKey) {
  ASN1Sequence s = ASN1Sequence()
    ..add(ASN1Integer(publicKey.modulus!))
    ..add(ASN1Integer(publicKey.exponent!));

  return base64.encode(s.encodedBytes);
}

/// Extract RSA-Public-Keys from DER structure that is a BASE64 encoded Strings.
/// According to the PKCS#8 format:
///
/// PublicKeyInfo ::= SEQUENCE {
///     algorithm       AlgorithmIdentifier,
///     PublicKey       BIT STRING
/// }
///
/// AlgorithmIdentifier ::= SEQUENCE {
///     algorithm       OBJECT IDENTIFIER,
///     parameters      ANY DEFINED BY algorithm OPTIONAL
/// }
RSAPublicKey deserializeRSAPublicKeyPKCS8(String keyStr) {
  var baseSequence =
      ASN1Parser(base64.decode(keyStr)).nextObject() as ASN1Sequence;

  var encodedAlgorithm = baseSequence.elements[0];

  var algorithm = ASN1Parser(encodedAlgorithm.contentBytes()!).nextObject()
      as ASN1ObjectIdentifier;

  if (algorithm.identifier != '1.2.840.113549.1.1.1') {
    throw ArgumentError.value(
        algorithm.identifier,
        'algorithm.identifier',
        'Identifier of algorgorithm does not math identifier of RSA '
            '(1.2.840.113549.1.1.1).');
  }

  var encodedKey = baseSequence.elements[1];

  var asn1sequence =
      ASN1Parser(encodedKey.contentBytes()!).nextObject() as ASN1Sequence;

  BigInt modulus = (asn1sequence.elements[0] as ASN1Integer).valueAsBigInteger!;
  BigInt exponent =
      (asn1sequence.elements[1] as ASN1Integer).valueAsBigInteger!;

  return RSAPublicKey(modulus, exponent);
}

/// Convert an RSA-Public-Key to a DER structure as a BASE64 encoded String.
/// According to the PKCS#8 format:
///
/// PublicKeyInfo ::= SEQUENCE {
///     algorithm       AlgorithmIdentifier,
///     PublicKey       BIT STRING
/// }
///
/// AlgorithmIdentifier ::= SEQUENCE {
///     algorithm       OBJECT IDENTIFIER,
///     parameters      ANY DEFINED BY algorithm OPTIONAL
/// }
String serializeRSAPublicKeyPKCS8(RSAPublicKey key) {
  ASN1ObjectIdentifier.registerFrequentNames();
  ASN1Sequence algorithm = ASN1Sequence()
    ..add(ASN1ObjectIdentifier.fromName('rsaEncryption'))
    ..add(ASN1Null());

  var keySequence = ASN1Sequence()
    ..add(ASN1Integer(key.modulus!))
    ..add(ASN1Integer(key.exponent!));

  var publicKey = ASN1BitString(keySequence.encodedBytes);

  var asn1sequence = ASN1Sequence()
    ..add(algorithm)
    ..add(publicKey);
  return base64.encode(asn1sequence.encodedBytes);
}

/// Convert an RSA-Private-Key to a DER structure as a BASE64 encoded String.
/// According to the PKCS#1 format:
///
/// RSAPrivateKey ::= SEQUENCE {
///    version           Version,
///    modulus           INTEGER,  -- n
///    publicExponent    INTEGER,  -- e
///    privateExponent   INTEGER,  -- d
///    prime1            INTEGER,  -- p
///    prime2            INTEGER,  -- q
///    exponent1         INTEGER,  -- d mod (p-1)
///    exponent2         INTEGER,  -- d mod (q-1)
///    coefficient       INTEGER,  -- (inverse of q) mod p
///    otherPrimeInfos   OtherPrimeInfos OPTIONAL
/// }
///
/// Version ::= INTEGER { two-prime(0), multi(1) }
/// (CONSTRAINED BY {-- version must be multi if otherPrimeInfos present --})
String serializeRSAPrivateKeyPKCS1(RSAPrivateKey key) {
  ASN1Sequence s = ASN1Sequence()
    ..add(ASN1Integer.fromInt(0)) // version
    ..add(ASN1Integer(key.modulus!)) // modulus
    ..add(ASN1Integer(key.exponent!)) // e
    ..add(ASN1Integer(key.privateExponent!)) // d
    ..add(ASN1Integer(key.p!)) // p
    ..add(ASN1Integer(key.q!)) // q
    ..add(ASN1Integer(
        key.privateExponent! % (key.p! - BigInt.one))) // d mod (p-1)
    ..add(ASN1Integer(
        key.privateExponent! % (key.q! - BigInt.one))) // d mod (q-1)
    ..add(ASN1Integer(key.q!.modInverse(key.p!))); // q^(-1) mod p

  return base64.encode(s.encodedBytes);
}

/// Extract RSA-Private-Keys from DER structure that is a BASE64 encoded Strings.
/// According to the PKCS#1 format:
///
/// RSAPrivateKey ::= SEQUENCE {
///    version           Version,
///    modulus           INTEGER,  -- n
///    publicExponent    INTEGER,  -- e
///    privateExponent   INTEGER,  -- d
///    prime1            INTEGER,  -- p
///    prime2            INTEGER,  -- q
///    exponent1         INTEGER,  -- d mod (p-1)
///    exponent2         INTEGER,  -- d mod (q-1)
///    coefficient       INTEGER,  -- (inverse of q) mod p
///    otherPrimeInfos   OtherPrimeInfos OPTIONAL
/// }
///
/// Version ::= INTEGER { two-prime(0), multi(1) }
/// (CONSTRAINED BY {-- version must be multi if otherPrimeInfos present --})
RSAPrivateKey deserializeRSAPrivateKeyPKCS1(String keyStr) {
  ASN1Sequence asn1sequence =
      ASN1Parser(base64.decode(keyStr)).nextObject() as ASN1Sequence;
  BigInt modulus = (asn1sequence.elements[1] as ASN1Integer).valueAsBigInteger!;
  BigInt exponent =
      (asn1sequence.elements[2] as ASN1Integer).valueAsBigInteger!;
  BigInt p = (asn1sequence.elements[4] as ASN1Integer).valueAsBigInteger!;
  BigInt q = (asn1sequence.elements[5] as ASN1Integer).valueAsBigInteger!;

  return RSAPrivateKey(modulus, exponent, p, q);
}

/// The method returns a map that contains all the uri parameters.
Map<String, dynamic> parseQRCodeToMap(String uriAsString) {
  Uri uri = Uri.parse(uriAsString);
  log(
    'Barcode is valid Uri:',
    name: 'utils.dart',
    error: uri,
  );

  // TODO Parse crash report recipients

  if (uri.scheme != 'otpauth') {
    throw ArgumentError.value(
      uri,
      'uri',
      'The uri is not a valid otpauth uri but a(n) [${uri.scheme}] uri instead.',
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
    'uri',
    'The token type [$type] is not supported.',
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

  // If we do not support the version of this piauth url, we can stop here.
  String? pushVersionAsString = uri.queryParameters['v'];

  if (pushVersionAsString == null) {
    throw ArgumentError.value(uri, 'uri',
        'Parameter [v] is not an optional parameter and is missing.');
  }

  try {
    int pushVersion = int.parse(pushVersionAsString);

    log('Parsing push token with version: $pushVersion');

    if (pushVersion > 1) {
      throw ArgumentError.value(
          uri,
          'uri',
          'The piauth version [$pushVersionAsString] '
              'is not supported by this version of the app.');
    }
  } on FormatException {
    throw ArgumentError.value(uri, 'uri',
        '[$pushVersionAsString] is not a valid value for parameter [v].');
  }

  List labelIssuerList = _parseLabelAndIssuer(uri);
  uriMap[URI_LABEL] = labelIssuerList[0];
  uriMap[URI_ISSUER] ??= labelIssuerList[1];

  uriMap[URI_SERIAL] = uri.queryParameters['serial'];
  ArgumentError.checkNotNull(uriMap[URI_SERIAL], 'serial');

  String? url = uri.queryParameters['url'];
  ArgumentError.checkNotNull(url);
  try {
    uriMap[URI_ROLLOUT_URL] = Uri.parse(url!);
  } on FormatException catch (e) {
    throw ArgumentError.value(
        uri, 'uri', '[$url] is not a valid Uri. Error: ${e.message}');
  }

  String ttlAsString = uri.queryParameters['ttl'] ?? '10';
  try {
    uriMap[URI_TTL] = int.parse(ttlAsString);
  } on FormatException {
    throw ArgumentError.value(
        uri, 'uri', '[$ttlAsString] is not a valid value for parameter [ttl].');
  }

  uriMap[URI_ENROLLMENT_CREDENTIAL] =
      uri.queryParameters['enrollment_credential'];
  ArgumentError.checkNotNull(
      uriMap[URI_ENROLLMENT_CREDENTIAL], 'enrollment_credential');

  uriMap[URI_SSL_VERIFY] = (uri.queryParameters['sslverify'] ?? '1') == '1';

  return uriMap;
}

/// This method parses otpauth uris according
/// to https://github.com/google/google-authenticator/wiki/Key-Uri-Format.
Map<String, dynamic> parseOtpAuth(Uri uri) {
  // otpauth://TYPE/LABEL?PARAMETERS

  Map<String, dynamic> uriMap = Map();

  // parse.host -> Type totp or hotp
  uriMap[URI_TYPE] = uri.host;

  // parse.path.substring(1) -> Label
  log('Key: [..] | Value: [..]');
  uri.queryParameters.forEach((key, value) {
    log('  $key | $value');
  });

  List labelIssuerList = _parseLabelAndIssuer(uri);
  uriMap[URI_LABEL] = labelIssuerList[0];
  uriMap[URI_ISSUER] ??= labelIssuerList[1];

  String algorithm = uri.queryParameters['algorithm'] ??
      enumAsString(Algorithms.SHA1); // Optional parameter

  if (!equalsIgnoreCase(algorithm, enumAsString(Algorithms.SHA1)) &&
      !equalsIgnoreCase(algorithm, enumAsString(Algorithms.SHA256)) &&
      !equalsIgnoreCase(algorithm, enumAsString(Algorithms.SHA512))) {
    throw ArgumentError.value(
      uri,
      'uri',
      'The algorithm [$algorithm] is not supported',
    );
  }

  uriMap[URI_ALGORITHM] = algorithm;

  // Parse digits.
  String digitsAsString =
      uri.queryParameters['digits'] ?? '6'; // Optional parameter

  if (digitsAsString != '6' && digitsAsString != '8') {
    throw ArgumentError.value(
      uri,
      'uri',
      '[$digitsAsString] is not a valid number of digits',
    );
  }

  int digits = int.parse(digitsAsString);

  uriMap[URI_DIGITS] = digits;

  // Parse secret.
  String? secretAsString = uri.queryParameters['secret'];
  ArgumentError.checkNotNull(secretAsString);

  // This is a fix for omitted padding in base32 encoded secrets.
  //
  // According to https://github.com/google/google-authenticator/wiki/Key-Uri-Format,
  // the padding can be omitted, but the libraries for base32 do not allow this.
  if (secretAsString!.length % 2 == 1) {
    secretAsString += '=';
  }

  if (!isValidEncoding(secretAsString, Encodings.base32)) {
    throw ArgumentError.value(
      uri,
      'uri',
      '[${enumAsString(Encodings.base32)}] is not a valid encoding for [$secretAsString].',
    );
  }

  Uint8List secret = decodeSecretToUint8(secretAsString, Encodings.base32);

  uriMap[URI_SECRET] = secret;

  if (uriMap[URI_TYPE] == 'hotp') {
    // Parse counter.
    String? counterAsString = uri.queryParameters['counter'];
    try {
      if (counterAsString == null) {
        throw ArgumentError.value(
          uri,
          'uri',
          'Value for parameter [counter] is not optional and is missing.',
        );
      }
      uriMap[URI_COUNTER] = int.parse(counterAsString);
    } on FormatException {
      throw ArgumentError.value(
        uri,
        'uri',
        '[$counterAsString] is not a valid value for uri parameter [counter].',
      );
    }
  }

  if (uriMap[URI_TYPE] == 'totp') {
    // Parse period.
    String periodAsString = uri.queryParameters['period'] ?? '30';

    int? period = int.tryParse(periodAsString);
    if (period == null) {
      throw ArgumentError(
          'Value [$periodAsString] for parameter [period] is invalid.');
    }
    uriMap[URI_PERIOD] = period;
  }

  if (is2StepURI(uri)) {
    // Parse for 2 step roll out.
    String saltLengthAsString = uri.queryParameters['2step_salt'] ?? '10';
    String outputLengthInByteAsString =
        uri.queryParameters['2step_output'] ?? '20';
    String iterationsAsString =
        uri.queryParameters['2step_difficulty'] ?? '10000';

    // Parse parameters
    try {
      uriMap[URI_SALT_LENGTH] = int.parse(saltLengthAsString);
    } on FormatException {
      throw ArgumentError.value(
        uri,
        'uri',
        '[$saltLengthAsString] is not a valid value for parameter [2step_salt].',
      );
    }
    try {
      uriMap[URI_OUTPUT_LENGTH_IN_BYTES] =
          int.parse(outputLengthInByteAsString);
    } on FormatException {
      throw ArgumentError.value(
        uri,
        'uri',
        '[$outputLengthInByteAsString] is not a valid value for parameter [2step_output].',
      );
    }
    try {
      uriMap[URI_ITERATIONS] = int.parse(iterationsAsString);
    } on FormatException {
      throw ArgumentError.value(
        uri,
        'uri',
        '[$iterationsAsString] is not a valid value for parameter [2step_difficulty].',
      );
    }
  }

  return uriMap;
}

/// Parse the label and the issuer (if it exists) from the url.
List _parseLabelAndIssuer(Uri uri) {
  String label = '';
  String issuer = '';
  String param = uri.path.substring(1);
  param = Uri.decodeFull(param);

  try {
    if (param.contains(':')) {
      List split = param.split(':');
      issuer = split[0];
      label = split[1];
    } else {
      label = param;
      issuer = _parseIssuer(uri);
    }
  } on Error {
    label = param;
  }

  return [label, issuer];
}

String _parseIssuer(Uri uri) {
  String? issuer;
  String? param = uri.queryParameters['issuer'];

  try {
    issuer = Uri.decodeFull(param!);
  } on Error {
    issuer = param;
  }

  return issuer ?? '';
}

bool is2StepURI(Uri uri) {
  return uri.queryParameters['2step_salt'] != null ||
      uri.queryParameters['2step_output'] != null ||
      uri.queryParameters['2step_difficulty'] != null;
}
