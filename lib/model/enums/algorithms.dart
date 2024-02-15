// ignore_for_file: constant_identifier_names

import 'package:otp/otp.dart' as otp_library;

enum Algorithms {
  SHA1,
  SHA256,
  SHA512,
}

extension AlgorithmsExtension on Algorithms {
  otp_library.Algorithm get otpLibraryAlgorithm => switch (this) {
        Algorithms.SHA1 => otp_library.Algorithm.SHA1,
        Algorithms.SHA256 => otp_library.Algorithm.SHA256,
        Algorithms.SHA512 => otp_library.Algorithm.SHA512,
      };
}
