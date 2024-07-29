import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/token_origin_source_type.dart';
import '../../../model/enums/token_origin_source_type.dart';
import '../../../model/token_import/token_origin_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/enums/algorithms.dart';
import '../../../model/enums/encodings.dart';
import '../../../model/enums/token_types.dart';
import '../../../model/extensions/enum_extension.dart';
import '../../../model/extensions/enums/encodings_extension.dart';
import '../../../model/processor_result.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/errors.dart';
import '../../../utils/globals.dart';
import '../../../utils/identifiers.dart';
import '../../../utils/logger.dart';
import '../../../utils/utils.dart' show getCurrentAppName;
import '../../../utils/view_utils.dart';
import '../../../widgets/dialog_widgets/two_step_dialog.dart';

import 'token_import_scheme_processor_interface.dart';

class OtpAuthProcessor extends TokenImportSchemeProcessor {
  const OtpAuthProcessor();
  @override
  Set<String> get supportedSchemes => {'otpauth'};

  @override
  Future<List<ProcessorResult<Token>>> processUri(Uri uri, {bool fromInit = false}) async {
    if (!supportedSchemes.contains(uri.scheme)) return [ProcessorResultFailed('The scheme [${uri.scheme}] not supported')];
    Logger.info('Try to handle otpAuth:', name: 'token_notifier.dart#addTokenFromOtpAuth');
    Map<String, dynamic> uriMap;
    try {
      uriMap = _parseOtpToken(uri);
    } catch (e, s) {
      if (e is LocalizedException) {
        Logger.warning('Error while parsing otpAuth.', name: 'token_notifier.dart#addTokenFromOtpAuth', error: e.unlocalizedMessage, stackTrace: s);
        final message = globalContextSync != null ? e.localizedMessage(AppLocalizations.of(globalContextSync!)!) : e.unlocalizedMessage;
        return [ProcessorResult.failed(message)];
      }
      String? message;
      if (e is ArgumentError) {
        Logger.warning('Error while parsing otpAuth.', name: 'token_notifier.dart#addTokenFromOtpAuth', error: e.message, stackTrace: s);
        message = '${e.message} - ${e.name}: ${e.invalidValue}';
      }
      message ??= 'An error occurred while parsing the QR code.';
      return [ProcessorResult.failed(globalContextSync != null ? AppLocalizations.of(globalContextSync!)?.tokenDataParseError ?? message : message)];
    }
    if (_is2StepURI(uri)) {
      validateMap(uriMap, [URI_SECRET, URI_ITERATIONS, URI_OUTPUT_LENGTH_IN_BYTES, URI_SALT_LENGTH]);
      final secret = uriMap[URI_SECRET] as Uint8List;
      // Calculate the whole secret.

      final twoStepSecret = (await showAsyncDialog<Uint8List>(
        barrierDismissible: false,
        builder: (context) => GenerateTwoStepDialog(
          iterations: uriMap[URI_ITERATIONS],
          keyLength: uriMap[URI_OUTPUT_LENGTH_IN_BYTES],
          saltLength: uriMap[URI_SALT_LENGTH],
          password: secret,
        ),
      ));
      if (twoStepSecret == null) {
        return [const ProcessorResultFailed('The two step secret could not be generated, or was canceled.')];
      }
      uriMap[URI_SECRET] = twoStepSecret;
    }
    Token newToken;
    try {
      newToken = Token.fromUriMap(uriMap).copyWith(
        origin: TokenOriginData(
          appName: getCurrentAppName(),
          source: TokenOriginSourceType.link,
          data: uri.toString(),
          createdAt: DateTime.now(),
        ),
      );
    } on FormatException catch (e) {
      Logger.warning('Error while parsing otpAuth.', name: 'token_notifier.dart#addTokenFromOtpAuth', error: e);
      return [ProcessorResultFailed(e.message)];
    } catch (e, s) {
      Logger.warning('Error while parsing otpAuth.', name: 'token_notifier.dart#addTokenFromOtpAuth', error: e, stackTrace: s);
      // showMessage(message: 'An error occurred while parsing the QR code.', duration: const Duration(seconds: 3));
      return [const ProcessorResultFailed('An error occurred while parsing the QR code.')];
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

const String _steamTokenIssuer = "Steam";
Map<String, dynamic> _parseOtpAuth(Uri uri) {
  // otpauth://TYPE/LABEL?PARAMETERS
  final Map<String, dynamic> uriMap = {};
  // parse.host -> Type totp or hotp
  uriMap[URI_TYPE] = uri.host;
  // parse.path.substring(1) -> Label
  var infoLog = '\nKey: [..] | Value: [..]';
  final queryParameters = uri.queryParameters;
  queryParameters.forEach((key, value) {
    if (key == URI_SECRET || key.toLowerCase().contains('secret')) {
      value = '********';
    }
    infoLog += '\n${key.padLeft(9)} | $value';
  });
  Logger.info(infoLog, name: 'parsing_utils.dart#_parseOtpAuth');

  final (label, issuer) = _parseLabelAndIssuer(uri);
  uriMap[URI_LABEL] = label;
  uriMap[URI_ISSUER] = issuer;
  if (issuer == _steamTokenIssuer) {
    uriMap[URI_TYPE] = TokenTypes.STEAM.name;
  }

  // parse pin from response 'True'
  if (queryParameters['pin'] == 'True') {
    uriMap[URI_PIN] = true;
  }

  if (queryParameters['image'] != null) {
    uriMap[URI_IMAGE] = queryParameters['image'];
  }

  String algorithm = (queryParameters['algorithm'] ?? Algorithms.SHA1.name).toUpperCase(); // Optional parameter
  algorithm = Algorithms.values.byName(algorithm).name; // Validate algorithm, throw error if not supported.

  uriMap[URI_ALGORITHM] = algorithm;

  // Parse digits.
  String digitsAsString = queryParameters['digits'] ?? '6'; // Optional parameter

  if (digitsAsString != '6' && digitsAsString != '8') {
    throw LocalizedArgumentError(
      localizedMessage: (localizations, value, name) => localizations.invalidValueForParameter(value, name),
      unlocalizedMessage: '[$digitsAsString] is not a valid number of digits.',
      invalidValue: digitsAsString,
      name: 'digits',
    );
  }

  int digits = int.parse(digitsAsString);

  uriMap[URI_DIGITS] = digits;

  // Parse secret.
  String? secretAsString = queryParameters['secret'];
  ArgumentError.checkNotNull(secretAsString, 'secret');

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

  // Parse counter.
  String? counterString = queryParameters['counter'];
  if (counterString != null) {
    uriMap[URI_COUNTER] = int.tryParse(counterString);
    if (uriMap[URI_COUNTER] == null) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: '[$counterString] is not a valid value for uri parameter [counter].',
        invalidValue: counterString,
        name: 'counter',
      );
    }
  }

  // Parse period.
  String? periodString = queryParameters['period'];
  if (periodString != null) {
    uriMap[URI_PERIOD] = int.tryParse(periodString);
    if (uriMap[URI_PERIOD] == null) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Value [$periodString] for parameter [period] is invalid.',
        invalidValue: periodString,
        name: 'period',
      );
    }
  }

  if (_is2StepURI(uri)) {
    uriMap.addAll(_parse2StepURI(uri));
  }

  // Parse creator.
  uriMap[URI_ORIGIN] = _parseCreatorToOrigin(uri);

  return uriMap;
}

