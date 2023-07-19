import 'package:json_annotation/json_annotation.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

import 'package:otp/otp.dart' as OTPLibrary;

part 'hotp_token.g.dart';

@JsonSerializable()
class HOTPToken extends OTPToken {
  final int counter; // this value is used to calculate the current otp value

  HOTPToken({
    this.counter = 0,
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
          type: type ?? enumAsString(TokenTypes.HOTP),
          algorithm: algorithm,
          digits: digits,
          secret: secret,
          pin: pin,
          imageURL: imageURL,
          sortIndex: sortIndex,
          isLocked: isLocked,
          canToggleLock: canToggleLock,
        );

  @override
  String get otpValue => OTPLibrary.OTP.generateHOTPCodeString(
        secret,
        counter,
        length: digits,
        algorithm: mapAlgorithms(algorithm),
        isGoogle: true,
      );

  HOTPToken withNextCounter() => this.copyWith(counter: this.counter + 1);

  HOTPToken copyWith({
    int? counter,
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
  }) =>
      HOTPToken(
        counter: counter ?? this.counter,
        label: label ?? this.label,
        issuer: issuer ?? this.issuer,
        id: id ?? this.id,
        algorithm: algorithm ?? this.algorithm,
        digits: digits ?? this.digits,
        secret: secret ?? this.secret,
        pin: pin ?? this.pin,
        imageURL: imageURL ?? this.imageURL,
        sortIndex: sortIndex ?? this.sortIndex,
        isLocked: isLocked ?? this.isLocked,
      );

  @override
  String toString() {
    return super.toString() + ' | Type HOTP | Counter $counter';
  }

  factory HOTPToken.fromJson(Map<String, dynamic> json) => _$HOTPTokenFromJson(json);

  Map<String, dynamic> toJson() => _$HOTPTokenToJson(this);
}
