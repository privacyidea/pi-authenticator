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

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../utils/identifiers.dart';
import '../../utils/object_validators.dart';
import '../token_template.dart';
import 'package:uuid/uuid.dart';

import '../enums/algorithms.dart';
import '../enums/day_password_token_view_mode.dart';
import '../enums/token_types.dart';
import '../extensions/enums/algorithms_extension.dart';
import '../token_import/token_origin_data.dart';
import 'otp_token.dart';
import 'token.dart';

part 'day_password_token.g.dart';

@JsonSerializable()
@immutable
class DayPasswordToken extends OTPToken {
  static String get tokenType => TokenTypes.DAYPASSWORD.name;
  final DayPasswordTokenViewMode viewMode;
  final Duration period;

  DayPasswordToken({
    required Duration period,
    required super.id,
    required super.algorithm,
    required super.digits,
    required super.secret,
    super.serial,
    super.containerSerial,
    super.checkedContainer,
    this.viewMode = DayPasswordTokenViewMode.VALIDFOR,
    String? type, // just for @JsonSerializable(): type of DayPasswordToken is always TokenTypes.DAYPASSWORD
    super.tokenImage,
    super.sortIndex,
    super.folderId,
    super.pin,
    super.isLocked,
    super.isHidden,
    super.origin,
    super.label = '',
    super.issuer = '',
  })  : period = period.inSeconds > 0 ? period : const Duration(hours: 24),
        super(type: TokenTypes.DAYPASSWORD.name);

  @override
  // Only the viewMode can be changed even if its the same token
  bool sameValuesAs(Token other) {
    return super.sameValuesAs(other) && other is DayPasswordToken && other.viewMode == viewMode;
  }

  @override
  // It is the same token the the period as to be the same
  bool isSameTokenAs(Token other) {
    return super.isSameTokenAs(other) && other is DayPasswordToken && other.period == period;
  }

  @override
  bool operator ==(Object other) {
    return super == other && other is DayPasswordToken && other.period == period && other.viewMode == viewMode;
  }

  @override
  int get hashCode => Object.hashAll([super.hashCode, period, viewMode]);

  @override
  DayPasswordToken copyWith({
    String? serial,
    Duration? period,
    DayPasswordTokenViewMode? viewMode,
    String? label,
    String? issuer,
    String? Function()? containerSerial,
    List<String>? checkedContainer,
    String? id,
    Algorithms? algorithm,
    int? digits,
    String? secret,
    String? tokenImage,
    bool? pin,
    bool? isLocked,
    bool? isHidden,
    int? sortIndex,
    int? Function()? folderId,
    TokenOriginData? origin,
  }) =>
      DayPasswordToken(
        serial: serial ?? this.serial,
        period: period ?? this.period,
        viewMode: viewMode ?? this.viewMode,
        label: label ?? this.label,
        issuer: issuer ?? this.issuer,
        containerSerial: containerSerial != null ? containerSerial() : this.containerSerial,
        checkedContainer: checkedContainer ?? this.checkedContainer,
        id: id ?? this.id,
        type: TokenTypes.DAYPASSWORD.name,
        algorithm: algorithm ?? this.algorithm,
        digits: digits ?? this.digits,
        secret: secret ?? this.secret,
        tokenImage: tokenImage ?? this.tokenImage,
        sortIndex: sortIndex ?? this.sortIndex,
        pin: pin ?? this.pin,
        isLocked: isLocked ?? this.isLocked,
        isHidden: isHidden ?? this.isHidden,
        folderId: folderId != null ? folderId() : this.folderId,
        origin: origin ?? this.origin,
      );

  String otpFromTime(DateTime time) => algorithm.generateTOTPCodeString(
        secret: secret,
        time: time,
        length: digits,
        interval: period,
        isGoogle: true,
      );

  @override
  String get otpValue => otpFromTime(DateTime.now());
  @override
  String get nextValue => otpFromTime(DateTime.now().add(period));

  Duration get durationSinceLastOTP {
    final msPassedThisPeriod = (DateTime.now().millisecondsSinceEpoch) % period.inMilliseconds;
    return Duration(milliseconds: msPassedThisPeriod);
  }

  Duration get durationUntilNextOTP => period - durationSinceLastOTP;
  DateTime get thisOTPTimeStart => DateTime.now().subtract(durationSinceLastOTP);
  DateTime get nextOTPTimeStart {
    // Sometimes there is an rounding error. For example it showes sometomes 23:59:59 instead of 00:00:00 so we add 1ms to be sure
    return DateTime.now().add(durationUntilNextOTP + const Duration(milliseconds: 1));
  }

  @override
  DayPasswordToken copyUpdateByTemplate(TokenTemplate template) {
    final uriMap = validateMap(
      map: template.otpAuthMap,
      validators: {
        OTP_AUTH_LABEL: const ObjectValidatorNullable<String>(),
        OTP_AUTH_ISSUER: const ObjectValidatorNullable<String>(),
        OTP_AUTH_SERIAL: const ObjectValidatorNullable<String>(),
        OTP_AUTH_ALGORITHM: stringToAlgorithmsValidatorNullable,
        OTP_AUTH_DIGITS: stringToIntValidatorNullable,
        OTP_AUTH_SECRET_BASE32: base32SecretValidatorNullable,
        OTP_AUTH_PERIOD_SECONDS: stringSecondsToDurationValidatorNullable,
        OTP_AUTH_IMAGE: const ObjectValidatorNullable<String>(),
        OTP_AUTH_PIN: stringToBoolValidatorNullable,
      },
      name: 'DayPasswordToken',
    );
    return copyWith(
      label: uriMap[OTP_AUTH_LABEL] as String?,
      issuer: uriMap[OTP_AUTH_ISSUER] as String?,
      serial: uriMap[OTP_AUTH_SERIAL] as String?,
      algorithm: uriMap[OTP_AUTH_ALGORITHM] as Algorithms?,
      digits: uriMap[OTP_AUTH_DIGITS] as int?,
      secret: uriMap[OTP_AUTH_SECRET_BASE32] as String?,
      period: uriMap[OTP_AUTH_PERIOD_SECONDS] as Duration?,
      tokenImage: uriMap[OTP_AUTH_IMAGE] as String?,
      pin: uriMap[OTP_AUTH_PIN] as bool?,
      isLocked: uriMap[OTP_AUTH_PIN] as bool?,
    );
  }

