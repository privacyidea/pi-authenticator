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

import 'dart:typed_data';

import 'package:privacyidea_authenticator/utils/identifiers.dart';

// TODO refactor this to use the factory pattern instead?

abstract class Token {
  String _label; // the name of the token, it cannot be uses as an identifier
  String _serial; // this is the identifier of the secret
  Algorithms
      _algorithm; // the hashing algorithm that is used to calculate the otp value
  int _digits; // the number of digits the otp value will have
  Uint8List _secret; // the secret based on which the otp value is calculated

  String get label => _label;

  String get serial => _serial;

  Algorithms get algorithm => _algorithm;

  int get digits => _digits;

  Uint8List get secret => _secret;

  Token(this._label, this._serial, this._algorithm, this._digits, this._secret);

  @override
  String toString() {
    return 'Label $label | Serial $serial | Algorithm $algorithm | Digits $digits | Secret $secret';
  }
}

class HOTPToken extends Token {
  int _counter; // this value is used to calculate the current otp value

  int get counter => _counter;

  void incrementCounter() => _counter++;

  HOTPToken(String label, String serial, Algorithms algorithm, int digits,
      Uint8List secret,
      {int counter = 0})
      : this._counter = counter,
        super(label, serial, algorithm, digits, secret);

  @override
  String toString() {
    return super.toString() + ' | Type HOTP | Counter $counter';
  }
}

class TOTPToken extends Token {
  int _period; // this value is used to calculate the current 'counter' of this token
// based on the UNIX systemtime), the counter is used to calculate the current otp value

  int get period => _period;

  TOTPToken(String label, String serial, Algorithms algorithm, int digits,
      Uint8List secret, this._period)
      : super(label, serial, algorithm, digits, secret);

  @override
  String toString() {
    return super.toString() + ' | Type TOTP | Period $period';
  }
}
