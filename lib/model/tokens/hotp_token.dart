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
    required super.label,
    required super.issuer,
    required super.id,
    required super.algorithm,
    required super.digits,
    required super.secret,
    String? type, // just for @JsonSerializable(): type of HOTPToken is always TokenTypes.HOTP
    super.pin,
    super.tokenImage,
    super.sortIndex,
    super.isLocked,
    super.folderId,
  }) : super(type: enumAsString(TokenTypes.HOTP));

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
      );

  @override
  String toString() {
    return 'H${super.toString()}counter: $counter}';
  }

  factory HOTPToken.fromUriMap(Map<String, dynamic> uriMap) {
    if (uriMap[URI_SECRET] == null) throw ArgumentError('Secret is required');
    if (uriMap[URI_DIGITS] < 1) throw ArgumentError('Digits must be greater than 0');
    HOTPToken hotpToken;
    try {
      hotpToken = HOTPToken(
        label: uriMap[URI_LABEL] ?? '',
        issuer: uriMap[URI_ISSUER] ?? '',
        id: const Uuid().v4(),
        algorithm: mapStringToAlgorithm(uriMap[URI_ALGORITHM] ?? 'SHA1'),
        digits: uriMap[URI_DIGITS] ?? 6,
        secret: encodeSecretAs(uriMap[URI_SECRET], Encodings.base32),
        counter: uriMap[URI_COUNTER],
        tokenImage: uriMap[URI_IMAGE],
        pin: uriMap[URI_PIN],
        isLocked: uriMap[URI_PIN],
      );
    } catch (e) {
      throw ArgumentError('Invalid URI: $e');
    }
    return hotpToken;
  }

  factory HOTPToken.fromJson(Map<String, dynamic> json) => _$HOTPTokenFromJson(json);

  Map<String, dynamic> toJson() => _$HOTPTokenToJson(this);
}
