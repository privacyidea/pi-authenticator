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

/// A privacyIDEA push endpoint, derived from privacyidea#5618 (and the #5590
/// state it describes). Every behaviour below carries the sentence it
/// implements, so a change to the issue can be traced to a change here.
///
/// Two things are not stated in the issue and are marked where they are used:
/// the part of the challenge sign string after `{nonce}|{url}|{serial}|`, which
/// predates the feature and is taken from the app as it was before it, and the
/// shape of the capability sign document, which is the reference vector of the
/// app facing description of #5583.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart' as asn1;
import 'package:basic_utils/basic_utils.dart' show CryptoUtils;
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/model/enums/push_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/push_request/push_capabilities.dart';
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/helpers/base32_helper.dart';
import 'package:privacyidea_authenticator/utils/helpers/json_canonicalizer.dart';
import 'package:privacyidea_authenticator/utils/push_key_utils.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

/// The server versions the issue distinguishes.
enum PushServerGeneration {
  /// Before #5590. Knows neither the advertisement nor `decline_reason`.
  legacy,

  /// #5590: "every challenge carries a capabilities field plus a detached,
  /// nonce-bound signature (capabilities_signature)".
  advertising,

  /// #5618 phase 1: "Server parses it defensively and stores it in tokeninfo
  /// (e.g. app_capabilities) but does not branch on it yet - store-and-ignore."
  storing,

  /// #5618 phase 2: "read app_capabilities and intersect with
  /// SERVER_PUSH_CAPABILITIES, tailoring the challenge per token".
  tailoring,
}

/// How a challenge was resolved.
enum ChallengeSession { declined, cancelled, answered }

/// The outcome of an answer.
class PushAnswerResult {
  final bool result;
  final ChallengeSession? session;
  final String? presenceAnswer;

  const PushAnswerResult({
    required this.result,
    this.session,
    this.presenceAnswer,
  });

  @override
  String toString() =>
      'PushAnswerResult{result: $result, session: $session, '
      'presenceAnswer: $presenceAnswer}';
}

class _Challenge {
  final String nonce;
  final String? correctAnswer;
  ChallengeSession? session;
  bool otpStatus = false;

  _Challenge(this.nonce, this.correctAnswer);
}

class FakePushServer {
  static const String enrollmentCredential = 'enrollment_credential_1234';
  static const String url = 'https://example.com/ttype/push';

  final PushServerGeneration generation;
  final String serial;

  /// The server side `SERVER_PUSH_CAPABILITIES`.
  final Map<String, Object> serverCapabilities;

  final AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair;
  final RsaUtils rsaUtils;

  RSAPublicKey? smartphonePublicKey;

  /// The P-256 key of a smartphone that enrolled with ECDSA (privacyidea#2943).
  /// The server key then is a P-256 key as well and every signature in both
  /// directions is SHA-256/ECDSA, DER encoded, base32.
  ECPublicKey? smartphoneEcPublicKey;

  /// The server key for a smartphone that enrolled with a P-256 key.
  late final AsymmetricKeyPair<ECPublicKey, ECPrivateKey> ecKeyPair =
      generateP256KeyPair();

  bool get usesEcdsa => smartphoneEcPublicKey != null;

  /// The `app_capabilities` tokeninfo of phase 1, null while nothing was
  /// stored: "a server that consumes later treats an absent set as legacy".
  List<String>? appCapabilities;

  final Map<String, _Challenge> _challenges = {};
  int _nonceCounter = 0;

  FakePushServer._({
    required this.generation,
    required this.serial,
    required this.serverCapabilities,
    AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? keyPair,
  }) : keyPair = keyPair ?? generateShortRsaKeyPair(),
       rsaUtils = const RsaUtils();

  factory FakePushServer.legacy({
    String serial = 'PIPU0001',
    AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? keyPair,
  }) => FakePushServer._(
    generation: PushServerGeneration.legacy,
    serial: serial,
    serverCapabilities: const {},
    keyPair: keyPair,
  );

  factory FakePushServer.advertising({
    String serial = 'PIPU0001',
    Map<String, Object> capabilities = const {'decline_reason': true},
    AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? keyPair,
  }) => FakePushServer._(
    generation: PushServerGeneration.advertising,
    serial: serial,
    serverCapabilities: capabilities,
    keyPair: keyPair,
  );

