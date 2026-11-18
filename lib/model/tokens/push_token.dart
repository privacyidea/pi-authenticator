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
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/api.dart' show PrivateKey, PublicKey;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/push_token_rollout_state_extension.dart';
import 'package:privacyidea_authenticator/utils/helpers/uuid_helper.dart';

import '../../../../../../../model/token_template.dart';
import '../../utils/ecc_utils.dart';
import '../../utils/logger.dart';
import '../../utils/object_validator/object_validators.dart';
import '../../utils/rsa_utils.dart';
import '../capabilities/capabilities.dart';
import '../enums/force_biometric_option.dart';
import '../enums/push_key_algorithm.dart';
import '../enums/push_token_rollout_state.dart';
import '../enums/token_types.dart';
import '../exception_errors/localized_argument_error.dart';
import '../extensions/date_time_extension.dart';
import '../token_import/token_origin_data.dart';
import 'token.dart';

part 'push_token.g.dart';

@JsonSerializable()
class PushToken extends Token {
  // --- Constants ---
  static RsaUtils rsaParser = const RsaUtils();
  static const EccUtils _eccParser = EccUtils();

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
  static const String KEY_ALGORITHM = 'key_algorithm';

  /// What the server can do at enrollment, sent only by servers that
  /// understand capabilities.
  static const String CAPABILITIES = 'capabilities';
  static const String EXPIRATION_DATE = 'expirationDate';
  static const String ROLLOUT_STATE = 'rolloutState';
  static const String IS_ROLLED_OUT = 'isRolledOut';
  static const String PUBLIC_SERVER_KEY = 'publicServerKey';
  static const String PRIVATE_TOKEN_KEY = 'privateTokenKey';
  static const String PUBLIC_TOKEN_KEY = 'publicTokenKey';

  /// The key algorithm the token was enrolled with. Lives in the additional
  /// data, never in the otpauth map, because that map goes to the server on a
  /// container sync and comes back as the base of the rebuilt token.
  static const String KEY_ALGORITHM_CHOSEN = 'keyAlgorithm';

  /// The capabilities of the enrollment link, kept with the token so a retry
  /// of the rollout after a restart answers the same way. Lives in the
  /// additional data, never in the otpauth map (see [KEY_ALGORITHM_CHOSEN]).
  static const String SERVER_CAPABILITIES = 'serverCapabilities';

  // --- Static Accessors & Validators ---
  static String get tokenType => TokenTypes.PIPUSH.name;

  static final Map<String, BaseValidator> otpAuthValidators = {
    ...Token.otpAuthValidators,
    Token.SERIAL: Validators.string,
    SSL_VERIFY: Validators.boolSafeTrue,
    IS_POLL_ONLY: Validators.boolOptional,
    TTL_MINUTES: Validators.minutesDuration.withDefault(
      const Duration(minutes: 3),
    ),
    ENROLLMENT_CREDENTIAL: Validators.stringOptional,
    ROLLOUT_URL: Validators.httpUri,
    VERSION: Validators.string,
    // The key algorithms the server wants, ordered by its preference. The
    // first one this app knows wins, none known or no list means RSA.
    KEY_ALGORITHM: OptionalObjectValidator<PushKeyAlgorithm>(
      transformer: (v) => v is PushKeyAlgorithm
          ? v
          : PushKeyAlgorithm.firstSupported(v as String?)!,
    ),
    // Never throws: a parameter that is present marks a server that knows
    // capabilities, even when its content cannot be read.
    CAPABILITIES: OptionalObjectValidator<Capabilities>(
      transformer: serverCapabilitiesFrom,
    ),
  };

  /// The capabilities of the enrollment link, [Capabilities.none] when they
  /// cannot be read. Entries this app does not know are kept.
  static Capabilities serverCapabilitiesFrom(Object? raw) {
    if (raw is Capabilities) return raw;
    try {
      final decoded = raw is String ? jsonDecode(raw) : raw;
      if (decoded is! Map) {
        throw FormatException('Expected a json object, got $decoded');
      }
      return Capabilities.fromJson(decoded);
    } catch (e, s) {
      Logger.warning(
        'The capabilities of the enrollment link cannot be read.',
        error: e,
        stackTrace: s,
      );
      return Capabilities.none;
    }
  }

