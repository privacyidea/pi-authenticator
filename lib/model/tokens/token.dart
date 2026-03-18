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
import '../../utils/object_validator/object_validators.dart';
import '../enums/token_types.dart';
import '../extensions/enum_extension.dart';
import '../extensions/enums/force_biometric_option_extension.dart';
import '../mixins/sortable_mixin.dart';
import '../token_import/token_origin_data.dart';
import '../token_template.dart';
import 'day_password_token.dart';
import 'hotp_token.dart';
import 'push_token.dart';
import 'steam_token.dart';
import 'totp_token.dart';

enum ForceBiometricOption { none, any, biometric, pin }

@immutable
abstract class Token with SortableMixin {
  // --- Constants: Default Values ---
  static const String PIN_VALUE_TRUE = 'True';
  static const String PIN_VALUE_FALSE = 'False';

  // --- Constants: Default Data Keys (OTPAuth / JSON) ---
  static const String TOKENTYPE_OTPAUTH = 'tokentype';
  static const String TOKENTYPE_JSON = 'type';
  static const String LABEL = 'label';
  static const String ISSUER = 'issuer';
  static const String PIN = 'pin';
  static const String IMAGE = 'image';
  static const String FORCE_BIOMETRIC_OPTION = 'app_force_unlock';
  static const String OFFLINE = 'offline';
  static const String SERIAL = 'serial';

  // --- Constants: Additional Data Keys ---
  static const String CONTAINER_SERIAL = 'containerSerial';
  static const String ID = 'id';
  static const String ORIGIN = 'origin';
  static const String IS_HIDDEN = 'isHidden';
  static const String CHECKED_CONTAINERS = 'checkedContainer';
  static const String FOLDER_ID = 'folderId';
  static const String SORT_INDEX = SortableMixin.SORT_INDEX;
  static const String CREATOR = 'creator';

  // --- Constants: OTP Auth 2Step ---
  static const String TWO_STEP_SALT_LENTH = '2step_salt';
  static const String TWO_STEP_OUTPUT_LENTH = '2step_output';
  static const String TWO_STEP_ITERATIONS = '2step_difficulty';

  // --- Static Validators ---
  static final Map<String, BaseValidator> otpAuthValidators = {
    LABEL: stringValidator.withDefault(''),
    ISSUER: stringValidator.withDefault(''),
    SERIAL: stringValidatorOptional,
    IMAGE: stringValidatorOptional,
    PIN: boolValidatorOptional,
    OFFLINE: boolValidator.withDefault(false),
    FORCE_BIOMETRIC_OPTION: ForceBiometricOptionX.validator,
  };

  static final Map<String, BaseValidator> additionalDataValidators = {
    CONTAINER_SERIAL: stringValidatorOptional,
    ID: stringValidatorOptional,
    ORIGIN: const OptionalObjectValidator<TokenOriginData>(),
    IS_HIDDEN: boolValidatorOptional,
    CHECKED_CONTAINERS: const OptionalObjectValidator<List<String>>(
      defaultValue: [],
    ),
    FOLDER_ID: intValidatorOptional,
    SORT_INDEX: intValidatorOptional,
  };

  // --- Static Validation Methods ---
  static Map<String, Object?> validateOtpAuthMap(
    Map<String, dynamic> otpAuthMap,
  ) {
    return validateMap(
      map: otpAuthMap,
      validators: otpAuthValidators,
      name: 'Token#otpAuthMap',
    );
  }

  static Map<String, Object?> validateAdditionalData(
    Map<String, dynamic> additionalData,
  ) {
    return validateMap(
      map: additionalData,
      validators: additionalDataValidators,
      name: 'Token#additionalData',
    );
  }

  // --- Instance Properties ---
  final String tokenVersion = 'v1.0.0';
  final String id;
  final String type;
  final String label;
  final String issuer;
  final String? serial;
  final String? containerSerial;
  final List<String> checkedContainer;
  final bool pin;
  final ForceBiometricOption forceBiometricOption;
  final String? tokenImage;
  final int? folderId;
  final bool isOffline;
  final TokenOriginData? origin;

  @override
  final int? sortIndex;

  final bool? _isLocked;
  bool get isLocked {
    if (pin == true || forceBiometricOption != ForceBiometricOption.none) {
      return true;
    }
    return _isLocked ?? false;
  }

  final bool? _isHidden;
  bool get isHidden => _isHidden ?? isLocked;

  bool? get isPrivacyIdeaToken => origin?.isPrivacyIdeaToken;
  bool get isExportable => origin?.isExportable ?? false;

