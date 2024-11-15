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
import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../../model/token_template.dart';
import '../../utils/custom_int_buffer.dart';
import '../../utils/identifiers.dart';
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
  bool? get isPrivacyIdeaToken => true;

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
  bool isSameTokenAs(Token other) => super.isSameTokenAs(other) && (other is PushToken && other.serial == serial);

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
        OTP_AUTH_LABEL: const ObjectValidatorNullable<String>(defaultValue: ''),
        OTP_AUTH_ISSUER: const ObjectValidatorNullable<String>(defaultValue: ''),
        OTP_AUTH_SERIAL: const ObjectValidator<String>(),
        OTP_AUTH_PUSH_SSL_VERIFY: boolValidator.withDefault(true),
        OTP_AUTH_PUSH_TTL_MINUTES: ObjectValidator<Duration>(
          transformer: (v) => Duration(minutes: int.parse(v)),
          defaultValue: const Duration(minutes: 10),
        ),
        OTP_AUTH_PUSH_ENROLLMENT_CREDENTIAL: const ObjectValidatorNullable<String>(),
        OTP_AUTH_PUSH_ROLLOUT_URL: stringToUrivalidator,
        OTP_AUTH_IMAGE: stringToUriValidatorNullable,
        OTP_AUTH_PIN: boolValidatorNullable,
        OTP_AUTH_VERSION: const ObjectValidator<String>(),
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
    return switch (validatedMap[OTP_AUTH_VERSION]) {
      '1' => PushToken(
          label: validatedMap[OTP_AUTH_LABEL] as String,
          issuer: validatedMap[OTP_AUTH_ISSUER] as String,
          serial: validatedMap[OTP_AUTH_SERIAL] as String,
          sslVerify: validatedMap[OTP_AUTH_PUSH_SSL_VERIFY] as bool,
          expirationDate: expirationDate ?? DateTime.now().add(validatedMap[OTP_AUTH_PUSH_TTL_MINUTES] as Duration),
          rolloutState: validatedAdditionalData[ROLLOUT_STATE],
          isRolledOut: validatedAdditionalData[IS_ROLLED_OUT],
          enrollmentCredentials: validatedMap[OTP_AUTH_PUSH_ENROLLMENT_CREDENTIAL] as String?,
          url: validatedMap[OTP_AUTH_PUSH_ROLLOUT_URL] as Uri,
          tokenImage: validatedMap[OTP_AUTH_IMAGE] as String?,
          pin: validatedMap[OTP_AUTH_PIN] as bool?,
          isLocked: validatedMap[OTP_AUTH_PIN] as bool?,
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
          unlocalizedMessage: 'The piauth version [${validatedMap[OTP_AUTH_VERSION]}] is not supported by this version of the app.',
          invalidValue: validatedMap[OTP_AUTH_VERSION].toString(),
          name: 'piauth version',
        ),
    };
  }

  @override
  Token copyUpdateByTemplate(TokenTemplate template) {
    final uriMap = validateMap(
      map: template.otpAuthMap,
      validators: {
        OTP_AUTH_LABEL: const ObjectValidatorNullable<String>(),
        OTP_AUTH_ISSUER: const ObjectValidatorNullable<String>(),
        OTP_AUTH_SERIAL: const ObjectValidatorNullable<String>(),
        OTP_AUTH_PUSH_SSL_VERIFY: boolValidatorNullable,
        OTP_AUTH_PUSH_TTL_MINUTES: ObjectValidatorNullable<Duration>(
          transformer: (v) => Duration(minutes: int.parse(v)),
        ),
        OTP_AUTH_PUSH_ENROLLMENT_CREDENTIAL: const ObjectValidatorNullable<String>(),
        OTP_AUTH_PUSH_ROLLOUT_URL: stringToUriValidatorNullable,
        OTP_AUTH_IMAGE: stringToUriValidatorNullable,
        OTP_AUTH_PIN: boolValidator,
        OTP_AUTH_VERSION: stringToIntValidatorNullable,
      },
      name: 'PushToken',
    );

    return copyWith(
      label: uriMap[OTP_AUTH_LABEL] as String?,
      issuer: uriMap[OTP_AUTH_ISSUER] as String?,
      serial: uriMap[OTP_AUTH_SERIAL] as String?,
      sslVerify: uriMap[OTP_AUTH_PUSH_SSL_VERIFY] as bool?,
      expirationDate: uriMap[OTP_AUTH_PUSH_TTL_MINUTES] != null ? DateTime.now().add(uriMap[OTP_AUTH_PUSH_TTL_MINUTES] as Duration) : expirationDate,
      enrollmentCredentials: uriMap[OTP_AUTH_PUSH_ENROLLMENT_CREDENTIAL] as String?,
      url: uriMap[OTP_AUTH_PUSH_ROLLOUT_URL] as Uri?,
      tokenImage: uriMap[OTP_AUTH_IMAGE] as String?,
      pin: uriMap[OTP_AUTH_PIN] as bool?,
      isLocked: uriMap[OTP_AUTH_PIN] as bool?,
    );
  }

  /// This is used to create a map that typically was created from a uri.
  /// ```dart
  ///  ---------------------------- [Token] ----------------------------
  /// | OTP_AUTH_SERIAL: serial, (optional)                              |
  /// | OTP_AUTH_TYPE: type,                                             |
  /// | OTP_AUTH_LABEL: label,                                           |
  /// | OTP_AUTH_ISSUER: issuer,                                         |
  /// | OTP_AUTH_PIN: pin,                                               |
  /// | OTP_AUTH_IMAGE: tokenImage, (optional)                           |
  ///  ------------------------------------------------------------------
  ///  -------------------------- [PushToken] ---------------------------
  /// | OTP_AUTH_SSL_VERIFY: sslVerify,                                  |
  /// | OTP_AUTH_ROLLOUT_TTL_MINUTES: expirationDate, (optional)         |
  /// | OTP_AUTH_ENROLLMENT_CREDENTIAL: enrollmentCredentials, (optional)|
  /// | OTP_AUTH_ROLLOUT_URL: url, (optional)                            |
  /// | OTP_AUTH_IMAGE: tokenImage, (optional)                           |
  /// | OTP_AUTH_PIN: pin,                                               |
  /// | OTP_AUTH_VERSION: 1,                                             |
  ///  ------------------------------------------------------------------
  /// ```
  @override
  Map<String, dynamic> toOtpAuthMap() {
    return super.toOtpAuthMap()
      ..addAll({
        OTP_AUTH_PUSH_SSL_VERIFY: sslVerify ? OTP_AUTH_PUSH_SSL_VERIFY_TRUE : OTP_AUTH_PUSH_SSL_VERIFY_FALSE,
        if (expirationDate != null) OTP_AUTH_PUSH_TTL_MINUTES: expirationDate!.difference(DateTime.now()).inMinutes.toString(),
        if (enrollmentCredentials != null) OTP_AUTH_PUSH_ENROLLMENT_CREDENTIAL: enrollmentCredentials!,
        if (url != null) OTP_AUTH_PUSH_ROLLOUT_URL: url.toString(),
        if (tokenImage != null) OTP_AUTH_IMAGE: tokenImage!,
        OTP_AUTH_PIN: pin ? OTP_AUTH_PIN_TRUE : OTP_AUTH_PIN_FALSE,
        OTP_AUTH_VERSION: '1',
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
