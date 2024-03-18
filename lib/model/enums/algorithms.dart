// ignore_for_file: constant_identifier_names

import 'package:otp/otp.dart' as otp_library;

enum Algorithms {
  SHA1,
  SHA256,
  SHA512,
}

extension AlgorithmsExtension on Algorithms {
  String generateTOTPCodeString({
    required String secret,
    required DateTime time,
    required int length,
    required Duration interval,
    required bool isGoogle,
  }) =>
      switch (this) {
        Algorithms.SHA1 => otp_library.OTP.generateTOTPCodeString(secret, time.millisecondsSinceEpoch,
            length: length, interval: interval.inSeconds, algorithm: otp_library.Algorithm.SHA1, isGoogle: isGoogle),
        Algorithms.SHA256 => otp_library.OTP.generateTOTPCodeString(secret, time.millisecondsSinceEpoch,
            length: length, interval: interval.inSeconds, algorithm: otp_library.Algorithm.SHA256, isGoogle: isGoogle),
        Algorithms.SHA512 => otp_library.OTP.generateTOTPCodeString(secret, time.millisecondsSinceEpoch,
            length: length, interval: interval.inSeconds, algorithm: otp_library.Algorithm.SHA512, isGoogle: isGoogle),
      };

  String generateHOTPCodeString({
    required String secret,
    required int counter,
    required int length,
    required bool isGoogle,
  }) =>
      switch (this) {
        Algorithms.SHA1 => otp_library.OTP.generateHOTPCodeString(secret, counter, length: length, algorithm: otp_library.Algorithm.SHA1, isGoogle: isGoogle),
        Algorithms.SHA256 =>
          otp_library.OTP.generateHOTPCodeString(secret, counter, length: length, algorithm: otp_library.Algorithm.SHA256, isGoogle: isGoogle),
        Algorithms.SHA512 =>
          otp_library.OTP.generateHOTPCodeString(secret, counter, length: length, algorithm: otp_library.Algorithm.SHA512, isGoogle: isGoogle),
      };

  bool isString(String algoAsString) {
    return algoAsString == asString;
  }

  String get asString => switch (this) {
        Algorithms.SHA1 => 'SHA1',
        Algorithms.SHA256 => 'SHA256',
        Algorithms.SHA512 => 'SHA512',
      };

  static Algorithms fromString(String algoAsString) => switch (algoAsString) {
        'SHA1' => Algorithms.SHA1,
        'SHA256' => Algorithms.SHA256,
        'SHA512' => Algorithms.SHA512,
        _ => throw ArgumentError('Unknown algorithm: $algoAsString'),
      };
}
