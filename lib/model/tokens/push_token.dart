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
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../../model/token_template.dart';
import '../../utils/custom_int_buffer.dart';
import '../../utils/object_validator.dart';
import '../../utils/rsa_utils.dart';
import '../enums/push_token_rollout_state.dart';
import '../enums/token_types.dart';
import '../exception_errors/localized_argument_error.dart';
import '../token_container.dart';
import '../token_import/token_origin_data.dart';
import 'token.dart';

part 'push_token.g.dart';

@JsonSerializable()
class PushToken extends Token {
  static RsaUtils rsaParser = const RsaUtils();

  /// [String] (required for PUSH)
  static const String ROLLOUT_URL = 'url';
  static const String TTL_MINUTES = 'ttl';

  /// [String] (optional) default = null
  static const String ENROLLMENT_CREDENTIAL = 'enrollment_credential';

  /// [String] '1' / '0' (optional) default = '1'
  static const String SSL_VERIFY = 'sslverify';
  static const String SSL_VERIFY_VALUE_TRUE = '1';
  static const String SSL_VERIFY_VALUE_FALSE = '0';

  static const String VERSION = 'v';
  static const String EXPIRATION_DATE = 'expirationDate';
  static const String ROLLOUT_STATE = 'rolloutState';
  static const String IS_ROLLED_OUT = 'isRolledOut';

  static const String PUBLIC_SERVER_KEY = 'publicServerKey';
  static const String PRIVATE_TOKEN_KEY = 'privateTokenKey';
  static const String PUBLIC_TOKEN_KEY = 'publicTokenKey';

  final DateTime? expirationDate;
  @override
  String get serial => super.serial!;
  final String? fbToken;

  @override
  bool? get isPrivacyIdeaTokenna => true;

  // Roll out
  final bool sslVerify;
  final String? enrollmentCredentials;
  final Uri? url;
  final bool isRolledOut;
  final PushTokenRollOutState rolloutState;

  // RSA keys - String values for backward compatibility with serialization
  final String? publicServerKey;
  final String? privateTokenKey;
  final String? publicTokenKey;

  // Custom getter and setter for RSA keys
  RSAPublicKey? get rsaPublicServerKey => publicServerKey == null ? null : rsaParser.deserializeRSAPublicKeyPKCS1(publicServerKey!);
  PushToken withPublicServerKey(RSAPublicKey key) => copyWith(publicServerKey: rsaParser.serializeRSAPublicKeyPKCS1(key));
  RSAPublicKey? get rsaPublicTokenKey => publicTokenKey == null ? null : rsaParser.deserializeRSAPublicKeyPKCS1(publicTokenKey!);
  PushToken withPublicTokenKey(RSAPublicKey key) => copyWith(publicTokenKey: rsaParser.serializeRSAPublicKeyPKCS1(key));
  RSAPrivateKey? get rsaPrivateTokenKey => privateTokenKey == null ? null : rsaParser.deserializeRSAPrivateKeyPKCS1(privateTokenKey!);
  PushToken withPrivateTokenKey(RSAPrivateKey key) => copyWith(privateTokenKey: rsaParser.serializeRSAPrivateKeyPKCS1(key));

  PushToken({
    required String serial,
    super.label,
    super.issuer,
    super.containerSerial,
    super.checkedContainer,
    required super.id,
    this.fbToken,
    this.url,
    this.expirationDate,
    this.enrollmentCredentials,
    this.publicServerKey,
    this.publicTokenKey,
    this.privateTokenKey,
    bool? isRolledOut,
    bool? sslVerify,
    PushTokenRollOutState? rolloutState,
    String? type,
    super.tokenImage,
    super.sortIndex,
    super.folderId,
    super.pin,
    super.isLocked,
    super.isHidden,
    super.origin,
    super.isOffline,
  })  : isRolledOut = isRolledOut ?? false,
        sslVerify = sslVerify ?? false,
        rolloutState = rolloutState ?? PushTokenRollOutState.rolloutNotStarted,
        super(type: type ?? TokenTypes.PIPUSH.name, serial: serial);