  // --- Constructor ---
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
    this.forceBiometricOption = ForceBiometricOption.none,
    bool? pin,
    bool? isLocked,
    bool? isHidden,
  }) : _isLocked = isLocked,
       _isHidden = isHidden,
       pin = pin ?? false;

  // --- Factories ---
  /// Creates a token from a json map.
  factory Token.fromJson(Map<String, dynamic> json) {
    String? type = json[TOKENTYPE_JSON];

    if (type == null) {
      throw ArgumentError.value(
        json,
        'Token#fromJson',
        'Token type is not defined in the json',
      );
    }
    if (TokenTypes.HOTP.isName(type, caseSensitive: false)) {
      return HOTPToken.fromJson(json);
    }
    if (TokenTypes.TOTP.isName(type, caseSensitive: false)) {
      return TOTPToken.fromJson(json);
    }
    if (TokenTypes.PIPUSH.isName(type, caseSensitive: false) ||
        TokenTypes.PUSH.isName(type, caseSensitive: false)) {
      return PushToken.fromJson(json);
    }
    if (TokenTypes.DAYPASSWORD.isName(type, caseSensitive: false)) {
      return DayPasswordToken.fromJson(json);
    }
    if (TokenTypes.STEAM.isName(type, caseSensitive: false)) {
      return SteamToken.fromJson(json);
    }

    throw ArgumentError.value(
      json,
      'Token#fromJson',
      'Token type [$type] is not supported',
    );
  }

  /// Creates a token from a uri map.
  factory Token.fromOtpAuthMap(
    Map<String, dynamic> otpAuthMap, {
    Map<String, dynamic> additionalData = const {},
  }) {
    String? type = otpAuthMap[TOKENTYPE_OTPAUTH];

    if (type == null) {
      throw ArgumentError.value(
        otpAuthMap,
        'Token#fromUriMap',
        'Token type is not defined in the uri map',
      );
    }
    if (TokenTypes.HOTP.isName(type, caseSensitive: false)) {
      return HOTPToken.fromOtpAuthMap(
        otpAuthMap,
        additionalData: additionalData,
      );
    }
    if (TokenTypes.TOTP.isName(type, caseSensitive: false)) {
      return TOTPToken.fromOtpAuthMap(
        otpAuthMap,
        additionalData: additionalData,
      );
    }
    if (TokenTypes.PIPUSH.isName(type, caseSensitive: false) ||
        TokenTypes.PUSH.isName(type, caseSensitive: false)) {
      return PushToken.fromOtpAuthMap(
        otpAuthMap,
        additionalData: additionalData,
      );
    }
    if (TokenTypes.DAYPASSWORD.isName(type, caseSensitive: false)) {
      return DayPasswordToken.fromOtpAuthMap(
        otpAuthMap,
        additionalData: additionalData,
      );
    }
    if (TokenTypes.STEAM.isName(type, caseSensitive: false)) {
      return SteamToken.fromOtpAuthMap(
        otpAuthMap,
        additionalData: additionalData,
      );
    }
    throw ArgumentError.value(
      otpAuthMap,
      'Token#fromUriMap',
      'Token type [$type] is not supported',
    );
  }

  // --- Methods ---
  /// This is used to compare the changeable values of the token.
  bool sameValuesAs(Token other) =>
      other.label == label &&
      other.issuer == issuer &&
      other.pin == pin &&
      other.isLocked == isLocked &&
      other.tokenImage == tokenImage;

  /// This is used to identify the same token even if the id is different.
  /// The token should be considered the same if (the id is the same) or (the serial and issuer are the same).
  bool? isSameTokenAs(Token other) {
    if (id == other.id) return true;
    if (serial != null || other.serial != null) {
      return (serial == other.serial && issuer == other.issuer);
    }
    return null;
  }

  @override
  bool operator ==(Object other) => other is Token && other.id == id;

  @override
  int get hashCode => (id + type).hashCode;

  @override
  String toString() {
    return 'Token{label: $label, issuer: $issuer, id: $id, pin: $pin, isLocked: $isLocked, isHidden: $isHidden, type: $type, isOffline: $isOffline}';
  }

  // --- Abstract Methods ---
  Map<String, dynamic> toJson();

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

  Token copyUpdateByTemplate(TokenTemplate template);

  // --- Serialization Helpers ---
  /// This is used to create a map that typically was created from a uri.
  Map<String, dynamic> toOtpAuthMap() {
    return {
      SERIAL: ?serial,
      TOKENTYPE_OTPAUTH: type,
      LABEL: label,
      ISSUER: issuer,
      PIN: pin ? PIN_VALUE_TRUE : PIN_VALUE_FALSE,
      OFFLINE: isOffline,
      IMAGE: ?tokenImage,
    };
  }

  Map<String, dynamic> get additionalData => {
    ID: id,
    ORIGIN: origin,
    SORT_INDEX: sortIndex,
    FOLDER_ID: folderId,
    IS_HIDDEN: isHidden,
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
