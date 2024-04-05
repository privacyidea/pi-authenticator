import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uuid/uuid.dart';

import '../../utils/custom_int_buffer.dart';
import '../../utils/identifiers.dart';
import '../../utils/rsa_utils.dart';
import '../enums/push_token_rollout_state.dart';
import '../enums/token_types.dart';
import '../token_import/token_origin_data.dart';
import 'token.dart';

part 'push_token.g.dart';

@JsonSerializable()
class PushToken extends Token {
  static RsaUtils rsaParser = const RsaUtils();
  final DateTime? expirationDate;
  final String serial;
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
    required this.serial,
    super.label,
    super.issuer,
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
    super.sortIndex,
    super.tokenImage,
    super.folderId,
    super.pin,
    super.isLocked,
    super.isHidden,
    super.origin,
  })  : isRolledOut = isRolledOut ?? false,
        sslVerify = sslVerify ?? false,
        rolloutState = rolloutState ?? PushTokenRollOutState.rolloutNotStarted,
        super(type: TokenTypes.PIPUSH.name);

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
    String? id,
    String? tokenImage,
    String? fbToken,
    bool? pin,
    bool? isLocked,
    bool? isHidden,
    bool? sslVerify,
    String? enrollmentCredentials,
    Uri? url,
    int? sortIndex,
    String? publicServerKey,
    String? publicTokenKey,
    String? privateTokenKey,
    DateTime? expirationDate,
    bool? isRolledOut,
    PushTokenRollOutState? rolloutState,
    CustomIntBuffer? knownPushRequests,
    int? Function()? folderId,
    TokenOriginData? origin,
  }) {
    return PushToken(
      label: label ?? this.label,
      serial: serial ?? this.serial,
      issuer: issuer ?? this.issuer,
      tokenImage: tokenImage ?? this.tokenImage,
      fbToken: fbToken ?? this.fbToken,
      id: id ?? this.id,
      pin: pin ?? this.pin,
      isLocked: isLocked ?? this.isLocked,
      isHidden: isHidden ?? this.isHidden,
      sslVerify: sslVerify ?? this.sslVerify,
      enrollmentCredentials: enrollmentCredentials ?? this.enrollmentCredentials,
      url: url ?? this.url,
      sortIndex: sortIndex ?? this.sortIndex,
      publicServerKey: publicServerKey ?? this.publicServerKey,
      publicTokenKey: publicTokenKey ?? this.publicTokenKey,
      privateTokenKey: privateTokenKey ?? this.privateTokenKey,
      expirationDate: expirationDate ?? this.expirationDate,
      isRolledOut: isRolledOut ?? this.isRolledOut,
      rolloutState: rolloutState ?? this.rolloutState,
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
        'publicTokenKey: $publicTokenKey}';
  }

  factory PushToken.fromUriMap(Map<String, dynamic> uriMap) => PushToken(
        serial: uriMap[URI_SERIAL] ?? '',
        label: uriMap[URI_LABEL] ?? '',
        issuer: uriMap[URI_ISSUER] ?? '',
        id: const Uuid().v4(),
        sslVerify: uriMap[URI_SSL_VERIFY],
        expirationDate: uriMap[URI_TTL] != null ? DateTime.now().add(Duration(minutes: uriMap[URI_TTL])) : null,
        enrollmentCredentials: uriMap[URI_ENROLLMENT_CREDENTIAL],
        url: uriMap[URI_ROLLOUT_URL],
        tokenImage: uriMap[URI_IMAGE],
        pin: uriMap[URI_PIN],
        isLocked: uriMap[URI_PIN],
        origin: uriMap[URI_ORIGIN],
      );

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
