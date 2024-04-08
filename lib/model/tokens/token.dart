import 'package:flutter/material.dart';

import '../../utils/identifiers.dart';
import '../enums/token_types.dart';
import '../extensions/enum_extension.dart';
import '../mixins/sortable_mixin.dart';
import '../token_import/token_origin_data.dart';
import 'day_password_token.dart';
import 'hotp_token.dart';
import 'push_token.dart';
import 'steam_token.dart';
import 'totp_token.dart';

@immutable
abstract class Token with SortableMixin {
  bool? get isPrivacyIdeaToken => origin?.isPrivacyIdeaToken;
  final String tokenVersion = 'v1.0.0'; // The version of this token, this is used for serialization.
  final String label; // the name of the token, it cannot be uses as an identifier
  final String issuer; // The issuer of this token, currently unused.
  final String id; // this is the identifier of the token
  final bool pin;
  final bool isLocked;
  final bool isHidden;
  final String? tokenImage;
  final int? folderId;
  @override
  final int? sortIndex;

  final TokenOriginData? origin;

  // Must be string representation of TokenType enum.
  final String type; // Used to identify the token when deserializing.

  factory Token.fromJson(Map<String, dynamic> json) {
    String type = json['type'];
    if (TokenTypes.HOTP.isName(type, caseSensitive: false)) return HOTPToken.fromJson(json);
    if (TokenTypes.TOTP.isName(type, caseSensitive: false)) return TOTPToken.fromJson(json);
    if (TokenTypes.PIPUSH.isName(type, caseSensitive: false)) return PushToken.fromJson(json);
    if (TokenTypes.DAYPASSWORD.isName(type, caseSensitive: false)) return DayPasswordToken.fromJson(json);
    if (TokenTypes.STEAM.isName(type, caseSensitive: false)) return SteamToken.fromJson(json);
    throw ArgumentError.value(json, 'Token#fromJson', 'Token type [$type] is not a supported');
  }
  factory Token.fromUriMap(
    Map<String, dynamic> uriMap,
  ) {
    String type = uriMap[URI_TYPE];
    if (TokenTypes.HOTP.isName(type, caseSensitive: false)) return HOTPToken.fromUriMap(uriMap);
    if (TokenTypes.TOTP.isName(type, caseSensitive: false)) return TOTPToken.fromUriMap(uriMap);
    if (TokenTypes.PIPUSH.isName(type, caseSensitive: false)) return PushToken.fromUriMap(uriMap);
    if (TokenTypes.DAYPASSWORD.isName(type, caseSensitive: false)) return DayPasswordToken.fromUriMap(uriMap);
    if (TokenTypes.STEAM.isName(type, caseSensitive: false)) return SteamToken.fromUriMap(uriMap);
    throw ArgumentError.value(uriMap, 'Token#fromUriMap', 'Token type [$type] is not a supported');
  }

  const Token({
    this.label = '',
    this.issuer = '',
    required this.id,
    required this.type,
    this.tokenImage,
    this.sortIndex,
    this.folderId,
    this.origin,
    bool? pin,
    bool? isLocked,
    bool? isHidden,
  })  : // when pin is true isLocked is also true otherwise it's the value of isLocked if it is null it's false
        isLocked = pin != null && pin ? true : isLocked ?? false,
        isHidden = (pin != null && pin ? true : isLocked ?? false) == false ? false : isHidden ?? false,
        pin = pin ?? false;

  /// This is used to compare the changeable values of the token.
  bool sameValuesAs(Token other) =>
      other.label == label && other.issuer == issuer && other.pin == pin && other.isLocked == isLocked && other.tokenImage == tokenImage;

  /// This is used to identify the same token even if the id is different.
  bool isSameTokenAs(Token other) {
    return other.type == type; // && other.origin?.appName == origin?.appName && other.origin?.data == origin?.data;
  }

  @override
  Token copyWith({
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
  });

  @override
  bool operator ==(Object other) {
    return other is Token && other.id == id;
  }

  @override
  int get hashCode => (id + type).hashCode;

  @override
  String toString() {
    return 'Token{label: $label, '
        'issuer: $issuer, '
        'id: $id, '
        'pin: $pin, '
        'isLocked: $isLocked, '
        'isHidden: $isHidden, '
        'tokenImage: $tokenImage, '
        'type: $type, '
        'sortIndex: $sortIndex, '
        'folderId: $folderId, '
        'origin: $origin, ';
  }

  Map<String, dynamic> toJson();
}
