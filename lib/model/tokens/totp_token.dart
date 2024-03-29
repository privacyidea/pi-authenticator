import 'package:json_annotation/json_annotation.dart';
import 'package:otp/otp.dart' as otp_library;
import 'package:uuid/uuid.dart';

import '../../utils/crypto_utils.dart';
import '../../utils/identifiers.dart';
import '../../utils/logger.dart';
import '../../utils/utils.dart';
import '../enums/algorithms.dart';
import '../enums/encodings.dart';
import '../enums/token_types.dart';
import '../extensions/enum_extension.dart';
import '../token_origin.dart';
import 'otp_token.dart';
import 'token.dart';

part 'totp_token.g.dart';

@JsonSerializable()
class TOTPToken extends OTPToken {
  static String get tokenType => TokenTypes.TOTP.asString;
  // this value is used to calculate the current 'counter' of this token
  // based on the UNIX systemtime), the counter is used to calculate the
  // current otp value

  @override
  Duration get showDuration {
    final Duration duration = Duration(milliseconds: (period * 1000 + (secondsUntilNextOTP * 1000).toInt()));
    Logger.warning('TOTPToken.showDuration: $duration');
    return duration;
  }

  final int period;
  @override
  String get otpValue => otp_library.OTP.generateTOTPCodeString(
        secret,
        DateTime.now().millisecondsSinceEpoch,
        length: digits,
        algorithm: algorithm.otpLibraryAlgorithm,
        interval: period,
        isGoogle: true,
      );

  TOTPToken({
    required int period,
    required super.label,
    required super.issuer,
    required super.id,
    required super.algorithm,
    required super.digits,
    required super.secret,
    String? type, // just for @JsonSerializable(): type of TOTPToken is always TokenTypes.TOTP
    super.tokenImage,
    super.sortIndex,
    super.pin,
    super.isLocked,
    super.isHidden,
    super.folderId,
    super.origin,
  })  : period = period < 1 ? 30 : period, // period must be greater than 0 otherwise IntegerDivisionByZeroException is thrown in OTP.generateTOTPCodeString
        super(type: TokenTypes.TOTP.asString);

  @override
  bool sameValuesAs(Token other) {
    return super.sameValuesAs(other) && other is TOTPToken && other.period == period;
  }

  @override
  TOTPToken copyWith({
    String? label,
    String? issuer,
    String? id,
    Algorithms? algorithm,
    int? digits,
    String? secret,
    int? period,
    String? tokenImage,
    int? sortIndex,
    bool? pin,
    bool? isLocked,
    bool? isHidden,
    int? Function()? folderId,
    TokenOriginData? origin,
  }) {
    return TOTPToken(
      label: label ?? this.label,
      issuer: issuer ?? this.issuer,
      id: id ?? this.id,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      secret: secret ?? this.secret,
      period: period ?? this.period,
      tokenImage: tokenImage ?? this.tokenImage,
      sortIndex: sortIndex ?? this.sortIndex,
      pin: pin ?? this.pin,
      isLocked: isLocked ?? this.isLocked,
      isHidden: isHidden ?? this.isHidden,
      folderId: folderId != null ? folderId() : this.folderId,
      origin: origin ?? this.origin,
    );
  }

  @override
  String toString() {
    return 'T${super.toString()}period: $period';
  }

  factory TOTPToken.fromUriMap(Map<String, dynamic> uriMap) {
    if (uriMap[URI_SECRET] == null) throw ArgumentError('Secret is required');
    if (uriMap[URI_DIGITS] != null && uriMap[URI_DIGITS] < 1) throw ArgumentError('Digits must be greater than 0');
    if (uriMap[URI_PERIOD] != null && uriMap[URI_PERIOD] < 1) throw ArgumentError('Period must be greater than 0');
    TOTPToken totpToken;
    try {
      totpToken = TOTPToken(
        label: uriMap[URI_LABEL] ?? '',
        issuer: uriMap[URI_ISSUER] ?? '',
        id: const Uuid().v4(),
        algorithm: mapStringToAlgorithm(uriMap[URI_ALGORITHM] ?? 'SHA1'),
        digits: uriMap[URI_DIGITS] ?? 6,
        tokenImage: uriMap[URI_IMAGE],
        secret: encodeSecretAs(uriMap[URI_SECRET], Encodings.base32),
        period: uriMap[URI_PERIOD] ?? 30,
        pin: uriMap[URI_PIN],
        isLocked: uriMap[URI_PIN],
      );
    } catch (e) {
      throw ArgumentError('Invalid URI: $e');
    }
    return totpToken;
  }

  factory TOTPToken.fromJson(Map<String, dynamic> json) => _$TOTPTokenFromJson(json).copyWith(isHidden: true);

  double get currentProgress {
    final secondsSinceEpoch = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return (secondsSinceEpoch % (period)) * (1 / period);
  }

  double get secondsUntilNextOTP {
    final secondsSinceEpoch = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000);
    return period - (secondsSinceEpoch % (period));
  }

  Map<String, dynamic> toJson() => _$TOTPTokenToJson(this);
}
