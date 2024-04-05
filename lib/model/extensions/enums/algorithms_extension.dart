import 'package:otp/otp.dart';

import '../../enums/algorithms.dart';

extension AlgorithmsX on Algorithms {
  String generateTOTPCodeString({
    required String secret,
    required DateTime time,
    required int length,
    required Duration interval,
    required bool isGoogle,
  }) =>
      switch (this) {
        Algorithms.SHA1 => OTP.generateTOTPCodeString(secret, time.millisecondsSinceEpoch,
            length: length, interval: interval.inSeconds, algorithm: Algorithm.SHA1, isGoogle: isGoogle),
        Algorithms.SHA256 => OTP.generateTOTPCodeString(secret, time.millisecondsSinceEpoch,
            length: length, interval: interval.inSeconds, algorithm: Algorithm.SHA256, isGoogle: isGoogle),
        Algorithms.SHA512 => OTP.generateTOTPCodeString(secret, time.millisecondsSinceEpoch,
            length: length, interval: interval.inSeconds, algorithm: Algorithm.SHA512, isGoogle: isGoogle),
      };

  String generateHOTPCodeString({
    required String secret,
    required int counter,
    required int length,
    required bool isGoogle,
  }) =>
      switch (this) {
        Algorithms.SHA1 => OTP.generateHOTPCodeString(secret, counter, length: length, algorithm: Algorithm.SHA1, isGoogle: isGoogle),
        Algorithms.SHA256 => OTP.generateHOTPCodeString(secret, counter, length: length, algorithm: Algorithm.SHA256, isGoogle: isGoogle),
        Algorithms.SHA512 => OTP.generateHOTPCodeString(secret, counter, length: length, algorithm: Algorithm.SHA512, isGoogle: isGoogle),
      };
}
