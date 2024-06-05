import '../l10n/app_localizations.dart';

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
