/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2025 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:convert';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/utils/helpers/base32_helper.dart';

import '../model/tokens/push_token.dart';
import '../model/enums/biometric_push_key_status.dart';
import '../l10n/app_localizations.dart';
import 'biometric_push_key_manager.dart';
import 'globals.dart';
import '../utils/crypto_utils.dart';
import '../utils/identifiers.dart';
import '../utils/logger.dart';

class RsaUtils {
  static const biometricKeyStatusUnprotected = 'unprotected';
  static const biometricKeyStatusProtected = 'protected';
  static const biometricKeyStatusInvalidated = 'invalidated';
  static const biometricKeyStatusUnsupported = 'unsupported';

  final BiometricPushKeyManager _biometricPushKeyManager;

  // Keep the public injection parameter readable while the dependency itself
  // remains private (and therefore outside generated Mockito interfaces).
  const RsaUtils({
    BiometricPushKeyManager biometricPushKeyManager =
        const BiometricPushKeyManager(),
  }) : this._withBiometricPushKeyManager(biometricPushKeyManager);

  const RsaUtils._withBiometricPushKeyManager(this._biometricPushKeyManager);

  bool get supportsBiometricPushKeyProtection =>
      _biometricPushKeyManager.isSupportedPlatform;

  Future<String> biometricPushKeyStatus(String tokenId) async =>
      (await _biometricPushKeyManager.status(tokenId)).name;

  Future<void> deleteBiometricPushKey(String tokenId) =>
      _biometricPushKeyManager.delete(tokenId);

  /// Extract RSA-Public-Keys from DER structure that is a BASE64 encoded Strings.
  /// According to the PKCS#1 format:
  ///
  /// RSAPublicKey ::= SEQUENCE {
  ///     modulus           INTEGER,  -- n
  ///     publicExponent    INTEGER   -- e
  /// }
  RSAPublicKey deserializeRSAPublicKeyPKCS1(String keyStr) {
    ASN1Sequence asn1sequence =
        ASN1Parser(base64.decode(keyStr)).nextObject() as ASN1Sequence;
    BigInt modulus =
        (asn1sequence.elements[0] as ASN1Integer).valueAsBigInteger;
    BigInt exponent =
        (asn1sequence.elements[1] as ASN1Integer).valueAsBigInteger;

    return RSAPublicKey(modulus, exponent);
  }

  /// Convert an RSA-Public-Key to a DER structure as a BASE64 encoded String.
  /// According to the PKCS#1 format:
  ///
  /// RSAPublicKey ::= SEQUENCE {
  ///     modulus           INTEGER,  -- n
  ///     publicExponent    INTEGER   -- e
  /// }
  String serializeRSAPublicKeyPKCS1(RSAPublicKey publicKey) {
    ASN1Sequence s = ASN1Sequence()
      ..add(ASN1Integer(publicKey.modulus!))
      ..add(ASN1Integer(publicKey.exponent!));

    return base64.encode(s.encodedBytes);
  }

  /// Extract RSA-Public-Keys from DER structure that is a BASE64 encoded Strings.
  /// According to the PKCS#8 format:
  ///
  /// PublicKeyInfo ::= SEQUENCE {
  ///     algorithm       AlgorithmIdentifier,
  ///     PublicKey       BIT STRING
  /// }
  ///
  /// AlgorithmIdentifier ::= SEQUENCE {
  ///     algorithm       OBJECT IDENTIFIER,
  ///     parameters      ANY DEFINED BY algorithm OPTIONAL
  /// }
  RSAPublicKey deserializeRSAPublicKeyPKCS8(String keyStr) {
    var baseSequence =
        ASN1Parser(base64.decode(keyStr)).nextObject() as ASN1Sequence;

    var encodedAlgorithm = baseSequence.elements[0];

    var algorithm =
        ASN1Parser(encodedAlgorithm.contentBytes()).nextObject()
            as ASN1ObjectIdentifier;

    if (algorithm.identifier != '1.2.840.113549.1.1.1') {
      throw ArgumentError.value(
        algorithm.identifier,
        'algorithm.identifier',
        'Identifier of algorgorithm does not math identifier of RSA '
            '(1.2.840.113549.1.1.1).',
      );
    }

    var encodedKey = baseSequence.elements[1];

    var asn1sequence =
        ASN1Parser(encodedKey.contentBytes()).nextObject() as ASN1Sequence;

    BigInt modulus =
        (asn1sequence.elements[0] as ASN1Integer).valueAsBigInteger;
    BigInt exponent =
        (asn1sequence.elements[1] as ASN1Integer).valueAsBigInteger;

    return RSAPublicKey(modulus, exponent);
  }

