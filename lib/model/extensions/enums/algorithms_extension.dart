import 'package:otp/otp.dart';

import '../../enums/algorithms.dart';

extension AlgorithmsX on Algorithms {
  /// Generates a Time-based one time password code and return as a 0 padded string.
  /// DateTime should be the current time.
  /// Ig isGoogle is true, the secret will be decoded as base32, otherwise it will be decoded as utf8.
  String generateTOTPCodeString({
    required String secret,
    required DateTime time,
    required int length,
    required Duration interval,
    bool isGoogle = true,
  }) =>
      switch (this) {
        Algorithms.SHA1 => OTP.generateTOTPCodeString(secret, time.millisecondsSinceEpoch,
            length: length, interval: interval.inSeconds, algorithm: Algorithm.SHA1, isGoogle: isGoogle),
        Algorithms.SHA256 => OTP.generateTOTPCodeString(secret, time.millisecondsSinceEpoch,
            length: length, interval: interval.inSeconds, algorithm: Algorithm.SHA256, isGoogle: isGoogle),
        Algorithms.SHA512 => OTP.generateTOTPCodeString(secret, time.millisecondsSinceEpoch,
            length: length, interval: interval.inSeconds, algorithm: Algorithm.SHA512, isGoogle: isGoogle),
      };

  /// Generates a Counter-based one time password code and return as a 0 padded string.
  /// If isGoogle is true, the secret will be decoded as base32, otherwise it will be decoded as utf8.
  String generateHOTPCodeString({
    required String secret,
    required int counter,
    required int length,
    bool isGoogle = true,
  }) =>
      switch (this) {
        Algorithms.SHA1 => OTP.generateHOTPCodeString(secret, counter, length: length, algorithm: Algorithm.SHA1, isGoogle: isGoogle),
        Algorithms.SHA256 => OTP.generateHOTPCodeString(secret, counter, length: length, algorithm: Algorithm.SHA256, isGoogle: isGoogle),
        Algorithms.SHA512 => OTP.generateHOTPCodeString(secret, counter, length: length, algorithm: Algorithm.SHA512, isGoogle: isGoogle),
      };
}
