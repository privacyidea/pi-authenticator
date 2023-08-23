import 'package:json_annotation/json_annotation.dart';
// ignore: library_prefixes
import 'package:otp/otp.dart' as OTPLibrary;
import 'package:uuid/uuid.dart';

import '../../utils/identifiers.dart';
import '../../utils/utils.dart';
import 'otp_token.dart';

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
    required int period,
    required String label,
    required String issuer,
    required String id,
    required Algorithms algorithm,
    required int digits,
    required String secret,
    String? type,
    bool? pin,
    String? tokenImage,
    int? sortIndex,
    bool isLocked = false,
    bool canToggleLock = true,
    int? folderId,
    bool isInEditMode = false,
  })  : period = period < 1 ? 30 : period, // period must be greater than 0 otherwise IntegerDivisionByZeroException is thrown in OTP.generateTOTPCodeString
        super(
          label: label,
          issuer: issuer,
          id: id,
          algorithm: algorithm,
          digits: digits,
          secret: secret,
          type: type ?? enumAsString(TokenTypes.TOTP),
          pin: pin,
          tokenImage: tokenImage,
          sortIndex: sortIndex,
          isLocked: isLocked,
          canToggleLock: canToggleLock,
          folderId: folderId,
          isInEditMode: isInEditMode,
        );

  @override
  TOTPToken copyWith({
    String? label,
    String? issuer,
    String? id,
    Algorithms? algorithm,
    int? digits,
    String? secret,
    bool? pin,
    int? period,
    String? tokenImage,
    int? sortIndex,
    bool? isLocked,
    int? Function()? folderId,
    bool? isInEditMode,
  }) {
    return TOTPToken(
      label: label ?? this.label,
      issuer: issuer ?? this.issuer,
      id: id ?? this.id,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      secret: secret ?? this.secret,
      pin: pin ?? this.pin,
      period: period ?? this.period,
      tokenImage: tokenImage ?? this.tokenImage,
      sortIndex: sortIndex ?? this.sortIndex,
      isLocked: isLocked ?? this.isLocked,
      folderId: folderId != null ? folderId() : this.folderId,
      isInEditMode: isInEditMode ?? this.isInEditMode,
    );
  }

  @override
  String toString() {
    return 'T${super.toString()}period: $period';
  }

  factory TOTPToken.fromUriMap(Map<String, dynamic> uriMap) {
    if (uriMap[URI_SECRET] == null) throw ArgumentError('Secret is required');
    if (uriMap[URI_PERIOD] < 1) throw ArgumentError('Period must be greater than 0');
    return TOTPToken(
      label: uriMap[URI_LABEL] ?? '',
      issuer: uriMap[URI_ISSUER] ?? '',
      id: const Uuid().v4(),
      algorithm: mapStringToAlgorithm(uriMap[URI_ALGORITHM] ?? 'SHA1'),
      digits: uriMap[URI_DIGITS] ?? 6,
      tokenImage: uriMap[URI_IMAGE],
      secret: encodeSecretAs(uriMap[URI_SECRET], Encodings.base32),
      period: uriMap[URI_PERIOD] ?? 30,
      pin: uriMap[URI_PIN],
    );
  }

  factory TOTPToken.fromJson(Map<String, dynamic> json) => _$TOTPTokenFromJson(json);

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
