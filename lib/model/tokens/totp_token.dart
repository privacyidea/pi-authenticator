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

import '../../utils/identifiers.dart';
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
    );
  }

  @override
  TOTPToken copyUpdateByTemplate(TokenTemplate template) {
    final uriMap = validateMap(
      map: template.otpAuthMap,
      validators: {
        OTP_AUTH_LABEL: const ObjectValidatorNullable<String>(),
        OTP_AUTH_ISSUER: const ObjectValidatorNullable<String>(),
        OTP_AUTH_SERIAL: const ObjectValidatorNullable<String>(),
        OTP_AUTH_ALGORITHM: stringToAlgorithmsValidatorNullable,
        OTP_AUTH_DIGITS: stringToIntValidatorNullable,
        OTP_AUTH_SECRET_BASE32: base32SecretValidatorNullable,
        OTP_AUTH_PERIOD_SECONDS: stringToIntValidatorNullable,
        OTP_AUTH_IMAGE: const ObjectValidatorNullable<String>(),
        OTP_AUTH_PIN: boolValidatorNullable,
      },
      name: 'TOTPToken',
    );
    return copyWith(
      label: uriMap[OTP_AUTH_LABEL] as String?,
      issuer: uriMap[OTP_AUTH_ISSUER] as String?,
      serial: uriMap[OTP_AUTH_SERIAL] as String?,
      algorithm: uriMap[OTP_AUTH_ALGORITHM] as Algorithms?,
      digits: uriMap[OTP_AUTH_DIGITS] as int?,
      secret: uriMap[OTP_AUTH_SECRET_BASE32] as String?,
      period: uriMap[OTP_AUTH_PERIOD_SECONDS] as int?,
      tokenImage: uriMap[OTP_AUTH_IMAGE] as String?,
      pin: uriMap[OTP_AUTH_PIN] as bool?,
      isLocked: uriMap[OTP_AUTH_PIN] as bool?,
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
        OTP_AUTH_LABEL: const ObjectValidator<String>(defaultValue: ''),
        OTP_AUTH_ISSUER: const ObjectValidator<String>(defaultValue: ''),
        OTP_AUTH_SERIAL: const ObjectValidatorNullable<String>(),
        OTP_AUTH_ALGORITHM: stringToAlgorithmsValidator.withDefault(Algorithms.SHA1),
        OTP_AUTH_DIGITS: stringToIntvalidator.withDefault(6),
        OTP_AUTH_SECRET_BASE32: base32Secretvalidator,
        OTP_AUTH_PERIOD_SECONDS: stringToIntvalidator.withDefault(30),
        OTP_AUTH_IMAGE: const ObjectValidatorNullable<String>(),
        OTP_AUTH_PIN: boolValidatorNullable,
      },
      name: 'TOTPToken#otpAuthMap',
    );
    final validatedAdditionalData = Token.validateAdditionalData(additionalData);
    return TOTPToken(
      label: validatedMap[OTP_AUTH_LABEL] as String,
      issuer: validatedMap[OTP_AUTH_ISSUER] as String,
      serial: validatedMap[OTP_AUTH_SERIAL] as String?,
      algorithm: validatedMap[OTP_AUTH_ALGORITHM] as Algorithms,
      digits: validatedMap[OTP_AUTH_DIGITS] as int,
      secret: validatedMap[OTP_AUTH_SECRET_BASE32] as String,
      period: validatedMap[OTP_AUTH_PERIOD_SECONDS] as int,
      tokenImage: validatedMap[OTP_AUTH_IMAGE] as String?,
      pin: validatedMap[OTP_AUTH_PIN] as bool?,
      isLocked: validatedMap[OTP_AUTH_PIN] as bool?,
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
  ///  ------------------------- [Token] -------------------------
  /// | OTP_AUTH_SERIAL: serial, (optional)                       |
  /// | OTP_AUTH_TYPE: type,                                      |
  /// | OTP_AUTH_LABEL: label,                                    |
  /// | OTP_AUTH_ISSUER: issuer,                                  |
  /// | OTP_AUTH_PIN: pin,                                        |
  /// | OTP_AUTH_IMAGE: tokenImage, (optional)                    |
  ///  -----------------------------------------------------------
  ///  ----------------------- [OTPToken] ------------------------
  /// | OTP_AUTH_ALGORITHM: algorithm,                            |
  /// | OTP_AUTH_DIGITS: digits,                                  |
  ///  -----------------------------------------------------------
  ///  ----------------------- [HOTPToken] -----------------------
  /// | OTP_AUTH_COUNTER: period,                                 |
  ///  -----------------------------------------------------------
  /// ```
  @override
  Map<String, dynamic> toOtpAuthMap() {
    return super.toOtpAuthMap()
      ..addAll({
        OTP_AUTH_COUNTER: period.toString(),
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
