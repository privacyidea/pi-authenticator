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
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart'
    show AesGcm, KeyPairType, SimplePublicKey, X25519;
import 'package:http/http.dart';
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart'
    show
        ECDSASigner,
        ECDomainParameters,
        ECPublicKey,
        ECSignature,
        PublicKeyParameter,
        SHA256Digest;

import 'fake_backend.dart';
import 'reference_otp.dart';

/// A token of the container on the server, in the two shapes the sync hands
/// out: an enrollment url for a client that does not have the token yet and a
/// token dictionary for a client that has it.
class FakeContainerToken {
  final String serial;
  final String type;
  final String label;
  final List<int> secret;
  final int counter;
  final int period;
  final int digits;

  const FakeContainerToken._({
    required this.serial,
    required this.type,
    required this.label,
    required this.secret,
    required this.counter,
    required this.period,
    required this.digits,
  });

  factory FakeContainerToken.hotp({
    required String serial,
    required List<int> secret,
    String? label,
    int counter = 1,
    int digits = 6,
  }) => FakeContainerToken._(
    serial: serial,
    type: 'hotp',
    label: label ?? serial,
    secret: secret,
    counter: counter,
    period: 30,
    digits: digits,
  );

  factory FakeContainerToken.totp({
    required String serial,
    required List<int> secret,
    String? label,
    int period = 30,
    int digits = 6,
  }) => FakeContainerToken._(
    serial: serial,
    type: 'totp',
    label: label ?? serial,
    secret: secret,
    counter: 0,
    period: period,
    digits: digits,
  );

  FakeContainerToken withCounter(int counter) => FakeContainerToken._(
    serial: serial,
    type: type,
    label: label,
    secret: secret,
    counter: counter,
    period: period,
    digits: digits,
  );

  String get secretBase32 => base32(secret);

  /// Built like `create_google_authenticator_url` of privacyIDEA.
  String get enrollUrl {
    final extra = type == 'hotp' ? 'counter=$counter&' : 'period=$period&';
    return 'otpauth://$type/${Uri.encodeComponent(label)}'
        '?secret=$secretBase32&$extra'
        'digits=$digits&creator=privacyidea&issuer=privacyIDEA'
        '&serial=${Uri.encodeComponent(serial)}';
  }

  /// The database dictionary of the token with `count` renamed to `counter`,
  /// the way `synchronize_container_details` of privacyIDEA returns it.
  Map<String, dynamic> get updateEntry => {
    'serial': serial,
    'tokentype': type,
    'active': true,
    'otplen': digits,
    if (type == 'hotp') 'counter': counter,
  };
}

class FakeContainerPolicies {
  final bool rolloverAllowed;
  final bool initialTokenAssignment;
  final bool disabledTokenDeletion;
  final bool disabledUnregister;

  const FakeContainerPolicies({
    this.rolloverAllowed = false,
    this.initialTokenAssignment = false,
    this.disabledTokenDeletion = false,
    this.disabledUnregister = false,
  });

  Map<String, bool> toJson() => {
    'container_client_rollover': rolloverAllowed,
    'initially_add_tokens_to_container': initialTokenAssignment,
    'disable_client_token_deletion': disabledTokenDeletion,
    'disable_client_container_unregister': disabledUnregister,
  };
}

/// A request to `/container/register/finalize` and the server's verdict.
class FinalizationRecord {
  final RecordedRequest request;
  final bool accepted;

  /// The message the signature was checked against, null if the server never
  /// got that far.
  final String? signedMessage;

  const FinalizationRecord(this.request, this.accepted, this.signedMessage);
}

/// A request to `/container/synchronize` and what the server made of it.
class SyncRecord {
  final RecordedRequest request;
  final bool accepted;
  final String? signedMessage;

  /// The tokens of `container_dict_client`.
  final List<Map<String, dynamic>> clientTokens;

  /// The enrollment urls and the token dictionaries the server answered with.
  final List<String> added;
  final List<Map<String, dynamic>> updated;

  const SyncRecord({
    required this.request,
    required this.accepted,
    required this.signedMessage,
    required this.clientTokens,
    required this.added,
    required this.updated,
  });

