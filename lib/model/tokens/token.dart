// ignore_for_file: constant_identifier_names

/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/container_credentials.dart';
import '../token_template.dart';

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
  static const CONTAINER_SERIAL = 'containerSerial';
  static const ID = 'id';
  static const ORIGIN = 'origin';
  static const HIDDEN = 'hidden';
  static const CHECKED_CONTAINERS = 'checkedContainers';
  static const FOLDER_ID = 'folderId';
  static const SORT_INDEX = SortableMixin.SORT_INDEX;

  bool? get isPrivacyIdeaToken => origin?.isPrivacyIdeaToken;
  final String tokenVersion = 'v1.0.0'; // The version of this token, this is used for serialization.
  final List<String> checkedContainers; // The serials of the containers this token should not be in.
  final String label; // the name of the token, it cannot be uses as an identifier
  final String issuer; // The issuer of this token, currently unused.
  final String? containerSerial; // The serial of the container this token belongs to.
  final String id; // this is the identifier of the token
  final String? serial; // The serial of the token, this is used to identify the token in the privacyIDEA server.
  final bool pin;
  final bool isLocked;
  final bool isHidden;
  final String? tokenImage;
  final int? folderId;
  @override
  final int? sortIndex;
  final TokenOriginData? origin;

  /// Must be string representation of TokenType enum.
  final String type; // Used to identify the token when deserializing.

  /// Creates a token from a json map.
  factory Token.fromJson(Map<String, dynamic> json) {
    String? type = json['type'];
    if (type == null) throw ArgumentError.value(json, 'Token#fromJson', 'Token type is not defined in the json');
    if (TokenTypes.HOTP.isName(type, caseSensitive: false)) return HOTPToken.fromJson(json);
    if (TokenTypes.TOTP.isName(type, caseSensitive: false)) return TOTPToken.fromJson(json);
    if (TokenTypes.PIPUSH.isName(type, caseSensitive: false)) return PushToken.fromJson(json);
    if (TokenTypes.DAYPASSWORD.isName(type, caseSensitive: false)) return DayPasswordToken.fromJson(json);
    if (TokenTypes.STEAM.isName(type, caseSensitive: false)) return SteamToken.fromJson(json);
    throw ArgumentError.value(json, 'Token#fromJson', 'Token type [$type] is not a supported');
  }

  /// Creates a token from a uri map.
  factory Token.fromOtpAuthMap(Map<String, dynamic> otpAuthMap, {required Map<String, dynamic> additionalData}) {
    String? type = otpAuthMap[OTP_AUTH_TYPE];
    if (type == null) throw ArgumentError.value(otpAuthMap, 'Token#fromUriMap', 'Token type is not defined in the uri map');
    if (TokenTypes.HOTP.isName(type, caseSensitive: false)) return HOTPToken.fromOtpAuthMap(otpAuthMap, additionalData: additionalData);
    if (TokenTypes.TOTP.isName(type, caseSensitive: false)) return TOTPToken.fromOtpAuthMap(otpAuthMap, additionalData: additionalData);
    if (TokenTypes.PIPUSH.isName(type, caseSensitive: false)) return PushToken.fromOtpAuthMap(otpAuthMap, additionalData: additionalData);
    if (TokenTypes.DAYPASSWORD.isName(type, caseSensitive: false)) {
      return DayPasswordToken.fromOtpAuthMap(otpAuthMap, additionalData: additionalData);
    }
    if (TokenTypes.STEAM.isName(type, caseSensitive: false)) return SteamToken.fromOtpAuthMap(otpAuthMap, additionalData: additionalData);
    throw ArgumentError.value(otpAuthMap, 'Token#fromUriMap', 'Token type [$type] is not a supported');
  }

  static Map<String, dynamic> validateAdditionalData(Map<String, dynamic> additionalData) => validateMap(
        map: additionalData,
        validators: {
          Token.CONTAINER_SERIAL: const TypeValidatorOptional<String>(),
          Token.ID: const TypeValidatorOptional<String>(),
          Token.ORIGIN: const TypeValidatorOptional<TokenOriginData>(),
          Token.HIDDEN: const TypeValidatorOptional<bool>(),
          Token.CHECKED_CONTAINERS: const TypeValidatorOptional<List<String>>(),
          Token.FOLDER_ID: const TypeValidatorOptional<int>(),
          Token.SORT_INDEX: const TypeValidatorOptional<int>(),
        },
        name: 'Token#validateAdditionalData',
      );

  const Token({
    this.serial,
    this.label = '',
    this.issuer = '',
    this.containerSerial,
    this.checkedContainers = const [],
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
    String? serial,
    String? label,
    String? issuer,
    String? Function()? containerSerial,
    List<String>? checkedContainers,
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
        'origin: $origin, '
        'containerSerial: $containerSerial, ';
  }

  /// This is used to create a map that can be used to serialize the token.
  Map<String, dynamic> toJson();

  /// This is used to create a map that typically was created from a uri.
  /// ```dart
  ///  ------------------------- [Token] -------------------------
  /// | OTP_AUTH_SERIAL: serial, (optional)                       |
  /// | OTP_AUTH_TYPE: type,                                      |
  /// | OTP_AUTH_LABEL: label,                                    |
  /// | OTP_AUTH_ISSUER: issuer,                                  |
  /// | OTP_AUTH_PIN: pin,                                        |
  /// | OTP_AUTH_IMAGE: tokenImage, (optional)                    |
  ///  -----------------------------------------------------------
  ///
  /// ```
  Map<String, dynamic> toOtpAuthMap() {
    return {
      if (serial != null) OTP_AUTH_SERIAL: serial!,
      OTP_AUTH_TYPE: type,
      OTP_AUTH_LABEL: label,
      OTP_AUTH_ISSUER: issuer,
      OTP_AUTH_PIN: pin ? OTP_AUTH_PIN_TRUE : OTP_AUTH_PIN_FALSE,
      if (tokenImage != null) OTP_AUTH_IMAGE: tokenImage!,
    };
  }

  Token copyUpdateByTemplate(TokenTemplate template);

  Map<String, dynamic> get additionalData => {
        ID: id,
        ORIGIN: origin?.data,
        SORT_INDEX: sortIndex,
        FOLDER_ID: folderId,
        HIDDEN: isHidden,
        CHECKED_CONTAINERS: checkedContainers,
      };

  TokenTemplate? toTemplate({ContainerCredential? container}) => serial != null
      ? TokenTemplate.withSerial(
          otpAuthMap: toOtpAuthMap(),
          additionalData: additionalData,
          serial: serial!,
          container: container,
        )
      : null;
}
