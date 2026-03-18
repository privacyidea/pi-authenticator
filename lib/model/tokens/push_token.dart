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
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../../model/token_template.dart';
import '../../utils/object_validator/object_validators.dart';
import '../../utils/rsa_utils.dart';
import '../enums/push_token_rollout_state.dart';
import '../enums/token_types.dart';
import '../exception_errors/localized_argument_error.dart';
import '../token_import/token_origin_data.dart';
import 'token.dart';

part 'push_token.g.dart';

@JsonSerializable()
class PushToken extends Token {
  // --- Constants ---
  static RsaUtils rsaParser = const RsaUtils();

  static const String ROLLOUT_URL = 'url';
  static const String TTL_MINUTES = 'ttl';
  static const String ENROLLMENT_CREDENTIAL = 'enrollment_credential';
  static const String SSL_VERIFY = 'sslverify';
  static const String SSL_VERIFY_VALUE_TRUE = '1';
  static const String SSL_VERIFY_VALUE_FALSE = '0';
  static const String IS_POLL_ONLY = 'poll_only';
  static const String IS_POLL_ONLY_VALUE_TRUE = 'True';
  static const String IS_POLL_ONLY_VALUE_FALSE = 'False';
  static const String VERSION = 'v';
  static const String EXPIRATION_DATE = 'expirationDate';
  static const String ROLLOUT_STATE = 'rolloutState';
  static const String IS_ROLLED_OUT = 'isRolledOut';
  static const String PUBLIC_SERVER_KEY = 'publicServerKey';
  static const String PRIVATE_TOKEN_KEY = 'privateTokenKey';
  static const String PUBLIC_TOKEN_KEY = 'publicTokenKey';

  // --- Static Accessors & Validators ---
  static String get tokenType => TokenTypes.PIPUSH.name;

  static final Map<String, BaseValidator> otpAuthValidators = {
    ...Token.otpAuthValidators,
    Token.SERIAL: stringValidator,
    SSL_VERIFY: boolValidator.withDefault(true),
    IS_POLL_ONLY: boolValidatorOptional,
    TTL_MINUTES: minutesDurationValidator.withDefault(
      const Duration(minutes: 3),
    ),
    ENROLLMENT_CREDENTIAL: stringValidatorOptional,
    ROLLOUT_URL: uriValidator,
    VERSION: stringValidator,
  };

  static final Map<String, BaseValidator> additionalDataValidators = {
    ...Token.additionalDataValidators,
    EXPIRATION_DATE: const OptionalObjectValidator<DateTime>(),
    ROLLOUT_STATE: const OptionalObjectValidator<PushTokenRollOutState>(
      defaultValue: PushTokenRollOutState.rolloutNotStarted,
    ),
    IS_ROLLED_OUT: boolValidator.withDefault(false),
    PUBLIC_SERVER_KEY: stringValidatorOptional,
    PUBLIC_TOKEN_KEY: stringValidatorOptional,
    PRIVATE_TOKEN_KEY: stringValidatorOptional,
  };

  // --- Static Validation Methods ---
  static Map<String, Object?> validateOtpAuthMap(
    Map<String, dynamic> otpAuthMap,
  ) {
    return validateMap(
      map: otpAuthMap,
      validators: otpAuthValidators,
      name: 'PushToken#otpAuthMap',
    );
  }

  static Map<String, Object?> validateAdditionalData(
    Map<String, dynamic> additionalData,
  ) {
    return validateMap(
      map: additionalData,
      validators: additionalDataValidators,
      name: 'PushToken#additionalData',
    );
  }

  // --- Instance Properties ---
  final DateTime? expirationDate;
  final String? fbToken;
  final bool sslVerify;
  final bool? isPollOnly;
  final String? enrollmentCredentials;
  final Uri? url;
  final bool isRolledOut;
  final PushTokenRollOutState rolloutState;
  final String? publicServerKey;
  final String? privateTokenKey;
  final String? publicTokenKey;

  @override
  String get serial => super.serial!;
  @override
  bool get isHidden => false;
  @override
  bool? get isPrivacyIdeaToken => true;

  // --- RSA Helpers ---
  RSAPublicKey? get rsaPublicServerKey => publicServerKey == null
      ? null
      : rsaParser.deserializeRSAPublicKeyPKCS1(publicServerKey!);
  RSAPublicKey? get rsaPublicTokenKey => publicTokenKey == null
      ? null
      : rsaParser.deserializeRSAPublicKeyPKCS1(publicTokenKey!);
  RSAPrivateKey? get rsaPrivateTokenKey => privateTokenKey == null
      ? null
      : rsaParser.deserializeRSAPrivateKeyPKCS1(privateTokenKey!);

