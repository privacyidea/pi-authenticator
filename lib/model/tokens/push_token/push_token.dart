import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/model/push_request_queue.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/custom_int_buffer.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/parsing_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

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
  final int? sortIndex;
  final bool? pin;

  // RSA keys - String values for backward compatibility with serialization
  final String? publicServerKey;
  final String? privateTokenKey;
  final String? publicTokenKey;

  // Custom getter and setter for RSA keys
  RSAPublicKey? get RSAPublicServerKey => publicServerKey == null ? null : deserializeRSAPublicKeyPKCS1(publicServerKey!);
  PushToken withPublicServerKey(RSAPublicKey key) => this.copyWith(publicServerKey: serializeRSAPublicKeyPKCS1(key));
  RSAPublicKey? get RSAPublicTokenKey => publicTokenKey == null ? null : deserializeRSAPublicKeyPKCS1(publicTokenKey!);
  PushToken withPublicTokenKey(RSAPublicKey key) => this.copyWith(publicTokenKey: serializeRSAPublicKeyPKCS1(key));
  RSAPrivateKey? get RSAPrivateTokenKey => privateTokenKey == null ? null : deserializeRSAPrivateKeyPKCS1(privateTokenKey!);
  PushToken withPrivateTokenKey(RSAPrivateKey key) => this.copyWith(privateTokenKey: serializeRSAPrivateKeyPKCS1(key));

  final PushRequestQueue pushRequests;
  final String? tokenImage;
  CustomIntBuffer? _knownPushRequests;

  // The get and set methods are needed for serialization.
  CustomIntBuffer get knownPushRequests {
    _knownPushRequests ??= CustomIntBuffer();
    return _knownPushRequests!;
  }

  set knownPushRequests(CustomIntBuffer buffer) {
    if (_knownPushRequests != null) {
      throw ArgumentError('Initializing [knownPushRequests] in [PushToken] is only allowed once.');
    }

    this._knownPushRequests = buffer;
  }

  bool knowsRequestWithId(int id) {
    bool exists = pushRequests.any((element) => element.id == id);

    return this.knownPushRequests.contains(id) || exists;
  }

  PushToken({
    required String label,
    required String serial,
    required String issuer,
    required String id,
    String? type,
    String? imageURL,
    PushRequestQueue? pushRequests,
    bool isLocked = false,
    bool? pin = false,
    // 2. step
    bool? sslVerify,
    this.enrollmentCredentials,
    Uri? url,
    int? sortIndex,
    String? tokenImage,
    String? publicServerKey,
    String? publicTokenKey,
    String? privateTokenKey,
    required DateTime expirationDate,
    bool isRolledOut = false,
  })  : this.pushRequests = pushRequests ?? PushRequestQueue(),
        this.publicServerKey = publicServerKey,
        this.publicTokenKey = publicTokenKey,
        this.privateTokenKey = privateTokenKey,
        this.serial = serial,
        this.sslVerify = sslVerify,
        this.expirationDate = expirationDate,
        this.sortIndex = sortIndex,
        this.url = url,
        this.tokenImage = tokenImage,
        this.pin = pin,
        this.isRolledOut = isRolledOut,
        super(
          label: label,
          issuer: issuer,
          id: id,
          isLocked: isLocked,
          imageURL: imageURL,
          type: type ?? enumAsString(TokenTypes.PIPUSH),
        );

  @override
  PushToken copyWith({
    String? label,
    String? serial,
    String? issuer,
    String? id,
    String? imageURL,
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
    String? tokenImage,
    String? publicServerKey,
    String? publicTokenKey,
    String? privateTokenKey,
    DateTime? expirationDate,
    bool? isRolledOut,
  }) {
    return PushToken(
      label: label ?? this.label,
      serial: serial ?? this.serial,
      issuer: issuer ?? this.issuer,
      imageURL: imageURL ?? this.imageURL,
      id: id ?? this.id,
      pushRequests: pushRequests ?? this.pushRequests,
      isLocked: isLocked ?? this.isLocked,
      pin: pin ?? this.pin,
      sslVerify: sslVerify ?? this.sslVerify,
      enrollmentCredentials: enrollmentCredentials ?? this.enrollmentCredentials,
      url: url ?? this.url,
      sortIndex: sortIndex ?? this.sortIndex,
      tokenImage: tokenImage ?? this.tokenImage,
      publicServerKey: publicServerKey,
      publicTokenKey: publicTokenKey,
      privateTokenKey: privateTokenKey,
      expirationDate: expirationDate ?? this.expirationDate,
      isRolledOut: isRolledOut ?? this.isRolledOut,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is PushToken && runtimeType == other.runtimeType && serial == other.serial;

  @override
  int get hashCode => serial.hashCode;

  @override
  String toString() {
    return 'PushToken{_serial: $serial, _sslVerify: $sslVerify, '
        '_enrollmentCredentials: $enrollmentCredentials, url: $url, '
        'isRolledOut: $isRolledOut, publicServerKey: $publicServerKey, '
        'privateTokenKey: $privateTokenKey, publicTokenKey: $publicTokenKey, '
        '_pushRequests: $pushRequests, _expirationDate: $expirationDate},'
        'id: $id';
  }

  factory PushToken.fromJson(Map<String, dynamic> json) => _$PushTokenFromJson(json);

  Map<String, dynamic> toJson() => _$PushTokenToJson(this);
}