  factory DayPasswordToken.fromOtpAuthMap(Map<String, dynamic> uriMap, {Map<String, dynamic> additionalData = const {}}) {
    uriMap = validateMap(
      map: uriMap,
      validators: {
        OTP_AUTH_LABEL: const ObjectValidator<String>(defaultValue: ''),
        OTP_AUTH_ISSUER: const ObjectValidator<String>(defaultValue: ''),
        OTP_AUTH_SERIAL: const ObjectValidatorNullable<String>(),
        OTP_AUTH_ALGORITHM: stringToAlgorithmsValidator.withDefault(Algorithms.SHA1),
        OTP_AUTH_DIGITS: otpAuthDigitsValidatorNullable,
        OTP_AUTH_SECRET_BASE32: base32Secretvalidator,
        OTP_AUTH_PERIOD_SECONDS: stringSecondsToDurationValidator.withDefault(const Duration(hours: 24)),
        OTP_AUTH_IMAGE: const ObjectValidatorNullable<String>(),
        OTP_AUTH_PIN: stringToBoolValidatorNullable,
      },
      name: 'DayPasswordToken',
    );
    final validatedAdditionalData = Token.validateAdditionalData(additionalData);
    return DayPasswordToken(
      label: uriMap[OTP_AUTH_LABEL],
      issuer: uriMap[OTP_AUTH_ISSUER],
      serial: uriMap[OTP_AUTH_SERIAL],
      algorithm: uriMap[OTP_AUTH_ALGORITHM],
      digits: uriMap[OTP_AUTH_DIGITS],
      secret: uriMap[OTP_AUTH_SECRET_BASE32],
      period: uriMap[OTP_AUTH_PERIOD_SECONDS],
      tokenImage: uriMap[OTP_AUTH_IMAGE],
      pin: uriMap[OTP_AUTH_PIN],
      isLocked: uriMap[OTP_AUTH_PIN],
      id: validatedAdditionalData[Token.ID] ?? const Uuid().v4(),
      containerSerial: validatedAdditionalData[Token.CONTAINER_SERIAL],
      checkedContainer: validatedAdditionalData[Token.CHECKED_CONTAINERS] ?? [],
      sortIndex: validatedAdditionalData[Token.SORT_INDEX],
      folderId: validatedAdditionalData[Token.FOLDER_ID],
      origin: validatedAdditionalData[Token.ORIGIN],
      isHidden: validatedAdditionalData[Token.HIDDEN],
    );
  }

  /// This is used to create a map that typically was created from a uri.
  /// ```dart
  /// -------------------------- [Token] --------------------------------
  /// | OTP_AUTH_SERIAL: serial, (optional)                             |
  /// | OTP_AUTH_LABEL: label,                                          |
  /// | OTP_AUTH_ISSUER: issuer,                                        |
  /// | CONTAINER_SERIAL: containerSerial, (optional)                   |
  /// | CHECKED_CONTAINERS: checkedContainer,                          |
  /// | TOKEN_ID: id,                                                   |
  /// | OTP_AUTH_TYPE: type,                                            |
  /// | OTP_AUTH_IMAGE: tokenImage, (optional)                          |
  /// | SORTABLE_INDEX: sortIndex, (optional)                           |
  /// | FOLDER_ID: folderId, (optional)                                 |
  /// | TOKEN_ORIGIN: origin, (optional)                                |
  /// | OTP_AUTH_PIN: pin,                                              |
  /// | TOKEN_HIDDEN: isHidden,                                         |
  /// -------------------------------------------------------------------
  /// ------------------------- [OTPToken] ------------------------------
  /// | OTP_AUTH_ALGORITHM: algorithm,                                  |
  /// | OTP_AUTH_DIGITS: digits,                                        |
  /// | OTP_AUTH_SECRET_BASE32: secret,                                 |
  /// | OTP_AUTH_OTP_VALUES: [otpValue, nextValue], (if serial is null) |
  /// -------------------------------------------------------------------
  /// -------------------- [DayPasswordToken] ---------------------------
  /// | OTP_AUTH_PERIOD: period,                                        |
  /// -------------------------------------------------------------------
  /// ```
  @override
  Map<String, dynamic> toOtpAuthMap() {
    return super.toOtpAuthMap()
      ..addAll({
        OTP_AUTH_PERIOD_SECONDS: period.inSeconds.toString(),
      });
  }

  @override
  Map<String, dynamic> toJson() => _$DayPasswordTokenToJson(this);
  factory DayPasswordToken.fromJson(Map<String, dynamic> json) => _$DayPasswordTokenFromJson(json);

  @override
  String toString() => 'DayPassword${super.toString()}period: $period';
}
