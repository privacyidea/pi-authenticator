import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uuid/uuid.dart';

import '../../utils/custom_int_buffer.dart';
import '../../utils/identifiers.dart';
import '../../utils/rsa_utils.dart';
import '../enums/push_token_rollout_state.dart';
import '../enums/token_types.dart';
import '../push_request.dart';
import '../push_request_queue.dart';
import 'token.dart';

part 'push_token.g.dart';

@JsonSerializable()
class PushToken extends Token {
  static RsaUtils rsaParser = const RsaUtils();
  final DateTime? expirationDate;
  final String serial;

  Duration get showDuration => Duration.zero;

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
    required super.label,
    required super.issuer,
    required super.id,
    this.url,
    this.expirationDate,
    this.enrollmentCredentials,
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
    super.pin,
    super.isLocked,
    super.isHidden,
  })  : isRolledOut = isRolledOut ?? false,
        sslVerify = sslVerify ?? false,
        rolloutState = rolloutState ?? PushTokenRollOutState.rolloutNotStarted,
        knownPushRequests = knownPushRequests ?? CustomIntBuffer(),
        pushRequests = pushRequests ?? PushRequestQueue(),
        super(type: TokenTypes.PIPUSH.asString);

  @override
  PushToken copyWith({
    String? label,
    String? serial,
    String? issuer,
    String? id,
    String? tokenImage,
    PushRequestQueue? pushRequests,
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
  }) {
    return PushToken(
      label: label ?? this.label,
      serial: serial ?? this.serial,
      issuer: issuer ?? this.issuer,
      tokenImage: tokenImage ?? this.tokenImage,
      id: id ?? this.id,
      pushRequests: pushRequests ?? this.pushRequests,
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
    return 'Push${super.toString()} '
        'expirationDate: $expirationDate, '
        'serial: $serial, '
        'sslVerify: $sslVerify, '
        'enrollmentCredentials: $enrollmentCredentials, '
        'url: $url, '
        'isRolledOut: $isRolledOut, '
        'rolloutState: $rolloutState, '
        'publicServerKey: $publicServerKey, '
        'publicTokenKey: $publicTokenKey, '
        'pushRequests: $pushRequests, '
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
    return newToken.copyWith(rolloutState: currentRolloutState, isHidden: true);
  }

  Map<String, dynamic> toJson() => _$PushTokenToJson(this);
}
