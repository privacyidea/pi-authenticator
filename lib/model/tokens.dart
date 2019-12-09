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

part 'tokens.g.dart';

abstract class Token {
  String _tokenVersion =
      "v1.0.0"; // The version of this token, this is used for serialization.
  String _label; // The name of the token, it cannot be uses as an identifier.
  String _serial; // This is the identifier of the secret.
  String
      _algorithm; // The hashing algorithm that is used to calculate the otp value.
  int _digits; // The number of digits the otp value will have.
  List<int> _secret; // The secret based on which the otp value is calculated.

  String get tokenVersion => _tokenVersion;

  String get label => _label;

  String get serial => _serial;

  String get algorithm => _algorithm;

  int get digits => _digits;

  List<int> get secret => _secret;

  Token(this._label, this._serial, this._algorithm, this._digits, this._secret);

  @override
  String toString() {
    return 'Label $label | Serial $serial | Algorithm $algorithm | Digits $digits | Secret $secret';
  }
}

@JsonSerializable()
class HOTPToken extends Token {
  int _counter; // this value is used to calculate the current otp value

  int get counter => _counter;

  void incrementCounter() => _counter++;

  HOTPToken(String label, String serial, String algorithm, int digits,
      List<int> secret,
      {int counter = 0})
      : this._counter = counter,
        super(label, serial, algorithm, digits, secret);

  @override
  String toString() {
    return super.toString() + ' | Type HOTP | Counter $counter';
  }

  factory HOTPToken.fromJson(Map<String, dynamic> json) =>
      _$HOTPTokenFromJson(json);

  Map<String, dynamic> toJson() => _$HOTPTokenToJson(this);
}

@JsonSerializable()
class TOTPToken extends Token {
  int _period; // this value is used to calculate the current 'counter' of this token
// based on the UNIX systemtime), the counter is used to calculate the current otp value

  int get period => _period;

  TOTPToken(String label, String serial, String algorithm, int digits,
      List<int> secret, int period)
      : this._period = period,
        super(label, serial, algorithm, digits, secret);

  @override
  String toString() {
    return super.toString() + ' | Type TOTP | Period $period';
  }

  factory TOTPToken.fromJson(Map<String, dynamic> json) =>
      _$TOTPTokenFromJson(json);

  Map<String, dynamic> toJson() => _$TOTPTokenToJson(this);
}
