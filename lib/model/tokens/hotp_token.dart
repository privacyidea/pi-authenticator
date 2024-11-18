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

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../utils/identifiers.dart';
import '../../utils/object_validator.dart';
import '../enums/algorithms.dart';
import '../enums/token_types.dart';
import '../extensions/enums/algorithms_extension.dart';
import '../token_import/token_origin_data.dart';
import '../token_template.dart';
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
    super.containerSerial,
    super.checkedContainer,
    required super.id,
    required super.algorithm,
    required super.digits,
    required super.secret,
    super.serial,
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

  @override
  String get nextValue => algorithm.generateHOTPCodeString(
        secret: secret,
        counter: counter + 1,
        length: digits,
        isGoogle: true,
      );

  HOTPToken withNextCounter() => copyWith(counter: counter + 1);

  @override
  HOTPToken copyWith({
    String? serial,
    int? counter,
    String? label,
    String? issuer,
    String? Function()? containerSerial,
    List<String>? checkedContainer,
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
        serial: serial ?? this.serial,
        counter: counter ?? this.counter,
        label: label ?? this.label,
        issuer: issuer ?? this.issuer,
        containerSerial: containerSerial != null ? containerSerial() : this.containerSerial,
        checkedContainer: checkedContainer ?? this.checkedContainer,
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

  @override
  HOTPToken copyUpdateByTemplate(TokenTemplate template) {
    final uriMap = validateMap(
      map: template.otpAuthMap,
      validators: {
        OTP_AUTH_LABEL: const ObjectValidatorNullable<String>(),
        OTP_AUTH_ISSUER: const ObjectValidatorNullable<String>(),
        OTP_AUTH_SERIAL: const ObjectValidatorNullable<String>(),
        OTP_AUTH_ALGORITHM: stringToAlgorithmsValidatorNullable,
        OTP_AUTH_DIGITS: intValidatorNullable,
        OTP_AUTH_SECRET_BASE32: base32SecretValidatorNullable,
        OTP_AUTH_COUNTER: intValidatorNullable,
        OTP_AUTH_IMAGE: const ObjectValidatorNullable<String>(),
        OTP_AUTH_PIN: boolValidatorNullable,
      },
      name: 'HOTPToken',
    );
    return copyWith(
      label: uriMap[OTP_AUTH_LABEL] as String?,
      issuer: uriMap[OTP_AUTH_ISSUER] as String?,
      serial: uriMap[OTP_AUTH_SERIAL] as String?,
      algorithm: uriMap[OTP_AUTH_ALGORITHM] as Algorithms?,
      digits: uriMap[OTP_AUTH_DIGITS] as int?,
      secret: uriMap[OTP_AUTH_SECRET_BASE32] as String?,
      counter: uriMap[OTP_AUTH_COUNTER] as int?,
      tokenImage: uriMap[OTP_AUTH_IMAGE] as String?,
      pin: uriMap[OTP_AUTH_PIN] as bool?,
      isLocked: uriMap[OTP_AUTH_PIN] as bool?,
    );
  }

  factory HOTPToken.fromOtpAuthMap(Map<String, dynamic> otpAuthMap, {Map<String, dynamic> additionalData = const {}}) {
    final validatedMap = validateMap(
      map: otpAuthMap,
      validators: {
        OTP_AUTH_LABEL: const ObjectValidator<String>(defaultValue: ''),
        OTP_AUTH_ISSUER: const ObjectValidator<String>(defaultValue: ''),
        OTP_AUTH_SERIAL: const ObjectValidatorNullable<String>(),
        OTP_AUTH_ALGORITHM: stringToAlgorithmsValidator.withDefault(Algorithms.SHA1),
        OTP_AUTH_DIGITS: otpAuthDigitsValidatorNullable,
        OTP_AUTH_SECRET_BASE32: base32Secretvalidator,
        OTP_AUTH_COUNTER: otpAuthCounterValidator,
        OTP_AUTH_IMAGE: const ObjectValidatorNullable<String>(),
        OTP_AUTH_PIN: boolValidatorNullable,
      },
      name: 'HOTPToken#otpAuthMap',
    );
    final validatedAdditionalData = Token.validateAdditionalData(additionalData);
    return HOTPToken(
      label: validatedMap[OTP_AUTH_LABEL] as String,
      issuer: validatedMap[OTP_AUTH_ISSUER] as String,
      serial: validatedMap[OTP_AUTH_SERIAL] as String?,
      algorithm: validatedMap[OTP_AUTH_ALGORITHM] as Algorithms,
      digits: validatedMap[OTP_AUTH_DIGITS] as int,
      secret: validatedMap[OTP_AUTH_SECRET_BASE32] as String,
      counter: validatedMap[OTP_AUTH_COUNTER] as int,
      tokenImage: validatedMap[OTP_AUTH_IMAGE] as String?,
      pin: validatedMap[OTP_AUTH_PIN] as bool?,
      isLocked: validatedMap[OTP_AUTH_PIN] as bool?,
      containerSerial: validatedAdditionalData[Token.CONTAINER_SERIAL],
      id: validatedAdditionalData[Token.ID] ?? const Uuid().v4(),
      origin: validatedAdditionalData[Token.ORIGIN],
      isHidden: validatedAdditionalData[Token.HIDDEN],
      checkedContainer: validatedAdditionalData[Token.CHECKED_CONTAINERS] ?? [],
      folderId: validatedAdditionalData[Token.FOLDER_ID],
      sortIndex: validatedAdditionalData[Token.SORT_INDEX],
    );
  }

  /// This is used to create a map that typically was created from a uri.
  /// ```dart
  /// -------------------------- [Token] --------------------------------
  /// | OTP_AUTH_SERIAL: serial, (optional)                             |
  /// | OTP_AUTH_LABEL: label,                                          |
  /// | OTP_AUTH_ISSUER: issuer,                                        |
  /// | CONTAINER_SERIAL: containerSerial, (optional)                   |
  /// | CHECKED_CONTAINERS: checkedContainer,                          |
  /// | TOKEN_ID: id,                                                   |
  /// | OTP_AUTH_TYPE: type,                                            |
  /// | OTP_AUTH_IMAGE: tokenImage, (optional)                          |
  /// | SORTABLE_INDEX: sortIndex, (optional)                           |
  /// | FOLDER_ID: folderId, (optional)                                 |
  /// | TOKEN_ORIGIN: origin, (optional)                                |
  /// | OTP_AUTH_PIN: pin,                                              |
  /// | TOKEN_HIDDEN: isHidden,                                         |
  /// -------------------------------------------------------------------
  /// ------------------------- [OTPToken] ------------------------------
  /// | OTP_AUTH_ALGORITHM: algorithm,                                  |
  /// | OTP_AUTH_DIGITS: digits,                                        |
  /// | OTP_AUTH_SECRET_BASE32: secret,                                 |
  /// | OTP_AUTH_OTP_VALUES: [otpValue, nextValue], (if serial is null) |
  /// -------------------------------------------------------------------
  /// ------------------------ [HOTPToken] ------------------------------
  /// | OTP_AUTH_COUNTER: counter,                                      |
  /// -------------------------------------------------------------------
  /// ```
  @override
  Map<String, dynamic> toOtpAuthMap() {
    return super.toOtpAuthMap()
      ..addAll({
        OTP_AUTH_COUNTER: counter.toString(),
      });
  }

  @override
  Map<String, dynamic> toJson() => _$HOTPTokenToJson(this);
  factory HOTPToken.fromJson(Map<String, dynamic> json) => _$HOTPTokenFromJson(json);
}
