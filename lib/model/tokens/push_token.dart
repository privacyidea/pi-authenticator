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
  final DateTime expirationDate;
  final String serial;

  // Roll out
  final bool? sslVerify;
  final String? enrollmentCredentials;
  final Uri? url; // Full access to allow adding to legacy android tokens
  final bool isRolledOut;

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

  // The get and set methods are needed for serialization.

  bool knowsRequestWithId(int id) {
    bool exists = pushRequests.any((element) => element.id == id);

    return knownPushRequests.contains(id) || exists;
  }

  PushToken({
    required String label,
    required this.serial,
    required String issuer,
    required String id,
    String? type,
    String? tokenImage,
    PushRequestQueue? pushRequests,
    bool isLocked = false,
    super.pin = false,
    // 2. step
    this.sslVerify,
    this.enrollmentCredentials,
    this.url,
    super.sortIndex,
    this.publicServerKey,
    this.publicTokenKey,
    this.privateTokenKey,
    required this.expirationDate,
    this.isRolledOut = false,
    CustomIntBuffer? knownPushRequests,
    int? categoryId,
    bool isInEditMode = false,
  })  : knownPushRequests = knownPushRequests ?? CustomIntBuffer(),
        super(
          label: label,
          issuer: issuer,
          id: id,
          isLocked: isLocked,
          tokenImage: tokenImage,
          type: type ?? enumAsString(TokenTypes.PIPUSH),
          categoryId: categoryId,
          isInEditMode: isInEditMode,
        ) {
    final now = DateTime.now();
    pushRequests?.removeWhere((request) => request.expirationDate.isBefore(now));
    this.pushRequests = pushRequests ?? PushRequestQueue();
  }

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
    // 2. step
    bool? sslVerify,
    String? enrollmentCredentials,
    Uri? url,
    int? sortIndex,
    String? publicServerKey,
    String? publicTokenKey,
    String? privateTokenKey,
    DateTime? expirationDate,
    bool? isRolledOut,
    CustomIntBuffer? knownPushRequests,
    int? Function()? categoryId,
    bool? isInEditMode,
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
      knownPushRequests: knownPushRequests ?? this.knownPushRequests,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      isInEditMode: isInEditMode ?? this.isInEditMode,
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
        'sortIndex: $sortIndex, '
        'pin: $pin, '
        'publicServerKey: $publicServerKey, '
        'privateTokenKey: $privateTokenKey, '
        'publicTokenKey: $publicTokenKey, '
        'pushRequests: $pushRequests, '
        'tokenImage: $tokenImage, '
        'knownPushRequests: $knownPushRequests}';
  }

  factory PushToken.fromUriMap(Map<String, dynamic> uriMap) => PushToken(
        serial: uriMap[URI_SERIAL],
        label: uriMap[URI_LABEL],
        issuer: uriMap[URI_ISSUER],
        id: const Uuid().v4(),
        sslVerify: uriMap[URI_SSL_VERIFY],
        expirationDate: DateTime.now().add(Duration(minutes: uriMap[URI_TTL])),
        enrollmentCredentials: uriMap[URI_ENROLLMENT_CREDENTIAL],
        url: uriMap[URI_ROLLOUT_URL],
        pin: uriMap[URI_PIN],
        tokenImage: uriMap[URI_IMAGE],
      );

  factory PushToken.fromJson(Map<String, dynamic> json) => _$PushTokenFromJson(json);

  Map<String, dynamic> toJson() => _$PushTokenToJson(this);
}
