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

/// Characters that must be written as a short escape sequence.
const Map<int, String> _escapeSequences = {
  0x08: r'\b',
  0x09: r'\t',
  0x0a: r'\n',
  0x0c: r'\f',
  0x0d: r'\r',
  0x22: r'\"',
  0x5c: r'\\',
};

/// Returns the canonical json form (RFC 8785 / JCS) of [value].
///
/// Only booleans, strings, lists and string keyed maps are allowed, a number
/// has to be given as a string. Throws a [FormatException] for any other value.
String canonicalizeJson(Object? value) {
  final buffer = StringBuffer();
  _writeValue(value, buffer);
  return buffer.toString();
}

void _writeValue(Object? value, StringBuffer out) {
  switch (value) {
    case final bool value:
      out.write(value ? 'true' : 'false');
    case final String value:
      _writeString(value, out);
    case final List<Object?> value:
      _writeList(value, out);
    case final Map<Object?, Object?> value:
      _writeMap(value, out);
    default:
      throw FormatException(
        'Cannot canonicalize ${value.runtimeType}. Only booleans, strings, '
        'lists and objects are allowed.',
      );
  }
}

void _writeList(List<Object?> values, StringBuffer out) {
  out.write('[');
  for (var i = 0; i < values.length; i++) {
    if (i > 0) out.write(',');
    _writeValue(values[i], out);
  }
  out.write(']');
}

/// Writes the entries sorted ascending by the utf-16 code units of their keys.
void _writeMap(Map<Object?, Object?> entries, StringBuffer out) {
  final keys = <String>[];
  for (final key in entries.keys) {
    if (key is! String) {
      throw FormatException(
        'Cannot canonicalize an object with a ${key.runtimeType} key. '
        'Only strings are allowed as keys.',
      );
    }
    keys.add(key);
  }
  keys.sort();
  out.write('{');
  for (var i = 0; i < keys.length; i++) {
    if (i > 0) out.write(',');
    _writeString(keys[i], out);
    out.write(':');
    _writeValue(entries[keys[i]], out);
  }
  out.write('}');
}

/// Writes a double quoted string, escaping only what json requires and leaving
/// everything else as raw utf-8.
void _writeString(String value, StringBuffer out) {
  out.write('"');
  for (final codeUnit in value.codeUnits) {
    final escapeSequence = _escapeSequences[codeUnit];
    if (escapeSequence != null) {
      out.write(escapeSequence);
      continue;
    }
    if (codeUnit < 0x20) {
      out.write('\\u${codeUnit.toRadixString(16).padLeft(4, '0')}');
      continue;
    }
    out.writeCharCode(codeUnit);
  }
  out.write('"');
}