  /// Convert an RSA-Public-Key to a DER structure as a BASE64 encoded String.
  /// According to the PKCS#8 format:
  ///
  /// PublicKeyInfo ::= SEQUENCE {
  ///     algorithm       AlgorithmIdentifier,
  ///     PublicKey       BIT STRING
  /// }
  ///
  /// AlgorithmIdentifier ::= SEQUENCE {
  ///     algorithm       OBJECT IDENTIFIER,
  ///     parameters      ANY DEFINED BY algorithm OPTIONAL
  /// }
  String serializeRSAPublicKeyPKCS8(RSAPublicKey key) {
    ASN1ObjectIdentifier.registerFrequentNames();
    ASN1Sequence algorithm = ASN1Sequence()
      ..add(ASN1ObjectIdentifier.fromName('rsaEncryption'))
      ..add(ASN1Null());

    var keySequence = ASN1Sequence()
      ..add(ASN1Integer(key.modulus!))
      ..add(ASN1Integer(key.exponent!));

    var publicKey = ASN1BitString(keySequence.encodedBytes);

    var asn1sequence = ASN1Sequence()
      ..add(algorithm)
      ..add(publicKey);
    return base64.encode(asn1sequence.encodedBytes);
  }

  /// Convert an RSA-Private-Key to a DER structure as a BASE64 encoded String.
  /// According to the PKCS#1 format:
  ///
  /// RSAPrivateKey ::= SEQUENCE {
  ///    version           Version,
  ///    modulus           INTEGER,  -- n
  ///    publicExponent    INTEGER,  -- e
  ///    privateExponent   INTEGER,  -- d
  ///    prime1            INTEGER,  -- p
  ///    prime2            INTEGER,  -- q
  ///    exponent1         INTEGER,  -- d mod (p-1)
  ///    exponent2         INTEGER,  -- d mod (q-1)
  ///    coefficient       INTEGER,  -- (inverse of q) mod p
  ///    otherPrimeInfos   OtherPrimeInfos OPTIONAL
  /// }
  ///
  /// Version ::= INTEGER { two-prime(0), multi(1) }
  /// (CONSTRAINED BY {-- version must be multi if otherPrimeInfos present --})
  String serializeRSAPrivateKeyPKCS1(RSAPrivateKey key) {
    ASN1Sequence s = ASN1Sequence()
      ..add(ASN1Integer.fromInt(0)) // version
      ..add(ASN1Integer(key.modulus!)) // modulus
      ..add(ASN1Integer(key.publicExponent!)) // e
      ..add(ASN1Integer(key.privateExponent!)) // d
      ..add(ASN1Integer(key.p!)) // p
      ..add(ASN1Integer(key.q!)) // q
      ..add(
        ASN1Integer(key.privateExponent! % (key.p! - BigInt.one)),
      ) // d mod (p-1)
      ..add(
        ASN1Integer(key.privateExponent! % (key.q! - BigInt.one)),
      ) // d mod (q-1)
      ..add(ASN1Integer(key.q!.modInverse(key.p!))); // q^(-1) mod p

    return base64.encode(s.encodedBytes);
  }

