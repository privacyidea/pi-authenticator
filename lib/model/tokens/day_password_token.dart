/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:uuid/uuid.dart';

import '../../utils/object_validator/object_validators.dart';
import '../enums/algorithms.dart';
import '../enums/day_password_token_view_mode.dart';
import '../enums/token_types.dart';
import '../extensions/enums/algorithms_extension.dart';
import '../token_import/token_origin_data.dart';
import '../token_template.dart';
import 'otp_token.dart';
import 'token.dart';

part 'day_password_token.g.dart';

@JsonSerializable()
@immutable
class DayPasswordToken extends OTPToken {
  // --- Constants ---
  static const String VIEW_MODE = 'view_mode';

  // --- Static Accessors & Validators ---
  static String get tokenType => TokenTypes.DAYPASSWORD.name;

  static final Map<String, BaseValidator> otpAuthValidators = {
    ...OTPToken.otpAuthValidators,
    TOTPToken.PERIOD_SECONDS: secondsDurationValidator.withDefault(
      const Duration(hours: 24),
    ),
  };

  static final Map<String, BaseValidator> additionalDataValidators = {
    ...OTPToken.additionalDataValidators,
    VIEW_MODE: const OptionalObjectValidator<DayPasswordTokenViewMode>(
      defaultValue: DayPasswordTokenViewMode.VALIDFOR,
    ),
  };

  // --- Static Validation Methods ---
  static Map<String, Object?> validateOtpAuthMap(
    Map<String, dynamic> otpAuthMap,
  ) {
    return validateMap(
      map: otpAuthMap,
      validators: otpAuthValidators,
      name: 'DayPasswordToken#otpAuthMap',
    );
  }

  static Map<String, Object?> validateAdditionalData(
    Map<String, dynamic> additionalData,
  ) {
    return validateMap(
      map: additionalData,
      validators: additionalDataValidators,
      name: 'DayPasswordToken#additionalData',
    );
  }

  // --- Instance Properties ---
  final DayPasswordTokenViewMode viewMode;
  final Duration period;

  @override
  String get otpValue => otpFromTime(DateTime.now());

  @override
  String get nextValue => otpFromTime(DateTime.now().add(period));

  Duration get durationSinceLastOTP {
    final msPassedThisPeriod =
        (DateTime.now().millisecondsSinceEpoch) % period.inMilliseconds;
    return Duration(milliseconds: msPassedThisPeriod);
  }

  Duration get durationUntilNextOTP => period - durationSinceLastOTP;

  DateTime get thisOTPTimeStart =>
      DateTime.now().subtract(durationSinceLastOTP);

  DateTime get nextOTPTimeStart {
    return DateTime.now().add(
      durationUntilNextOTP + const Duration(milliseconds: 1),
    );
  }

