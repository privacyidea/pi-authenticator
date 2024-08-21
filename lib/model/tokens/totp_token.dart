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

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../utils/errors.dart';
import '../../utils/identifiers.dart';
import '../../utils/logger.dart';
import '../enums/algorithms.dart';
import '../enums/encodings.dart';
import '../enums/token_types.dart';
import '../extensions/enums/algorithms_extension.dart';
import '../extensions/enums/encodings_extension.dart';
import '../token_container.dart';
import '../token_import/token_origin_data.dart';
import 'otp_token.dart';
import 'token.dart';

part 'totp_token.g.dart';

@JsonSerializable()
class TOTPToken extends OTPToken {
  static String get tokenType => TokenTypes.TOTP.name;
  // this value is used to calculate the current 'counter' of this token
  // based on the UNIX systemtime), the counter is used to calculate the
  // current otp value
  final int period;

  @override
  Duration get showDuration {
    final Duration duration = Duration(milliseconds: (period * 1000 + (secondsUntilNextOTP * 1000).toInt()));
    Logger.info('$runtimeType showDuration: ${duration.inSeconds} seconds');
    return duration;
  }

  String otpFromTime(DateTime time) => algorithm.generateTOTPCodeString(
        secret: secret,
        time: time,
        length: digits,
        interval: Duration(seconds: period),
        isGoogle: true,
      );

  @override
  String get otpValue => otpFromTime(DateTime.now());

  TOTPToken({
    required int period,
    required super.id,
    required super.algorithm,
    required super.digits,
    required super.secret,
    super.containerSerial,
    super.serial,
    String? type,
    super.tokenImage,
    super.pin,
    super.isLocked,
    super.isHidden,
    super.sortIndex,
    super.folderId,
    super.origin,
    super.label = '',
    super.issuer = '',
  })  : period = period < 1 ? 30 : period, // period must be greater than 0 otherwise IntegerDivisionByZeroException is thrown in OTP.generateTOTPCodeString
        super(type: type ?? tokenType);

  // @override
  // No changeable value in TOTPToken
  // bool sameValuesAs(Token other) => super.sameValuesAs(other);

  @override
  bool isSameTokenAs(Token other) => super.isSameTokenAs(other) && other is TOTPToken && other.period == period;

  @override
  TOTPToken copyWith({
    String? serial,
    String? label,
    String? issuer,
    String? Function()? containerSerial,
    String? id,
    Algorithms? algorithm,
    int? digits,
    String? secret,
    int? period,
    String? tokenImage,
    bool? pin,
    bool? isLocked,
    bool? isHidden,
    int? sortIndex,
    int? Function()? folderId,
    TokenOriginData? origin,
  }) {
    return TOTPToken(
      serial: serial ?? this.serial,
      label: label ?? this.label,
      issuer: issuer ?? this.issuer,
      containerSerial: containerSerial != null ? containerSerial() : this.containerSerial,
      id: id ?? this.id,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      secret: secret ?? this.secret,
      period: period ?? this.period,
      tokenImage: tokenImage ?? this.tokenImage,
      pin: pin ?? this.pin,
      isLocked: isLocked ?? this.isLocked,
      isHidden: isHidden ?? this.isHidden,
      sortIndex: sortIndex ?? this.sortIndex,
      folderId: folderId != null ? folderId() : this.folderId,
      origin: origin ?? this.origin,
    );
  }

  @override
  TOTPToken copyWithFromTemplate(TokenTemplate template) {
    final uriMap = template.data;

    final newToken = copyWith(
      id: uriMap[URI_ID],
      label: uriMap[URI_LABEL],
      issuer: uriMap[URI_ISSUER],
      serial: uriMap[URI_SERIAL],
      algorithm: uriMap[URI_ALGORITHM] != null ? Algorithms.values.byName((uriMap[URI_ALGORITHM] as String).toUpperCase()) : null,
      digits: uriMap[URI_DIGITS],
      tokenImage: uriMap[URI_IMAGE],
      secret: uriMap[URI_SECRET] != null ? Encodings.base32.encode(uriMap[URI_SECRET]) : null,
      period: uriMap[URI_PERIOD],
      pin: uriMap[URI_PIN],
      isLocked: uriMap[URI_PIN],
      origin: uriMap[URI_ORIGIN],
    );
    Logger.debug('TOTPToken.copyWithFromTemplate old token: $this');
    Logger.debug('TOTPToken.copyWithFromTemplate new token: $newToken');
    return newToken;
  }