  Iterable<String> get clientSerials =>
      clientTokens.map((t) => t['serial']).whereType<String>();
}

class _OpenChallenge {
  final String nonce;
  final String timeStamp;
  final String scope;
  final String? passphrase;

  const _OpenChallenge(this.nonce, this.timeStamp, this.scope, this.passphrase);
}

/// A stateful privacyIDEA container server for the app's smartphone container
/// protocol, mounted on a [FakeBackend]:
///
/// * `/container/register/finalize` registers the public key of the app. The
///   app has to sign the registration link's nonce, time, serial and url (and
///   device information and passphrase, if given) with the key it sends.
/// * `/container/challenge` hands out a nonce and a time stamp for a scope.
/// * `/container/synchronize` verifies the signature over the challenge, the
///   encryption key and the client's container dictionary, and answers with the
///   container dictionary encrypted for the client (X25519 and AES-GCM-256).
///
/// Like the real server it checks every signature as UTF-8 bytes of the
/// message, consumes a challenge when it is answered correctly and refuses
/// everything else with the same errors.
class FakeContainerServer {
  static final Uri baseUrl = Uri.parse('https://pi.example.test');

  static const _curveOids = {
    'secp256r1': '1.2.840.10045.3.1.7',
    'secp384r1': '1.3.132.0.34',
    'secp521r1': '1.3.132.0.35',
  };

  final FakeBackend backend;
  final String serial;
  final String curve;

  /// The prompt the registration link shows and the passphrase the server
  /// expects in the signature. Both are null for a container without one.
  final String? passphrasePrompt;
  final String? passphrase;

  FakeContainerPolicies policies;
  final List<FakeContainerToken> tokens;

  final List<FinalizationRecord> finalizations = [];
  final List<SyncRecord> syncs = [];
  final List<RecordedRequest> challengeRequests = [];

  final List<_OpenChallenge> _open = [];
  ECPublicKey? _clientKey;
  String? _clientKeyPem;

  FakeContainerServer(
    this.backend, {
    this.serial = 'SMPH0001A2B3',
    this.curve = 'secp384r1',
    this.passphrasePrompt,
    this.passphrase,
    this.policies = const FakeContainerPolicies(),
    List<FakeContainerToken> tokens = const [],
  }) : tokens = List.of(tokens) {
    bool at(RecordedRequest r, String path) =>
        r.isPost && r.url.host == baseUrl.host && r.url.path == path;
    backend.on((r) => at(r, '/container/register/finalize'), _finalize);
    backend.on((r) => at(r, '/container/challenge'), _challenge);
    backend.on((r) => at(r, '/container/synchronize'), _synchronize);
  }

  bool get registered => _clientKey != null;

  /// The PEM public key the app registered, null until it did.
  String? get clientPublicKeyPem => _clientKeyPem;

  Uri get registrationUrl =>
      baseUrl.replace(path: '/container/register/finalize');
  Uri get syncUrl => baseUrl.replace(path: '/container/synchronize');

  /// A registration link as privacyIDEA builds it
  /// (`create_container_registration_url`).
  Uri registrationLink({
    Duration ttl = const Duration(minutes: 10),
    DateTime? issuedAt,
    bool sslVerify = true,
  }) {
    final nonce = _randomHex(20);
    final timeStamp = _isoFormat(issuedAt ?? DateTime.now());
    _open.add(
      _OpenChallenge(nonce, timeStamp, registrationUrl.toString(), passphrase),
    );
    return Uri.parse(
      'pia://container/$serial?issuer=privacyIDEA&ttl=${ttl.inMinutes}'
      '&nonce=$nonce&time=${Uri.encodeComponent(timeStamp)}'
      '&url=$baseUrl&serial=$serial&key_algorithm=$curve'
      '&hash_algorithm=SHA256&ssl_verify=${sslVerify ? 'True' : 'False'}'
      '&passphrase=${Uri.encodeComponent(passphrasePrompt ?? '')}',
    );
  }

  void removeToken(String tokenSerial) =>
      tokens.removeWhere((t) => t.serial == tokenSerial);

