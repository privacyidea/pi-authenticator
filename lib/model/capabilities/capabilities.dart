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
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../../utils/helpers/base32_helper.dart';
import '../../utils/helpers/json_canonicalizer.dart';
import '../../utils/logger.dart';
import '../../utils/rsa_utils.dart';

const String _VALUES = 'values';
const String _NONCE = 'nonce';

/// The optional features one side of the protocol understands, one entry per
/// feature, advertised as a plain flag: {'decline_reason': true}
/// To stay compatible with future server versions, an entry this app does not
/// know must never make it reject the message. Only a signature that fails
/// verification does that. An unknown entry is kept as it is, because the
/// signature covers every entry and dropping one would break the verification,
/// and it is left out by [negotiate], so it is never used.
class Capabilities {
  static const Capabilities none = Capabilities._({});

  final Map<String, Object> _entries;

  const Capabilities._(this._entries);

  /// The capabilities this app implements.
  ///
  /// Throws a [FormatException] if a value cannot be represented in the
  /// capability format.
  factory Capabilities.declared(Map<String, Object> entries) =>
      Capabilities._(validateCapabilityEntries(entries));

  /// A capability entry that accepts exactly [values].
  static Map<String, Object> accepting(Iterable<String> values) => {
    _VALUES: values.toList(),
  };

  bool supports(String name) {
    final entry = _entries[name];
    return entry != null && entry != false;
  }

  /// The names of the advertised features, the form the app announces at
  /// enrollment.
  List<String> get names => [
    for (final name in _entries.keys)
      if (supports(name)) name,
  ];

  /// The values [name] accepts, or null if [name] is advertised as a plain flag
  /// and therefore does not restrict its values.
  Set<String>? allowedValues(String name) {
    final entry = _entries[name];
    if (entry is! Map<String, Object>) return null;
    final values = entry[_VALUES];
    if (values is! List<Object>) return null;
    return values.whereType<String>().toSet();
  }

  /// The capabilities advertised here as well as in [other], restricted to the
  /// values both accept. A feature whose value sets do not overlap is left out.
  Capabilities negotiate(Capabilities other) {
    final negotiated = <String, Object>{};
    for (final name in _entries.keys) {
      if (!supports(name) || !other.supports(name)) continue;
      final mine = allowedValues(name);
      final theirs = other.allowedValues(name);
      if (mine == null && theirs == null) {
        negotiated[name] = true;
        continue;
      }
      final shared = (mine ?? theirs!).intersection(theirs ?? mine!);
      if (shared.isEmpty) continue;
      negotiated[name] = accepting(shared.toList()..sort());
    }
    return Capabilities._(negotiated);
  }

  /// The canonical json (RFC 8785) form, which is what gets signed and what is
  /// sent when announcing these capabilities.
  String toCanonicalJson() => canonicalizeJson(_entries);

  bool get isEmpty => _entries.isEmpty;

  Map<String, Object> toJson() => _entries;

  @override
  String toString() => 'Capabilities${toCanonicalJson()}';

  @override
  bool operator ==(Object other) =>
      other is Capabilities && toCanonicalJson() == other.toCanonicalJson();

  @override
  int get hashCode => toCanonicalJson().hashCode;
}

/// The capabilities a server advertised, readable only through [verify].
class SignedCapabilities {
  static const String CAPABILITIES = 'capabilities';
  static const String SIGNATURE = 'capabilities_signature';

  final Map<String, Object> _capabilities;
  final String signature;

  const SignedCapabilities._(this._capabilities, this.signature);

