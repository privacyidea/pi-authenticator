// ignore_for_file: constant_identifier_names

import 'package:otp/otp.dart' as otp_library;

import '../../l10n/app_localizations.dart';

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
        _ => throw LocalizedArgumentError(
            message: (l, algo) => l.algorithmUnsupported(algo),
            invalidValue: algoAsString,
            unlocalizedMessage: 'The algorithm [$algoAsString] is not supported',
          ),
      };
}

class LocalizedArgumentError extends LocalizedException implements ArgumentError {
  final dynamic _invalidValue;
  final String? _name;
  final StackTrace? _stackTrace;
  final String Function(AppLocalizations localizations, dynamic value) messageGetter;

  factory LocalizedArgumentError({
    required String Function(AppLocalizations localizations, dynamic value) message,
    required String unlocalizedMessage,
    required dynamic invalidValue,
    String? name,
    StackTrace? stackTrace,
  }) =>
      LocalizedArgumentError._(
        messageGetter: message,
        unlocalizedMessage: unlocalizedMessage,
        localizedMessage: (localizations) => message(localizations, invalidValue),
        invalidValue: invalidValue,
        name: name,
        stackTrace: stackTrace,
      );

  const LocalizedArgumentError._({
    required this.messageGetter,
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