  void replaceToken(FakeContainerToken token) {
    final index = tokens.indexWhere((t) => t.serial == token.serial);
    if (index < 0) {
      tokens.add(token);
    } else {
      tokens[index] = token;
    }
  }

  Response _finalize(RecordedRequest request) {
    final data = request.data;
    final publicKeyPem = data['public_client_key'];
    final signature = data['signature'];
    if (data['container_serial'] != serial) return _unknownContainer();
    if (publicKeyPem == null || signature == null) return _missingParameter();

    final ECPublicKey key;
    try {
      key = _publicKeyFromPem(publicKeyPem);
    } on Object catch (e) {
      finalizations.add(FinalizationRecord(request, false, null));
      return FakeBackend.error(905, 'Invalid public key: $e');
    }
    final message = _consumeChallenge(
      scope: registrationUrl.toString(),
      signature: signature,
      key: key,
      brand: data['device_brand'],
      model: data['device_model'],
    );
    finalizations.add(FinalizationRecord(request, message != null, message));
    if (message == null) return _invalidChallenge();

    _clientKey = key;
    _clientKeyPem = publicKeyPem;
    return FakeBackend.json({'policies': policies.toJson()});
  }

  Response _challenge(RecordedRequest request) {
    challengeRequests.add(request);
    if (request.data['container_serial'] != serial) return _unknownContainer();
    if (!registered) return _notRegistered();
    final scope = request.data['scope'];
    if (scope == null) return _missingParameter();

    final challenge = _OpenChallenge(
      _randomHex(20),
      _isoFormat(DateTime.now()),
      scope,
      null,
    );
    _open.add(challenge);
    return FakeBackend.json({
      'nonce': challenge.nonce,
      'time_stamp': challenge.timeStamp,
      'enc_key_algorithm': 'X25519',
      'server_url': baseUrl.toString(),
    });
  }

  Future<Response> _synchronize(RecordedRequest request) async {
    final data = request.data;
    final key = _clientKey;
    if (data['container_serial'] != serial) return _unknownContainer();
    if (key == null) return _notRegistered();
    final signature = data['signature'];
    final encryptionKey = data['public_enc_key_client'];
    final clientDictionary = data['container_dict_client'];
    if (signature == null ||
        encryptionKey == null ||
        clientDictionary == null) {
      return _missingParameter();
    }

    final message = _consumeChallenge(
      scope: syncUrl.toString(),
      signature: signature,
      key: key,
      publicEncryptionKey: encryptionKey,
      containerDictionary: clientDictionary,
    );
    final clientTokens =
        ((jsonDecode(clientDictionary) as Map<String, dynamic>)['tokens']
                as List)
            .cast<Map<String, dynamic>>();
    final clientSerials = clientTokens
        .map((t) => t['serial'])
        .whereType<String>()
        .toSet();
    final added = [
      for (final t in tokens)
        if (!clientSerials.contains(t.serial)) t.enrollUrl,
    ];
    final updated = [
      for (final t in tokens)
        if (clientSerials.contains(t.serial)) t.updateEntry,
    ];
    syncs.add(
      SyncRecord(
        request: request,
        accepted: message != null,
        signedMessage: message,
        clientTokens: clientTokens,
        added: added,
        updated: updated,
      ),
    );
    if (message == null) return _invalidChallenge();

    final x25519 = X25519();
    final serverKeyPair = await x25519.newKeyPair();
    final sessionKey = await x25519.sharedSecretKey(
      keyPair: serverKeyPair,
      remotePublicKey: SimplePublicKey(
        base64.decode(encryptionKey),
        type: KeyPairType.x25519,
      ),
    );
    final box = await AesGcm.with256bits(nonceLength: 16).encrypt(
      utf8.encode(
        jsonEncode({
          'container': {
            'serial': serial,
            'type': 'smartphone',
            'states': ['active'],
          },
          'tokens': {'add': added, 'update': updated},
        }),
      ),
      secretKey: sessionKey,
    );
    return FakeBackend.json({
      'container_dict_server': base64UrlEncode(box.cipherText),
      'encryption_algorithm': 'AES',
      'encryption_params': {
        'algorithm': 'AES',
        'mode': 'GCM',
        'init_vector': base64UrlEncode(box.nonce),
        'tag': base64UrlEncode(box.mac.bytes),
      },
      'public_server_key': base64UrlEncode(
        (await serverKeyPair.extractPublicKey()).bytes,
      ),
      'server_url': syncUrl.toString(),
      'policies': policies.toJson(),
    });
  }