  factory FakePushServer.storing({
    String serial = 'PIPU0001',
    Map<String, Object> capabilities = const {'decline_reason': true},
  }) => FakePushServer._(
    generation: PushServerGeneration.storing,
    serial: serial,
    serverCapabilities: capabilities,
  );

  factory FakePushServer.tailoring({
    String serial = 'PIPU0001',
    Map<String, Object> capabilities = const {'decline_reason': true},
  }) => FakePushServer._(
    generation: PushServerGeneration.tailoring,
    serial: serial,
    serverCapabilities: capabilities,
  );

  bool get advertises => generation != PushServerGeneration.legacy;

  /// #5583 exists because a server that predates it rejects an answer carrying
  /// a field it does not expect.
  bool get knowsDeclineReason => generation != PushServerGeneration.legacy;

  bool get storesAppCapabilities =>
      generation.index >= PushServerGeneration.storing.index;

  bool get tailorsPerToken => generation == PushServerGeneration.tailoring;

  /// What this server advertises to this token.
  Map<String, Object> get advertisedCapabilities {
    if (!advertises) return const {};
    if (!tailorsPerToken) return serverCapabilities;
    final reported = appCapabilities ?? const [];
    return {
      for (final entry in serverCapabilities.entries)
        if (reported.contains(entry.key)) entry.key: entry.value,
    };
  }

  /// The enrollment finalize request: "App includes a capabilities JSON array
  /// (e.g. ["decline_reason"]) in the enrollment finalize request
  /// (serial + fbtoken + pubkey)."
  Map<String, dynamic> enroll(Map<String, dynamic> requestData) {
    if (!requestData.containsKey('serial') ||
        !requestData.containsKey('fbtoken') ||
        !requestData.containsKey('pubkey')) {
      throw ArgumentError('Missing parameters!');
    }
    // "the request is already gated by enrollment_credential"
    if (requestData['enrollment_credential'] != enrollmentCredential) {
      throw ArgumentError('Invalid enrollment credential.');
    }
    // "the pubkey is trust-on-first-use there anyway"
    // The server tells the key type by the pubkey (SubjectPublicKeyInfo).
    final pubkey = requestData['pubkey'] as String;
    if (_spkiAlgorithm(pubkey) == _ecPublicKeyOid) {
      smartphoneEcPublicKey = _ecPublicKeyFromSpki(pubkey);
    } else {
      smartphonePublicKey = rsaUtils.deserializeRSAPublicKeyPKCS8(pubkey);
    }
    // "Unsigned at enrollment is acceptable", so nothing is verified here.
    if (storesAppCapabilities) {
      appCapabilities = _parseAppCapabilities(requestData['capabilities']);
    }
    return {
      // The server key has the type of the smartphone key: PKCS#1 for RSA,
      // SubjectPublicKeyInfo for P-256, both base64 without header.
      'public_key': usesEcdsa
          ? _ecPublicKeyToSpki(ecKeyPair.publicKey)
          : rsaUtils.serializeRSAPublicKeyPKCS1(keyPair.publicKey),
    };
  }

  static const _ecPublicKeyOid = '1.2.840.10045.2.1';
  static const _p256Oid = '1.2.840.10045.3.1.7';

  static String _spkiAlgorithm(String base64Spki) {
    final spki =
        asn1.ASN1Parser(base64.decode(base64Spki)).nextObject()
            as asn1.ASN1Sequence;
    final algorithm = spki.elements[0] as asn1.ASN1Sequence;
    return (algorithm.elements[0] as asn1.ASN1ObjectIdentifier).identifier!;
  }

  static ECPublicKey _ecPublicKeyFromSpki(String base64Spki) {
    final spki =
        asn1.ASN1Parser(base64.decode(base64Spki)).nextObject()
            as asn1.ASN1Sequence;
    final algorithm = spki.elements[0] as asn1.ASN1Sequence;
    final curve =
        (algorithm.elements[1] as asn1.ASN1ObjectIdentifier).identifier;
    if (curve != _p256Oid) throw ArgumentError('Only P-256 is allowed.');
    var point = (spki.elements[1] as asn1.ASN1BitString).contentBytes();
    // An uncompressed point is 0x04 || X || Y, 65 bytes. A leading 0x00 is the
    // unused-bits count of the BIT STRING.
    if (point.length == 66 && point.first == 0) point = point.sublist(1);
    final params = ECCurve_secp256r1();
    return ECPublicKey(params.curve.decodePoint(point), params);
  }