Map<String, dynamic> _parse2StepURI(Uri uri) {
  final Map<String, dynamic> uriMap2Step = {};
  final queryParameters = uri.queryParameters;
  // Parse for 2 step roll out.
  final String saltLengthAsString = queryParameters['2step_salt'] ?? '10';
  final String outputLengthInByteAsString = queryParameters['2step_output'] ?? '20';
  final String iterationsAsString = queryParameters['2step_difficulty'] ?? '10000';

  // Parse parameters
  try {
    uriMap2Step[URI_SALT_LENGTH] = int.parse(saltLengthAsString);
  } on FormatException {
    throw LocalizedArgumentError(
      localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
      unlocalizedMessage: '[$saltLengthAsString] is not a valid value for parameter [2step_salt].',
      invalidValue: saltLengthAsString,
      name: '2step_salt',
    );
  }
  try {
    uriMap2Step[URI_OUTPUT_LENGTH_IN_BYTES] = int.parse(outputLengthInByteAsString);
  } on FormatException {
    throw LocalizedArgumentError(
      localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
      unlocalizedMessage: '[$outputLengthInByteAsString] is not a valid value for parameter [2step_output].',
      invalidValue: outputLengthInByteAsString,
      name: '2step_output',
    );
  }
  try {
    uriMap2Step[URI_ITERATIONS] = int.parse(iterationsAsString);
  } on FormatException {
    throw LocalizedArgumentError(
      localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
      unlocalizedMessage: '[$iterationsAsString] is not a valid value for parameter [2step_difficulty].',
      invalidValue: iterationsAsString,
      name: '2step_difficulty',
    );
  }
  return uriMap2Step;
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

  final Map<String, dynamic> uriMap = {};
  final queryParameters = uri.queryParameters;

  uriMap[URI_TYPE] = uri.host;

  // If we do not support the version of this piauth url, we can stop here.
  String? pushVersionAsString = queryParameters['v'];

  if (pushVersionAsString == null) {
    throw LocalizedArgumentError(
      localizedMessage: (localizations, value, name) => localizations.missingRequiredParameter(name),
      unlocalizedMessage: 'Parameter [v] is not an optional parameter and is missing.',
      invalidValue: pushVersionAsString,
      name: 'v',
    );
  }

  try {
    int pushVersion = int.parse(pushVersionAsString);

    Logger.info('Parsing push token with version: $pushVersion', name: 'parsing_utils.dart#parsePiAuth');

    if (pushVersion > maxPushTokenVersion) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, name) => localizations.unsupported(value, name),
        unlocalizedMessage: 'The piauth version [$pushVersionAsString] is not supported by this version of the app.',
        invalidValue: pushVersionAsString,
        name: 'piauth version',
      );
    }
  } on FormatException {
    throw LocalizedArgumentError(
      localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
      unlocalizedMessage: '[$pushVersionAsString] is not a valid value for parameter [v].',
      invalidValue: pushVersionAsString,
      name: 'v',
    );
  }

  if (queryParameters['image'] != null) {
    uriMap[URI_IMAGE] = queryParameters['image'];
  }

  final (label, issuer) = _parseLabelAndIssuer(uri);
  uriMap[URI_LABEL] = label;
  uriMap[URI_ISSUER] = issuer;
  uriMap[URI_SERIAL] = queryParameters['serial'];
  ArgumentError.checkNotNull(uriMap[URI_SERIAL], 'serial');

  final String? url = queryParameters['url'];
  ArgumentError.checkNotNull(url, 'url');
  try {
    uriMap[URI_ROLLOUT_URL] = Uri.parse(url!);
  } on FormatException {
    throw LocalizedArgumentError(
      localizedMessage: (localizations, value, name) => localizations.invalidValueForParameter(value, name),
      unlocalizedMessage: '[$url] is not a valid Uri.',
      invalidValue: url!,
      name: 'url',
    );
  }

  String ttlAsString = queryParameters['ttl'] ?? '10';
  try {
    uriMap[URI_TTL] = int.parse(ttlAsString);
  } on FormatException {
    throw LocalizedArgumentError(
      localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
      unlocalizedMessage: '[$ttlAsString] is not a valid value for parameter [ttl].',
      invalidValue: ttlAsString,
      name: 'ttl',
    );
  }

  uriMap[URI_ENROLLMENT_CREDENTIAL] = queryParameters['enrollment_credential'];
  ArgumentError.checkNotNull(uriMap[URI_ENROLLMENT_CREDENTIAL], 'enrollment_credential');

  uriMap[URI_SSL_VERIFY] = (queryParameters['sslverify'] ?? '1') == '1';

  // parse pin from response 'True'
  if (queryParameters['pin'] == 'True') {
    uriMap[URI_PIN] = true;
  }

  // Parse creator.
  uriMap[URI_ORIGIN] = _parseCreatorToOrigin(uri);

  return uriMap;
}

TokenOriginData _parseCreatorToOrigin(Uri uri) {
  final origin = TokenOriginSourceType.unknown.toTokenOrigin(
    data: uri.toString(),
    originName: getCurrentAppName(),
    // If creator is present, it is a privacyIDEA token. If not it could be from an old version of the server too.
    isPrivacyIdeaToken: uri.queryParameters['creator'] != null ? true : null,
    creator: uri.queryParameters['creator'],
    createdAt: DateTime.now(),
  );
  return origin;
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
  final queryParameters = uri.queryParameters;
  return queryParameters['2step_salt'] != null || queryParameters['2step_output'] != null || queryParameters['2step_difficulty'] != null;
}
