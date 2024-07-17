import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';

import '../../utils/logger.dart';
import '../enums/algorithms.dart';
import '../enums/encodings.dart';
import '../token_import/token_origin_data.dart';
import 'token.dart';

abstract class OTPToken extends Token {
  final Algorithms algorithm; // the hashing algorithm that is used to calculate the otp value
  final int digits; // the number of digits the otp value will have
  final String secret; // the secret based on which the otp value is calculated in base32
  String get otpValue; // the current otp value
  Duration get showDuration {
    const Duration duration = Duration(seconds: 30);
    Logger.info('$runtimeType showDuration: ${duration.inSeconds} seconds');
    return duration;
  } // the duration the otp value is shown

  const OTPToken({
    required this.algorithm,
    required this.digits,
    required this.secret,
    required super.id,
    required super.type,
    super.pin,
    super.tokenImage,
    super.isLocked,
    super.isHidden,
    super.sortIndex,
    super.folderId,
    super.origin,
    super.label = '',
    super.issuer = '',
  });

  // @override
  // No changeable value in OTPToken
  // bool sameValuesAs(Token other) => super.sameValuesAs(other);

  @override
  bool isSameTokenAs(Token other) {
    return super.isSameTokenAs(other) && other is OTPToken && other.algorithm == algorithm && other.digits == digits && other.secret == secret;
  }

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
    TokenOriginData? origin,
  });

  @override
  String toString() {
    return 'OTP${super.toString()}algorithm: $algorithm, digits: $digits, pin: $pin, ';
  }

  /// ```dart
  /// URI_SECRET: Encodings.base32.decode(secret),
  /// URI_ALGORITHM: algorithm.name,
  /// URI_DIGITS: digits,
  /// ```
  /// ------- TOKEN ---------
  /// ```dart
  /// URI_LABEL: label,
  /// URI_ISSUER: issuer,
  /// URI_PIN: pin,
  /// URI_IMAGE: tokenImage,
  /// URI_ORIGIN: jsonEncode(origin!.toJson()),
  /// ```
  @override
  Map<String, dynamic> toUriMap() {
    return super.toUriMap()
      ..addAll({
        URI_SECRET: Encodings.base32.decode(secret),
        URI_ALGORITHM: algorithm.name,
        URI_DIGITS: digits,
      });
  }
}
