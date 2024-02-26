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
import '../extensions/enum_extension.dart';
import '../token_origin.dart';
import 'otp_token.dart';
import 'token.dart';

part 'day_password_token.g.dart';

@JsonSerializable()
@immutable
class DayPasswordToken extends OTPToken {
  static String get tokenType => TokenTypes.DAYPASSWORD.asString;
  final DayPasswordTokenViewMode viewMode;
  final Duration period;

  @override
  Duration get showDuration => const Duration(seconds: 30);

  DayPasswordToken({
    required Duration period,
    required super.id,
    required super.algorithm,
    required super.digits,
    required super.secret,
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
        super(type: TokenTypes.DAYPASSWORD.asString);

  @override
  bool sameValuesAs(Token other) {
    return super.sameValuesAs(other) && other is DayPasswordToken && other.period == period;
  }

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
    String? tokenImage,
    int? sortIndex,
    bool? pin,
    bool? isLocked,
    bool? isHidden,
    int? Function()? folderId,
    TokenOriginData? origin,
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
        tokenImage: tokenImage ?? this.tokenImage,
        sortIndex: sortIndex ?? this.sortIndex,
        pin: pin ?? this.pin,
        isLocked: isLocked ?? this.isLocked,
        isHidden: isHidden ?? this.isHidden,
        folderId: folderId != null ? folderId.call() : this.folderId,
        origin: origin ?? this.origin,
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

  factory DayPasswordToken.fromJson(Map<String, dynamic> json) => _$DayPasswordTokenFromJson(json).copyWith(isHidden: true);
  Map<String, dynamic> toJson() => _$DayPasswordTokenToJson(this);

  @override
  String toString() {
    return 'DayPassword${super.toString()}period: $period';
  }
}
