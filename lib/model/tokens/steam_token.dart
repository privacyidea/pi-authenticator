import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart' show Hmac, sha1;
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../extensions/int_extension.dart';
import '../../utils/identifiers.dart';
import '../enums/algorithms.dart';
import '../enums/encodings.dart';
import '../enums/token_types.dart';
import '../extensions/enum_extension.dart';
import '../token_import/token_origin_data.dart';
import 'token.dart';
import 'totp_token.dart' show TOTPToken;

part 'steam_token.g.dart';

@JsonSerializable()
class SteamToken extends TOTPToken {
  static String get tokenType => TokenTypes.STEAM.asString;
  static const String steamAlphabet = "23456789BCDFGHJKMNPQRTVWXY";

  SteamToken({
    required super.period,
    required super.id,
    required super.algorithm,
    required super.digits,
    required super.secret,
    super.tokenImage,
    super.sortIndex,
    super.pin,
    super.isLocked,
    super.isHidden,
    super.folderId,
    super.origin,
    super.label = '',
    super.issuer = '',
  }) : super(type: tokenType);

  @override
  SteamToken copyWith({
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
    int? period,
    Algorithms? algorithm,
    int? digits,
    String? secret,
  }) {
    return SteamToken(
      period: period ?? this.period,
      label: label ?? this.label,
      issuer: issuer ?? this.issuer,
      id: id ?? this.id,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      secret: secret ?? this.secret,
      tokenImage: tokenImage ?? this.tokenImage,
      sortIndex: sortIndex ?? this.sortIndex,
      pin: pin ?? this.pin,
      isLocked: isLocked ?? this.isLocked,
      isHidden: isHidden ?? this.isHidden,
      folderId: folderId?.call() ?? this.folderId,
      origin: origin ?? this.origin,
    );
  }

  // @override
  /// No changeable value in SteamToken
  // bool sameValuesAs(Token other) => super.sameValuesAs(other);

  @override
  bool isSameTokenAs(Token other) => super.isSameTokenAs(other) && other is SteamToken;

  @override
  String get otpValue {
    final counterBytes = (DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ period).bytes;
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

  static SteamToken fromUriMap(Map<String, dynamic> uriMap) => SteamToken(
        period: uriMap[URI_PERIOD] as int? ?? 30,
        label: uriMap[URI_LABEL] as String,
        issuer: uriMap[URI_ISSUER] as String,
        id: const Uuid().v4(),
        algorithm: AlgorithmsExtension.fromString(uriMap[URI_ALGORITHM] ?? 'SHA1'),
        digits: uriMap[URI_DIGITS] as int,
        secret: Encodings.base32.encode(uriMap[URI_SECRET]),
        tokenImage: uriMap[URI_IMAGE] as String?,
        pin: uriMap[URI_PIN] as bool?,
        origin: uriMap[URI_ORIGIN],
      );
  static SteamToken fromJson(Map<String, dynamic> json) => _$SteamTokenFromJson(json);
}
