/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
import 'dart:typed_data';

import '../../../model/enums/encodings.dart';
import '../../../model/enums/token_origin_source_type.dart';
import '../../../model/enums/token_types.dart';
import '../../../model/extensions/enums/encodings_extension.dart';
import '../../../model/extensions/enums/token_origin_source_type.dart';
import '../../../model/processor_result.dart';
import '../../../model/token_import/token_origin_data.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/identifiers.dart';
import '../../../utils/logger.dart';
import '../../../utils/object_validator.dart';
import '../../../utils/utils.dart';
import '../../../utils/view_utils.dart';
import '../../../widgets/dialog_widgets/two_step_dialog.dart';
import 'token_import_scheme_processor_interface.dart';

class OtpAuthProcessor extends TokenImportSchemeProcessor {
  static get resultHandlerType => TokenImportSchemeProcessor.resultHandlerType;
  const OtpAuthProcessor();
  @override
  Set<String> get supportedSchemes => {'otpauth'};

  /// This method parses otpauth uris according
  /// to https://github.com/google/google-authenticator/wiki/Key-Uri-Format.
  @override
  Future<List<ProcessorResult<Token>>> processUri(Uri uri, {bool fromInit = false}) async {
    if (!supportedSchemes.contains(uri.scheme)) {
      return [
        ProcessorResultFailed(
          'The scheme [${uri.scheme}] not supported',
          resultHandlerType: resultHandlerType,
        )
      ];
    }
    Logger.info('Try to handle otpAuth:');
    // The values from queryParameters are always strings.
    Map<String, String> queryParameters = {...uri.queryParameters};

    final (label, issuer) = _parseLabelAndIssuer(uri);
    queryParameters[OTP_AUTH_LABEL] = label;
    queryParameters[OTP_AUTH_ISSUER] = issuer;
    queryParameters[OTP_AUTH_TYPE] = _parseTokenType(uri);
    queryParameters = _secretAddPadding(queryParameters);

    _logInfo(uri);
    final twoStepSecretFuture = _parse2StepSecret(uri);
    if (twoStepSecretFuture != null) {
      final twoStepSecretString = await twoStepSecretFuture;
      if (twoStepSecretString == null) {
        return [
          ProcessorResultFailed(
            'The two step secret could not be generated, or was canceled.',
            resultHandlerType: resultHandlerType,
          )
        ];
      }
      // Update the secret with the two step secret.
      queryParameters[OTP_AUTH_SECRET_BASE32] = twoStepSecretString;
    }
    try {
      return [
        ProcessorResultSuccess(
          Token.fromOtpAuthMap(queryParameters, additionalData: {Token.ORIGIN: _parseCreatorToOrigin(uri)}),
          resultHandlerType: resultHandlerType,
        )
      ];
    } catch (e) {
      return [
        ProcessorResultFailed(
          'The token could not be created.',
          error: e,
          resultHandlerType: resultHandlerType,
        )
      ];
    }
  }
}

// Map<String, dynamic> _parseOtpToken(Uri uri) {
//   final type = uri.host;
//   if (TokenTypes.PIPUSH.isName(type, caseSensitive: false)) {
//     // otpauth://pipush/LABEL?PARAMETERS
//     return _parsePiPushToken(uri);
//   }
//   if (TokenTypes.values.firstWhereOrNull((element) => element.isName(type, caseSensitive: false)) != null) {
//     return _parseOtpAuth(uri);
//   }
//   throw ArgumentError.value(
//     'Invalid type: $type',
//     'QrParser#_parseOtpToken',
//     'The type [$type] is not supported.',
//   );
// }

