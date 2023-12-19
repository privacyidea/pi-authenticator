import '../enums/algorithms.dart';
import 'token.dart';

abstract class OTPToken extends Token {
  final Algorithms algorithm; // the hashing algorithm that is used to calculate the otp value
  final int digits; // the number of digits the otp value will have
  final String secret; // the secret based on which the otp value is calculated in base32
  String get otpValue; // the current otp value

  const OTPToken({
    required this.algorithm,
    required this.digits,
    required this.secret,
    required super.label,
    required super.issuer,
    required super.id,
    required super.type,
    super.pin,
    super.tokenImage,
    super.sortIndex,
    super.isLocked,
    super.isHidden,
    super.folderId,
  });

  @override
  OTPToken copyWith({
    String? label,
    String? issuer,
    String? id,
    Algorithms? algorithm,
    int? digits,
    String? secret,
    bool? pin,
    bool? isLocked,
    bool? isHidden,
    String? tokenImage,
    int? sortIndex,
    int? Function()? folderId,
  });

  @override
  String toString() {
    return 'OTP${super.toString()}algorithm: $algorithm, digits: $digits, pin: $pin, ';
  }
}
