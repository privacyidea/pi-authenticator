/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import '../../l10n/app_localizations.dart';
import 'localized_exception.dart';

class LocalizedArgumentError extends LocalizedException implements ArgumentError {
  final String _invalidValue;
  final String? _name;
  final StackTrace? _stackTrace;

  factory LocalizedArgumentError({
    required String Function(AppLocalizations localizations, String valueString, String name) localizedMessage,
    required String unlocalizedMessage,
    required String invalidValue,
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
