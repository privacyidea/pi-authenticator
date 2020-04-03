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
import 'package:privacyidea_authenticator/model/custom_rsa_keys.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';

part 'tokens.g.dart';

abstract class Token {
  String _tokenVersion =
      "v1.0.0"; // The version of this token, this is used for serialization.
  String _label; // the name of the token, it cannot be uses as an identifier
  String _issuer; // The issuer of this token, currently unused.
  String _uuid; // this is the identifier of the token

  String get tokenVersion => _tokenVersion;

  String get label => _label;

  set label(String label) {
    this._label = label;
  }

  String get uuid => _uuid;

  String get issuer => _issuer;

  Token(this._label, this._issuer, this._uuid);

  @override
  String toString() {
    return 'Label $label | Issuer $issuer'
        ' | Version $tokenVersion | ID $uuid';
  }
}

abstract class OTPToken extends Token {
  Algorithms
      _algorithm; // the hashing algorithm that is used to calculate the otp value
  int _digits; // the number of digits the otp value will have
  List<int> _secret; // the secret based on which the otp value is calculated

  Algorithms get algorithm => _algorithm;

  int get digits => _digits;

  List<int> get secret => _secret;

  OTPToken(String label, String issuer, String uuid, this._algorithm,
      this._digits, this._secret)
      : super(label, issuer, uuid);

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
      String uuid,
      Algorithms algorithm,
      int digits,
      List<int> secret,
      int counter = 0})
      : this._counter = counter,
        super(label, issuer, uuid, algorithm, digits, secret);

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
      String uuid,
      Algorithms algorithm,
      int digits,
      List<int> secret,
      int period})
      : this._period = period,
        super(label, issuer, uuid, algorithm, digits, secret);

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
  String _firebaseToken;
  bool isRolledOut = false;

  // RSA keys
  SerializableRSAPublicKey _publicServerKey;
  SerializableRSAPrivateKey _privateTokenKey;

  set publicServerKey(RSAPublicKey key) =>
      _publicServerKey = SerializableRSAPublicKey(key.modulus, key.exponent);

  set privateTokenKey(RSAPrivateKey key) => _privateTokenKey =
      SerializableRSAPrivateKey(key.modulus, key.exponent, key.p, key.q);

  SerializableRSAPublicKey get publicServerKey => _publicServerKey;

  SerializableRSAPrivateKey get privateTokenKey => _privateTokenKey;

  bool hasPendingRequest = false;
  Uri requestUri;
  String requestNonce;
  bool requestSSLVerify = false;

  String get firebaseToken => _firebaseToken;

  DateTime _expirationDate;

  String get serial => _serial;

  bool get sslVerify => _sslVerify;

  String get enrollmentCredentials => _enrollmentCredentials;

  Uri get url => _url;

  DateTime get expirationDate => _expirationDate;

  PushToken({
    String label,
    String serial,
    String issuer,
    String uuid,
    // 2. step
    bool sslVerify,
    String enrollmentCredentials,
    Uri url,
    String firebaseToken,
    DateTime expirationDate,
  })  : this._serial = serial,
        this._sslVerify = sslVerify,
        this._enrollmentCredentials = enrollmentCredentials,
        this._url = url,
        this._firebaseToken = firebaseToken,
        this._expirationDate = expirationDate,
        super(label, issuer, uuid);

  // TODO update this method depending on isRolledOut
  @override
  String toString() {
    return super.toString() +
        ' | Type Push | Serial $serial | SSLVerify $sslVerify '
            '| Enrollment Credentials $enrollmentCredentials '
            '| URL $url | Firebase Token $firebaseToken '
            '| Time to die $expirationDate | Is rolled out $isRolledOut';
  }

  factory PushToken.fromJson(Map<String, dynamic> json) =>
      _$PushTokenFromJson(json);

  Map<String, dynamic> toJson() => _$PushTokenToJson(this);
}
