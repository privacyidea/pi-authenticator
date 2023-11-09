import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:otp/otp.dart' as otp_library;
import 'package:uuid/uuid.dart';

import '../../utils/crypto_utils.dart';
import '../../utils/identifiers.dart';
import '../../utils/utils.dart';
import '../enums/algorithms.dart';
import '../enums/day_passoword_token_view_mode.dart';
import '../enums/encodings.dart';
import '../enums/token_types.dart';
import 'otp_token.dart';

part 'day_password_token.g.dart';

@JsonSerializable()
@immutable
class DayPasswordToken extends OTPToken {
  final DayPasswordTokenViewMode viewMode;
  final Duration period;

  DayPasswordToken({
    required Duration period,
    required super.label,
    required super.issuer,
    required super.id,
    required super.algorithm,
    required super.digits,
    required super.secret,
    this.viewMode = DayPasswordTokenViewMode.VALIDFOR,
    String? type, // just for @JsonSerializable(): type of DayPasswordToken is always TokenTypes.DAYPASSWORD
    super.pin,
    super.tokenImage,
    super.sortIndex,
    super.isLocked,
    super.folderId,
  })  : period = period.inSeconds > 0 ? period : const Duration(hours: 24),
        super(type: TokenTypes.DAYPASSWORD.asString);

  @override
  DayPasswordToken copyWith({
    Duration? period,
    DayPasswordTokenViewMode? viewMode,
    String? label,
    String? issuer,
    String? id,
    Algorithms? algorithm,
    int? digits,
    String? secret,
    bool? pin,
    String? tokenImage,
    int? sortIndex,
    bool? isLocked,
    int? Function()? folderId,
  }) =>
      DayPasswordToken(
        period: period ?? this.period,
        viewMode: viewMode ?? this.viewMode,
        label: label ?? this.label,
        issuer: issuer ?? this.issuer,
        id: id ?? this.id,
        type: TokenTypes.DAYPASSWORD.asString,
        algorithm: algorithm ?? this.algorithm,
        digits: digits ?? this.digits,
        secret: secret ?? this.secret,
        pin: pin ?? this.pin,
        tokenImage: tokenImage ?? this.tokenImage,
        sortIndex: sortIndex ?? this.sortIndex,
        isLocked: isLocked ?? this.isLocked,
        folderId: folderId != null ? folderId.call() : this.folderId,
      );

  @override
  String get otpValue => otp_library.OTP.generateTOTPCodeString(
        secret,
        DateTime.now().millisecondsSinceEpoch,
        length: digits,
        algorithm: algorithm.otpLibraryAlgorithm,
        interval: period.inSeconds,
        isGoogle: true,
      );

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

  factory DayPasswordToken.fromUriMap(Map<String, dynamic> uriMap) {
    if (uriMap[URI_SECRET] == null) throw ArgumentError('Secret is required');
    if (uriMap[URI_PERIOD] < 1) throw ArgumentError('Period must be greater than 0');
    if (uriMap[URI_DIGITS] < 1) throw ArgumentError('Digits must be greater than 0');
    DayPasswordToken dayPasswordToken;
    try {
      dayPasswordToken = DayPasswordToken(
        label: uriMap[URI_LABEL] ?? '',
        issuer: uriMap[URI_ISSUER] ?? '',
        id: const Uuid().v4(),
        algorithm: mapStringToAlgorithm(uriMap[URI_ALGORITHM] ?? 'SHA1'),
        digits: uriMap[URI_DIGITS] ?? 6,
        secret: encodeSecretAs(uriMap[URI_SECRET], Encodings.base32),
        period: Duration(seconds: uriMap[URI_PERIOD]),
        tokenImage: uriMap[URI_IMAGE],
        pin: uriMap[URI_PIN],
        isLocked: uriMap[URI_PIN],
      );
    } catch (e) {
      throw ArgumentError('Invalid URI: $e');
    }
    return dayPasswordToken;
  }

  factory DayPasswordToken.fromJson(Map<String, dynamic> json) => _$DayPasswordTokenFromJson(json);
  Map<String, dynamic> toJson() => _$DayPasswordTokenToJson(this);

  @override
  String toString() {
    return 'DayPassword${super.toString()}period: $period';
  }
}
