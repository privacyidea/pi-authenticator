import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../utils/errors.dart';
import '../../utils/identifiers.dart';
import '../enums/algorithms.dart';
import '../enums/encodings.dart';
import '../enums/token_types.dart';
import '../extensions/enums/encodings_extension.dart';
import '../extensions/int_extension.dart';
import '../token_import/token_origin_data.dart';
import 'token.dart';
import 'totp_token.dart';

part 'steam_token.g.dart';

@JsonSerializable()
class SteamToken extends TOTPToken {
  @override
  bool get isPrivacyIdeaToken => false;
  static String get tokenType => TokenTypes.STEAM.name;
  static const String steamAlphabet = "23456789BCDFGHJKMNPQRTVWXY";

  SteamToken({
    required super.id,
    required super.secret,
    super.serial,
    String? type,
    super.tokenImage,
    super.pin,
    super.isLocked,
    super.isHidden,
    super.sortIndex,
    super.folderId,
    super.origin,
    super.label = '',
    super.issuer = '',
  }) : super(
          type: type ?? tokenType,
          period: 30,
          digits: 5,
          algorithm: Algorithms.SHA1,
        );

  @override
  SteamToken copyWith({
    String? serial,
    String? label,
    String? issuer,
    String? id,
    bool? isLocked,
    bool? isHidden,
    bool? pin,
    String? tokenImage,
    int? sortIndex,
    int? Function()? folderId,
    TokenOriginData? origin,
    int? period, // unused steam tokens always have 30 seconds period
    int? digits, // unused steam tokens always have 5 digits
    Algorithms? algorithm, // unused steam tokens always have SHA1 algorithm
    String? secret,
  }) {
    return SteamToken(
      serial: serial ?? this.serial,
      label: label ?? this.label,
      issuer: issuer ?? this.issuer,
      id: id ?? this.id,
      secret: secret ?? this.secret,
      tokenImage: tokenImage ?? this.tokenImage,
      pin: pin ?? this.pin,
      isLocked: isLocked ?? this.isLocked,
      isHidden: isHidden ?? this.isHidden,
      sortIndex: sortIndex ?? this.sortIndex,
      folderId: folderId != null ? folderId() : this.folderId,
      origin: origin ?? this.origin,
    );
  }

  // @override
  /// No changeable value in SteamToken
  // bool sameValuesAs(Token other) => super.sameValuesAs(other);

  @override
  bool isSameTokenAs(Token other) => super.isSameTokenAs(other) && other is SteamToken;

  String otpOfTime(DateTime time) {
    // Flooring time/counter is TOTP default, but yes, steam uses the rounded time/counter.
    final counterBytes = (time.millisecondsSinceEpoch / 1000 / period).round().bytes;
    final secretList = base32.decode(secret.toUpperCase());
    final hmac = Hmac(sha1, secretList);
    final digest = hmac.convert(counterBytes).bytes;
    final offset = digest[digest.length - 1] & 0x0f;

    var code = ((digest[offset] & 0x7f) << 24) | ((digest[offset + 1] & 0xff) << 16) | ((digest[offset + 2] & 0xff) << 8) | (digest[offset + 3] & 0xff);

    final stringBuffer = StringBuffer();
    for (int i = 0; i < digits; i++) {
      stringBuffer.write(steamAlphabet[code % steamAlphabet.length]);
      code ~/= steamAlphabet.length;
    }
    return stringBuffer.toString();
  }

  @override
  String get otpValue => otpOfTime(DateTime.now());

  static SteamToken fromUriMap(Map<String, dynamic> uriMap) {
    if (uriMap[URI_SECRET] == null) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, name) => localizations.secretIsRequired,
        unlocalizedMessage: 'Secret is required',
        invalidValue: uriMap[URI_SECRET],
        name: 'SteamToken#fromUriMap',
      );
    }
    return SteamToken(
      label: (uriMap[URI_LABEL] as String?) ?? '',
      issuer: (uriMap[URI_ISSUER] as String?) ?? '',
      id: const Uuid().v4(),
      secret: Encodings.base32.encode(uriMap[URI_SECRET]),
      tokenImage: uriMap[URI_IMAGE] as String?,
      pin: uriMap[URI_PIN] as bool?,
      origin: uriMap[URI_ORIGIN] as TokenOriginData?,
    );
  }

  /// ----- TOTP TOKEN -----
  /// ```dart
  /// URI_TYPE: tokenType,
  /// URI_PERIOD: period,
  /// ```
  /// ------ OTP TOKEN ------
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
  Map<String, dynamic> toUriMap() => super.toUriMap();

  static SteamToken fromJson(Map<String, dynamic> json) => _$SteamTokenFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SteamTokenToJson(this);
}
