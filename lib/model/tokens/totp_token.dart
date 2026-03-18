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

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../utils/logger.dart';
import '../../utils/object_validator/object_validators.dart';
import '../enums/algorithms.dart';
import '../enums/token_types.dart';
import '../extensions/enums/algorithms_extension.dart';
import '../token_import/token_origin_data.dart';
import '../token_template.dart';
import 'otp_token.dart';
import 'token.dart';

part 'totp_token.g.dart';

@JsonSerializable()
class TOTPToken extends OTPToken {
  // --- Constants ---
  static const String PERIOD_SECONDS = 'period';

  // --- Static Accessors & Validators ---
  static String get tokenType => TokenTypes.TOTP.name;

  static final Map<String, BaseValidator> otpAuthValidators = {
    ...OTPToken.otpAuthValidators,
    PERIOD_SECONDS: otpAuthPeriodSecondsValidator.withDefault(30),
  };

  static final Map<String, BaseValidator> additionalDataValidators = {
    ...OTPToken.additionalDataValidators,
  };

  // --- Static Validation Methods ---
  static Map<String, Object?> validateOtpAuthMap(
    Map<String, dynamic> otpAuthMap,
  ) {
    return validateMap(
      map: otpAuthMap,
      validators: otpAuthValidators,
      name: 'TOTPToken#otpAuthMap',
    );
  }

  static Map<String, Object?> validateAdditionalData(
    Map<String, dynamic> additionalData,
  ) {
    return validateMap(
      map: additionalData,
      validators: additionalDataValidators,
      name: 'TOTPToken#additionalData',
    );
  }

  // --- Instance Properties ---
  final int period;

  @override
  Duration get showDuration {
    final Duration duration = Duration(
      milliseconds: (period * 1000 + (secondsUntilNextOTP * 1000).toInt()),
    );
    Logger.info('$runtimeType showDuration: ${duration.inSeconds} seconds');
    return duration;
  }

  @override
  String get otpValue => otpFromTime(DateTime.now());

  @override
  String get nextValue =>
      otpFromTime(DateTime.now().add(Duration(seconds: period)));

  double get currentProgress {
    final secondsSinceEpoch =
        DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return (secondsSinceEpoch % (period)) * (1 / period);
  }

  double get secondsUntilNextOTP {
    final secondsSinceEpoch =
        (DateTime.now().toUtc().millisecondsSinceEpoch / 1000);
    return period - (secondsSinceEpoch % (period));
  }

  // --- Constructor ---
  TOTPToken({
    required int period,
    required super.id,
    required super.algorithm,
    required super.digits,
    required super.secret,
    super.serial,
    super.containerSerial,
    super.checkedContainer,
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
    super.isOffline,
    super.forceBiometricOption,
  }) : period = period < 1 ? 30 : period,
       super(type: type ?? tokenType);

  // --- Factories ---
  factory TOTPToken.fromJson(Map<String, dynamic> json) =>
      _$TOTPTokenFromJson(json);

  factory TOTPToken.fromOtpAuthMap(
    Map<String, dynamic> otpAuthMap, {
    Map<String, dynamic> additionalData = const {},
  }) {
    final validatedMap = validateOtpAuthMap(otpAuthMap);
    final validatedAdditionalData = validateAdditionalData(additionalData);

    return TOTPToken(
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
      period: validatedMap[PERIOD_SECONDS] as int,
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
    interval: Duration(seconds: period),
    isGoogle: true,
  );

  @override
  bool isSameTokenAs(Token other) {
    if (super.isSameTokenAs(other) != null) return super.isSameTokenAs(other)!;
    return (other is TOTPToken && period == other.period);
  }

  @override
  TOTPToken copyWith({
    String? serial,
    String? label,
    String? issuer,
    String? Function()? containerSerial,
    List<String>? checkedContainer,
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
    bool? isOffline,
    ForceBiometricOption? forceBiometricOption,
  }) {
    return TOTPToken(
      serial: serial ?? this.serial,
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
      period: period ?? this.period,
      tokenImage: tokenImage ?? this.tokenImage,
      pin: pin ?? this.pin,
      isLocked: isLocked ?? this.isLocked,
      isHidden: isHidden ?? this.isHidden,
      sortIndex: sortIndex ?? this.sortIndex,
      folderId: folderId != null ? folderId() : this.folderId,
      origin: origin ?? this.origin,
      isOffline: isOffline ?? this.isOffline,
      forceBiometricOption: forceBiometricOption ?? this.forceBiometricOption,
    );
  }

  @override
  TOTPToken copyUpdateByTemplate(TokenTemplate template) {
    final uriMap = validateOtpAuthMap(template.otpAuthMap);
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
      period: uriMap[PERIOD_SECONDS] as int?,
    );
  }

  @override
  String toString() => 'T${super.toString()}period: $period}';

  // --- Serialization Helpers ---
  @override
  Map<String, dynamic> toJson() => _$TOTPTokenToJson(this);

  @override
  Map<String, dynamic> toOtpAuthMap() =>
      super.toOtpAuthMap()..addAll({PERIOD_SECONDS: period.toString()});
}
