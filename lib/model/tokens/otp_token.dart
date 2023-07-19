import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';

abstract class OTPToken extends Token {
  final Algorithms algorithm; // the hashing algorithm that is used to calculate the otp value
  final int digits; // the number of digits the otp value will have
  final String secret; // the secret based on which the otp value is calculated in base32
  final bool? pin; // backend can send pin = true, in that case the token should be locked by default
  String get otpValue; // the current otp value

  const OTPToken({
    required String label,
    required String issuer,
    required String id,
    required String type,
    required this.algorithm,
    required this.digits,
    required this.secret,
    required this.pin,
    String? imageURL,
    int? sortIndex,
    bool isLocked = false,
    bool canToggleLock = true,
  }) : super(
          label: label,
          issuer: issuer,
          id: id,
          type: type,
          imageURL: imageURL,
          sortIndex: sortIndex,
          isLocked: isLocked,
        );

  OTPToken copyWith({
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
  });

  @override
  String toString() {
    return 'OTP' + super.toString() + 'algorithm: $algorithm, digits: $digits, pin: $pin, ';
  }
}