  @override
  String toString() {
    return 'T${super.toString()}period: $period}';
  }

  factory TOTPToken.fromUriMap(Map<String, dynamic> uriMap) {
    validateUriMap(uriMap);
    return TOTPToken(
      label: uriMap[URI_LABEL] ?? '',
      issuer: uriMap[URI_ISSUER] ?? '',
      id: uriMap[URI_ID] == String ? uriMap[URI_ID] : const Uuid().v4(),
      serial: uriMap[URI_SERIAL],
      algorithm: Algorithms.values.byName((uriMap[URI_ALGORITHM] as String? ?? 'SHA1').toUpperCase()),
      digits: uriMap[URI_DIGITS] ?? 6,
      tokenImage: uriMap[URI_IMAGE],
      secret: Encodings.base32.encode(uriMap[URI_SECRET]),
      period: uriMap[URI_PERIOD] ?? 30,
      pin: uriMap[URI_PIN],
      isLocked: uriMap[URI_PIN],
      origin: uriMap[URI_ORIGIN],
    );
  }

  /// This is used to create a map that typically was created from a uri.
  /// ```dart
  /// ----------------------------- [TOTPToken] ------------------------------
  /// URI_PERIOD: period of otp generation in seconds (int),
  /// ------------------------------ [OTPToken] ------------------------------
  /// URI_SECRET: base32 encoded string (String),
  /// URI_ALGORITHM: algorithm name e.g. SHA1 (String),
  /// URI_DIGITS: number of digits (int),
  /// ------------------------------- [Token] ---------------------------------
  /// URI_LABEL: name of the token (String),
  /// URI_ISSUER: name of the issuer (String),
  /// URI_PIN: is the user forced to have a pin (bool),
  /// URI_IMAGE: url to an image e.g. "https://example.com/image.png" (String),
  /// URI_ORIGIN: json string of the origin class (String),
  /// -------------------------------------------------------------------------
  /// ```
  @override
  Map<String, dynamic> toUriMap() {
    return super.toUriMap()
      ..addAll({
        URI_PERIOD: period,
      });
  }

  /// Validates the uriMap for the required fields throws [LocalizedArgumentError] if a field is missing or invalid.
  static void validateUriMap(Map<String, dynamic> uriMap) {
    if (uriMap[URI_SECRET] is! Uint8List) {
      throw LocalizedArgumentError(
        localizedMessage: ((localizations, value, name) => localizations.secretIsRequired),
        unlocalizedMessage: 'Secret is required and must be a Uint8List',
        invalidValue: uriMap[URI_SECRET],
        name: URI_SECRET,
      );
    }
    if (uriMap[URI_SERIAL] is! String?) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Serial must be a string',
        invalidValue: uriMap[URI_SERIAL],
        name: URI_SERIAL,
      );
    }
    if (uriMap[URI_DIGITS] != null && uriMap[URI_DIGITS] < 1) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Digits must be greater than 0',
        invalidValue: uriMap[URI_DIGITS],
        name: URI_DIGITS,
      );
    }
    if (uriMap[URI_PERIOD] != null && uriMap[URI_PERIOD] < 1) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Period must be greater than 0',
        invalidValue: uriMap[URI_PERIOD],
        name: URI_PERIOD,
      );
    }
    if (uriMap[URI_ALGORITHM] != null) {
      try {
        Algorithms.values.byName(uriMap[URI_ALGORITHM].toUpperCase());
      } catch (e) {
        throw LocalizedArgumentError(
          localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
          unlocalizedMessage: 'Algorithm ${uriMap[URI_ALGORITHM]} is not supported',
          invalidValue: uriMap[URI_ALGORITHM],
          name: URI_ALGORITHM,
        );
      }
    }
  }

  double get currentProgress {
    final secondsSinceEpoch = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return (secondsSinceEpoch % (period)) * (1 / period);
  }

  double get secondsUntilNextOTP {
    final secondsSinceEpoch = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000);
    return period - (secondsSinceEpoch % (period));
  }

  @override
  Map<String, dynamic> toJson() => _$TOTPTokenToJson(this);
  factory TOTPToken.fromJson(Map<String, dynamic> json) => _$TOTPTokenFromJson(json);
}
