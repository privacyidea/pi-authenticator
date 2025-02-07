/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

import '../../../../../../../model/token_container.dart';
import '../../utils/object_validator.dart';
import '../enums/token_types.dart';
import '../extensions/enum_extension.dart';
import '../mixins/sortable_mixin.dart';
import '../token_import/token_origin_data.dart';
import '../token_template.dart';
import 'day_password_token.dart';
import 'hotp_token.dart';
import 'push_token.dart';
import 'steam_token.dart';
import 'totp_token.dart';

@immutable
abstract class Token with SortableMixin {
  /// [String] (optional) default = 'False'
  static const String PIN_VALUE_TRUE = 'True';
  static const String PIN_VALUE_FALSE = 'False';

  /// [String] (optional) default = ''
  static const String IMAGE = 'image';

  // Default data keys
  static const String TOKENTYPE_OTPAUTH = 'tokentype';
  static const String TOKENTYPE_JSON = 'type';

  /// [String] (optional) default = ''
  static const String LABEL = 'label';

  /// [String] (optional) default = ''
  static const String ISSUER = 'issuer';

  /// [String] 'True' / 'False' (optional) default = 'False'
  static const String PIN = 'pin';

  /// [String] 'True' / 'False' (optional) default = 'False'
  static const String OFFLINE = 'offline';

  /// [String] (optional) default = null
  static const String SERIAL = 'serial';

  // Additional data keys
  static const String CONTAINER_SERIAL = 'containerSerial';
  static const String ID = 'id';
  static const String ORIGIN = 'origin';
  static const String HIDDEN = 'hidden';
  static const String CHECKED_CONTAINERS = 'checkedContainer';
  static const String FOLDER_ID = 'folderId';
  static const String SORT_INDEX = SortableMixin.SORT_INDEX;
  static const String CREATOR = 'creator';

  // otp auth 2step
  /// [String] (required for 2step)
  static const String TWO_STEP_SALT_LENTH = '2step_salt';

  /// [String] (required for 2step)
  static const String TWO_STEP_OUTPUT_LENTH = '2step_output';

  /// [String] (required for 2step)
  static const String TWO_STEP_ITERATIONS = '2step_difficulty';

  bool? get isPrivacyIdeaToken => origin?.isPrivacyIdeaToken;
  final String tokenVersion = 'v1.0.0'; // The version of this token, this is used for serialization.
  final List<String> checkedContainer; // The serials of the container this token should not be in.
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
  final bool isOffline;
  @override
  final int? sortIndex;
  final TokenOriginData? origin;

  /// Must be string representation of TokenType enum.
  final String type; // Used to identify the token when deserializing.

  /// Creates a token from a json map.
  factory Token.fromJson(Map<String, dynamic> json) {
    String? type = json[TOKENTYPE_JSON];
    if (type == null) throw ArgumentError.value(json, 'Token#fromJson', 'Token type is not defined in the json');
    if (TokenTypes.HOTP.isName(type, caseSensitive: false)) return HOTPToken.fromJson(json);
    if (TokenTypes.TOTP.isName(type, caseSensitive: false)) return TOTPToken.fromJson(json);
    if (TokenTypes.PIPUSH.isName(type, caseSensitive: false) || TokenTypes.PUSH.isName(type, caseSensitive: false)) return PushToken.fromJson(json);
    if (TokenTypes.DAYPASSWORD.isName(type, caseSensitive: false)) return DayPasswordToken.fromJson(json);
    if (TokenTypes.STEAM.isName(type, caseSensitive: false)) return SteamToken.fromJson(json);
    throw ArgumentError.value(json, 'Token#fromJson', 'Token type [$type] is not supported');
  }