  /// Extract RSA-Private-Keys from DER structure that is a BASE64 encoded Strings.
  /// According to the PKCS#1 format:
  ///
  /// RSAPrivateKey ::= SEQUENCE {
  ///    version           Version,
  ///    modulus           INTEGER,  -- n
  ///    publicExponent    INTEGER,  -- e
  ///    privateExponent   INTEGER,  -- d
  ///    prime1            INTEGER,  -- p
  ///    prime2            INTEGER,  -- q
  ///    exponent1         INTEGER,  -- d mod (p-1)
  ///    exponent2         INTEGER,  -- d mod (q-1)
  ///    coefficient       INTEGER,  -- (inverse of q) mod p
  ///    otherPrimeInfos   OtherPrimeInfos OPTIONAL
  /// }
  ///
  /// Version ::= INTEGER { two-prime(0), multi(1) }
  /// (CONSTRAINED BY {-- version must be multi if otherPrimeInfos present --})
  RSAPrivateKey deserializeRSAPrivateKeyPKCS1(String keyStr) {
    Uint8List keyBytes = base64.decode(keyStr);
    ASN1Sequence asn1sequence =
        ASN1Parser(keyBytes).nextObject() as ASN1Sequence;
    if (asn1sequence.elements.length != 9 ||
        (asn1sequence.elements[0] as ASN1Integer).valueAsBigInteger !=
            BigInt.zero) {
      throw const FormatException('Unsupported RSA private key format.');
    }
    BigInt modulus =
        (asn1sequence.elements[1] as ASN1Integer).valueAsBigInteger;
    BigInt publicExponent =
        (asn1sequence.elements[2] as ASN1Integer).valueAsBigInteger;
    BigInt privateExponent =
        (asn1sequence.elements[3] as ASN1Integer).valueAsBigInteger;
    BigInt p = (asn1sequence.elements[4] as ASN1Integer).valueAsBigInteger;
    BigInt q = (asn1sequence.elements[5] as ASN1Integer).valueAsBigInteger;
    final exponent1 =
        (asn1sequence.elements[6] as ASN1Integer).valueAsBigInteger;
    final exponent2 =
        (asn1sequence.elements[7] as ASN1Integer).valueAsBigInteger;
    final coefficient =
        (asn1sequence.elements[8] as ASN1Integer).valueAsBigInteger;

    if (modulus != p * q ||
        exponent1 != privateExponent % (p - BigInt.one) ||
        exponent2 != privateExponent % (q - BigInt.one) ||
        coefficient != q.modInverse(p)) {
      throw const FormatException('Inconsistent RSA private key parameters.');
    }

    final privateKey = RSAPrivateKey(modulus, privateExponent, p, q);
    if (publicExponent == privateExponent) {
      if (privateKey.publicExponent != BigInt.from(65537)) {
        throw const FormatException('Unexpected legacy RSA public exponent.');
      }
    } else if (privateKey.publicExponent != publicExponent) {
      throw const FormatException('Inconsistent RSA public exponent.');
    }
    return privateKey;
  }

  /// signedMessage is what was allegedly signed, signature gets validated
  bool verifyRSASignature(
    RSAPublicKey publicKey,
    Uint8List signedMessage,
    Uint8List signature,
  ) {
    RSASigner signer =
        Signer(DEFAULT_SIGNING_ALGORITHM)
            as RSASigner; // Get algorithm from registry
    signer.init(
      false,
      PublicKeyParameter<RSAPublicKey>(publicKey),
    ); // false to validate

    bool isVerified = false;
    try {
      isVerified = signer.verifySignature(
        signedMessage,
        RSASignature(signature),
      );
    } on ArgumentError catch (e, s) {
      Logger.warning(
        'Verifying signature failed due to ${e.name}',
        error: e,
        stackTrace: s,
      );
    }

    return isVerified;
  }

