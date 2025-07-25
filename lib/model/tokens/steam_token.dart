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
import '../../utils/object_validator.dart';
import '../enums/algorithms.dart';
import '../enums/token_types.dart';
import '../extensions/int_extension.dart';
import '../token_import/token_origin_data.dart';
import 'otp_token.dart';
import 'token.dart';
import 'totp_token.dart';

part 'steam_token.g.dart';

@JsonSerializable()
class SteamToken extends TOTPToken {
  static const STEAM_ISSUER = 'Steam';

  @override
  bool get isPrivacyIdeaToken => false;
  @override
  Null get serial => null;
  static String get tokenType => TokenTypes.STEAM.name;
  static const String steamAlphabet = "23456789BCDFGHJKMNPQRTVWXY";

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
  }) : super(
          type: type ?? tokenType,
          period: 30,
          digits: 5,
          algorithm: Algorithms.SHA1,
        );

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
    int? period, // unused steam tokens always have 30 seconds period
    int? digits, // unused steam tokens always have 5 digits
    Algorithms? algorithm, // unused steam tokens always have SHA1 algorithm
    bool? isOffline,
  }) {
    return SteamToken(
      label: label ?? this.label,
      issuer: issuer ?? this.issuer,
      containerSerial: containerSerial != null ? containerSerial() : this.containerSerial,
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
    );
  }

  // @override
  /// No changeable value in SteamToken
  // bool sameValuesAs(Token other) => super.sameValuesAs(other);

  @override
  bool isSameTokenAs(Token other) => super.isSameTokenAs(other) && other is SteamToken;

  @override
  String otpFromTime(DateTime time) {
    // Flooring time/counter is TOTP default, but yes, steam uses the rounded time/counter.
    final counterBytes = (time.millisecondsSinceEpoch / 1000 / period).round().bytes;
    final secretList = base32.decode(secret.toUpperCase());
    final hmac = Hmac(sha1, secretList);
    final digest = hmac.convert(counterBytes).bytes;
    final offset = digest[digest.length - 1] & 0x0f;

    var code = ((digest[offset] & 0x7f) << 24) | ((digest[offset + 1] & 0xff) << 16) | ((digest[offset + 2] & 0xff) << 8) | (digest[offset + 3] & 0xff);

    final stringBuffer = StringBuffer();
    for (int i = 0; i < digits; i++) {
      stringBuffer.write(steamAlphabet[code % steamAlphabet.length]);
      code ~/= steamAlphabet.length;
    }
    return stringBuffer.toString();
  }

  @override
  String get otpValue => otpFromTime(DateTime.now());

  @override
  String toString() {
    return 'STEAM-${super.toString()}';
  }

  @override
  SteamToken copyUpdateByTemplate(TokenTemplate template) {
    final uriMap = validateMap(
      map: template.otpAuthMap,
      validators: {
        Token.LABEL: const ObjectValidatorNullable<String>(),
        Token.ISSUER: const ObjectValidatorNullable<String>(),
        Token.SERIAL: const ObjectValidatorNullable<String>(),
        OTPToken.SECRET_BASE32: base32SecretValidatorNullable,
        Token.IMAGE: const ObjectValidatorNullable<String>(),
        Token.PIN: boolValidatorNullable,
      },
      name: 'SteamToken',
    );
    return copyWith(
      label: uriMap[Token.LABEL] as String?,
      issuer: uriMap[Token.ISSUER] as String?,
      serial: uriMap[Token.SERIAL] as String?,
      secret: uriMap[OTPToken.SECRET_BASE32] as String?,
      tokenImage: uriMap[Token.IMAGE] as String?,
      pin: uriMap[Token.PIN] as bool?,
      isLocked: uriMap[Token.PIN] as bool?,
    );
  }

  static SteamToken fromOtpAuthMap(Map<String, dynamic> uriMap, {Map<String, dynamic> additionalData = const {}}) {
    uriMap = validateMap(
      map: uriMap,
      validators: {
        Token.LABEL: const ObjectValidator<String>(defaultValue: ''),
        Token.ISSUER: const ObjectValidator<String>(defaultValue: ''),
        Token.SERIAL: const ObjectValidatorNullable<String>(),
        OTPToken.SECRET_BASE32: base32Secretvalidator,
        Token.IMAGE: const ObjectValidatorNullable<String>(),
        Token.PIN: boolValidatorNullable,
      },
      name: 'SteamToken#otpAuthMap',
    );
    final validatedAdditionalData = Token.validateAdditionalData(additionalData);
    return SteamToken(
      label: uriMap[Token.LABEL],
      issuer: uriMap[Token.ISSUER],
      secret: uriMap[OTPToken.SECRET_BASE32],
      tokenImage: uriMap[Token.IMAGE],
      pin: uriMap[Token.PIN],
      isLocked: uriMap[Token.PIN],
      id: validatedAdditionalData[Token.ID] ?? const Uuid().v4(),
      containerSerial: validatedAdditionalData[Token.CONTAINER_SERIAL],
      checkedContainer: validatedAdditionalData[Token.CHECKED_CONTAINERS] ?? [],
      sortIndex: validatedAdditionalData[Token.SORT_INDEX],
      folderId: validatedAdditionalData[Token.FOLDER_ID],
      origin: validatedAdditionalData[Token.ORIGIN],
      isHidden: validatedAdditionalData[Token.HIDDEN],
    );
  }

  /// This is used to create a map that typically was created from a uri.
  /// ```dart
  ///  ------------------------- [Token] -------------------------
  /// | Token.SERIAL: serial, (optional)                          |
  /// | Token.TOKENTYPE_JSON: type,                                         |
  /// | Token.LABEL: label,                                       |
  /// | Token.ISSUER: issuer,                                     |
  /// | Token.PIN: pin,                                           |
  /// | Token.IMAGE: tokenImage, (optional)                       |
  ///  -----------------------------------------------------------
  ///  ----------------------- [OTPToken] ------------------------
  /// | OTPToken.ALGORITHM: algorithm,                            |
  /// | OTPToken.DIGITS: digits,                                  |
  ///  -----------------------------------------------------------
  ///  ----------------------- [HOTPToken] -----------------------
  /// | HOTPToken.COUNTER: period,                                |
  ///  -----------------------------------------------------------
  ///  ----------------------- [SteamToken] ----------------------
  /// | /*No additional fields*/                                  |
  ///  -----------------------------------------------------------
  /// ```
  @override
  Map<String, dynamic> toOtpAuthMap() => super.toOtpAuthMap();

  static SteamToken fromJson(Map<String, dynamic> json) => _$SteamTokenFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SteamTokenToJson(this);
}
