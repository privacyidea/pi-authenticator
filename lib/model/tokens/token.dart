import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';

import '../../utils/identifiers.dart';
import '../../utils/utils.dart';
import '../mixins/sortable_mixin.dart';
import 'hotp_token.dart';
import 'push_token.dart';
import 'totp_token.dart';

@immutable
abstract class Token with SortableMixin {
  final String tokenVersion = 'v1.0.0'; // The version of this token, this is used for serialization.
  final String label; // the name of the token, it cannot be uses as an identifier
  final String issuer; // The issuer of this token, currently unused.
  final String id; // this is the identifier of the token
  final bool isLocked;
  final bool? pin;
  final String? imageURL;
  final int? categoryId;
  final bool isInEditMode;
  @override
  final int? sortIndex;

  // Must be string representation of TokenType enum.
  final String type; // Used to identify the token when deserializing.

  factory Token.fromJson(Map<String, dynamic> json) {
    String type = json['type'];
    if (type == enumAsString(TokenTypes.HOTP)) return HOTPToken.fromJson(json);
    if (type == enumAsString(TokenTypes.TOTP)) return TOTPToken.fromJson(json);
    if (type == enumAsString(TokenTypes.PIPUSH)) return PushToken.fromJson(json);
    if (type == enumAsString(TokenTypes.DAYPASSWORD)) return DayPasswordToken.fromJson(json);
    throw Exception('Unknown token type: $type');
  }

  const Token({
    required this.label,
    required this.issuer,
    required this.id,
    required this.type,
    this.pin,
    this.imageURL,
    this.sortIndex,
    this.isLocked = false,
    this.categoryId,
    this.isInEditMode = false,
  });

  @override
  Token copyWith({
    String? label,
    String? issuer,
    String? id,
    bool? isLocked,
    bool? pin,
    String? imageURL,
    int? sortIndex,
    int? Function()? categoryId,
    bool? isInEditMode,
  });

  @override
  String toString() {
    return 'Token{label: $label, issuer: $issuer, id: $id, _sLocked: $isLocked, pin: $pin, imageURL: $imageURL, sortIndex: $sortIndex, type: $type, categoryId: $categoryId, isInEditMode: $isInEditMode';
  }
}
