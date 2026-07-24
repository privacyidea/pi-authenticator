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

/// The entry names whose value may be written to the log.
///
/// This is an allowlist rather than a list of secrets to hide, because the log
/// can leave the device with an error report: a name that is added to a model
/// later stays redacted until someone decides it is safe, instead of leaking
/// until someone notices.
///
/// The names here describe how a token is configured, which is what a failed
/// deserialization usually turns on. Secrets, keys, credentials and everything
/// naming the account stay out.
const Set<String> loggableEntryNames = {
  'type',
  'tokenVersion',
  'algorithm',
  'digits',
  'period',
  'counter',
  'rolloutState',
  'isRolledOut',
  'isPollOnly',
  'sslVerify',
  'pin',
  'isLocked',
  'isHidden',
  'isOffline',
  'forceBiometricOption',
  'viewMode',
  'sortIndex',
  'folderId',
};

/// [decoded] with every value replaced by its type, except the ones named in
/// [loggableEntryNames], which are kept as they are.
///
/// Entry names are kept throughout, so the result shows which names are
/// present, which are null and what the remaining values are typed as, without
/// revealing what they hold.
String redactedShape(Object? decoded) => switch (decoded) {
  null => '<null>',
  final Map<String, dynamic> map =>
    '{${map.entries.map((e) => '${e.key}: ${_redactedValue(e.key, e.value)}').join(', ')}}',
  final List<Object?> list => '<List(${list.length})>',
  _ => '<${decoded.runtimeType}>',
};

String _redactedValue(String name, Object? value) => switch (value) {
  null => '<null>',
  final Map<String, dynamic> map => redactedShape(map),
  final List<Object?> list => '<List(${list.length})>',
  _ when loggableEntryNames.contains(name) => jsonEncode(value),
  _ => '<${value.runtimeType}>',
};

/// The entry names whose value is scrubbed out of a log line.
///
/// This is the last line of defence for the call sites that hand a whole object
/// to the logger instead of building a [redactedShape] first. Because it can
/// only remove what it is told about, prefer [redactedShape] where the data is
/// known.
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

/// Matches the value that follows one of the [sensitiveEntryNames].
///
/// After the name it skips the characters that can only separate a name from
/// its value, then takes the run that follows. The run covers the alphabets a
/// key or token is encoded in, standard and url safe base64, base32 and hex.
final List<RegExp> _sensitiveValuePatterns = [
  for (final name in sensitiveEntryNames)
    RegExp(
      '(?<=${RegExp.escape(name)}[^A-Z0-9+/=,]*)[A-Z0-9+/=,:._-]+',
      caseSensitive: false,
    ),
];

/// [text] with the value behind every one of the [sensitiveEntryNames]
/// replaced by `******`.
String filterSensitiveValues(String text) {
  for (final pattern in _sensitiveValuePatterns) {
    text = text.replaceAll(pattern, '******');
  }
  return text;
}
