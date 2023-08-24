import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uuid/uuid.dart';

import '../../utils/custom_int_buffer.dart';
import '../../utils/identifiers.dart';
import '../../utils/parsing_utils.dart';
import '../../utils/utils.dart';
import '../push_request.dart';
import '../push_request_queue.dart';
import 'token.dart';

part 'push_token.g.dart';

@JsonSerializable()
class PushToken extends Token {
  final DateTime? expirationDate;
  final String serial;

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
  RSAPublicKey? get rsaPublicServerKey => publicServerKey == null ? null : deserializeRSAPublicKeyPKCS1(publicServerKey!);
  PushToken withPublicServerKey(RSAPublicKey key) => copyWith(publicServerKey: serializeRSAPublicKeyPKCS1(key));
  RSAPublicKey? get rsaPublicTokenKey => publicTokenKey == null ? null : deserializeRSAPublicKeyPKCS1(publicTokenKey!);
  PushToken withPublicTokenKey(RSAPublicKey key) => copyWith(publicTokenKey: serializeRSAPublicKeyPKCS1(key));
  RSAPrivateKey? get rsaPrivateTokenKey => privateTokenKey == null ? null : deserializeRSAPrivateKeyPKCS1(privateTokenKey!);
  PushToken withPrivateTokenKey(RSAPrivateKey key) => copyWith(privateTokenKey: serializeRSAPrivateKeyPKCS1(key));

  PushToken withPushRequest(PushRequest pr) {
    pushRequests.add(pr);
    knownPushRequests.put(pr.id);
    return copyWith(pushRequests: pushRequests, knownPushRequests: knownPushRequests);
  }

  PushToken withoutPushRequest(PushRequest pr) {
    if (pushRequests.list.firstWhereOrNull((element) => element.id == pr.id) != null) {
      pushRequests.remove(pr);
    }
    return copyWith(pushRequests: pushRequests);
  }

  late final PushRequestQueue pushRequests;
  final CustomIntBuffer knownPushRequests;

  bool knowsRequestWithId(int id) {
    bool exists = pushRequests.any((element) => element.id == id);
    return exists || knownPushRequests.contains(id);
  }

  PushToken({
    required this.serial,
    required this.expirationDate,
    required super.label,
    required super.issuer,
    required super.id,
    this.enrollmentCredentials,
    this.url,
    this.publicServerKey,
    this.publicTokenKey,
    this.privateTokenKey,
    bool? isRolledOut,
    bool? sslVerify,
    PushTokenRollOutState? rolloutState,
    PushRequestQueue? pushRequests,
    CustomIntBuffer? knownPushRequests,
    String? type, // just for @JsonSerializable(): type of PushToken is always TokenTypes.PIPUSH
    super.sortIndex,
    super.tokenImage,
    super.folderId,
    super.isLocked,
    super.pin,
  })  : isRolledOut = isRolledOut ?? false,
        sslVerify = sslVerify ?? false,
        rolloutState = rolloutState ?? PushTokenRollOutState.rolloutNotStarted,
        knownPushRequests = knownPushRequests ?? CustomIntBuffer(),
        pushRequests = pushRequests ?? PushRequestQueue(),
        super(type: enumAsString(TokenTypes.PIPUSH));

  @override
  PushToken copyWith({
    String? label,
    String? serial,
    String? issuer,
    String? id,
    String? tokenImage,
    PushRequestQueue? pushRequests,
    bool? isLocked,
    bool? canToggleLock,
    bool? relock,
    bool? pin,
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
  }) {
    return PushToken(
      label: label ?? this.label,
      serial: serial ?? this.serial,
      issuer: issuer ?? this.issuer,
      tokenImage: tokenImage ?? this.tokenImage,
      id: id ?? this.id,
      pushRequests: pushRequests ?? this.pushRequests,
      isLocked: isLocked ?? this.isLocked,
      pin: pin ?? this.pin,
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
      knownPushRequests: knownPushRequests ?? this.knownPushRequests,
      folderId: folderId != null ? folderId() : this.folderId,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is PushToken && runtimeType == other.runtimeType && serial == other.serial;

  @override
  int get hashCode => serial.hashCode;

  @override
  String toString() {
    return 'Push${super.toString()}'
        'expirationDate: $expirationDate, '
        'serial: $serial, sslVerify: $sslVerify, '
        'enrollmentCredentials: $enrollmentCredentials, '
        'url: $url, isRolledOut: $isRolledOut, '
        'rolloutState: $rolloutState, '
        'sortIndex: $sortIndex, '
        'pin: $pin, '
        'publicServerKey: $publicServerKey, '
        'privateTokenKey: $privateTokenKey, '
        'publicTokenKey: $publicTokenKey, '
        'pushRequests: $pushRequests, '
        'tokenImage: $tokenImage, '
        'knownPushRequests: $knownPushRequests}';
  }

  factory PushToken.fromUriMap(Map<String, dynamic> uriMap) {
    PushToken pushToken;
    try {
      pushToken = PushToken(
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
      );
    } catch (e) {
      throw ArgumentError('Invalid URI: $e');
    }
    return pushToken;
  }

  factory PushToken.fromJson(Map<String, dynamic> json) {
    final newToken = _$PushTokenFromJson(json);
    newToken.pushRequests.removeWhere((request) => request.expirationDate.isBefore(DateTime.now()));
    final currentRolloutState = switch (newToken.rolloutState) {
      PushTokenRollOutState.rolloutNotStarted => PushTokenRollOutState.rolloutNotStarted,
      PushTokenRollOutState.generatingRSAKeyPair || PushTokenRollOutState.generatingRSAKeyPairFailed => PushTokenRollOutState.generatingRSAKeyPairFailed,
      PushTokenRollOutState.sendRSAPublicKey || PushTokenRollOutState.sendRSAPublicKeyFailed => PushTokenRollOutState.sendRSAPublicKeyFailed,
      PushTokenRollOutState.parsingResponse || PushTokenRollOutState.parsingResponseFailed => PushTokenRollOutState.parsingResponseFailed,
      PushTokenRollOutState.rolloutComplete => PushTokenRollOutState.rolloutComplete,
    };
    return newToken.copyWith(rolloutState: currentRolloutState);
  }

  Map<String, dynamic> toJson() => _$PushTokenToJson(this);
}
