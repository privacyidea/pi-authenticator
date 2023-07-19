import 'package:json_annotation/json_annotation.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

import 'package:otp/otp.dart' as OTPLibrary;

part 'totp_token.g.dart';

@JsonSerializable()
class TOTPToken extends OTPToken {
  // this value is used to calculate the current 'counter' of this token
  // based on the UNIX systemtime), the counter is used to calculate the
  // current otp value

  final int period;
  @override
  String get otpValue => OTPLibrary.OTP.generateTOTPCodeString(
        secret,
        DateTime.now().millisecondsSinceEpoch,
        length: digits,
        algorithm: mapAlgorithms(algorithm),
        interval: period,
        isGoogle: true,
      );

  TOTPToken({
    required this.period,
    required String label,
    required String issuer,
    required String id,
    required Algorithms algorithm,
    required int digits,
    required String secret,
    String? type,
    bool? pin,
    String? imageURL,
    int? sortIndex,
    bool isLocked = false,
    bool canToggleLock = true,
  }) : super(
          label: label,
          issuer: issuer,
          id: id,
          type: type ?? enumAsString(TokenTypes.TOTP),
          algorithm: algorithm,
          digits: digits,
          secret: secret,
          pin: pin,
          imageURL: imageURL,
          sortIndex: sortIndex,
          isLocked: isLocked,
          canToggleLock: canToggleLock,
        );

  TOTPToken copyWith({
    String? label,
    String? issuer,
    String? id,
    Algorithms? algorithm,
    int? digits,
    String? secret,
    bool? pin,
    int? periodInSeconds,
    String? imageURL,
    int? sortIndex,
    bool? isLocked,
    bool? canToggleLock,
  }) {
    return TOTPToken(
      label: label ?? this.label,
      issuer: issuer ?? this.issuer,
      id: id ?? this.id,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      secret: secret ?? this.secret,
      pin: pin ?? this.pin,
      period: periodInSeconds ?? this.period,
      imageURL: imageURL ?? this.imageURL,
      sortIndex: sortIndex ?? this.sortIndex,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  String toString() {
    return 'T' + super.toString() + 'period: $period';
  }

  factory TOTPToken.fromJson(Map<String, dynamic> json) => _$TOTPTokenFromJson(json);

  double get currentProgress {
    int unixTime = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return (unixTime % (period)) * (1 / period);
  }

  Map<String, dynamic> toJson() => _$TOTPTokenToJson(this);
}