  /// The capabilities [data] carries, or null if it carries none, which means
  /// the counterpart is too old to advertise any.
  ///
  /// Firebase sends them as a json string because its payload values have to be
  /// strings, a poll response sends the object as it is.
  ///
  /// Capabilities in a shape this app cannot represent are dropped instead of
  /// rejected: their signature could not be checked either way, and the message
  /// they came with carries its own signature. The result is the behaviour of a
  /// counterpart that advertised nothing.
  static SignedCapabilities? fromMessageData(Map<String, dynamic> data) {
    final raw = data[CAPABILITIES];
    if (raw == null) return null;

    final signature = data[SIGNATURE];
    if (signature is! String) {
      return _dropped(
        'Signature is ${signature.runtimeType}. Expected String.',
      );
    }

    final Object? decoded;
    try {
      decoded = raw is String ? jsonDecode(raw) : raw;
    } on FormatException catch (e) {
      return _dropped('Not valid json: ${e.message}');
    }
    if (decoded is! Map<String, dynamic>) {
      return _dropped(
        'They are ${decoded.runtimeType}. Expected a json object.',
      );
    }

    try {
      return SignedCapabilities._(
        validateCapabilityEntries(decoded),
        signature,
      );
    } on FormatException catch (e) {
      return _dropped(e.message);
    }
  }

  static SignedCapabilities? _dropped(String reason) {
    Logger.warning('Ignoring the advertised capabilities.', error: reason);
    return null;
  }

  factory SignedCapabilities.fromJson(Map<String, dynamic> json) =>
      SignedCapabilities._(
        validateCapabilityEntries(json[CAPABILITIES] as Map<String, dynamic>),
        json[SIGNATURE] as String,
      );

  Map<String, dynamic> toJson() => {
    CAPABILITIES: _capabilities,
    SIGNATURE: signature,
  };

  /// The advertised capabilities if [signature] matches them and was made for
  /// [nonce], null if they cannot be trusted.
  ///
  /// The nonce is part of the signed data, so a signature taken from another
  /// message of the same server does not verify here.
  Capabilities? verify({
    required RSAPublicKey publicKey,
    required String nonce,
    RsaUtils rsaUtils = const RsaUtils(),
  }) {
    final signedData = canonicalizeJson({
      CAPABILITIES: _capabilities,
      _NONCE: nonce,
    });

    final Uint8List signatureBytes;
    try {
      signatureBytes = base32Decode(signature);
    } on FormatException catch (e, s) {
      Logger.warning(
        'Validating capabilities failed.',
        error: e,
        stackTrace: s,
      );
      return null;
    }

    if (!rsaUtils.verifyRSASignature(
      publicKey,
      utf8.encode(signedData),
      signatureBytes,
    )) {
      Logger.warning(
        'Validating capabilities failed.',
        error: 'Signature does not match the advertised capabilities.',
      );
      return null;
    }

    return Capabilities._(_capabilities);
  }

  @override
  String toString() =>
      'SignedCapabilities{capabilities: ${canonicalizeJson(_capabilities)}, '
      'signature: $signature}';

  @override
  bool operator ==(Object other) =>
      other is SignedCapabilities &&
      signature == other.signature &&
      canonicalizeJson(_capabilities) == canonicalizeJson(other._capabilities);

  @override
  int get hashCode => Object.hash(canonicalizeJson(_capabilities), signature);
}

/// Deep copies [entries] into the types the capability format allows.
///
/// Throws a [FormatException] if a name is not a string or a value is of a type
/// the canonical json form cannot represent.
Map<String, Object> validateCapabilityEntries(Map<Object?, Object?> entries) {
  final validated = <String, Object>{};
  for (final entry in entries.entries) {
    final name = entry.key;
    if (name is! String) {
      throw FormatException(
        'Capability names have to be strings but ${name.runtimeType} '
        'was given.',
      );
    }
    validated[name] = _validatedValue(entry.value);
  }
  return validated;
}

Object _validatedValue(Object? value) => switch (value) {
  final bool value => value,
  final String value => value,
  final List<Object?> value => [
    for (final item in value) _validatedValue(item),
  ],
  final Map<Object?, Object?> value => validateCapabilityEntries(value),
  _ => throw FormatException(
    'Capability values have to be booleans, strings, lists or objects but '
    '${value.runtimeType} was given.',
  ),
};
