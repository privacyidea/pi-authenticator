/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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

import 'dart:convert';

import '../logger.dart';

/// [decoded] with the values that may not be logged replaced by their type.
///
/// With [allowedEntryNames] only the values of the names it lists are kept,
/// without it every value is kept except the ones named in
/// [sensitiveEntryNames]. A caller that knows its data should pass a list, so
/// that a name which is added to the model later stays out of the log until
/// someone decides it is safe.
///
/// Entry names are kept throughout, so the result shows which names are
/// present, which are null and what the remaining values are typed as, without
/// revealing what they hold.
String redactedShape(Object? decoded, {Set<String>? allowedEntryNames}) =>
    switch (decoded) {
      null => '<null>',
      final Map<String, dynamic> map =>
        '{${map.entries.map((e) => '${e.key}: ${_redactedValue(e.key, e.value, allowedEntryNames)}').join(', ')}}',
      final List<Object?> list => '<List(${list.length})>',
      _ => '<${decoded.runtimeType}>',
    };

String _redactedValue(
  String name,
  Object? value,
  Set<String>? allowedEntryNames,
) => switch (value) {
  null => '<null>',
  final Map<String, dynamic> map =>
    redactedShape(map, allowedEntryNames: allowedEntryNames),
  final List<Object?> list => '<List(${list.length})>',
  _ when _isLoggable(name, allowedEntryNames) => jsonEncode(value),
  _ => '<${value.runtimeType}>',
};

/// The names an allowlist was already warned about, so that a storage full of
/// tokens reports the same mistake once instead of once per token.
final Set<String> _reportedConflicts = {};

/// Whether the value behind [name] may be written to the log.
///
/// A name that an allowlist permits but [sensitiveEntryNames] blocks stays
/// redacted and is reported, because the allowlist is the newer and more local
/// of the two and is therefore the one that is likely wrong.
bool _isLoggable(String name, Set<String>? allowedEntryNames) {
  if (allowedEntryNames == null) return !_isSensitiveName(name);
  if (!allowedEntryNames.contains(name)) return false;
  if (!_isSensitiveName(name)) return true;
  if (_reportedConflicts.add(name)) {
    Logger.warning(
      'An allowed entry name is blocked as well and stays redacted: $name',
      verbose: true,
    );
  }
  return false;
}

/// Whether [name] is one of the [sensitiveEntryNames].
///
/// Matched the way [filterSensitiveValues] matches, case insensitively and as a
/// substring, so that the two cannot disagree about a name.
bool _isSensitiveName(String name) {
  final lowerName = name.toLowerCase();
  return sensitiveEntryNames.any((sensitive) => lowerName.contains(sensitive));
}

/// The entry names whose value never reaches the log.
///
/// These are scrubbed out of every log line by [filterSensitiveValues] and are
/// what [redactedShape] withholds when it is given no allowlist. A name here
/// outranks any allowlist, so this list alone decides what can never be logged.
///
/// Names are matched case insensitively and as a substring, so 'passphrase'
/// covers 'send_passphrase' too. Both the dart and the wire spelling of a name
/// are listed where they differ.
const Set<String> sensitiveEntryNames = {
  // OTP
  'secret',
  // Push token key material and credentials
  'privatetokenkey',
  'publictokenkey',
  'publicserverkey',
  'private_token_key',
  'public_token_key',
  'public_server_key',
  'enrollmentcredentials',
  'enrollment_credential',
  // Container key material, passphrase and its wire spellings
  'privateclientkey',
  'publicclientkey',
  'private_client_key',
  'public_client_key',
  'public_enc_key_client',
  'passphrase',
  // Firebase
  'fbtoken',
  'new_fb_token',
};

/// Finds every one of the [sensitiveEntryNames].
///
/// Matched case insensitively and as a substring, the way [_isSensitiveName]
/// matches, so that the two cannot disagree about a name.
final RegExp _sensitiveNamePattern = RegExp(
  sensitiveEntryNames.map(RegExp.escape).join('|'),
  caseSensitive: false,
);

/// Matches the rest of a name that [_sensitiveNamePattern] found only a part
/// of, the 'Flag' of 'hasSecretFlag'.
final RegExp _nameRemainder = RegExp(r'[A-Za-z0-9_]*');

/// Matches what can stand between a name and its value, the closing quote of
/// the name, one assignment and the space around it.
final RegExp _nameValueSeparator = RegExp(r'''["']?\s*[:=]?\s*''');

/// The characters that end a value that is neither quoted nor nested.
const String _bareValueEnders = ' \t\r\n,;)}]"\'';

/// [text] with the value behind every one of the [sensitiveEntryNames]
/// replaced by `******`.
///
/// A quoted value keeps its quotes and an object or a list is replaced as a
/// whole, so that a name which may not be logged does not leak through what is
/// nested below it. Everything around the value is left as it is, so the
/// entries next to a sensitive one stay readable.
String filterSensitiveValues(String text) {
  final filtered = StringBuffer();
  var copiedUpTo = 0;
  for (final name in _sensitiveNamePattern.allMatches(text)) {
    // A name inside a value that was already replaced is part of that value.
    if (name.start < copiedUpTo) continue;
    final value = _valueRange(text, name.end);
    if (value == null) continue;
    filtered
      ..write(text.substring(copiedUpTo, value.start))
      ..write('******');
    copiedUpTo = value.end;
  }
  filtered.write(text.substring(copiedUpTo));
  return filtered.toString();
}

/// The part of [text] that holds the value of the name ending at [nameEnd], or
/// null if the name is not followed by one.
({int start, int end})? _valueRange(String text, int nameEnd) {
  var index = _nameRemainder.matchAsPrefix(text, nameEnd)!.end;
  index = _nameValueSeparator.matchAsPrefix(text, index)!.end;
  if (index >= text.length) return null;
  final firstCharacter = text[index];
  if (firstCharacter == '"' || firstCharacter == "'") {
    return (start: index + 1, end: _quotedValueEnd(text, index));
  }
  if (firstCharacter == '{' || firstCharacter == '[') {
    return (start: index, end: _nestedValueEnd(text, index));
  }
  var end = index;
  while (end < text.length && !_bareValueEnders.contains(text[end])) {
    end++;
  }
  return (start: index, end: end);
}

/// The index of the quote that closes the one at [start].
///
/// An unterminated value reaches to the end of [text] and is replaced whole,
/// because a line that was cut off says nothing about where its value ended.
int _quotedValueEnd(String text, int start) {
  final quote = text[start];
  var index = start + 1;
  while (index < text.length) {
    if (text[index] == r'\') {
      index += 2;
      continue;
    }
    if (text[index] == quote) return index;
    index++;
  }
  return text.length;
}

/// The index behind the bracket that closes the object or list at [start].
///
/// Brackets inside a quoted value are not counted, and an unterminated value
/// reaches to the end of [text] for the reason given at [_quotedValueEnd].
int _nestedValueEnd(String text, int start) {
  var depth = 0;
  var index = start;
  while (index < text.length) {
    final character = text[index];
    if (character == '"' || character == "'") {
      index = _quotedValueEnd(text, index) + 1;
      continue;
    }
    if (character == '{' || character == '[') {
      depth++;
    } else if (character == '}' || character == ']') {
      depth--;
      if (depth == 0) return index + 1;
    }
    index++;
  }
  return text.length;
}
