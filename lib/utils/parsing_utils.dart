import 'dart:convert';

import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/export.dart';

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
  BigInt modulus = (asn1sequence.elements[0] as ASN1Integer).valueAsBigInteger;
  BigInt exponent = (asn1sequence.elements[1] as ASN1Integer).valueAsBigInteger;

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
    ..add(ASN1Integer(publicKey.modulus))
    ..add(ASN1Integer(publicKey.exponent));

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

  var algorithm = ASN1Parser(encodedAlgorithm.contentBytes()).nextObject()
      as ASN1ObjectIdentifier;

  if (algorithm.identifier != "1.2.840.113549.1.1.1") {
    throw ArgumentError.value(
        algorithm.identifier,
        "algorithm.identifier",
        "Identifier of algorgorithm does not math identifier of RSA "
            "(1.2.840.113549.1.1.1).");
  }

  var encodedKey = baseSequence.elements[1];

  var asn1sequence =
      ASN1Parser(encodedKey.contentBytes()).nextObject() as ASN1Sequence;

  BigInt modulus = (asn1sequence.elements[0] as ASN1Integer).valueAsBigInteger;
  BigInt exponent = (asn1sequence.elements[1] as ASN1Integer).valueAsBigInteger;

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
    ..add(ASN1Integer(key.modulus))
    ..add(ASN1Integer(key.exponent));

  var publicKey = ASN1BitString(keySequence.encodedBytes);

  var asn1sequence = ASN1Sequence()..add(algorithm)..add(publicKey);
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
    ..add(ASN1Integer(key.modulus)) // modulus
    ..add(ASN1Integer(key.exponent)) // e
    ..add(ASN1Integer(key.d)) // d
    ..add(ASN1Integer(key.p)) // p
    ..add(ASN1Integer(key.q)) // q
    ..add(ASN1Integer(key.d % (key.p - BigInt.one))) // d mod (p-1)
    ..add(ASN1Integer(key.d % (key.q - BigInt.one))) // d mod (q-1)
    ..add(ASN1Integer(key.q.modInverse(key.p))); // q^(-1) mod p

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
  ASN1Sequence asn1sequence =
      ASN1Parser(base64.decode(keyStr)).nextObject() as ASN1Sequence;
  BigInt modulus = (asn1sequence.elements[1] as ASN1Integer).valueAsBigInteger;
  BigInt exponent = (asn1sequence.elements[2] as ASN1Integer).valueAsBigInteger;
  BigInt p = (asn1sequence.elements[4] as ASN1Integer).valueAsBigInteger;
  BigInt q = (asn1sequence.elements[5] as ASN1Integer).valueAsBigInteger;

  return RSAPrivateKey(modulus, exponent, p, q);
}