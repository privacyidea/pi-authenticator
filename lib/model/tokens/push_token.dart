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

import '../../utils/custom_int_buffer.dart';
import '../../utils/errors.dart';
import '../../utils/identifiers.dart';
import '../../utils/logger.dart';
import '../../utils/rsa_utils.dart';
import '../enums/push_token_rollout_state.dart';
import '../enums/token_types.dart';
import '../token_container.dart';
import '../token_import/token_origin_data.dart';
import 'token.dart';

part 'push_token.g.dart';

@JsonSerializable()
class PushToken extends Token {
  static RsaUtils rsaParser = const RsaUtils();
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
    String? type, // just for @JsonSerializable(): type of PushToken is always TokenTypes.PIPUSH
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
        super(type: TokenTypes.PIPUSH.name, serial: serial);

  @override
  bool sameValuesAs(Token other) {
    return super.sameValuesAs(other) &&
        other is PushToken &&
        other.fbToken == fbToken &&
        other.expirationDate == expirationDate &&
        other.sslVerify == sslVerify &&
        other.enrollmentCredentials == enrollmentCredentials &&
        other.url == url &&
        other.isRolledOut == isRolledOut;
  }

  @override
  bool isSameTokenAs(Token other) {
    return super.isSameTokenAs(other) &&
        other is PushToken &&
        other.serial == serial &&
        other.privateTokenKey == privateTokenKey &&
        other.publicTokenKey == publicTokenKey &&
        other.publicServerKey == publicServerKey;
  }