  PushToken withPublicServerKey(RSAPublicKey key) =>
      copyWith(publicServerKey: rsaParser.serializeRSAPublicKeyPKCS1(key));
  PushToken withPublicTokenKey(RSAPublicKey key) =>
      copyWith(publicTokenKey: rsaParser.serializeRSAPublicKeyPKCS1(key));
  PushToken withPrivateTokenKey(RSAPrivateKey key) =>
      copyWith(privateTokenKey: rsaParser.serializeRSAPrivateKeyPKCS1(key));

  // --- Constructor ---
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
    this.isPollOnly,
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
    super.forceBiometricOption,
  }) : isRolledOut = isRolledOut ?? false,
       sslVerify = sslVerify ?? false,
       rolloutState = rolloutState ?? PushTokenRollOutState.rolloutNotStarted,
       super(type: type ?? TokenTypes.PIPUSH.name, serial: serial);

  // --- Factories ---
  factory PushToken.fromJson(Map<String, dynamic> json) {
    final newToken = _$PushTokenFromJson(json);
    final currentRolloutState = switch (newToken.rolloutState) {
      PushTokenRollOutState.rolloutNotStarted =>
        PushTokenRollOutState.rolloutNotStarted,
      PushTokenRollOutState.generatingRSAKeyPair ||
      PushTokenRollOutState.generatingRSAKeyPairFailed =>
        PushTokenRollOutState.generatingRSAKeyPairFailed,
      PushTokenRollOutState.receivingFirebaseToken ||
      PushTokenRollOutState.receivingFirebaseTokenFailed =>
        PushTokenRollOutState.receivingFirebaseTokenFailed,
      PushTokenRollOutState.sendRSAPublicKey ||
      PushTokenRollOutState.sendRSAPublicKeyFailed =>
        PushTokenRollOutState.sendRSAPublicKeyFailed,
      PushTokenRollOutState.parsingResponse ||
      PushTokenRollOutState.parsingResponseFailed =>
        PushTokenRollOutState.parsingResponseFailed,
      PushTokenRollOutState.rolloutComplete =>
        PushTokenRollOutState.rolloutComplete,
    };
    return newToken.copyWith(rolloutState: currentRolloutState);
  }

  factory PushToken.fromOtpAuthMap(
    Map<String, dynamic> otpAuthMap, {
    Map<String, dynamic> additionalData = const {},
  }) {
    final validatedMap = validateOtpAuthMap(otpAuthMap);
    final validatedAdditionalData = validateAdditionalData(additionalData);

    if (validatedMap[VERSION] != '1') {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, name) =>
            localizations.unsupported(value, name),
        unlocalizedMessage:
            'The piauth version [${validatedMap[VERSION]}] is not supported.',
        invalidValue: validatedMap[VERSION].toString(),
        name: 'piauth version',
      );
    }

    return PushToken(
      label: validatedMap[Token.LABEL] as String,
      issuer: validatedMap[Token.ISSUER] as String,
      serial: validatedMap[Token.SERIAL] as String,
      sslVerify: validatedMap[SSL_VERIFY] as bool,
      isPollOnly: validatedMap[IS_POLL_ONLY] as bool?,
      expirationDate:
          (validatedAdditionalData[EXPIRATION_DATE] as DateTime?) ??
          DateTime.now().add(validatedMap[TTL_MINUTES] as Duration),
      rolloutState:
          validatedAdditionalData[ROLLOUT_STATE] as PushTokenRollOutState,
      isRolledOut: validatedAdditionalData[IS_ROLLED_OUT] as bool,
      enrollmentCredentials: validatedMap[ENROLLMENT_CREDENTIAL] as String?,
      url: validatedMap[ROLLOUT_URL] as Uri,
      tokenImage: validatedMap[Token.IMAGE] as String?,
      pin: validatedMap[Token.PIN] as bool?,
      isLocked: validatedMap[Token.PIN] as bool?,
      isOffline: validatedMap[Token.OFFLINE] as bool,
      forceBiometricOption:
          validatedMap[Token.FORCE_BIOMETRIC_OPTION] as ForceBiometricOption,
      id: validatedAdditionalData[Token.ID] as String? ?? const Uuid().v4(),
      containerSerial:
          validatedAdditionalData[Token.CONTAINER_SERIAL] as String?,
      checkedContainer:
          validatedAdditionalData[Token.CHECKED_CONTAINERS] as List<String>,
      sortIndex: validatedAdditionalData[Token.SORT_INDEX] as int?,
      folderId: validatedAdditionalData[Token.FOLDER_ID] as int?,
      origin: validatedAdditionalData[Token.ORIGIN] as TokenOriginData?,
      publicServerKey: validatedAdditionalData[PUBLIC_SERVER_KEY] as String?,
      publicTokenKey: validatedAdditionalData[PUBLIC_TOKEN_KEY] as String?,
      privateTokenKey: validatedAdditionalData[PRIVATE_TOKEN_KEY] as String?,
    );
  }

  // --- Methods ---
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
    return (publicServerKey == other.publicServerKey &&
        publicTokenKey == other.publicTokenKey &&
        privateTokenKey == other.privateTokenKey &&
        enrollmentCredentials == other.enrollmentCredentials);
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
    bool? Function()? isPollOnly,
    String? enrollmentCredentials,
    Uri? url,
    String? publicServerKey,
    String? publicTokenKey,
    String? privateTokenKey,
    DateTime? expirationDate,
    bool? isRolledOut,
    PushTokenRollOutState? rolloutState,
    int? sortIndex,
    int? Function()? folderId,
    TokenOriginData? origin,
    bool? isOffline,
    ForceBiometricOption? forceBiometricOption,
  }) => PushToken(
    label: label ?? this.label,
    serial: serial ?? this.serial,
    issuer: issuer ?? this.issuer,
    tokenImage: tokenImage ?? this.tokenImage,
    fbToken: fbToken ?? this.fbToken,
    containerSerial: containerSerial != null
        ? containerSerial()
        : this.containerSerial,
    checkedContainer: checkedContainer ?? this.checkedContainer,
    id: id ?? this.id,
    pin: pin ?? this.pin,
    isLocked: isLocked ?? this.isLocked,
    isHidden: isHidden ?? this.isHidden,
    sslVerify: sslVerify ?? this.sslVerify,
    isPollOnly: isPollOnly != null ? isPollOnly() : this.isPollOnly,
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
    forceBiometricOption: forceBiometricOption ?? this.forceBiometricOption,
  );

  @override
  Token copyUpdateByTemplate(TokenTemplate template) {
    final uriMap = validateOtpAuthMap(template.otpAuthMap);
    return copyWith(
      label: uriMap[Token.LABEL] as String?,
      issuer: uriMap[Token.ISSUER] as String?,
      serial: uriMap[Token.SERIAL] as String?,
      sslVerify: uriMap[SSL_VERIFY] as bool?,
      isPollOnly: uriMap[IS_POLL_ONLY] != null
          ? () => (uriMap[IS_POLL_ONLY] as bool)
          : () => isPollOnly,
      enrollmentCredentials: uriMap[ENROLLMENT_CREDENTIAL] as String?,
      url: uriMap[ROLLOUT_URL] as Uri?,
      tokenImage: uriMap[Token.IMAGE] as String?,
      pin: uriMap[Token.PIN] as bool?,
      isLocked: uriMap[Token.PIN] as bool?,
    );
  }

  @override
  Map<String, dynamic> toOtpAuthMap() => super.toOtpAuthMap()
    ..addAll({
      SSL_VERIFY: sslVerify ? SSL_VERIFY_VALUE_TRUE : SSL_VERIFY_VALUE_FALSE,
      if (isPollOnly != null)
        IS_POLL_ONLY: isPollOnly!
            ? IS_POLL_ONLY_VALUE_TRUE
            : IS_POLL_ONLY_VALUE_FALSE,
      ENROLLMENT_CREDENTIAL: enrollmentCredentials,
      if (url != null) ROLLOUT_URL: url.toString(),
      VERSION: '1',
    });

  @override
  Map<String, dynamic> get additionalData => super.additionalData
    ..addAll({
      EXPIRATION_DATE: expirationDate,
      ROLLOUT_STATE: rolloutState,
      IS_ROLLED_OUT: isRolledOut,
      PUBLIC_SERVER_KEY: publicServerKey,
      PUBLIC_TOKEN_KEY: publicTokenKey,
      PRIVATE_TOKEN_KEY: privateTokenKey,
    });

  @override
  Map<String, dynamic> toJson() => _$PushTokenToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PushToken && serial == other.serial);
  @override
  int get hashCode => serial.hashCode;
  @override
  String toString() =>
      'Push${super.toString()} expirationDate: $expirationDate, url: $url}';
}
