// TODO add license

import 'dart:typed_data';

// TODO refactor this to use the factory pattern instead?

abstract class Token {
  String _label; // the name of the token, it cannot be uses as an identifier
  String _serial; // this is the identifier of the secret
  String
      _algorithm; // the hashing algorithm that is used to calculate the otp value
  int _digits; // the number of digits the otp value will have
  Uint8List _secret; // the secret based on which the otp value is calculated

  String get label => _label;

  String get serial => _serial;

  String get algorithm => _algorithm;

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

  HOTPToken(String label, String serial, String algorithm, int digits,
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

  TOTPToken(String label, String serial, String algorithm, int digits,
      Uint8List secret, this._period)
      : super(label, serial, algorithm, digits, secret);

  @override
  String toString() {
    return super.toString() + ' | Type TOTP | Period $period';
  }
}