  /// `validate_challenge` of privacyIDEA: every open challenge of the scope is
  /// tried, the one whose message the signature fits is consumed. The
  /// passphrase is part of the message only if the challenge carries one.
  /// Returns the verified message, null if no challenge fits.
  String? _consumeChallenge({
    required String scope,
    required String signature,
    required ECPublicKey key,
    String? brand,
    String? model,
    String? publicEncryptionKey,
    String? containerDictionary,
  }) {
    for (final challenge in List.of(_open)) {
      if (challenge.scope != scope) continue;
      final message = [
        challenge.nonce,
        challenge.timeStamp,
        serial,
        challenge.scope,
        if (brand != null && brand.isNotEmpty) brand,
        if (model != null && model.isNotEmpty) model,
        if (challenge.passphrase != null && challenge.passphrase!.isNotEmpty)
          challenge.passphrase!,
        if (publicEncryptionKey != null && publicEncryptionKey.isNotEmpty)
          publicEncryptionKey,
        if (containerDictionary != null && containerDictionary.isNotEmpty)
          containerDictionary,
      ].join('|');
      if (_verify(key, message, signature)) {
        _open.remove(challenge);
        return message;
      }
    }
    return null;
  }

  bool _verify(ECPublicKey key, String message, String signatureBase64) {
    try {
      final signature =
          ASN1Parser(base64.decode(signatureBase64)).nextObject()
              as ASN1Sequence;
      final r = (signature.elements![0] as ASN1Integer).integer!;
      final s = (signature.elements![1] as ASN1Integer).integer!;
      final verifier = ECDSASigner(SHA256Digest())
        ..init(false, PublicKeyParameter<ECPublicKey>(key));
      return verifier.verifySignature(
        Uint8List.fromList(utf8.encode(message)),
        ECSignature(r, s),
      );
    } on Object {
      return false;
    }
  }

  ECPublicKey _publicKeyFromPem(String pem) {
    final body = pem
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('-----'))
        .join();
    final info = ASN1Parser(base64.decode(body)).nextObject() as ASN1Sequence;
    final algorithm = info.elements![0] as ASN1Sequence;
    final oid = (algorithm.elements![1] as ASN1ObjectIdentifier)
        .objectIdentifierAsString;
    if (oid != _curveOids[curve]) {
      throw ArgumentError('The key is not on the curve $curve but on $oid.');
    }
    final point = (info.elements![1] as ASN1BitString).stringValues!;
    final parameters = ECDomainParameters(curve);
    return ECPublicKey(
      parameters.curve.decodePoint(Uint8List.fromList(point)),
      parameters,
    );
  }

  static final _random = Random.secure();

  static String _randomHex(int bytes) => List.generate(
    bytes,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();

  /// Python's `datetime.isoformat()` for a UTC time, which leaves out the
  /// fraction when the microseconds are zero and otherwise always prints six
  /// digits.
  static String _isoFormat(DateTime time) {
    final utc = time.toUtc();
    String pad(int value, [int width = 2]) =>
        value.toString().padLeft(width, '0');
    final micros = utc.millisecond * 1000 + utc.microsecond;
    return '${pad(utc.year, 4)}-${pad(utc.month)}-${pad(utc.day)}'
        'T${pad(utc.hour)}:${pad(utc.minute)}:${pad(utc.second)}'
        '${micros == 0 ? '' : '.${pad(micros, 6)}'}+00:00';
  }

  Response _invalidChallenge() =>
      FakeBackend.error(3002, 'Could not verify signature!');

  Response _notRegistered() => FakeBackend.error(
    3001,
    'The container is not registered or was unregistered!',
  );

  Response _unknownContainer() => FakeBackend.error(
    601,
    'Container $serial does not exist.',
    statusCode: 404,
  );

  Response _missingParameter() =>
      FakeBackend.error(905, 'Missing parameter in the request.');
}
