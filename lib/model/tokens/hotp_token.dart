import 'package:json_annotation/json_annotation.dart';
import 'package:otp/otp.dart' as otp_library;
import '../../utils/crypto_utils.dart';
import 'package:uuid/uuid.dart';

import '../../utils/identifiers.dart';
import '../../utils/utils.dart';
import 'otp_token.dart';

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
    String? tokenImage,
    int? sortIndex,
    bool isLocked = false,
    bool canToggleLock = true,
    int? folderId,
    bool isInEditMode = false,
  }) : super(
          label: label,
          issuer: issuer,
          id: id,
          type: type ?? enumAsString(TokenTypes.HOTP),
          algorithm: algorithm,
          digits: digits,
          secret: secret,
          pin: pin,
          tokenImage: tokenImage,
          sortIndex: sortIndex,
          isLocked: isLocked,
          canToggleLock: canToggleLock,
          folderId: folderId,
          isInEditMode: isInEditMode,
        );

  @override
  String get otpValue => otp_library.OTP.generateHOTPCodeString(
        secret,
        counter,
        length: digits,
        algorithm: mapAlgorithms(algorithm),
        isGoogle: true,
      );

  HOTPToken withNextCounter() => copyWith(counter: counter + 1);

  @override
  HOTPToken copyWith({
    int? counter,
    String? label,
    String? issuer,
    String? id,
    Algorithms? algorithm,
    int? digits,
    String? secret,
    bool? pin,
    String? tokenImage,
    int? sortIndex,
    bool? isLocked,
    int? Function()? folderId,
    bool? isInEditMode,
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
        tokenImage: tokenImage ?? this.tokenImage,
        sortIndex: sortIndex ?? this.sortIndex,
        isLocked: isLocked ?? this.isLocked,
        folderId: folderId != null ? folderId() : this.folderId,
        isInEditMode: isInEditMode ?? this.isInEditMode,
      );

  @override
  String toString() {
    return 'H${super.toString()}counter: $counter}';
  }

  factory HOTPToken.fromUriMap(Map<String, dynamic> uriMap) => HOTPToken(
        label: uriMap[URI_LABEL],
        issuer: uriMap[URI_ISSUER],
        id: const Uuid().v4(),
        algorithm: mapStringToAlgorithm(uriMap[URI_ALGORITHM] ?? 'SHA1'),
        digits: uriMap[URI_DIGITS],
        secret: encodeSecretAs(uriMap[URI_SECRET], Encodings.base32),
        counter: uriMap[URI_COUNTER],
        type: uriMap[URI_TYPE],
        tokenImage: uriMap[URI_IMAGE],
      );

  factory HOTPToken.fromJson(Map<String, dynamic> json) => _$HOTPTokenFromJson(json);

  Map<String, dynamic> toJson() => _$HOTPTokenToJson(this);
}
