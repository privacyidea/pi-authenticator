// ignore_for_file: constant_identifier_names

import 'package:otp/otp.dart' as otp_library;

enum Algorithms {
  SHA1,
  SHA256,
  SHA512,
}

extension AlgorithmsExtension on Algorithms {
  String get asString => switch (this) {
        Algorithms.SHA1 => 'SHA1',
        Algorithms.SHA256 => 'SHA256',
        Algorithms.SHA512 => 'SHA512',
      };
  Algorithms fromString(String string) => switch (string) {
        'SHA1' => Algorithms.SHA1,
        'SHA256' => Algorithms.SHA256,
        'SHA512' => Algorithms.SHA512,
        _ => throw ArgumentError('Invalid algorithm string'),
      };
  otp_library.Algorithm get otpLibraryAlgorithm => switch (this) {
        Algorithms.SHA1 => otp_library.Algorithm.SHA1,
        Algorithms.SHA256 => otp_library.Algorithm.SHA256,
        Algorithms.SHA512 => otp_library.Algorithm.SHA512,
      };
  bool isString(String encoding) => encoding.toLowerCase() == asString.toLowerCase();
}
