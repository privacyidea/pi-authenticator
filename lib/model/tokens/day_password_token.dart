import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'otp_token.dart';
import '../../utils/identifiers.dart';
import 'package:uuid/uuid.dart';

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
    this.viewMode = DayPasswordTokenViewMode.VALIDFOR,
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
    DayPasswordTokenViewMode? viewMode,
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
  }) =>
      DayPasswordToken(
        period: period ?? this.period,
        viewMode: viewMode ?? this.viewMode,
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
        categoryId: categoryId != null ? categoryId.call() : this.categoryId,
        isInEditMode: isInEditMode ?? this.isInEditMode,
      );

  //TODO: Server software uses an offset of 30 seconds in my tests (remove this when server is in sync)
  static const Duration serverOffset = Duration(seconds: 30);

  @override
  String get otpValue => OTPLibrary.OTP.generateTOTPCodeString(
        secret,
        DateTime.now().millisecondsSinceEpoch + serverOffset.inMilliseconds,
        length: digits,
        algorithm: mapAlgorithms(algorithm),
        interval: period.inSeconds,
        isGoogle: true,
      );

  Duration get durationSinceLastOTP {
    final msPassedThisPeriod = (DateTime.now().millisecondsSinceEpoch + serverOffset.inMilliseconds) % period.inMilliseconds;
    return Duration(milliseconds: msPassedThisPeriod);
  }

  Duration get durationUntilNextOTP => period - durationSinceLastOTP;
  DateTime get thisOTPTimeStart => DateTime.now().subtract(durationSinceLastOTP);
  DateTime get nextOTPTimeStart {
    // Sometimes there is an rounding error. For example it showes sometomes 23:59:59 instead of 00:00:00 so we add 1ms to be sure
    return DateTime.now().add(durationUntilNextOTP + const Duration(milliseconds: 1) + serverOffset);
  }

  factory DayPasswordToken.fromUriMap(Map<String, dynamic> uriMap) => DayPasswordToken(
        label: uriMap[URI_LABEL],
        issuer: uriMap[URI_ISSUER],
        id: const Uuid().v4(),
        algorithm: mapStringToAlgorithm(uriMap[URI_ALGORITHM] ?? 'SHA1'),
        digits: uriMap[URI_DIGITS],
        secret: encodeSecretAs(uriMap[URI_SECRET], Encodings.base32),
        type: uriMap[URI_TYPE],
        period: Duration(seconds: uriMap[URI_PERIOD]),
      );

  factory DayPasswordToken.fromJson(Map<String, dynamic> json) => _$DayPasswordTokenFromJson(json);
  Map<String, dynamic> toJson() => _$DayPasswordTokenToJson(this);

  @override
  String toString() {
    return 'DayPassword${super.toString()}period: $period';
  }
}
