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

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../utils/object_validator/object_validators.dart';
import '../enums/algorithms.dart';
import '../enums/force_biometric_option.dart';
import '../enums/token_types.dart';
import '../extensions/enums/algorithms_extension.dart';
import '../token_import/token_origin_data.dart';
import '../token_template.dart';
import 'otp_token.dart';
import 'token.dart';

part 'hotp_token.g.dart';

@JsonSerializable()
class HOTPToken extends OTPToken {
  // --- Constants ---
  static const String COUNTER = 'counter';

  // --- Static Accessors & Validators ---
  static String get tokenType => TokenTypes.HOTP.name;

  static final Map<String, BaseValidator> otpAuthValidators = {
    ...OTPToken.otpAuthValidators,
    COUNTER: Validators.otpCounterSafe,
  };

  // --- Static Validation Methods ---
  static Map<String, Object?> validateOtpAuthMap(
    Map<String, dynamic> otpAuthMap,
  ) {
    return validateMap(
      map: otpAuthMap,
      validators: otpAuthValidators,
      name: 'HOTPToken#otpAuthMap',
    );
  }

  // --- Instance Properties ---
  final int counter;

  @override
  Duration get showDuration => const Duration(seconds: 30);

  @override
  String get otpValue => algorithm.generateHOTPCodeString(
    secret: secret,
    counter: counter,
    length: digits,
  );

  @override
  String get nextValue => algorithm.generateHOTPCodeString(
    secret: secret,
    counter: counter + 1,
    length: digits,
  );

  // --- Constructor ---
  HOTPToken({
    this.counter = 0,
    super.containerSerial,
    super.checkedContainer,
    required super.id,
    required super.algorithm,
    required super.digits,
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
    super.isOffline,
    super.forceBiometricOption,
  }) : super(type: TokenTypes.HOTP.name);

  // --- Factories ---
  factory HOTPToken.fromJson(Map<String, dynamic> json) =>
      _$HOTPTokenFromJson(json);

  factory HOTPToken.fromOtpAuthMap(
    Map<String, dynamic> otpAuthMap, {
    Map<String, dynamic> additionalData = const {},
  }) {
    final validatedMap = validateOtpAuthMap(otpAuthMap);
    final validatedAdditionalData = Token.validateAdditionalData(
      additionalData,
    );

    return HOTPToken(
      label: validatedMap[Token.LABEL] as String,
      issuer: validatedMap[Token.ISSUER] as String,
      serial: validatedMap[Token.SERIAL] as String?,
      tokenImage: validatedMap[Token.IMAGE] as String?,
      pin: validatedMap[Token.PIN] as bool?,
      isLocked: validatedMap[Token.PIN] as bool?,
      isOffline: validatedMap[Token.OFFLINE] as bool,
      algorithm: validatedMap[OTPToken.ALGORITHM] as Algorithms,
      digits: validatedMap[OTPToken.DIGITS] as int,
      secret: validatedMap[OTPToken.SECRET_BASE32] as String,
      counter: validatedMap[COUNTER] as int,
      forceBiometricOption:
          validatedMap[Token.FORCE_BIOMETRIC_OPTION] as ForceBiometricOption,
      containerSerial:
          validatedAdditionalData[Token.CONTAINER_SERIAL] as String?,
      id: validatedAdditionalData[Token.ID] as String? ?? const Uuid().v4(),
      origin: validatedAdditionalData[Token.ORIGIN] as TokenOriginData?,
      isHidden: validatedAdditionalData[Token.IS_HIDDEN] as bool?,
      checkedContainer:
          validatedAdditionalData[Token.CHECKED_CONTAINERS] as List<String>,
      folderId: validatedAdditionalData[Token.FOLDER_ID] as int?,
      sortIndex: validatedAdditionalData[Token.SORT_INDEX] as int?,
    );
  }

  // --- Methods ---
  @override
  bool sameValuesAs(Token other) =>
      super.sameValuesAs(other) &&
      other is HOTPToken &&
      other.counter == counter;

  @override
  bool isSameTokenAs(Token other) {
    if (super.isSameTokenAs(other) != null) return super.isSameTokenAs(other)!;
    return other is HOTPToken;
  }

  HOTPToken withNextCounter() => copyWith(counter: counter + 1);

  @override
  HOTPToken copyWith({
    String? Function()? serial,
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
    bool? isOffline,
    ForceBiometricOption? forceBiometricOption,
  }) => HOTPToken(
    serial: serial != null ? serial() : this.serial,
    counter: counter ?? this.counter,
    label: label ?? this.label,
    issuer: issuer ?? this.issuer,
    containerSerial: containerSerial != null
        ? containerSerial()
        : this.containerSerial,
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
    isOffline: isOffline ?? this.isOffline,
    forceBiometricOption: forceBiometricOption ?? this.forceBiometricOption,
  );

  @override
  HOTPToken copyUpdateByTemplate(TokenTemplate template) {
    final uriMap = validateMap(
      map: template.otpAuthMap,
      validators: otpAuthValidators,
      name: 'HOTPToken#copyUpdateByTemplate',
    );
    return copyWith(
      label: uriMap[Token.LABEL] as String?,
      issuer: uriMap[Token.ISSUER] as String?,
      serial: () => uriMap[Token.SERIAL] as String?,
      tokenImage: uriMap[Token.IMAGE] as String?,
      pin: uriMap[Token.PIN] as bool?,
      isLocked: uriMap[Token.PIN] as bool?,
      algorithm: uriMap[OTPToken.ALGORITHM] as Algorithms?,
      digits: uriMap[OTPToken.DIGITS] as int?,
      secret: uriMap[OTPToken.SECRET_BASE32] as String?,
      counter: uriMap[COUNTER] as int?,
    );
  }

  @override
  String toString() => 'H${super.toString()}counter: $counter}';

  // --- Serialization Helpers ---
  @override
  Map<String, dynamic> toJson() => _$HOTPTokenToJson(this);

  @override
  Map<String, dynamic> toOtpAuthMap() =>
      super.toOtpAuthMap()..addAll({COUNTER: counter.toString()});
}