  @override
  bool sameValuesAs(Token other) =>
      super.sameValuesAs(other) &&
      other is PushToken &&
      other.fbToken == fbToken &&
      other.expirationDate == expirationDate &&
      other.sslVerify == sslVerify &&
      other.enrollmentCredentials == enrollmentCredentials &&
      other.url == url &&
      other.isRolledOut == isRolledOut &&
      other.rolloutState == rolloutState &&
      other.publicServerKey == publicServerKey &&
      other.publicTokenKey == publicTokenKey &&
      other.privateTokenKey == privateTokenKey;

  @override
  bool isSameTokenAs(Token other) {
    if (super.isSameTokenAs(other) != null) return super.isSameTokenAs(other)!;
    if (other is! PushToken) return false;
    if (publicServerKey != null && other.publicServerKey != null && publicServerKey != other.publicServerKey) return false;
    if (publicTokenKey != null && other.publicTokenKey != null && publicTokenKey != other.publicTokenKey) return false;
    if (privateTokenKey != null && other.privateTokenKey != null && privateTokenKey != other.privateTokenKey) return false;
    if (enrollmentCredentials != null && other.enrollmentCredentials != null && enrollmentCredentials != other.enrollmentCredentials) return false;
    return true;
  }

  @override
  PushToken copyWith({
    String? label,
    String? serial,
    String? issuer,
    String? Function()? containerSerial,
    List<String>? checkedContainer,
    String? id,
    String? tokenImage,
    String? fbToken,
    bool? pin,
    bool? isLocked,
    bool? isHidden,
    bool? sslVerify,
    String? enrollmentCredentials,
    Uri? url,
    String? publicServerKey,
    String? publicTokenKey,
    String? privateTokenKey,
    DateTime? expirationDate,
    bool? isRolledOut,
    PushTokenRollOutState? rolloutState,
    CustomIntBuffer? knownPushRequests,
    int? sortIndex,
    int? Function()? folderId,
    TokenOriginData? origin,
    bool? isOffline,
  }) {
    return PushToken(
      label: label ?? this.label,
      serial: serial ?? this.serial,
      issuer: issuer ?? this.issuer,
      tokenImage: tokenImage ?? this.tokenImage,
      fbToken: fbToken ?? this.fbToken,
      containerSerial: containerSerial != null ? containerSerial() : this.containerSerial,
      checkedContainer: checkedContainer ?? this.checkedContainer,
      id: id ?? this.id,
      pin: pin ?? this.pin,
      isLocked: isLocked ?? this.isLocked,
      isHidden: isHidden ?? this.isHidden,
      sslVerify: sslVerify ?? this.sslVerify,
      enrollmentCredentials: enrollmentCredentials ?? this.enrollmentCredentials,
      url: url ?? this.url,
      publicServerKey: publicServerKey ?? this.publicServerKey,
      publicTokenKey: publicTokenKey ?? this.publicTokenKey,
      privateTokenKey: privateTokenKey ?? this.privateTokenKey,
      expirationDate: expirationDate ?? this.expirationDate,
      isRolledOut: isRolledOut ?? this.isRolledOut,
      rolloutState: rolloutState ?? this.rolloutState,
      sortIndex: sortIndex ?? this.sortIndex,
      folderId: folderId != null ? folderId() : this.folderId,
      origin: origin ?? this.origin,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is PushToken && runtimeType == other.runtimeType && serial == other.serial;

  @override
  int get hashCode => serial.hashCode;

  @override
  String toString() {
    return 'Push${super.toString()} '
        'expirationDate: $expirationDate, '
        'serial: $serial, '
        'sslVerify: $sslVerify, '
        'enrollmentCredentials: $enrollmentCredentials, '
        'url: $url, '
        'isRolledOut: $isRolledOut, '
        'rolloutState: $rolloutState, '
        'publicServerKey: $publicServerKey, '
        'privateTokenKey: $privateTokenKey, '
        'publicTokenKey: $publicTokenKey}';
  }

  factory PushToken.fromOtpAuthMap(Map<String, dynamic> otpAuthMap, {Map<String, dynamic> additionalData = const {}}) {
// Validate map for Push token
    final validatedMap = validateMap(
      map: otpAuthMap,
      validators: {
        Token.LABEL: const ObjectValidatorNullable<String>(defaultValue: ''),
        Token.ISSUER: const ObjectValidatorNullable<String>(defaultValue: ''),
        Token.SERIAL: const ObjectValidator<String>(),
        SSL_VERIFY: boolValidator.withDefault(true),
        TTL_MINUTES: minutesDurationValidator.withDefault(const Duration(minutes: 3)),
        ENROLLMENT_CREDENTIAL: const ObjectValidatorNullable<String>(),
        ROLLOUT_URL: uriValidator,
        Token.IMAGE: const ObjectValidatorNullable<String>(),
        Token.PIN: boolValidatorNullable,
        VERSION: const ObjectValidator<String>(),
      },
      name: 'PushToken',
    );
    final validatedAdditionalData = Token.validateAdditionalData(additionalData);
    validatedAdditionalData.addAll(validateMap(
      map: additionalData,
      validators: {
        EXPIRATION_DATE: const ObjectValidatorNullable<DateTime>(),
        ROLLOUT_STATE: ObjectValidatorNullable<PushTokenRollOutState>(),
        IS_ROLLED_OUT: ObjectValidatorNullable<bool>(),
        PUBLIC_SERVER_KEY: const ObjectValidatorNullable<String>(),
        PUBLIC_TOKEN_KEY: const ObjectValidatorNullable<String>(),
        PRIVATE_TOKEN_KEY: const ObjectValidatorNullable<String>(),
      },
      name: 'PushToken#additionalData',
    ));
    final expirationDate = validatedAdditionalData[EXPIRATION_DATE] as DateTime?;
    return switch (validatedMap[VERSION]) {
      '1' => PushToken(
          label: validatedMap[Token.LABEL] as String,
          issuer: validatedMap[Token.ISSUER] as String,
          serial: validatedMap[Token.SERIAL] as String,
          sslVerify: validatedMap[SSL_VERIFY] as bool,
          expirationDate: expirationDate ?? DateTime.now().add(validatedMap[TTL_MINUTES] as Duration),
          rolloutState: validatedAdditionalData[ROLLOUT_STATE],
          isRolledOut: validatedAdditionalData[IS_ROLLED_OUT],
          enrollmentCredentials: validatedMap[ENROLLMENT_CREDENTIAL] as String?,
          url: validatedMap[ROLLOUT_URL] as Uri,
          tokenImage: validatedMap[Token.IMAGE] as String?,
          pin: validatedMap[Token.PIN] as bool?,
          isLocked: validatedMap[Token.PIN] as bool?,
          id: validatedAdditionalData[Token.ID] ?? const Uuid().v4(),
          origin: validatedAdditionalData[Token.ORIGIN],
          isHidden: validatedAdditionalData[Token.HIDDEN],
          checkedContainer: validatedAdditionalData[Token.CHECKED_CONTAINERS] ?? [],
          folderId: validatedAdditionalData[Token.FOLDER_ID],
          sortIndex: validatedAdditionalData[Token.SORT_INDEX],
          publicServerKey: validatedAdditionalData[PUBLIC_SERVER_KEY],
          publicTokenKey: validatedAdditionalData[PUBLIC_TOKEN_KEY],
          privateTokenKey: validatedAdditionalData[PRIVATE_TOKEN_KEY],
        ),
      _ => throw LocalizedArgumentError(
          localizedMessage: (localizations, value, name) => localizations.unsupported(value, name),
          unlocalizedMessage: 'The piauth version [${validatedMap[VERSION]}] is not supported by this version of the app.',
          invalidValue: validatedMap[VERSION].toString(),
          name: 'piauth version',
        ),
    };
  }

  @override
  Token copyUpdateByTemplate(TokenTemplate template) {
    final uriMap = validateMap(
      map: template.otpAuthMap,
      validators: {
        Token.LABEL: const ObjectValidatorNullable<String>(),
        Token.ISSUER: const ObjectValidatorNullable<String>(),
        Token.SERIAL: const ObjectValidatorNullable<String>(),
        SSL_VERIFY: boolValidatorNullable,
        ENROLLMENT_CREDENTIAL: const ObjectValidatorNullable<String>(),
        ROLLOUT_URL: uriValidatorNullable,
        Token.IMAGE: const ObjectValidatorNullable<String>(),
        Token.PIN: boolValidator,
        VERSION: intValidatorNullable,
      },
      name: 'PushToken',
    );

    return copyWith(
      label: uriMap[Token.LABEL] as String?,
      issuer: uriMap[Token.ISSUER] as String?,
      serial: uriMap[Token.SERIAL] as String?,
      sslVerify: uriMap[SSL_VERIFY] as bool?,
      enrollmentCredentials: uriMap[ENROLLMENT_CREDENTIAL] as String?,
      url: uriMap[ROLLOUT_URL] as Uri?,
      tokenImage: uriMap[Token.IMAGE] as String?,
      pin: uriMap[Token.PIN] as bool?,
      isLocked: uriMap[Token.PIN] as bool?,
    );
  }

  /// This is used to create a map that typically was created from a uri.
  /// ```dart
  ///  ---------------------------- [Token] ----------------------------
  /// | Token.SERIAL: serial, (optional)                                 |
  /// | Token.TOKENTYPE_JSON: type,                                                |
  /// | Token.LABEL: label,                                              |
  /// | Token.ISSUER: issuer,                                            |
  /// | Token.PIN: pin,                                                  |
  /// | Token.IMAGE: tokenImage, (optional)                              |
  ///  ------------------------------------------------------------------
  ///  -------------------------- [PushToken] ---------------------------
  /// | Token.SSL_VERIFY: sslVerify,                                     |
  /// | Token.ROLLOUT_TTL_MINUTES: expirationDate, (optional)            |
  /// | Token.ENROLLMENT_CREDENTIAL: enrollmentCredentials, (optional)   |
  /// | Token.ROLLOUT_URL: url, (optional)                               |
  /// | Token.IMAGE: tokenImage, (optional)                              |
  /// | Token.PIN: pin,                                                  |
  /// | Token.VERSION: 1,                                                |
  ///  ------------------------------------------------------------------
  /// ```
  @override
  Map<String, dynamic> toOtpAuthMap() {
    return super.toOtpAuthMap()
      ..addAll({
        SSL_VERIFY: sslVerify ? SSL_VERIFY_VALUE_TRUE : SSL_VERIFY_VALUE_FALSE,
        if (enrollmentCredentials != null) ENROLLMENT_CREDENTIAL: enrollmentCredentials!,
        if (url != null) ROLLOUT_URL: url.toString(),
        if (tokenImage != null) Token.IMAGE: tokenImage!,
        Token.PIN: pin ? Token.PIN_VALUE_TRUE : Token.PIN_VALUE_FALSE,
        VERSION: '1',
      });
  }

  @override
  TokenTemplate? toTemplate({TokenContainer? container}) => super.toTemplate(container: container)?.withAditionalData({
        if (expirationDate != null) EXPIRATION_DATE: expirationDate!,
        ROLLOUT_STATE: rolloutState,
        IS_ROLLED_OUT: isRolledOut,
        if (publicServerKey != null) PUBLIC_SERVER_KEY: publicServerKey!,
        if (publicTokenKey != null) PUBLIC_TOKEN_KEY: publicTokenKey!,
        if (privateTokenKey != null) PRIVATE_TOKEN_KEY: privateTokenKey!,
      });

  factory PushToken.fromJson(Map<String, dynamic> json) {
    final newToken = _$PushTokenFromJson(json);
    final currentRolloutState = switch (newToken.rolloutState) {
      PushTokenRollOutState.rolloutNotStarted => PushTokenRollOutState.rolloutNotStarted,
      PushTokenRollOutState.generatingRSAKeyPair || PushTokenRollOutState.generatingRSAKeyPairFailed => PushTokenRollOutState.generatingRSAKeyPairFailed,
      PushTokenRollOutState.sendRSAPublicKey || PushTokenRollOutState.sendRSAPublicKeyFailed => PushTokenRollOutState.sendRSAPublicKeyFailed,
      PushTokenRollOutState.parsingResponse || PushTokenRollOutState.parsingResponseFailed => PushTokenRollOutState.parsingResponseFailed,
      PushTokenRollOutState.rolloutComplete => PushTokenRollOutState.rolloutComplete,
    };
    return newToken.copyWith(rolloutState: currentRolloutState);
  }

  @override
  Map<String, dynamic> toJson() => _$PushTokenToJson(this);
}