TokenOriginData _parseCreatorToOrigin(Uri uri) {
  final origin = TokenOriginSourceType.unknown.toTokenOrigin(
    data: uri.toString(),
    originName: getCurrentAppName(),
    // If creator is present, it is a privacyIDEA token. If not it could be from an old version of the server too.
    isPrivacyIdeaToken: uri.queryParameters[OTP_AUTH_CREATOR] != null ? true : null,
    creator: uri.queryParameters[OTP_AUTH_CREATOR],
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
  final param = validate(
    value: uri.queryParameters[OTP_AUTH_ISSUER],
    validator: const ObjectValidator<String>(defaultValue: ''),
    name: OTP_AUTH_ISSUER,
  );
  try {
    return Uri.decodeFull(param);
  } catch (_) {
    return param;
  }
}

bool _is2StepURI(Uri uri) {
  final queryParameters = uri.queryParameters;
  return queryParameters[OTP_AUTH_2STEP_SALT_LENTH] != null ||
      queryParameters[OTP_AUTH_2STEP_OUTPUT_LENTH] != null ||
      queryParameters[OTP_AUTH_2STEP_ITERATIONS] != null;
}

/// This method parses the 2 step secret from the uri.
/// If its not a 2 step uri, it returns no Future (only null).
/// If the two step secret could not be generated, or was canceled, it returns a Future with null.
/// If the two step secret was generated, it returns a Future with the secret.
Future<String?>? _parse2StepSecret(Uri uri) {
  final queryParameters = uri.queryParameters;
  if (_is2StepURI(uri) == false) return null;

  validateMap(
    map: queryParameters,
    validators: {
      OTP_AUTH_SECRET_BASE32: ObjectValidator<Uint8List>(transformer: (v) => Encodings.base32.decode(v)),
      OTP_AUTH_2STEP_SALT_LENTH: intValidator,
      OTP_AUTH_2STEP_OUTPUT_LENTH: intValidator,
      OTP_AUTH_2STEP_ITERATIONS: intValidator,
    },
    name: '2StepSecret',
  );
  final secret = Encodings.base32.decode(queryParameters[OTP_AUTH_SECRET_BASE32]!);
  // Calculate the whole secret.

  final twoStepSecret = showAsyncDialog<Uint8List>(
    barrierDismissible: false,
    builder: (context) => GenerateTwoStepDialog(
      iterations: int.parse(queryParameters[OTP_AUTH_2STEP_ITERATIONS]!),
      keyLength: int.parse(queryParameters[OTP_AUTH_2STEP_OUTPUT_LENTH]!),
      saltLength: int.parse(queryParameters[OTP_AUTH_2STEP_SALT_LENTH]!),
      password: secret,
    ),
  );
  final twoStepSecretString = twoStepSecret.then((value) {
    if (value == null) return null;
    try {
      return Encodings.base32.encode(value);
    } catch (_) {
      return null;
    }
  });
  return twoStepSecretString;
}

void _logInfo(Uri uri) {
  // parse.path.substring(1) -> Label
  var infoLog = '\nKey: [..] | Value: [..]' '\n-----------------------';
  final queryParameters = uri.queryParameters;
  queryParameters.forEach((key, value) {
    infoLog += '\n${key.padLeft(9)} | $value';
  });
  Logger.info(infoLog);
}

// This is a fix for omitted padding in base32 encoded secrets.
//
// According to https://github.com/google/google-authenticator/wiki/Key-Uri-Format,
// the padding can be omitted, but the libraries for base32 do not allow this.
Map<String, String> _secretAddPadding(Map<String, String> queryParameters) {
  if (queryParameters[OTP_AUTH_SECRET_BASE32] == null) return queryParameters;
  final secret = queryParameters[OTP_AUTH_SECRET_BASE32]!;
  return {...queryParameters}..addAll({OTP_AUTH_SECRET_BASE32: '$secret${secret.length % 2 == 1 ? '=' : ''}'});
}

String _parseTokenType(Uri uri) {
  if (_parseIssuer(uri) == "Steam") return TokenTypes.STEAM.name;
  Logger.debug('Token type host: ${uri.host}');
  Logger.debug('Token type queryParameters: ${uri.queryParameters[OTP_AUTH_TYPE]}');
  final value = uri.queryParameters[OTP_AUTH_TYPE] ?? uri.host;
  Logger.debug('Token type value: $value');
  return validate(
    value: uri.queryParameters[OTP_AUTH_TYPE] ?? uri.host,
    validator: ObjectValidator<String>(defaultValue: uri.host),
    name: OTP_AUTH_TYPE,
  );
}
