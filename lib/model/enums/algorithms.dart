// ignore_for_file: constant_identifier_names

import 'package:otp/otp.dart' as otp_library;
import 'package:privacyidea_authenticator/model/extensions/enum_extension.dart';

import '../../l10n/app_localizations.dart';

enum Algorithms {
  SHA1,
  SHA256,
  SHA512,
}

extension AlgorithmsX on Algorithms {
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

  static Algorithms fromString(String algoAsString) => switch (algoAsString) {
        'SHA1' => Algorithms.SHA1,
        'SHA256' => Algorithms.SHA256,
        'SHA512' => Algorithms.SHA512,
        _ => throw LocalizedArgumentError(
            localizedMessage: (l, algo, name) => l.algorithmUnsupported(algo),
            unlocalizedMessage: 'The algorithm [$algoAsString] is not supported',
            invalidValue: algoAsString,
            name: 'Algorithm'),
      };
}

class LocalizedArgumentError<T> extends LocalizedException implements ArgumentError {
  final T _invalidValue;
  final String? _name;
  final StackTrace? _stackTrace;

  factory LocalizedArgumentError({
    required String Function(AppLocalizations localizations, T value, String name) localizedMessage,
    required String unlocalizedMessage,
    required T invalidValue,
    required String name,
    StackTrace? stackTrace,
  }) =>
      LocalizedArgumentError._(
        unlocalizedMessage: unlocalizedMessage,
        localizedMessage: (localizations) => localizedMessage(localizations, invalidValue, name),
        invalidValue: invalidValue,
        name: name,
        stackTrace: stackTrace,
      );

  const LocalizedArgumentError._({
    required super.unlocalizedMessage,
    required super.localizedMessage,
    required dynamic invalidValue,
    String? name,
    StackTrace? stackTrace,
  })  : _invalidValue = invalidValue,
        _name = name,
        _stackTrace = stackTrace;

  @override
  dynamic get invalidValue => _invalidValue;
  @override
  dynamic get message => super.unlocalizedMessage;
  @override
  String? get name => _name;
  @override
  StackTrace? get stackTrace => _stackTrace;
  @override
  String toString() => 'ArgumentError: $message';
}

class LocalizedException implements Exception {
  final String Function(AppLocalizations localizations) localizedMessage;
  final String unlocalizedMessage;

  const LocalizedException({required this.localizedMessage, required this.unlocalizedMessage});

  @override
  String toString() => 'Exception: $unlocalizedMessage';
}
