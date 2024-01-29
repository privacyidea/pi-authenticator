// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:encrypt/encrypt.dart';
import 'package:file_selector/file_selector.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/model/enums/encodings.dart';

import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../../utils/crypto_utils.dart';
import 'token_migrate_file_processor_interface.dart';
import 'two_fas_migrate_file_processor.dart';

/// Args: [SendPort] sendPort, [ScryptParameters] scryptParameters, [String] password
void _isolatedKdf(List args) {
  final SendPort sendPort = args[0] as SendPort;
  final scryptParameters = args[1] as ScryptParameters;
  final String? password = args[2] as String?;

  final kdf = Scrypt();
  kdf.init(scryptParameters);
  final Uint8List inp = Uint8List.fromList(utf8.encode(password!));
  final Uint8List keyBytes = Uint8List(32);
  kdf.deriveKey(inp, 0, keyBytes, 0);

  sendPort.send(keyBytes);
}

class AegisImportFileProcessor extends TokenMigrateFileProcessor {
  const AegisImportFileProcessor();

  static const String AEGIS_TYPE = 'type';
  static const String AEGIS_LABEL = 'name';
  static const String AEGIS_ISSUER = 'issuer';
  static const String AEGIS_SECRET = 'secret';
  static const String AEGIS_ALGORITHM = 'algo';
  static const String AEGIS_DIGITS = 'digits';
  static const String AEGIS_PERIOD = 'period';
  static const String AEGIS_COUNTER = 'counter';
  static const String AEGIS_PIN = 'pin';

  bool _isValidPlain(Map<String, dynamic> json) {
    try {
      return json['db'] != null && json['db'] is Map<String, dynamic> && json['db']['entries'] != null && json['db']['entries'].length > 0;
    } catch (e) {
      return false;
    }
  }

  bool _isValidEncrypted(Map<String, dynamic> json) {
    try {
      return json['header'] != null &&
          json['header']['slots'] != null &&
          (json['header']['slots'] as List).isNotEmpty &&
          json['db'] != null &&
          (json['db'] is String);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> fileIsValid({required XFile file}) async {
    final Map<String, dynamic> json;
    try {
      final String fileContent = await file.readAsString();
      json = jsonDecode(fileContent) as Map<String, dynamic>;
    } catch (e) {
      return false;
    }
    return _isValidPlain(json) || _isValidEncrypted(json);
  }

  @override
  Future<bool> fileNeedsPassword({required XFile file}) async {
    Map<String, dynamic> json;
    try {
      final String fileContent = await file.readAsString();
      json = jsonDecode(fileContent) as Map<String, dynamic>;
    } catch (e) {
      return false;
    }
    return _isValidEncrypted(json);
  }

  @override
  Future<List<Token>> processFile({required XFile file, String? password}) async {
    final String fileContent = await file.readAsString();
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(fileContent) as Map<String, dynamic>;
    } catch (e) {
      throw InvalidFileContentException('No valid Aegis import file');
    }
    if (_isValidPlain(json)) {
      return _processPlain(json);
    } else if (_isValidEncrypted(json)) {
      return _processEncrypted(json, password);
    } else {
      throw Exception('Invalid file format');
    }
  }

  List<Token> _processPlain(Map<String, dynamic> json) {
    final List<Token> tokens = [];
    if (json['db']['version'] != 2) {
      throw Exception('Unsupported backup version: ${json['db']['version']}.');
    }
    for (Map<String, dynamic> entry in json['db']['entries']) {
      try {
        if (entry['type'] != 'totp' && entry['type'] != 'hotp') {
          // TODO: support other token types
          Logger.warning('Unsupported token type: ${entry['type']}', name: '_processPlain#OtpAuthImportFileProcessor');
          continue;
        }
        Map<String, dynamic> info = entry['info'];
        final entryUriMap = {
          URI_TYPE: entry[AEGIS_TYPE],
          URI_LABEL: entry[AEGIS_LABEL],
          URI_ISSUER: entry[AEGIS_ISSUER],
          URI_SECRET: decodeSecretToUint8(info[AEGIS_SECRET] as String, Encodings.none),
          URI_ALGORITHM: info[AEGIS_ALGORITHM],
          URI_DIGITS: info[AEGIS_DIGITS],
          URI_PERIOD: info[AEGIS_PERIOD],
          URI_COUNTER: info[AEGIS_COUNTER],
          URI_PIN: info[AEGIS_PIN],
        };
        tokens.add(Token.fromUriMap(entryUriMap));
      } catch (e) {
        Logger.warning('Failed to parse token.', name: '_processPlain#OtpAuthImportFileProcessor');
      }
    }
    return tokens;
  }

  Future<Uint8List> runIsolatedKdf(ScryptParameters scryptParameters, String password) async {
    final receivePort = ReceivePort();
    try {
      Isolate.spawn(_isolatedKdf, [receivePort.sendPort, scryptParameters, password]);
    } catch (e) {
      receivePort.close();
    }
    final Uint8List keyBytes = await receivePort.first;
    return keyBytes;
  }

  Future<List<Token>> _processEncrypted(Map<String, dynamic> json, String? password) async {
    final String dbEncrypted = json['db'];
    final Map<String, dynamic> header = json['header'];
    final Map<String, dynamic> dbParams = header['params'];
    final Map<String, dynamic> key = header['slots'].first;
    final Map<String, dynamic> keyParams = key['key_params'];

    final passwordKeyBytes = await runIsolatedKdf(
      ScryptParameters(key['n'], key['r'], key['p'], 32, decodeHexString(key['salt'])),
      password!,
    );
    final slotNonceBytes = decodeHexString(keyParams['nonce']);
    final cipher = crypto.AesGcm.with256bits(nonceLength: slotNonceBytes.length);
    final List<int> masterKeyBytes;

    try {
      masterKeyBytes = await cipher.decrypt(
        crypto.SecretBox(
          decodeHexString(key['key']),
          nonce: slotNonceBytes,
          mac: crypto.Mac(decodeHexString(keyParams['tag'])),
        ),
        secretKey: crypto.SecretKey(passwordKeyBytes),
      );
    } catch (e) {
      throw BadDecryptionPasswordException('Wrong password or corrupted data');
    }
    final dbDecryptedBytes = await cipher.decrypt(
      crypto.SecretBox(
        base64Decode(dbEncrypted),
        nonce: decodeHexString(dbParams['nonce']),
        mac: crypto.Mac(decodeHexString(dbParams['tag'])),
      ),
      secretKey: crypto.SecretKey(masterKeyBytes),
    );
    final dbDecrypted = utf8.decode(dbDecryptedBytes);
    final dbJson = jsonDecode(dbDecrypted) as Map<String, dynamic>;
    return _processPlain({'db': dbJson});
  }
}
