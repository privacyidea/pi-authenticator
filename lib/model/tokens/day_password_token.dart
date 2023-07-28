import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';

import '../../utils/utils.dart';
// ignore: library_prefixes
import 'package:otp/otp.dart' as OTPLibrary;

part 'day_password_token.g.dart';

@JsonSerializable()
@immutable
class DayPasswordToken extends OTPToken {
  final DayPasswordTokenViewMode viewMode;
  final Duration period;

  DayPasswordToken({
    this.period = const Duration(hours: 24),
    this.viewMode = DayPasswordTokenViewMode.timeLeft,
    required super.label,
    required super.issuer,
    required super.id,
    required super.algorithm,
    required super.digits,
    required super.secret,
    String? type,
    super.pin,
    super.imageURL,
    super.sortIndex,
    super.isLocked,
    super.categoryId,
    super.isInEditMode,
  }) : super(type: type ?? enumAsString(TokenTypes.DAYPASSWORD));

  @override
  DayPasswordToken copyWith({
    Duration? period,
    String? label,
    String? issuer,
    String? id,
    Algorithms? algorithm,
    int? digits,
    String? secret,
    bool? pin,
    String? imageURL,
    int? sortIndex,
    bool? isLocked,
    int? Function()? categoryId,
    bool? isInEditMode,
    DayPasswordTokenViewMode? viewMode,
  }) =>
      DayPasswordToken(
        period: period ?? this.period,
        label: label ?? this.label,
        issuer: issuer ?? this.issuer,
        id: id ?? this.id,
        type: enumAsString(TokenTypes.DAYPASSWORD),
        algorithm: algorithm ?? this.algorithm,
        digits: digits ?? this.digits,
        secret: secret ?? this.secret,
        pin: pin ?? this.pin,
        imageURL: imageURL ?? this.imageURL,
        sortIndex: sortIndex ?? this.sortIndex,
        isLocked: isLocked ?? this.isLocked,
        categoryId: categoryId?.call() ?? this.categoryId,
        isInEditMode: isInEditMode ?? this.isInEditMode,
        viewMode: viewMode ?? this.viewMode,
      );

  @override
  String get otpValue => OTPLibrary.OTP.generateTOTPCodeString(
        secret,
        DateTime.now().millisecondsSinceEpoch,
        length: digits,
        algorithm: mapAlgorithms(algorithm),
        interval: period.inMilliseconds,
        isGoogle: true,
      );

  Duration get durationSinceLastOTP {
    final msPassedThisPeriod = DateTime.now().millisecondsSinceEpoch % period.inMilliseconds;
    return Duration(milliseconds: msPassedThisPeriod);
  }

  Duration get durationUntilNextOTP => period - durationSinceLastOTP;
  DateTime get thisOTPTimeStart => DateTime.now().subtract(durationSinceLastOTP);
  DateTime get nextOTPTimeStart => DateTime.now().add(durationUntilNextOTP);

  factory DayPasswordToken.fromJson(Map<String, dynamic> json) => _$DayPasswordTokenFromJson(json);
  Map<String, dynamic> toJson() => _$DayPasswordTokenToJson(this);

  @override
  String toString() {
    return 'DayPassword${super.toString()}period: $period';
  }
}

enum DayPasswordTokenViewMode {
  timeLeft,
  timePeriod,
}
