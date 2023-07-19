import 'package:privacyidea_authenticator/model/tokens/otp_tokens/hotp_token/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_tokens/totp_token/totp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token/push_token.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

abstract class Token {
  final String tokenVersion = 'v1.0.0'; // The version of this token, this is used for serialization.
  final String label; // the name of the token, it cannot be uses as an identifier
  final String issuer; // The issuer of this token, currently unused.
  final String id; // this is the identifier of the token

  final bool isLocked;
  final bool? pin;
  final String? imageURL;

  final int? sortIndex;

  // Must be string representation of TokenType enum.
  final String type; // Used to identify the token when deserializing.

  factory Token.fromJson(Map<String, dynamic> json) {
    String type = json['type'];
    if (type == enumAsString(TokenTypes.HOTP)) return HOTPToken.fromJson(json);
    if (type == enumAsString(TokenTypes.TOTP)) return TOTPToken.fromJson(json);
    if (type == enumAsString(TokenTypes.PIPUSH)) return PushToken.fromJson(json);
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
  });

  Token copyWith({
    String? label,
    String? issuer,
    String? id,
    bool? isLocked,
    bool? pin,
    String? imageURL,
    int? sortIndex,
  });

  @override
  String toString() {
    return 'Token{_label: $label, _issuer: $issuer, _id: $id,'
        ' _isLocked: $isLocked';
  }
}
