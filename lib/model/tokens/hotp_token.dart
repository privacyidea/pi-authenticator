import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../utils/identifiers.dart';
import '../enums/algorithms.dart';
import '../enums/encodings.dart';
import '../enums/token_types.dart';
import '../extensions/enums/algorithms_extension.dart';
import '../extensions/enums/encodings_extension.dart';
import '../token_import/token_origin_data.dart';
import 'otp_token.dart';
import 'token.dart';

part 'hotp_token.g.dart';

@JsonSerializable()
class HOTPToken extends OTPToken {
  static String get tokenType => TokenTypes.HOTP.name;
  final int counter; // this value is used to calculate the current otp value

  @override
  Duration get showDuration => const Duration(seconds: 30);

  HOTPToken({
    this.counter = 0,
    required super.id,
    required super.algorithm,
    required super.digits,
    required super.secret,
    String? type, // just for @JsonSerializable(): type of HOTPToken is always TokenTypes.HOTP
    super.tokenImage,
    super.pin,
    super.isLocked,
    super.isHidden,
    super.sortIndex,
    super.folderId,
    super.origin,
    super.label = '',
    super.issuer = '',
  }) : super(type: TokenTypes.HOTP.name);

  @override
  bool sameValuesAs(Token other) => super.sameValuesAs(other) && other is HOTPToken && other.counter == counter;

  @override
  // Counter can be changed even if its the same token
  bool isSameTokenAs(Token other) => super.isSameTokenAs(other) && other is HOTPToken;

  @override
  String get otpValue => algorithm.generateHOTPCodeString(
        secret: secret,
        counter: counter,
        length: digits,
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
    String? tokenImage,
    bool? pin,
    bool? isLocked,
    bool? isHidden,
    int? sortIndex,
    int? Function()? folderId,
    TokenOriginData? origin,
  }) =>
      HOTPToken(
        counter: counter ?? this.counter,
        label: label ?? this.label,
        issuer: issuer ?? this.issuer,
        id: id ?? this.id,
        algorithm: algorithm ?? this.algorithm,
        digits: digits ?? this.digits,
        secret: secret ?? this.secret,
        tokenImage: tokenImage ?? this.tokenImage,
        pin: pin ?? this.pin,
        isLocked: isLocked ?? this.isLocked,
        isHidden: isHidden ?? this.isHidden,
        sortIndex: sortIndex ?? this.sortIndex,
        folderId: folderId != null ? folderId() : this.folderId,
        origin: origin ?? this.origin,
      );

  @override
  String toString() {
    return 'H${super.toString()}counter: $counter}';
  }

  factory HOTPToken.fromUriMap(Map<String, dynamic> uriMap) {
    if (uriMap[URI_SECRET] == null) throw ArgumentError('Secret is required');
    if (uriMap[URI_DIGITS] != null && uriMap[URI_DIGITS] < 1) throw ArgumentError('Digits must be greater than 0');
    return HOTPToken(
      label: uriMap[URI_LABEL] ?? '',
      issuer: uriMap[URI_ISSUER] ?? '',
      id: const Uuid().v4(),
      algorithm: Algorithms.values.byName(uriMap[URI_ALGORITHM] ?? 'SHA1'),
      digits: uriMap[URI_DIGITS] ?? 6,
      secret: Encodings.base32.encode(uriMap[URI_SECRET]),
      counter: uriMap[URI_COUNTER] ?? 0,
      tokenImage: uriMap[URI_IMAGE],
      pin: uriMap[URI_PIN],
      isLocked: uriMap[URI_PIN],
      origin: uriMap[URI_ORIGIN],
    );
  }

  @override
  Map<String, dynamic> toJson() => _$HOTPTokenToJson(this);
  factory HOTPToken.fromJson(Map<String, dynamic> json) => _$HOTPTokenFromJson(json);
}
