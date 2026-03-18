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
import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../../model/token_template.dart';
import '../../utils/object_validator/object_validators.dart';
import '../enums/algorithms.dart';
import '../enums/force_biometric_option.dart';
import '../enums/token_types.dart';
import '../extensions/int_extension.dart';
import '../token_import/token_origin_data.dart';
import 'otp_token.dart';
import 'token.dart';
import 'totp_token.dart';

part 'steam_token.g.dart';

@JsonSerializable()
class SteamToken extends TOTPToken {
  // --- Constants ---
  static const String STEAM_ISSUER = 'Steam';
  static const String steamAlphabet = "23456789BCDFGHJKMNPQRTVWXY";

  // --- Static Accessors & Validators ---
  static String get tokenType => TokenTypes.STEAM.name;

  static final Map<String, BaseValidator> otpAuthValidators = {
    ...Token.otpAuthValidators,
    OTPToken.SECRET_BASE32: base32Stringvalidator,
  };

  // --- Static Validation Methods ---
  static Map<String, Object?> validateOtpAuthMap(
    Map<String, dynamic> otpAuthMap,
  ) {
    return validateMap(
      map: otpAuthMap,
      validators: otpAuthValidators,
      name: 'SteamToken#otpAuthMap',
    );
  }

  // --- Instance Properties ---
  @override
  bool get isPrivacyIdeaToken => false;

  @override
  Null get serial => null;

  @override
  String get otpValue => otpFromTime(DateTime.now());

  // --- Constructor ---
  SteamToken({
    required super.id,
    required super.secret,
    super.containerSerial,
    super.checkedContainer,
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
  }) : super(
         type: type ?? tokenType,
         period: 30,
         digits: 5,
         algorithm: Algorithms.SHA1,
       );

  // --- Factories ---
  factory SteamToken.fromJson(Map<String, dynamic> json) =>
      _$SteamTokenFromJson(json);

  factory SteamToken.fromOtpAuthMap(
    Map<String, dynamic> otpAuthMap, {
    Map<String, dynamic> additionalData = const {},
  }) {
    final validatedMap = validateOtpAuthMap(otpAuthMap);
    final validatedAdditionalData = Token.validateAdditionalData(
      additionalData,
    );

    return SteamToken(
      label: validatedMap[Token.LABEL] as String,
      issuer: validatedMap[Token.ISSUER] as String,
      secret: validatedMap[OTPToken.SECRET_BASE32] as String,
      tokenImage: validatedMap[Token.IMAGE] as String?,
      pin: validatedMap[Token.PIN] as bool?,
      isLocked: validatedMap[Token.PIN] as bool?,
      isOffline: (validatedMap[Token.OFFLINE] as bool?) ?? false,
      forceBiometricOption:
          (validatedMap[Token.FORCE_BIOMETRIC_OPTION]
              as ForceBiometricOption?) ??
          ForceBiometricOption.none,
      id: validatedAdditionalData[Token.ID] as String? ?? const Uuid().v4(),
      containerSerial:
          validatedAdditionalData[Token.CONTAINER_SERIAL] as String?,
      checkedContainer:
          (validatedAdditionalData[Token.CHECKED_CONTAINERS]
              as List<String>?) ??
          [],
      sortIndex: validatedAdditionalData[Token.SORT_INDEX] as int?,
      folderId: validatedAdditionalData[Token.FOLDER_ID] as int?,
      origin: validatedAdditionalData[Token.ORIGIN] as TokenOriginData?,
      isHidden: validatedAdditionalData[Token.IS_HIDDEN] as bool?,
    );
  }

  // --- Methods ---
  @override
  String otpFromTime(DateTime time) {
    final counterBytes = (time.millisecondsSinceEpoch / 1000 / period)
        .round()
        .bytes;
    final secretList = base32.decode(secret.toUpperCase());
    final hmac = Hmac(sha1, secretList);
    final digest = hmac.convert(counterBytes).bytes;
    final offset = digest[digest.length - 1] & 0x0f;

    var code =
        ((digest[offset] & 0x7f) << 24) |
        ((digest[offset + 1] & 0xff) << 16) |
        ((digest[offset + 2] & 0xff) << 8) |
        (digest[offset + 3] & 0xff);

    final stringBuffer = StringBuffer();
    for (int i = 0; i < digits; i++) {
      stringBuffer.write(steamAlphabet[code % steamAlphabet.length]);
      code ~/= steamAlphabet.length;
    }
    return stringBuffer.toString();
  }

  @override
  bool isSameTokenAs(Token other) =>
      super.isSameTokenAs(other) && other is SteamToken;

  @override
  SteamToken copyWith({
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
    String? secret,
    int? period,
    int? digits,
    Algorithms? algorithm,
    bool? isOffline,
    ForceBiometricOption? forceBiometricOption,
  }) {
    return SteamToken(
      label: label ?? this.label,
      issuer: issuer ?? this.issuer,
      containerSerial: containerSerial != null
          ? containerSerial()
          : this.containerSerial,
      checkedContainer: checkedContainer ?? this.checkedContainer,
      id: id ?? this.id,
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
  }

  @override
  SteamToken copyUpdateByTemplate(TokenTemplate template) {
    final uriMap = validateOtpAuthMap(template.otpAuthMap);
    return copyWith(
      label: uriMap[Token.LABEL] as String?,
      issuer: uriMap[Token.ISSUER] as String?,
      secret: uriMap[OTPToken.SECRET_BASE32] as String?,
      tokenImage: uriMap[Token.IMAGE] as String?,
      pin: uriMap[Token.PIN] as bool?,
      isLocked: uriMap[Token.PIN] as bool?,
    );
  }

  @override
  String toString() => 'STEAM-${super.toString()}';

  // --- Serialization Helpers ---
  @override
  Map<String, dynamic> toJson() => _$SteamTokenToJson(this);
}