  static String _ecPublicKeyToSpki(ECPublicKey key) => base64.encode(
    CryptoUtils.getBytesFromPEMString(CryptoUtils.encodeEcPublicKeyToPem(key)),
  );

  /// Checks a signature of the smartphone over [message], the way the server
  /// checks the poll and answer signatures.
  bool verifySmartphoneSignature(String message, String base32Signature) {
    final signature = base32Decode(base32Signature);
    final data = utf8.encode(message);
    if (usesEcdsa) {
      final asn1.ASN1Sequence der;
      try {
        der = asn1.ASN1Parser(signature).nextObject() as asn1.ASN1Sequence;
      } catch (_) {
        return false;
      }
      final verifier = ECDSASigner(SHA256Digest())
        ..init(false, PublicKeyParameter<ECPublicKey>(smartphoneEcPublicKey!));
      return verifier.verifySignature(
        data,
        ECSignature(
          (der.elements[0] as asn1.ASN1Integer).valueAsBigInteger,
          (der.elements[1] as asn1.ASN1Integer).valueAsBigInteger,
        ),
      );
    }
    return rsaUtils.verifyRSASignature(smartphonePublicKey!, data, signature);
  }

  /// "Server parses it defensively": anything that is not an array of names is
  /// stored as nothing rather than failing the enrollment.
  List<String>? _parseAppCapabilities(Object? raw) {
    if (raw == null) return null;
    final Object? decoded;
    try {
      decoded = raw is String ? jsonDecode(raw) : raw;
    } on FormatException {
      return null;
    }
    if (decoded is! List) return null;
    return [
      for (final name in decoded)
        if (name is String) name,
    ];
  }

  /// A challenge as it is pushed through firebase or returned when polling.
  Map<String, dynamic> createChallenge({
    String title = 'Login',
    String question = 'Do you want to login?',
    bool sslVerify = true,
    List<String>? requirePresence,
    Map<String, Object>? advertise,
    String? capabilitiesNonce,
  }) {
    final nonce = 'nonce${_nonceCounter++}';
    final data = <String, dynamic>{
      'title': title,
      'question': question,
      'url': url,
      'nonce': nonce,
      'sslverify': sslVerify ? '1' : '0',
      'serial': serial,
    };

    // Not from the issue: everything after `{nonce}|{url}|{serial}|` predates
    // the feature. "with conditional |segment appends for require_presence".
    var signedData =
        '$nonce|$url|$serial|$question|$title|${sslVerify ? '1' : '0'}';
    if (requirePresence != null) {
      data['require_presence'] = requirePresence.join(',');
      signedData += '|${requirePresence.join(',')}';
      // "It has no base value (absent by default) and is set to "2" only to
      // signal presence-options."
      data['version'] = '2';
    }
    data['signature'] = _sign(signedData);

    // "the detached signature keeps the main signature byte-identical", so the
    // capabilities are appended after the main signature was built.
    final advertised = advertise ?? advertisedCapabilities;
    if (advertises && advertised.isNotEmpty || advertise != null) {
      // #5583: the value is a json string because firebase payload values have
      // to be strings.
      data['capabilities'] = jsonEncode(advertised);
      // "detached, nonce-bound signature" over canonical json (RFC 8785 / JCS).
      data['capabilities_signature'] = _sign(
        canonicalizeJson({
          'capabilities': advertised,
          'nonce': capabilitiesNonce ?? nonce,
        }),
      );
    }

    _challenges[nonce] = _Challenge(nonce, requirePresence?.first);
    return data;
  }

  /// The answer of the smartphone. The sign string is rebuilt from the
  /// parameters this server generation knows: "a positional, pipe-delimited
  /// sign string [...] with conditional |segment appends for require_presence,
  /// decline, decline_reason, presence_answer".
  PushAnswerResult handleAnswer(Map<String, String> requestData) {
    if (!requestData.containsKey('serial')) {
      throw ArgumentError('Missing parameters!');
    }
    final signature = requestData['signature'];
    final decline = requestData['decline'] == '1';
    final declineReason = knowsDeclineReason
        ? requestData['decline_reason']
        : null;
    final presenceAnswer = requestData['presence_answer'];

    final challenge = _challenges[requestData['nonce']];
    if (challenge == null || signature == null) {
      return const PushAnswerResult(result: false);
    }

    var signData = '${challenge.nonce}|${requestData['serial']}';
    if (decline) {
      signData += '|decline';
      if (declineReason != null) signData += '|$declineReason';
    }
    if (presenceAnswer != null) signData += '|$presenceAnswer';

    if (!verifySmartphoneSignature(signData, signature)) {
      return const PushAnswerResult(result: false);
    }

    if (decline) {
      challenge.session = declineReason == 'cancelled'
          ? ChallengeSession.cancelled
          : ChallengeSession.declined;
      return PushAnswerResult(result: true, session: challenge.session);
    }

    if (challenge.correctAnswer != null) {
      if (presenceAnswer != challenge.correctAnswer) {
        return const PushAnswerResult(result: false);
      }
    }
    challenge.otpStatus = true;
    challenge.session = ChallengeSession.answered;
    return PushAnswerResult(
      result: true,
      session: challenge.session,
      presenceAnswer: presenceAnswer,
    );
  }

