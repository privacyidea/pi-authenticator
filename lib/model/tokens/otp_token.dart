import '../../utils/identifiers.dart';
import 'token.dart';

abstract class OTPToken extends Token {
  final Algorithms algorithm; // the hashing algorithm that is used to calculate the otp value
  final int digits; // the number of digits the otp value will have
  final String secret; // the secret based on which the otp value is calculated in base32
  String get otpValue; // the current otp value

  const OTPToken({
    required String label,
    required String issuer,
    required String id,
    required String type,
    required this.algorithm,
    required this.digits,
    required this.secret,
    required super.pin,
    String? imageURL,
    int? sortIndex,
    bool isLocked = false,
    bool canToggleLock = true,
    int? categoryId,
    bool isInEditMode = false,
  }) : super(
          label: label,
          issuer: issuer,
          id: id,
          type: type,
          imageURL: imageURL,
          sortIndex: sortIndex,
          isLocked: isLocked,
          categoryId: categoryId,
          isInEditMode: isInEditMode,
        );

  @override
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
    int? Function()? categoryId,
    bool? isInEditMode,
  });

  @override
  String toString() {
    return 'OTP${super}algorithm: $algorithm, digits: $digits, pin: $pin, ';
  }
}
