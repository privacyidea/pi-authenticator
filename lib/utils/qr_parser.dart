/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2023 NetKnights GmbH

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
import 'package:flutter/foundation.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

class QrParser {
  const QrParser();

  /// The method returns a map that contains all the uri parameters.
  Map<String, dynamic> parseQRCodeToMap(String uriAsString) {
    Uri uri = Uri.parse(uriAsString);
    Logger.info(
      'Barcode is valid Uri:',
      name: 'parsing_utils.dart#parseQRCodeToMap',
      error: uri,
    );

    // TODO Parse crash report recipients

    if (uri.scheme != 'otpauth') {
      throw ArgumentError.value(
        uri,
        'parsing_utils.dart#parseQRCodeToMap',
        'The uri is not a valid otpauth uri but a(n) [${uri.scheme}] uri instead.',
      );
    }

    String type = uri.host;
    if (equalsIgnoreCase(type, enumAsString(TokenTypes.HOTP)) ||
        equalsIgnoreCase(type, enumAsString(TokenTypes.TOTP)) ||
        equalsIgnoreCase(type, enumAsString(TokenTypes.DAYPASSWORD))) {
      return _parseOtpAuth(uri);
    } else if (equalsIgnoreCase(type, enumAsString(TokenTypes.PIPUSH))) {
      return _parsePiAuth(uri);
    }

    throw ArgumentError.value(
      uri,
      'parsing_utils.dart#parseQRCodeToMap',
      'The token type [$type] is not supported.',
    );
  }

  Map<String, dynamic> _parsePiAuth(Uri uri) {
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

    Map<String, dynamic> uriMap = {};

    uriMap[URI_TYPE] = uri.host;

    // If we do not support the version of this piauth url, we can stop here.
    String? pushVersionAsString = uri.queryParameters['v'];

    if (pushVersionAsString == null) {
      throw ArgumentError.value(uri, 'uri', 'Parameter [v] is not an optional parameter and is missing.');
    }

    try {
      int pushVersion = int.parse(pushVersionAsString);

      Logger.info('Parsing push token with version: $pushVersion', name: 'parsing_utils.dart#parsePiAuth');

      if (pushVersion > 1) {
        throw ArgumentError.value(
            uri,
            'uri',
            'The piauth version [$pushVersionAsString] '
                'is not supported by this version of the app.');
      }
    } on FormatException {
      throw ArgumentError.value(uri, 'uri', '[$pushVersionAsString] is not a valid value for parameter [v].');
    }

    if (uri.queryParameters['image'] != null) {
      uriMap[URI_IMAGE] = uri.queryParameters['image'];
    }

    final (label, issuer) = _parseLabelAndIssuer(uri);
    uriMap[URI_LABEL] = label;
    uriMap[URI_ISSUER] = issuer;

    uriMap[URI_SERIAL] = uri.queryParameters['serial'];
    ArgumentError.checkNotNull(uriMap[URI_SERIAL], 'serial');

    String? url = uri.queryParameters['url'];
    ArgumentError.checkNotNull(url);
    try {
      uriMap[URI_ROLLOUT_URL] = Uri.parse(url!);
    } on FormatException catch (e) {
      throw ArgumentError.value(uri, 'uri', '[$url] is not a valid Uri. Error: ${e.message}');
    }

    String ttlAsString = uri.queryParameters['ttl'] ?? '10';
    try {
      uriMap[URI_TTL] = int.parse(ttlAsString);
    } on FormatException {
      throw ArgumentError.value(uri, 'uri', '[$ttlAsString] is not a valid value for parameter [ttl].');
    }

    uriMap[URI_ENROLLMENT_CREDENTIAL] = uri.queryParameters['enrollment_credential'];
    ArgumentError.checkNotNull(uriMap[URI_ENROLLMENT_CREDENTIAL], 'enrollment_credential');

    uriMap[URI_SSL_VERIFY] = (uri.queryParameters['sslverify'] ?? '1') == '1';

    // parse pin from response 'True'
    if (uri.queryParameters['pin'] == 'True') {
      uriMap[URI_PIN] = true;
    }

    return uriMap;
  }

  /// This method parses otpauth uris according
  /// to https://github.com/google/google-authenticator/wiki/Key-Uri-Format.
  Map<String, dynamic> _parseOtpAuth(Uri uri) {
    // otpauth://TYPE/LABEL?PARAMETERS

    Map<String, dynamic> uriMap = {};

    // parse.host -> Type totp or hotp
    uriMap[URI_TYPE] = uri.host;

    // parse.path.substring(1) -> Label
    String infoLog = '\nKey: [..] | Value: [..]';
    uri.queryParameters.forEach((key, value) {
      infoLog += '\n${key.padLeft(9)} | $value';
    });
    Logger.info(
      infoLog,
      name: 'parsing_utils.dart#_parseOtpAuth',
    );

    final (label, issuer) = _parseLabelAndIssuer(uri);
    uriMap[URI_LABEL] = label;
    uriMap[URI_ISSUER] = issuer;

    // parse pin from response 'True'
    if (uri.queryParameters['pin'] == 'True') {
      uriMap[URI_PIN] = true;
    }

    if (uri.queryParameters['image'] != null) {
      uriMap[URI_IMAGE] = uri.queryParameters['image'];
    }

    String algorithm = uri.queryParameters['algorithm'] ?? enumAsString(Algorithms.SHA1); // Optional parameter

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
    String digitsAsString = uri.queryParameters['digits'] ?? '6'; // Optional parameter

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
    secretAsString = secretAsString.toUpperCase();
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

    if (uriMap[URI_TYPE] == 'totp' || uriMap[URI_TYPE] == 'daypassword') {
      // Parse period.
      String periodAsString = uri.queryParameters['period'] ?? '30';

      int? period = int.tryParse(periodAsString);
      if (period == null) {
        throw ArgumentError('Value [$periodAsString] for parameter [period] is invalid.');
      }
      uriMap[URI_PERIOD] = period;
    }

    if (is2StepURI(uri)) {
      // Parse for 2 step roll out.
      String saltLengthAsString = uri.queryParameters['2step_salt'] ?? '10';
      String outputLengthInByteAsString = uri.queryParameters['2step_output'] ?? '20';
      String iterationsAsString = uri.queryParameters['2step_difficulty'] ?? '10000';

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
        uriMap[URI_OUTPUT_LENGTH_IN_BYTES] = int.parse(outputLengthInByteAsString);
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
  (String, String) _parseLabelAndIssuer(Uri uri) {
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

    return (label, issuer);
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
    return uri.queryParameters['2step_salt'] != null || uri.queryParameters['2step_output'] != null || uri.queryParameters['2step_difficulty'] != null;
  }
}