  ChallengeSession? sessionOf(String nonce) => _challenges[nonce]?.session;

  String _sign(String message) {
    if (!usesEcdsa) {
      return rsaUtils.createBase32Signature(
        keyPair.privateKey,
        utf8.encode(message),
      );
    }
    final signature = CryptoUtils.ecSign(
      ecKeyPair.privateKey,
      Uint8List.fromList(utf8.encode(message)),
      algorithmName: 'SHA-256/ECDSA',
    );
    final der = asn1.ASN1Sequence()
      ..add(asn1.ASN1Integer(signature.r))
      ..add(asn1.ASN1Integer(signature.s));
    return base32Encode(der.encodedBytes);
  }
}

/// A P-256 key pair as a smartphone or server of privacyidea#2943 has it.
AsymmetricKeyPair<ECPublicKey, ECPrivateKey> generateP256KeyPair() {
  final pair = CryptoUtils.generateEcKeyPair(curve: 'secp256r1');
  return AsymmetricKeyPair(
    pair.publicKey as ECPublicKey,
    pair.privateKey as ECPrivateKey,
  );
}

/// Enrolls a token against [server] the way `rolloutPushToken` does and returns
/// the token the app ends up with.
PushToken enrollAgainst(
  FakePushServer server, {
  Map<String, dynamic>? extraRequestData,
  RsaUtils rsaUtils = const RsaUtils(),
  bool ecdsa = false,
}) {
  const pushKeyUtils = PushKeyUtils();
  final AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = ecdsa
      ? generateP256KeyPair()
      : generateShortRsaKeyPair();
  final token = PushToken(serial: server.serial, id: 'id')
      .copyWith(
        keyAlgorithm: ecdsa ? PushKeyAlgorithm.secp256r1 : PushKeyAlgorithm.rsa4096,
      )
      .withPrivateTokenKey(keyPair.privateKey)
      .withPublicTokenKey(keyPair.publicKey)
      .copyWith(url: Uri.parse(FakePushServer.url), sslVerify: true);

  final response = server.enroll({
    'enrollment_credential': FakePushServer.enrollmentCredential,
    'serial': token.serial,
    'fbtoken': 'firebase_token',
    'pubkey': ecdsa
        ? pushKeyUtils.encodePublicKey(keyPair.publicKey as ECPublicKey)
        : rsaUtils.serializeRSAPublicKeyPKCS8(token.rsaPublicTokenKey!),
    'capabilities': canonicalizeJson(appPushCapabilities.names),
    ...?extraRequestData,
  });

  final serverKey = response['public_key'] as String;
  return token.withPublicServerKey(
    ecdsa
        ? pushKeyUtils.decodePublicKey(serverKey)
        : rsaUtils.deserializeRSAPublicKeyPKCS1(serverKey),
  );
}

/// Sends [request] back to [server] the way `_handleReaction` does.
Future<PushAnswerResult> answerWith(
  FakePushServer server,
  PushToken token,
  PushRequest request, {
  RsaUtils rsaUtils = const RsaUtils(),
}) async {
  final body = request
      .getResponseData(token)
      .map((key, value) => MapEntry(key, value.toString()));
  body['signature'] = (await rsaUtils.trySignWithToken(
    token,
    request.getResponseSignMsg(token),
  ))!;
  return server.handleAnswer(body);
}

/// A short key pair, enough for PKCS#1 v1.5 with SHA-256 and much faster than
/// the 4096 bit keys the app generates.
AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateShortRsaKeyPair() {
  final generator = RSAKeyGenerator()
    ..init(
      ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 1024, 64),
        secureRandom(),
      ),
    );
  final pair = generator.generateKeyPair();
  return AsymmetricKeyPair(pair.publicKey, pair.privateKey);
}
