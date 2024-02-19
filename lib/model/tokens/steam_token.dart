import 'package:json_annotation/json_annotation.dart';
import 'package:privacyidea_authenticator/extensions/int_extension.dart';
import 'package:privacyidea_authenticator/model/extensions/enum_extension.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:otp/otp.dart' as otp_library;

import '../enums/algorithms.dart';
import '../enums/token_types.dart';
import '../token_origin.dart';

part 'steam_token.g.dart';

@JsonSerializable()
class SteamToken extends TOTPToken {
  static String get tokenType => TokenTypes.STEAM.asString;
  static const String steamAlphabet = "23456789BCDFGHJKMNPQRTVWXY";

  SteamToken({
    required super.period,
    required super.label,
    required super.issuer,
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

  @override
  String get otpValue {
    var code = otp_library.OTP.generateTOTPCode(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      algorithm: otp_library.Algorithm.SHA1,
      interval: 30,
    );
    final stringBuffer = StringBuffer();
    for (int i = 0; i < digits; i++) {
      stringBuffer.write(steamAlphabet[code % steamAlphabet.length]);
      code ~/= steamAlphabet.length;
    }
    return stringBuffer.toString();
  }

  static SteamToken fromUriMap(Map<String, dynamic> uriMap) => SteamToken(
        period: uriMap['period'] as int,
        label: uriMap['label'] as String,
        issuer: uriMap['issuer'] as String,
        id: uriMap['id'] as String,
        algorithm: uriMap['algorithm'] as Algorithms,
        digits: uriMap['digits'] as int,
        secret: uriMap['secret'] as String,
        tokenImage: uriMap['tokenImage'] as String?,
        sortIndex: uriMap['sortIndex'] as int?,
        pin: uriMap['pin'] as bool?,
        isLocked: uriMap['isLocked'] as bool?,
        isHidden: uriMap['isHidden'] as bool?,
        folderId: uriMap['folderId'] as int?,
        origin: uriMap['origin'] == null ? null : TokenOriginData.fromJson(uriMap['origin'] as Map<String, dynamic>),
      );
  static SteamToken fromJson(Map<String, dynamic> json) => _$SteamTokenFromJson(json);
}