  static final Map<String, BaseValidator> additionalDataValidators = {
    ...Token.additionalDataValidators,
    EXPIRATION_DATE: DateTimeX.validator.optional(),
    ROLLOUT_STATE: PushTokenRollOutStateX.optionalValidator.withDefault(
      PushTokenRollOutState.rolloutNotStarted,
    ),
    IS_ROLLED_OUT: Validators.boolSafeFalse,
    PUBLIC_SERVER_KEY: Validators.stringOptional,
    PUBLIC_TOKEN_KEY: Validators.stringOptional,
    PRIVATE_TOKEN_KEY: Validators.stringOptional,
    SERVER_CAPABILITIES: OptionalObjectValidator<Capabilities>(
      transformer: serverCapabilitiesFrom,
    ),
    KEY_ALGORITHM_CHOSEN: OptionalObjectValidator<PushKeyAlgorithm>(
      transformer: (v) => v is PushKeyAlgorithm
          ? v
          : PushKeyAlgorithm.values.firstWhere((a) => a.wireName == v),
    ),
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

  /// The algorithm of the token key and the server key. Both keys are of the
  /// same type, EC keys are stored as PEM. Tokens stored before this field
  /// existed load as RSA.
  @JsonKey(
    defaultValue: PushKeyAlgorithm.rsa4096,
    unknownEnumValue: PushKeyAlgorithm.rsa4096,
  )
  final PushKeyAlgorithm keyAlgorithm;

  /// What the server said it can do in the enrollment link, null if the link
  /// had no capabilities (a server that does not know them). Only used to
  /// answer the enrollment, never for challenges.
  @JsonKey(
    fromJson: _serverCapabilitiesFromJson,
    toJson: _serverCapabilitiesToJson,
  )
  final Capabilities? serverCapabilities;

  /// Loading never fails on a stored value that cannot be read, it becomes
  /// [Capabilities.none] and keeps the signal that the server knows them.
  static Capabilities? _serverCapabilitiesFromJson(Object? json) =>
      json == null ? null : serverCapabilitiesFrom(json);

  static String? _serverCapabilitiesToJson(Capabilities? capabilities) =>
      capabilities?.toCanonicalJson();

  @override
  String get serial => super.serial!;
  @override
  bool get isHidden => false;
  @override
  bool? get isPrivacyIdeaToken => true;

  bool get usesEcKey => keyAlgorithm == PushKeyAlgorithm.secp256r1;

  /// The type of the token key as shown in the token details, null while the
  /// token has no key.
  String? get keyTypeName {
    if (publicTokenKey == null) return null;
    if (usesEcKey) return 'ECDSA P-256';
    final bits = rsaPublicTokenKey?.modulus?.bitLength;
    return bits == null ? 'RSA' : 'RSA $bits';
  }

  // --- RSA Helpers ---
  RSAPublicKey? get rsaPublicServerKey => publicServerKey == null || usesEcKey
      ? null
      : rsaParser.deserializeRSAPublicKeyPKCS1(publicServerKey!);
  RSAPublicKey? get rsaPublicTokenKey => publicTokenKey == null || usesEcKey
      ? null
      : rsaParser.deserializeRSAPublicKeyPKCS1(publicTokenKey!);
  RSAPrivateKey? get rsaPrivateTokenKey => privateTokenKey == null || usesEcKey
      ? null
      : rsaParser.deserializeRSAPrivateKeyPKCS1(privateTokenKey!);

  // --- Key Helpers of either type ---
  PublicKey? get parsedPublicServerKey => usesEcKey
      ? (publicServerKey == null
            ? null
            : _eccParser.deserializeECPublicKey(publicServerKey!))
      : rsaPublicServerKey;
  PublicKey? get parsedPublicTokenKey => usesEcKey
      ? (publicTokenKey == null
            ? null
            : _eccParser.deserializeECPublicKey(publicTokenKey!))
      : rsaPublicTokenKey;
  PrivateKey? get parsedPrivateTokenKey => usesEcKey
      ? (privateTokenKey == null
            ? null
            : _eccParser.deserializeECPrivateKey(privateTokenKey!))
      : rsaPrivateTokenKey;

  PushToken withPublicServerKey(PublicKey key) =>
      copyWith(publicServerKey: _serializePublicKey(key));
  PushToken withPublicTokenKey(PublicKey key) =>
      copyWith(publicTokenKey: _serializePublicKey(key));
  PushToken withPrivateTokenKey(PrivateKey key) => copyWith(
    privateTokenKey: switch (key) {
      RSAPrivateKey() => rsaParser.serializeRSAPrivateKeyPKCS1(key),
      ECPrivateKey() => _eccParser.serializeECPrivateKey(key),
      _ => throw ArgumentError.value(key, 'key', 'Unsupported key type'),
    },
  );

  static String _serializePublicKey(PublicKey key) => switch (key) {
    RSAPublicKey() => rsaParser.serializeRSAPublicKeyPKCS1(key),
    ECPublicKey() => _eccParser.serializeECPublicKey(key),
    _ => throw ArgumentError.value(key, 'key', 'Unsupported key type'),
  };

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
    PushKeyAlgorithm? keyAlgorithm,
    this.serverCapabilities,
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
  }) : keyAlgorithm = keyAlgorithm ?? PushKeyAlgorithm.rsa4096,
       isRolledOut = isRolledOut ?? false,
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
      isLocked:
          validatedAdditionalData[Token.IS_LOCKED] as bool? ??
          validatedMap[Token.PIN] as bool?,
      isOffline: validatedMap[Token.OFFLINE] as bool,
      forceBiometricOption:
          validatedMap[Token.FORCE_BIOMETRIC_OPTION] as ForceBiometricOption,
      id: validatedAdditionalData[Token.ID] as String? ?? uuidV4(),
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
      serverCapabilities:
          validatedAdditionalData[SERVER_CAPABILITIES] as Capabilities? ??
          validatedMap[CAPABILITIES] as Capabilities?,
      keyAlgorithm:
          validatedAdditionalData[KEY_ALGORITHM_CHOSEN] as PushKeyAlgorithm? ??
          validatedMap[KEY_ALGORITHM] as PushKeyAlgorithm?,
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
      other.privateTokenKey == privateTokenKey &&
      other.keyAlgorithm == keyAlgorithm &&
      other.serverCapabilities == serverCapabilities;

  @override
  bool isSameTokenAs(Token other) {
    if (other is! PushToken) return false;

    final bool samePushCredentials =
        publicServerKey == other.publicServerKey &&
        publicTokenKey == other.publicTokenKey &&
        privateTokenKey == other.privateTokenKey &&
        enrollmentCredentials == other.enrollmentCredentials;
    if (!samePushCredentials) return false;

    return super.isSameTokenAs(other) ?? true;
  }

  @override
  PushToken copyWith({
    String? label,
    String? Function()? serial,
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
    PushKeyAlgorithm? keyAlgorithm,
    Capabilities? Function()? serverCapabilities,
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
  }) {
    final String? newSerial = serial?.call();
    return PushToken(
      label: label ?? this.label,
      serial: newSerial ?? this.serial,
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
      keyAlgorithm: keyAlgorithm ?? this.keyAlgorithm,
      serverCapabilities: serverCapabilities != null
          ? serverCapabilities()
          : this.serverCapabilities,
      enrollmentCredentials:
          enrollmentCredentials ?? this.enrollmentCredentials,
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
  }

  @override
  Token copyUpdateByTemplate(TokenTemplate template) {
    final uriMap = validateOtpAuthMap(template.otpAuthMap);
    return copyWith(
      label: uriMap[Token.LABEL] as String?,
      issuer: uriMap[Token.ISSUER] as String?,
      serial: () => uriMap[Token.SERIAL] as String?,
      sslVerify: uriMap[SSL_VERIFY] as bool?,
      isPollOnly: uriMap[IS_POLL_ONLY] != null
          ? () => (uriMap[IS_POLL_ONLY] as bool)
          : () => isPollOnly,
      enrollmentCredentials: uriMap[ENROLLMENT_CREDENTIAL] as String?,
      url: uriMap[ROLLOUT_URL] as Uri?,
      tokenImage: uriMap[Token.IMAGE] as String?,
      pin: uriMap[Token.PIN] as bool?,
      isLocked: Token.lockAfterServerPin(
        serverPin: uriMap[Token.PIN] as bool?,
        hadPin: pin,
      ),
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
      KEY_ALGORITHM_CHOSEN: keyAlgorithm.wireName,
      SERVER_CAPABILITIES: serverCapabilities?.toCanonicalJson(),
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
