import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/enums/algorithms.dart';
import '../../../model/enums/encodings.dart';
import '../../../model/enums/token_types.dart';
import '../../../model/extensions/enum_extension.dart';
import '../../../model/processor_result.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/errors.dart';
import '../../../utils/globals.dart';
import '../../../utils/identifiers.dart';
import '../../../utils/logger.dart';
import '../../../utils/view_utils.dart';
import '../../../widgets/dialog_widgets/two_step_dialog.dart';
import 'token_import_scheme_processor_interface.dart';

class OtpAuthProcessor extends TokenImportSchemeProcessor {
  const OtpAuthProcessor();
  @override
  Set<String> get supportedSchemes => {'otpauth'};

  @override
  Future<List<ProcessorResult<Token>>> processUri(Uri uri, {bool fromInit = false}) async {
    if (!supportedSchemes.contains(uri.scheme)) return [ProcessorResultError('The scheme [${uri.scheme}] not supported')];
    Logger.info('Try to handle otpAuth:', name: 'token_notifier.dart#addTokenFromOtpAuth');
    Map<String, dynamic> uriMap;
    try {
      uriMap = _parseOtpToken(uri);
    } on LocalizedException catch (e) {
      Logger.warning('Error while parsing otpAuth.', name: 'token_notifier.dart#addTokenFromOtpAuth', error: e);
      final message = e.localizedMessage(AppLocalizations.of(await globalContext)!);
      return [ProcessorResultError(message)];
    }
    if (_is2StepURI(uri)) {
      validateMap(uriMap, [URI_SECRET, URI_ITERATIONS, URI_OUTPUT_LENGTH_IN_BYTES, URI_SALT_LENGTH]);
      final secret = uriMap[URI_SECRET] as Uint8List;
      // Calculate the whole secret.
      Uint8List? twoStepSecret;
      while (twoStepSecret == null) {
        twoStepSecret = (await showAsyncDialog<Uint8List>(
          barrierDismissible: false,
          builder: (context) => GenerateTwoStepDialog(
            iterations: uriMap[URI_ITERATIONS],
            keyLength: uriMap[URI_OUTPUT_LENGTH_IN_BYTES],
            saltLength: uriMap[URI_SALT_LENGTH],
            password: secret,
          ),
        ));
        await Future.delayed(const Duration(milliseconds: 500));
      }
      uriMap[URI_SECRET] = twoStepSecret;
    }
    Token newToken;
    try {
      newToken = Token.fromUriMap(uriMap);
    } on FormatException catch (e) {
      Logger.warning('Error while parsing otpAuth.', name: 'token_notifier.dart#addTokenFromOtpAuth', error: e);
      return [ProcessorResultError(e.message)];
    } catch (e, s) {
      Logger.warning('Error while parsing otpAuth.', name: 'token_notifier.dart#addTokenFromOtpAuth', error: e, stackTrace: s);
      showMessage(message: 'An error occurred while parsing the QR code.', duration: const Duration(seconds: 3));
      return [const ProcessorResultError('An error occurred while parsing the QR code.')];
    }
    return [ProcessorResultSuccess(newToken)];
  }
}

/// This method parses otpauth uris according
/// to https://github.com/google/google-authenticator/wiki/Key-Uri-Format.
Map<String, dynamic> _parseOtpToken(Uri uri) {
  final type = uri.host;
  if (TokenTypes.PIPUSH.isName(type, caseSensitive: false)) {
    // otpauth://pipush/LABEL?PARAMETERS
    return _parsePiPushToken(uri);
  }
  if (TokenTypes.values.firstWhereOrNull((element) => element.isName(type, caseSensitive: false)) != null) {
    return _parseOtpAuth(uri);
  }
  throw ArgumentError.value(
    'Invalid type: $type',
    'QrParser#_parseOtpToken',
    'The type [$type] is not supported.',
  );
}

Map<String, dynamic> _parseOtpAuth(Uri uri) {
  // otpauth://TYPE/LABEL?PARAMETERS
  Map<String, dynamic> uriMap = {};

  // parse.host -> Type totp or hotp
  uriMap[URI_TYPE] = uri.host;

  // parse.path.substring(1) -> Label
  String infoLog = '\nKey: [..] | Value: [..]';
  uri.queryParameters.forEach((key, value) {
    if (key == URI_SECRET || key.toLowerCase().contains('secret')) {
      value = '********';
    }
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

  String algorithm = uri.queryParameters['algorithm'] ?? Algorithms.SHA1.name; // Optional parameter
  algorithm = Algorithms.values.byName(algorithm).name; // Validate algorithm, throw error if not supported.

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
  final secret = Encodings.base32.tryDecode(secretAsString);
  if (secret == null) {
    throw ArgumentError.value(
      uri,
      'uri',
      '[${Encodings.base32.name}] is not a valid encoding for [$secretAsString].',
    );
  }

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

  if (_is2StepURI(uri)) {
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

Map<String, dynamic> _parsePiPushToken(Uri uri) {
  // otpauth://pipush/LABELTEXT?
  // url=https://privacyidea.org/enroll/this/token
  // &ttl=120
  // &issuer=privacyIDEA
  // &enrollment_credential=9311ee50678983c0f29d3d843f86e39405e2b427
  // &v=1
  // &serial=PIPU0006EF87
  // &sslverify=1

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

    if (pushVersion > maxPushTokenVersion) {
      throw ArgumentError.value(
        'Unsupported version: $pushVersion',
        'QrParser#_parsePiAuth',
        'The piauth version [$pushVersionAsString] is not supported by this version of the app.',
      );
    }
  } on FormatException {
    throw ArgumentError.value(
      'Invalid version: $pushVersionAsString',
      'QrParser#_parsePiAuth',
      '[$pushVersionAsString] is not a valid value for parameter [v].',
    );
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
  ArgumentError.checkNotNull(url, 'url');
  try {
    uriMap[URI_ROLLOUT_URL] = Uri.parse(url!);
  } on FormatException {
    throw ArgumentError.value(uri, 'uri', '[$url] is not a valid Uri.');
  }

  String ttlAsString = uri.queryParameters['ttl'] ?? '10';
  try {
    uriMap[URI_TTL] = int.parse(ttlAsString);
  } on FormatException {
    throw ArgumentError.value('Invalid ttl: $ttlAsString', 'QrParser#_parsePiAuth', '[$ttlAsString] is not a valid value for parameter [ttl].');
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
      issuer = _parseIssuer(uri);
      label = param;
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

bool _is2StepURI(Uri uri) {
  return uri.queryParameters['2step_salt'] != null || uri.queryParameters['2step_output'] != null || uri.queryParameters['2step_difficulty'] != null;
}