  /// Creates a token from a uri map.
  factory Token.fromOtpAuthMap(Map<String, dynamic> otpAuthMap, {Map<String, dynamic> additionalData = const {}}) {
    String? type = otpAuthMap[TOKENTYPE_OTPAUTH];
    if (type == null) throw ArgumentError.value(otpAuthMap, 'Token#fromUriMap', 'Token type is not defined in the uri map');
    if (TokenTypes.HOTP.isName(type, caseSensitive: false)) return HOTPToken.fromOtpAuthMap(otpAuthMap, additionalData: additionalData);
    if (TokenTypes.TOTP.isName(type, caseSensitive: false)) return TOTPToken.fromOtpAuthMap(otpAuthMap, additionalData: additionalData);
    if (TokenTypes.PIPUSH.isName(type, caseSensitive: false) || TokenTypes.PUSH.isName(type, caseSensitive: false)) {
      return PushToken.fromOtpAuthMap(otpAuthMap, additionalData: additionalData);
    }
    if (TokenTypes.DAYPASSWORD.isName(type, caseSensitive: false)) {
      return DayPasswordToken.fromOtpAuthMap(otpAuthMap, additionalData: additionalData);
    }
    if (TokenTypes.STEAM.isName(type, caseSensitive: false)) return SteamToken.fromOtpAuthMap(otpAuthMap, additionalData: additionalData);
    throw ArgumentError.value(otpAuthMap, 'Token#fromUriMap', 'Token type [$type] is not supported');
  }

  static Map<String, dynamic> validateAdditionalData(Map<String, dynamic> additionalData) => validateMap(
        map: additionalData,
        validators: {
          Token.CONTAINER_SERIAL: const ObjectValidatorNullable<String>(),
          Token.ID: const ObjectValidatorNullable<String>(),
          Token.ORIGIN: const ObjectValidatorNullable<TokenOriginData>(),
          Token.HIDDEN: const ObjectValidatorNullable<bool>(),
          Token.CHECKED_CONTAINERS: const ObjectValidatorNullable<List<String>>(),
          Token.FOLDER_ID: const ObjectValidatorNullable<int>(),
          Token.SORT_INDEX: const ObjectValidatorNullable<int>(),
        },
        name: 'Token#validateAdditionalData',
      );

  const Token({
    this.serial,
    this.label = '',
    this.issuer = '',
    this.containerSerial,
    this.checkedContainer = const [],
    required this.id,
    required this.type,
    this.tokenImage,
    this.sortIndex,
    this.folderId,
    this.origin,
    this.isOffline = false,
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
  /// The token should be considered the same if (the id is the same) or (the serial and issuer are the same).
  /// if the id is different and the serial is not null, it should be depend on other factors like the secret and the algorithm. So the token should be recognized when a the same token without a serial is imported multiple times.
  bool? isSameTokenAs(Token other) {
    if (id == other.id) return true;
    if (serial != null || other.serial != null) {
      return (serial == other.serial && issuer == other.issuer);
    }
    return null;
  }

  @override
  Token copyWith({
    String? serial,
    String? label,
    String? issuer,
    String? Function()? containerSerial,
    List<String>? checkedContainer,
    String? id,
    bool? isLocked,
    bool? isHidden,
    bool? pin,
    String? tokenImage,
    int? sortIndex,
    int? Function()? folderId,
    TokenOriginData? origin,
    bool? isOffline,
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
        'containerSerial: $containerSerial, '
        'isOffline: $isOffline';
  }

  /// This is used to create a map that can be used to serialize the token.
  Map<String, dynamic> toJson();

  /// This is used to create a map that typically was created from a uri.
  /// ```dart
  ///  ------------------------- [Token] -------------------------
  /// | SERIAL: serial, (optional)                                |
  /// | TYPE: type,                                               |
  /// | LABEL: label,                                             |
  /// | ISSUER: issuer,                                           |
  /// | PIN: pin,                                                 |
  /// | IMAGE: tokenImage, (optional)                             |
  ///  -----------------------------------------------------------
  ///
  /// ```
  Map<String, dynamic> toOtpAuthMap() {
    return {
      if (serial != null) SERIAL: serial!,
      TOKENTYPE_OTPAUTH: type,
      LABEL: label,
      ISSUER: issuer,
      PIN: pin ? PIN_VALUE_TRUE : PIN_VALUE_FALSE,
      OFFLINE: isOffline,
      if (tokenImage != null) IMAGE: tokenImage!,
    };
  }

  Token copyUpdateByTemplate(TokenTemplate template);

  Map<String, dynamic> get additionalData => {
        ID: id,
        ORIGIN: origin,
        SORT_INDEX: sortIndex,
        FOLDER_ID: folderId,
        HIDDEN: isHidden,
        CHECKED_CONTAINERS: checkedContainer,
        CONTAINER_SERIAL: containerSerial,
      };

  TokenTemplate? toTemplate({TokenContainer? container}) => serial != null
      ? TokenTemplate.withSerial(
          otpAuthMap: toOtpAuthMap(),
          additionalData: additionalData,
          serial: serial!,
          container: container,
        )
      : null;
}
