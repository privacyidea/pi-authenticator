import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../utils/identifiers.dart';
import '../../utils/logger.dart';
import '../enums/algorithms.dart';
import '../enums/encodings.dart';
import '../enums/token_types.dart';
import '../extensions/enum_extension.dart';
import '../token_import/token_origin_data.dart';
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
    Logger.info('$runtimeType showDuration: ${duration.inSeconds} seconds');
    return duration;
  }

  final int period;

  @override
  String get otpValue => algorithm.generateTOTPCodeString(
        secret: secret,
        time: DateTime.now(),
        length: digits,
        interval: Duration(seconds: period),
        isGoogle: true,
      );

  TOTPToken({
    required int period,
    required super.id,
    required super.algorithm,
    required super.digits,
    required super.secret,
    String? type,
    super.tokenImage,
    super.sortIndex,
    super.pin,
    super.isLocked,
    super.isHidden,
    super.folderId,
    super.origin,
    super.label = '',
    super.issuer = '',
  })  : period = period < 1 ? 30 : period, // period must be greater than 0 otherwise IntegerDivisionByZeroException is thrown in OTP.generateTOTPCodeString
        super(type: type ?? tokenType);

  // @override
  // No changeable value in TOTPToken
  // bool sameValuesAs(Token other) => super.sameValuesAs(other);

  @override
  bool isSameTokenAs(Token other) => super.isSameTokenAs(other) && other is TOTPToken && other.period == period;

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
    return TOTPToken(
      label: uriMap[URI_LABEL] ?? '',
      issuer: uriMap[URI_ISSUER] ?? '',
      id: const Uuid().v4(),
      algorithm: AlgorithmsX.fromString((uriMap[URI_ALGORITHM] ?? 'SHA1')),
      digits: uriMap[URI_DIGITS] ?? 6,
      tokenImage: uriMap[URI_IMAGE],
      secret: Encodings.base32.encode(uriMap[URI_SECRET]),
      period: uriMap[URI_PERIOD] ?? 30,
      pin: uriMap[URI_PIN],
      isLocked: uriMap[URI_PIN],
      origin: uriMap[URI_ORIGIN],
    );
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