  /// Tries to sign the [message] with the private key of the [token]. If the token is a
  /// legacy token (enrolled prior to v3), the Legacy plugin will be used for that operation.
  /// If an error occurs during the operation of the legacy plugin, a dialog will be shown
  /// if a [context] is provided, telling the users that it might be better to enroll a new
  /// push token so that the app can directly access the private key.
  /// Returns the signature on success and null on failure.
  Future<String?> trySignWithToken(
    PushToken token,
    String message, {
    Future<bool> Function(PushToken token)? onTokenChanged,
  }) async {
    if (token.requiresBiometricKeyProtection) {
      if (!supportsBiometricPushKeyProtection) {
        throw const BiometricPushKeyException(
          BiometricPushKeyManager.unsupportedCode,
        );
      }
      if (token.isBiometricKeyInvalidated) {
        throw const BiometricPushKeyException(
          BiometricPushKeyManager.invalidatedCode,
        );
      }
      if (token.isRolledOut &&
          token.biometricKeyStatus == BiometricPushKeyStatus.unprotected) {
        if (onTokenChanged != null) {
          try {
            await onTokenChanged(
              token.copyWith(
                privateTokenKey: () => null,
                biometricKeyStatus: BiometricPushKeyStatus.invalidated,
              ),
            );
          } catch (persistError, stackTrace) {
            Logger.warning(
              'Could not persist invalidated legacy biometric Push state.',
              error: persistError,
              stackTrace: stackTrace,
            );
          }
        }
        throw const BiometricPushKeyException(
          BiometricPushKeyManager.invalidatedCode,
        );
      }
      try {
        final localization = globalContextSync == null
            ? null
            : AppLocalizations.of(globalContextSync!);
        final result = await _biometricPushKeyManager.sign(
          tokenId: token.id,
          message: message,
          reason:
              localization?.biometricPushKeyAuthReason ??
              'Authenticate to use this Push token',
          cancelLabel: localization?.cancel ?? 'Cancel',
          invalidateOnBiometricChange: token.invalidateOnBiometricChange,
          privateKey:
              token.biometricKeyStatus == BiometricPushKeyStatus.unprotected
              ? token.privateTokenKey
              : null,
        );
        final migrationMustBePersisted =
            result.protectedNow ||
            token.privateTokenKey != null ||
            token.biometricKeyStatus != BiometricPushKeyStatus.protected;
        if (migrationMustBePersisted) {
          final updatedToken = token.copyWith(
            privateTokenKey: () => null,
            biometricKeyStatus: BiometricPushKeyStatus.protected,
          );
          var persisted = false;
          try {
            persisted =
                onTokenChanged != null && await onTokenChanged(updatedToken);
          } catch (persistError, stackTrace) {
            Logger.warning(
              'Could not persist protected biometric Push key state.',
              error: persistError,
              stackTrace: stackTrace,
            );
          }
          if (!persisted) {
            throw const BiometricPushKeyException(
              BiometricPushKeyManager.stateNotPersistedCode,
            );
          }
        }
        return base32Encode(base64.decode(result.signature));
      } on BiometricPushKeyException catch (error) {
        if (error.isInvalidated && onTokenChanged != null) {
          try {
            await onTokenChanged(
              token.copyWith(
                privateTokenKey: () => null,
                biometricKeyStatus: BiometricPushKeyStatus.invalidated,
              ),
            );
          } catch (persistError, stackTrace) {
            Logger.warning(
              'Could not persist invalidated biometric Push key state.',
              error: persistError,
              stackTrace: stackTrace,
            );
          }
        }
        rethrow;
      }
    }
    if (token.privateTokenKey != null) {
      return createBase32Signature(
        token.rsaPrivateTokenKey!,
        utf8.encode(message),
      );
    }
    Logger.warning(
      'Token ${token.serial} does not have a private key. Cannot sign message.',
    );
    return null;
  }

  /// Moves a biometric-required Push private key behind Android Keystore or
  /// iOS Keychain before its public key is sent to privacyIDEA.
  Future<void> protectBiometricPushKey(PushToken token) async {
    if (!token.requiresBiometricKeyProtection ||
        token.biometricKeyStatus == BiometricPushKeyStatus.protected) {
      return;
    }
    if (!supportsBiometricPushKeyProtection) {
      throw const BiometricPushKeyException(
        BiometricPushKeyManager.unsupportedCode,
      );
    }
    final privateKey = token.privateTokenKey;
    if (privateKey == null) {
      throw const BiometricPushKeyException(
        BiometricPushKeyManager.keyMissingCode,
      );
    }
    final localization = globalContextSync == null
        ? null
        : AppLocalizations.of(globalContextSync!);
    await _biometricPushKeyManager.protect(
      tokenId: token.id,
      privateKey: privateKey,
      reason:
          localization?.biometricPushKeyProtectReason ??
          'Protect this Push token with strong biometrics',
      cancelLabel: localization?.cancel ?? 'Cancel',
      invalidateOnBiometricChange: token.invalidateOnBiometricChange,
    );
  }

  Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>>
  generateRSAKeyPair() async {
    Logger.info('Start generating RSA key pair');
    AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair = await compute(
      _generateRSAKeyPairIsolate,
      4096,
    );
    Logger.info('Finished generating RSA key pair');
    return keyPair;
  }

  /// Computationally costly method to be run in an isolate.
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _generateRSAKeyPairIsolate(
    int bitLength,
  ) {
    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
          secureRandom(),
        ),
      );

    final pair = keyGen.generateKeyPair();

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey,
      pair.privateKey,
    );
  }

  String createBase32Signature(RSAPrivateKey privateKey, Uint8List dataToSign) {
    return base32Encode(createRSASignature(privateKey, dataToSign));
  }

  Uint8List createRSASignature(RSAPrivateKey privateKey, Uint8List dataToSign) {
    RSASigner signer =
        Signer(DEFAULT_SIGNING_ALGORITHM)
            as RSASigner; // Get algorithm from registry
    signer.init(
      true,
      PrivateKeyParameter<RSAPrivateKey>(privateKey),
    ); // true to sign

    return signer.generateSignature(dataToSign).bytes;
  }
}
