/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/parsing_utils.dart';

part 'tokens.g.dart';

abstract class Token {
  String _tokenVersion =
      "v1.0.0"; // The version of this token, this is used for serialization.
  String _label; // the name of the token, it cannot be uses as an identifier
  String _issuer; // The issuer of this token, currently unused.
  String _id; // this is the identifier of the token

  String get tokenVersion => _tokenVersion;

  String get label => _label;

  set label(String label) {
    this._label = label;
  }

  String get id => _id;

  String get issuer => _issuer;

  Token(this._label, this._issuer, this._id);

  @override
  String toString() {
    return 'Label $label | Issuer $issuer'
        ' | Version $tokenVersion | ID $id';
  }
}

abstract class OTPToken extends Token {
  Algorithms
      _algorithm; // the hashing algorithm that is used to calculate the otp value
  int _digits; // the number of digits the otp value will have
  String
      _secret; // the secret based on which the otp value is calculated in base32

  Algorithms get algorithm => _algorithm;

  int get digits => _digits;

  String get secret => _secret;

  OTPToken(String label, String issuer, String id, this._algorithm,
      this._digits, this._secret)
      : super(label, issuer, id);

  @override
  String toString() {
    return super.toString() +
        ' | Algorithm $algorithm | Digits $digits | Secret $secret';
  }
}

@JsonSerializable()
class HOTPToken extends OTPToken {
  int _counter; // this value is used to calculate the current otp value

  int get counter => _counter;

  void incrementCounter() => _counter++;

  HOTPToken(
      {String label,
      String issuer,
      String id,
      Algorithms algorithm,
      int digits,
      String secret,
      int counter = 0})
      : this._counter = counter,
        super(label, issuer, id, algorithm, digits, secret);

  @override
  String toString() {
    return super.toString() + ' | Type HOTP | Counter $counter';
  }

  factory HOTPToken.fromJson(Map<String, dynamic> json) =>
      _$HOTPTokenFromJson(json);

  Map<String, dynamic> toJson() => _$HOTPTokenToJson(this);
}

@JsonSerializable()
class TOTPToken extends OTPToken {
  int _period;

  // this value is used to calculate the current 'counter' of this token
  // based on the UNIX systemtime), the counter is used to calculate the
  // current otp value

  int get period => _period;

  TOTPToken(
      {String label,
      String issuer,
      String id,
      Algorithms algorithm,
      int digits,
      String secret,
      int period})
      : this._period = period,
        super(label, issuer, id, algorithm, digits, secret);

  @override
  String toString() {
    return super.toString() + ' | Type TOTP | Period $period';
  }

  factory TOTPToken.fromJson(Map<String, dynamic> json) =>
      _$TOTPTokenFromJson(json);

  Map<String, dynamic> toJson() => _$TOTPTokenToJson(this);
}

@JsonSerializable()
class PushToken extends Token {
  String _serial;

  // Roll out
  bool _sslVerify;
  String _enrollmentCredentials;
  Uri _url;
  bool isRolledOut = false;

  // RSA keys - String values for backward compatibility with serialization
  String publicServerKey;
  String privateTokenKey;
  String publicTokenKey;

  // Custom getter and setter for RSA keys
  RSAPublicKey getPublicServerKey() =>
      deserializeRSAPublicKeyPKCS1(publicServerKey);

  RSAPublicKey getPublicTokenKey() =>
      deserializeRSAPublicKeyPKCS1(publicTokenKey);

  RSAPrivateKey getPrivateTokenKey() =>
      deserializeRSAPrivateKeyPKCS1(privateTokenKey);

  void setPublicServerKey(RSAPublicKey key) =>
      publicServerKey = serializeRSAPublicKeyPKCS1(key);

  void setPublicTokenKey(RSAPublicKey key) =>
      publicTokenKey = serializeRSAPublicKeyPKCS1(key);

  void setPrivateTokenKey(RSAPrivateKey key) =>
      privateTokenKey = serializeRSAPrivateKeyPKCS1(key);

  PushRequestQueue _pushRequests;

  DateTime _expirationDate;

  String get serial => _serial;

  bool get sslVerify => _sslVerify;

  String get enrollmentCredentials => _enrollmentCredentials;

  Uri get url => _url;

  DateTime get expirationDate => _expirationDate;

  // The get and set methods are needed for serialization.
  PushRequestQueue get pushRequests {
    _pushRequests ??= PushRequestQueue();
    return _pushRequests;
  }

  set pushRequests(PushRequestQueue queue) {
    if (_pushRequests != null) {
      throw ArgumentError(
          "Initializing [pushRequests] in [PushToken] is only allowed once.");
    }

    this._pushRequests = queue;
  }

  CustomIntBuffer _knownPushRequests;

  // The get and set methods are needed for serialization.
  CustomIntBuffer get knownPushRequests {
    _knownPushRequests ??= CustomIntBuffer();
    return _knownPushRequests;
  }

  set knownPushRequests(CustomIntBuffer buffer) {
    if (_knownPushRequests != null) {
      throw ArgumentError(
          "Initializing [knownPushRequests] in [PushToken] is only allowed once.");
    }

    this._knownPushRequests = buffer;
  }

  bool knowsRequestWithId(int id) {
    bool exists = pushRequests.any((element) => element.id == id);

    return this.knownPushRequests.contains(id) || exists;
  }