  // --- Constructor ---
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
    String? type,
    super.tokenImage,
    super.sortIndex,
    super.folderId,
    super.pin,
    super.isLocked,
    super.isHidden,
    super.origin,
    super.label = '',
    super.issuer = '',
    super.isOffline,
    super.forceBiometricOption,
  }) : period = period.inSeconds > 0 ? period : const Duration(hours: 24),
       super(type: TokenTypes.DAYPASSWORD.name);

  // --- Factories ---
  factory DayPasswordToken.fromJson(Map<String, dynamic> json) =>
      _$DayPasswordTokenFromJson(json);

  factory DayPasswordToken.fromOtpAuthMap(
    Map<String, dynamic> otpAuthMap, {
    Map<String, dynamic> additionalData = const {},
  }) {
    final validatedMap = validateOtpAuthMap(otpAuthMap);
    final validatedAdditionalData = validateAdditionalData(additionalData);

    return DayPasswordToken(
      label: validatedMap[Token.LABEL] as String,
      issuer: validatedMap[Token.ISSUER] as String,
      serial: validatedMap[Token.SERIAL] as String?,
      tokenImage: validatedMap[Token.IMAGE] as String?,
      pin: validatedMap[Token.PIN] as bool?,
      isLocked: validatedMap[Token.PIN] as bool?,
      isOffline: validatedMap[Token.OFFLINE] as bool,
      algorithm: validatedMap[OTPToken.ALGORITHM] as Algorithms,
      digits: validatedMap[OTPToken.DIGITS] as int,
      secret: validatedMap[OTPToken.SECRET_BASE32] as String,
      period: validatedMap[TOTPToken.PERIOD_SECONDS] as Duration,
      viewMode: validatedAdditionalData[VIEW_MODE] as DayPasswordTokenViewMode,
      forceBiometricOption:
          validatedMap[Token.FORCE_BIOMETRIC_OPTION] as ForceBiometricOption,
      id: validatedAdditionalData[Token.ID] as String? ?? const Uuid().v4(),
      containerSerial:
          validatedAdditionalData[Token.CONTAINER_SERIAL] as String?,
      checkedContainer:
          validatedAdditionalData[Token.CHECKED_CONTAINERS] as List<String>,
      sortIndex: validatedAdditionalData[Token.SORT_INDEX] as int?,
      folderId: validatedAdditionalData[Token.FOLDER_ID] as int?,
      origin: validatedAdditionalData[Token.ORIGIN] as TokenOriginData?,
      isHidden: validatedAdditionalData[Token.IS_HIDDEN] as bool?,
    );
  }

  // --- Methods ---
  String otpFromTime(DateTime time) => algorithm.generateTOTPCodeString(
    secret: secret,
    time: time,
    length: digits,
    interval: period,
    isGoogle: true,
  );

  @override
  bool sameValuesAs(Token other) {
    return super.sameValuesAs(other) &&
        other is DayPasswordToken &&
        other.viewMode == viewMode;
  }

  @override
  bool isSameTokenAs(Token other) {
    if (super.isSameTokenAs(other) != null) return super.isSameTokenAs(other)!;
    return (other is DayPasswordToken && period == other.period);
  }

  @override
  bool operator ==(Object other) {
    return super == other &&
        other is DayPasswordToken &&
        other.period == period &&
        other.viewMode == viewMode;
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
    bool? isOffline,
    ForceBiometricOption? forceBiometricOption,
  }) => DayPasswordToken(
    serial: serial ?? this.serial,
    period: period ?? this.period,
    viewMode: viewMode ?? this.viewMode,
    label: label ?? this.label,
    issuer: issuer ?? this.issuer,
    containerSerial: containerSerial != null
        ? containerSerial()
        : this.containerSerial,
    checkedContainer: checkedContainer ?? this.checkedContainer,
    id: id ?? this.id,
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
    isOffline: isOffline ?? this.isOffline,
    forceBiometricOption: forceBiometricOption ?? this.forceBiometricOption,
  );

  @override
  DayPasswordToken copyUpdateByTemplate(TokenTemplate template) {
    final uriMap = validateOtpAuthMap(template.otpAuthMap);
    final additionalData = validateAdditionalData(template.additionalData);
    return copyWith(
      label: uriMap[Token.LABEL] as String?,
      issuer: uriMap[Token.ISSUER] as String?,
      serial: uriMap[Token.SERIAL] as String?,
      tokenImage: uriMap[Token.IMAGE] as String?,
      pin: uriMap[Token.PIN] as bool?,
      isLocked: uriMap[Token.PIN] as bool?,
      algorithm: uriMap[OTPToken.ALGORITHM] as Algorithms?,
      digits: uriMap[OTPToken.DIGITS] as int?,
      secret: uriMap[OTPToken.SECRET_BASE32] as String?,
      period: uriMap[TOTPToken.PERIOD_SECONDS] as Duration?,
      viewMode: additionalData[VIEW_MODE] as DayPasswordTokenViewMode?,
    );
  }

  @override
  String toString() => 'DayPassword${super.toString()}period: $period';

  // --- Serialization Helpers ---
  @override
  Map<String, dynamic> toJson() => _$DayPasswordTokenToJson(this);

  @override
  Map<String, dynamic> toOtpAuthMap() {
    return super.toOtpAuthMap()
      ..addAll({TOTPToken.PERIOD_SECONDS: period.inSeconds.toString()});
  }

  @override
  Map<String, dynamic> get additionalData =>
      super.additionalData..addAll({VIEW_MODE: viewMode});
}
