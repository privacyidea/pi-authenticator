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

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../utils/logger.dart';
import '../../utils/object_validator.dart';
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
  /// [String] (optional) default = '30'
  static const String PERIOD_SECONDS = 'period';

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
  @override
  String get nextValue => otpFromTime(DateTime.now().add(Duration(seconds: period)));

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
  })  : period = period < 1 ? 30 : period, // period must be greater than 0 otherwise IntegerDivisionByZeroException is thrown in OTP.generateTOTPCodeString
        super(type: type ?? tokenType);

  // @override
  // No changeable value in TOTPToken
  // bool sameValuesAs(Token other) => super.sameValuesAs(other);

  @override
  bool isSameTokenAs(Token other) {
    if (super.isSameTokenAs(other) != null) return super.isSameTokenAs(other)!;
    if (other is! TOTPToken) return false;
    if (period != other.period) return false;
    return true;
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
  }) {
    return TOTPToken(
      serial: serial ?? this.serial,
      label: label ?? this.label,
      issuer: issuer ?? this.issuer,
      containerSerial: containerSerial != null ? containerSerial() : this.containerSerial,
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
    );
  }

  @override
  TOTPToken copyUpdateByTemplate(TokenTemplate template) {
    final uriMap = validateMap(
      map: template.otpAuthMap,
      validators: {
        Token.LABEL: const ObjectValidatorNullable<String>(),
        Token.ISSUER: const ObjectValidatorNullable<String>(),
        Token.SERIAL: const ObjectValidatorNullable<String>(),
        Token.IMAGE: const ObjectValidatorNullable<String>(),
        Token.PIN: boolValidatorNullable,
        OTPToken.ALGORITHM: stringToAlgorithmsValidatorNullable,
        OTPToken.DIGITS: intValidatorNullable,
        OTPToken.SECRET_BASE32: base32SecretValidatorNullable,
        PERIOD_SECONDS: intValidatorNullable,
      },
      name: 'TOTPToken',
    );
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
  String toString() {
    return 'T${super.toString()}period: $period}';
  }

  factory TOTPToken.fromOtpAuthMap(Map<String, dynamic> otpAuthMap, {Map<String, dynamic> additionalData = const {}}) {
    final validatedMap = validateMap(
      map: otpAuthMap,
      validators: {
        Token.LABEL: const ObjectValidator<String>(defaultValue: ''),
        Token.ISSUER: const ObjectValidator<String>(defaultValue: ''),
        Token.SERIAL: const ObjectValidatorNullable<String>(),
        Token.IMAGE: const ObjectValidatorNullable<String>(),
        Token.PIN: boolValidatorNullable,
        OTPToken.ALGORITHM: stringToAlgorithmsValidator.withDefault(Algorithms.SHA1),
        OTPToken.DIGITS: otpAuthDigitsValidator,
        OTPToken.SECRET_BASE32: base32Secretvalidator,
        PERIOD_SECONDS: otpAuthPeriodSecondsValidator,
      },
      name: 'TOTPToken#otpAuthMap',
    );
    final validatedAdditionalData = Token.validateAdditionalData(additionalData);
    return TOTPToken(
      label: validatedMap[Token.LABEL] as String,
      issuer: validatedMap[Token.ISSUER] as String,
      serial: validatedMap[Token.SERIAL] as String?,
      tokenImage: validatedMap[Token.IMAGE] as String?,
      pin: validatedMap[Token.PIN] as bool?,
      isLocked: validatedMap[Token.PIN] as bool?,
      id: validatedAdditionalData[Token.ID] ?? const Uuid().v4(),
      containerSerial: validatedAdditionalData[Token.CONTAINER_SERIAL],
      checkedContainer: validatedAdditionalData[Token.CHECKED_CONTAINERS] ?? [],
      sortIndex: validatedAdditionalData[Token.SORT_INDEX],
      folderId: validatedAdditionalData[Token.FOLDER_ID],
      origin: validatedAdditionalData[Token.ORIGIN],
      isHidden: validatedAdditionalData[Token.HIDDEN],
      algorithm: validatedMap[OTPToken.ALGORITHM] as Algorithms,
      digits: validatedMap[OTPToken.DIGITS] as int,
      secret: validatedMap[OTPToken.SECRET_BASE32] as String,
      period: validatedMap[PERIOD_SECONDS] as int,
    );
  }

  /// This is used to create a map that typically was created from a uri.
  /// ```dart
  ///  ------------------------- [Token] -------------------------
  /// | Token.SERIAL: serial, (optional)                          |
  /// | Token.TOKENTYPE_JSON: type,                                         |
  /// | Token.LABEL: label,                                       |
  /// | Token.ISSUER: issuer,                                     |
  /// | Token.PIN: pin,                                           |
  /// | Token.IMAGE: tokenImage, (optional)                       |
  ///  -----------------------------------------------------------
  ///  ----------------------- [OTPToken] ------------------------
  /// | OTPToken.ALGORITHM: algorithm,                            |
  /// | OTPToken.DIGITS: digits,                                  |
  ///  -----------------------------------------------------------
  ///  ----------------------- [HOTPToken] -----------------------
  /// | PERIOD_SECONDS: period,                                   |
  ///  -----------------------------------------------------------
  /// ```
  @override
  Map<String, dynamic> toOtpAuthMap() {
    return super.toOtpAuthMap()
      ..addAll({
        PERIOD_SECONDS: period.toString(),
      });
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