  PushToken({
    String label,
    String serial,
    String issuer,
    String id,
    // 2. step
    bool sslVerify,
    String enrollmentCredentials,
    Uri url,
    DateTime expirationDate,
  })  : this._serial = serial,
        this._sslVerify = sslVerify,
        this._enrollmentCredentials = enrollmentCredentials,
        this._url = url,
        this._expirationDate = expirationDate,
        super(label, issuer, id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushToken &&
          runtimeType == other.runtimeType &&
          _serial == other._serial;

  @override
  int get hashCode => _serial.hashCode;

  @override
  String toString() {
    return 'PushToken{_serial: $_serial, _sslVerify: $_sslVerify, '
        '_enrollmentCredentials: $_enrollmentCredentials, _url: $_url, '
        'isRolledOut: $isRolledOut, publicServerKey: $publicServerKey, '
        'privateTokenKey: $privateTokenKey, publicTokenKey: $publicTokenKey, '
        '_pushRequests: $_pushRequests, _expirationDate: $_expirationDate}';
  }

  factory PushToken.fromJson(Map<String, dynamic> json) =>
      _$PushTokenFromJson(json);

  Map<String, dynamic> toJson() => _$PushTokenToJson(this);
}

@JsonSerializable()
class PushRequest {
  String _title;
  String _question;

  int _id;

  Uri _uri;
  String _nonce;
  bool _sslVerify;

  DateTime _expirationDate;

  DateTime get expirationDate => _expirationDate;

  int get id => _id;

  String get nonce => _nonce;

  bool get sslVerify => _sslVerify;

  Uri get uri => _uri;

  String get question => _question;

  String get title => _title;

  PushRequest(String title, String question, Uri uri, String nonce,
      bool sslVerify, int id,
      {DateTime expirationDate})
      : this._title = title,
        this._question = question,
        this._uri = uri,
        this._nonce = nonce,
        this._sslVerify = sslVerify,
        this._id = id,
        this._expirationDate = expirationDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushRequest &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    return 'PushRequest{_title: $_title, _question: $_question,'
        ' _id: $_id, _uri: $_uri, _nonce: $_nonce, _sslVerify: $_sslVerify}';
  }

  factory PushRequest.fromJson(Map<String, dynamic> json) =>
      _$PushRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PushRequestToJson(this);
}

@JsonSerializable()
class PushRequestQueue {
  PushRequestQueue();

  List<PushRequest> _list;

  // The get and set methods are needed for serialization.
  List<PushRequest> get list {
    _list ??= List();
    return _list;
  }

  set list(List<PushRequest> l) {
    if (_list != null) {
      throw ArgumentError(
          "Initializing [list] in [PushRequestQueue] is only allowed once.");
    }

    this._list = l;
  }

  int get length => list.length;

  void removeWhere(bool f(PushRequest request)) => list.removeWhere(f);

  Iterable<PushRequest> where(bool f(PushRequest element)) => _list.where(f);

  bool any(bool f(PushRequest element)) => _list.any(f);

  void remove(PushRequest request) => _list.remove(request);

  bool get isEmpty => list.isEmpty;

  bool get isNotEmpty => list.isNotEmpty;

  bool contains(PushRequest r) => _list.contains(r);

  void add(PushRequest pushRequest) => list.add(pushRequest);

  PushRequest peek() => list.first;

  PushRequest pop() => list.removeAt(0);

  @override
  String toString() {
    return 'PushRequestQueue{_list: $list}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushRequestQueue &&
          runtimeType == other.runtimeType &&
          _listsAreEqual(list, other.list);

  bool _listsAreEqual(List<PushRequest> l1, List<PushRequest> l2) {
    if (l1.length != l2.length) return false;

    for (int i = 0; i < l1.length - 1; i++) {
      if (l1[i] != l2[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode => list.hashCode;

  factory PushRequestQueue.fromJson(Map<String, dynamic> json) =>
      _$PushRequestQueueFromJson(json);

  Map<String, dynamic> toJson() => _$PushRequestQueueToJson(this);
}

@JsonSerializable()
class SerializableRSAPublicKey extends RSAPublicKey {
  SerializableRSAPublicKey(BigInt modulus, BigInt exponent)
      : super(modulus, exponent);

  factory SerializableRSAPublicKey.fromJson(Map<String, dynamic> json) =>
      _$SerializableRSAPublicKeyFromJson(json);

  Map<String, dynamic> toJson() => _$SerializableRSAPublicKeyToJson(this);
}

@JsonSerializable()
class SerializableRSAPrivateKey extends RSAPrivateKey {
  SerializableRSAPrivateKey(BigInt modulus, BigInt exponent, BigInt p, BigInt q)
      : super(modulus, exponent, p, q);

  factory SerializableRSAPrivateKey.fromJson(Map<String, dynamic> json) =>
      _$SerializableRSAPrivateKeyFromJson(json);

  Map<String, dynamic> toJson() => _$SerializableRSAPrivateKeyToJson(this);
}

@JsonSerializable()
class CustomIntBuffer {
  final int maxSize = 20;

//  CustomIntBuffer(int maxSize)
//      : assert(maxSize >= 1),
//        this.maxSize = maxSize,
//        _list = List();

  CustomIntBuffer();

  List<int> _list;

  // The get and set methods are needed for serialization.
  List<int> get list {
    _list ??= List();
    return _list;
  }

  set list(List<int> l) {
    if (_list != null) {
      throw ArgumentError(
          "Initializing [list] in [CustomStringBuffer] is only allowed once.");
    }

    if (l.length > maxSize) {
      throw ArgumentError(
          'The list $l is to long for a buffer of size $maxSize');
    }

    this._list = l;
  }

  void put(int value) {
    if (_list.length >= maxSize) list.removeAt(0);
    _list.add(value);
  }

  int get length => _list.length;

  bool contains(int value) => _list.contains(value);

  factory CustomIntBuffer.fromJson(Map<String, dynamic> json) =>
      _$CustomIntBufferFromJson(json);

  Map<String, dynamic> toJson() => _$CustomIntBufferToJson(this);
}