  @override
  PushToken copyWith({
    String? label,
    String? serial,
    String? issuer,
    String? Function()? containerSerial,
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

  @override
  PushToken copyWithFromTemplate(TokenTemplate template) {
    final uriMap = template.data;
    return copyWith(
      label: uriMap[URI_LABEL],
      issuer: uriMap[URI_ISSUER],
      id: uriMap[URI_ID],
      serial: uriMap[URI_SERIAL],
      sslVerify: uriMap[URI_SSL_VERIFY],
      enrollmentCredentials: uriMap[URI_ENROLLMENT_CREDENTIAL],
      url: uriMap[URI_ROLLOUT_URL],
      tokenImage: uriMap[URI_IMAGE],
      pin: uriMap[URI_PIN],
      isLocked: uriMap[URI_PIN],
      origin: uriMap[URI_ORIGIN],
      // do not update expirationDate
    );
  }

  factory PushToken.fromUriMap(Map<String, dynamic> uriMap) {
    validateUriMap(uriMap);
    return PushToken(
      label: uriMap[URI_LABEL] ?? '',
      issuer: uriMap[URI_ISSUER] ?? '',
      id: uriMap[URI_ID] == String ? uriMap[URI_ID] : const Uuid().v4(),
      serial: uriMap[URI_SERIAL],
      sslVerify: uriMap[URI_SSL_VERIFY],
      expirationDate: uriMap[URI_TTL] != null ? DateTime.now().add(Duration(minutes: uriMap[URI_TTL])) : null,
      enrollmentCredentials: uriMap[URI_ENROLLMENT_CREDENTIAL],
      url: uriMap[URI_ROLLOUT_URL],
      tokenImage: uriMap[URI_IMAGE],
      pin: uriMap[URI_PIN],
      isLocked: uriMap[URI_PIN],
      origin: uriMap[URI_ORIGIN],
    );
  }

  static void validateUriMap(Map<String, dynamic> uriMap) {
    uriMap = Map<String, dynamic>.from(uriMap);
    if (uriMap[URI_TYPE]?.toUpperCase() != TokenTypes.PIPUSH.name.toUpperCase()) {
      throw ArgumentError('Invalid type: ${uriMap[URI_TYPE]}');
    }
    uriMap.remove(URI_TYPE);
    if (uriMap[URI_LABEL] is! String?) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Invalid value ${uriMap[URI_LABEL]} for parameter $URI_LABEL',
        invalidValue: uriMap[URI_LABEL],
        name: URI_LABEL,
      );
    }
    uriMap.remove(URI_LABEL);
    if (uriMap[URI_ISSUER] is! String?) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Invalid value ${uriMap[URI_ISSUER]} for parameter $URI_ISSUER',
        invalidValue: uriMap[URI_ISSUER],
        name: URI_ISSUER,
      );
    }
    uriMap.remove(URI_ISSUER);
    if (uriMap[URI_ID] is! String?) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Invalid value ${uriMap[URI_ID]} for parameter $URI_ID',
        invalidValue: uriMap[URI_ID],
        name: URI_ID,
      );
    }
    uriMap.remove(URI_ID);
    if (uriMap[URI_SERIAL] is! String) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Invalid value ${uriMap[URI_SERIAL]} for parameter $URI_SERIAL',
        invalidValue: uriMap[URI_SERIAL],
        name: URI_SERIAL,
      );
    }
    uriMap.remove(URI_SERIAL);
    if (uriMap[URI_SSL_VERIFY] is! bool) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Invalid value ${uriMap[URI_SSL_VERIFY]} for parameter $URI_SSL_VERIFY',
        invalidValue: uriMap[URI_SSL_VERIFY],
        name: URI_SSL_VERIFY,
      );
    }
    uriMap.remove(URI_SSL_VERIFY);
    /**

      expirationDate: uriMap[URI_TTL] != null ? DateTime.now().add(Duration(minutes: uriMap[URI_TTL])) : null,
      enrollmentCredentials: uriMap[URI_ENROLLMENT_CREDENTIAL],
      url: uriMap[URI_ROLLOUT_URL],
      tokenImage: uriMap[URI_IMAGE],
      pin: uriMap[URI_PIN],
      isLocked: uriMap[URI_PIN],
      origin: uriMap[URI_ORIGIN],
     */
    if (uriMap[URI_TTL] is! int?) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Invalid value ${uriMap[URI_TTL]} for parameter $URI_TTL',
        invalidValue: uriMap[URI_TTL],
        name: URI_TTL,
      );
    }
    uriMap.remove(URI_TTL);
    if (uriMap[URI_ENROLLMENT_CREDENTIAL] is! String?) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Invalid value ${uriMap[URI_ENROLLMENT_CREDENTIAL]} for parameter $URI_ENROLLMENT_CREDENTIAL',
        invalidValue: uriMap[URI_ENROLLMENT_CREDENTIAL],
        name: URI_ENROLLMENT_CREDENTIAL,
      );
    }
    uriMap.remove(URI_ENROLLMENT_CREDENTIAL);
    if (uriMap[URI_ROLLOUT_URL] is! Uri?) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Invalid value ${uriMap[URI_ROLLOUT_URL]} for parameter $URI_ROLLOUT_URL',
        invalidValue: uriMap[URI_ROLLOUT_URL],
        name: URI_ROLLOUT_URL,
      );
    }
    uriMap.remove(URI_ROLLOUT_URL);
    if (uriMap[URI_IMAGE] is! String?) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Invalid value ${uriMap[URI_IMAGE]} for parameter $URI_IMAGE',
        invalidValue: uriMap[URI_IMAGE],
        name: URI_IMAGE,
      );
    }
    uriMap.remove(URI_IMAGE);
    if (uriMap[URI_PIN] is! bool?) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Invalid value ${uriMap[URI_PIN]} for parameter $URI_PIN',
        invalidValue: uriMap[URI_PIN],
        name: URI_PIN,
      );
    }
    uriMap.remove(URI_PIN);
    if (uriMap[URI_ORIGIN] is! TokenOriginData?) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter),
        unlocalizedMessage: 'Invalid value ${uriMap[URI_ORIGIN]} for parameter $URI_ORIGIN',
        invalidValue: uriMap[URI_ORIGIN],
        name: URI_ORIGIN,
      );
    }
    uriMap.remove(URI_ORIGIN);
    if (uriMap.isNotEmpty) {
      Logger.warning('Unknown parameters in uriMap: $uriMap');
    }
  }

  @override
  Map<String, dynamic> toUriMap() {
    return super.toUriMap()
      ..addAll({
        URI_SERIAL: serial,
        URI_SSL_VERIFY: sslVerify,
        if (expirationDate != null) URI_TTL: expirationDate!.difference(DateTime.now()).inMinutes,
        if (enrollmentCredentials != null) URI_ENROLLMENT_CREDENTIAL: enrollmentCredentials,
        if (url != null) URI_ROLLOUT_URL: url.toString(),
      });
  }

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
