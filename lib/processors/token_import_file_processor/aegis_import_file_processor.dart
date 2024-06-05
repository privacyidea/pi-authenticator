// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:encrypt/encrypt.dart';
import 'package:file_selector/file_selector.dart';
import 'package:pointycastle/export.dart';

import '../../l10n/app_localizations.dart';
import '../../model/enums/encodings.dart';
import '../../model/enums/token_origin_source_type.dart';
import '../../model/enums/token_types.dart';
import '../../model/extensions/enums/encodings_extension.dart';
import '../../model/extensions/enums/token_origin_source_type.dart';
import '../../model/processor_result.dart';
import '../../model/tokens/token.dart';
import '../../utils/errors.dart';
import '../../utils/globals.dart';
import '../../utils/identifiers.dart';
import '../../utils/logger.dart';
import '../../utils/token_import_origins.dart';
import '../../utils/utils.dart';
import 'token_import_file_processor_interface.dart';
import 'two_fas_import_file_processor.dart';

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

class AegisImportFileProcessor extends TokenImportFileProcessor {
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
  static const String AEGIS_ID = 'uuid';

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
  Future<bool> fileIsValid(XFile file) async {
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
  Future<bool> fileNeedsPassword(XFile file) async {
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
  Future<List<ProcessorResult<Token>>> processFile(XFile file, {String? password}) async {
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

  Future<List<ProcessorResult<Token>>> _processPlain(Map<String, dynamic> json) async => switch (json['db']['version'] as int) {
        2 => _processPlainV2(json),
        3 => _processPlainV3(json),
        _ => _processPlainTryLatest(json),
      };

  Future<List<ProcessorResult<Token>>> _processPlainTryLatest(Map<String, dynamic> json) async {
    try {
      return await _processPlainV3(json);
    } catch (_) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, name) => localizations.unsupported(name, value),
        unlocalizedMessage: 'Unsupported backup version: ${json['db']['version']}.',
        invalidValue: json['db']['version'],
        name: 'aegis backup version',
      );
    }
  }

  Future<List<ProcessorResult<Token>>> _processPlainV2(Map<String, dynamic> json) {
    final results = <ProcessorResult<Token>>[];
    final localization = globalContextSync != null ? AppLocalizations.of(globalContextSync!)! : null;
    for (Map<String, dynamic> entry in json['db']['entries']) {
      try {
        if (entry['type'] != 'totp' && entry['type'] != 'hotp') {
          // TODO: support other token types
          Logger.warning('Unsupported token type: ${entry['type']}', name: '_processPlain#OtpAuthImportFileProcessor');
          results.add(ProcessorResult.failed(localization?.unsupported('token type', entry['type']) ?? 'Unsupported token type: ${entry['type']}'));
          continue;
        }
        Map<String, dynamic> info = entry['info'];
        final entryUriMap = {
          URI_TYPE: entry[AEGIS_TYPE],
          URI_LABEL: entry[AEGIS_LABEL],
          URI_ISSUER: entry[AEGIS_ISSUER],
          URI_SECRET: Encodings.none.decode(info[AEGIS_SECRET]),
          URI_ALGORITHM: info[AEGIS_ALGORITHM],
          URI_DIGITS: info[AEGIS_DIGITS],
          URI_PERIOD: info[AEGIS_PERIOD],
          URI_COUNTER: info[AEGIS_COUNTER],
          URI_PIN: info[AEGIS_PIN],
          URI_ORIGIN: TokenOriginSourceType.backupFile.toTokenOrigin(
            originName: TokenImportOrigins.aegisAuthenticator.appName,
            isPrivacyIdeaToken: false,
            data: jsonEncode(entry),
          ),
        };
        final token = Token.fromUriMap(entryUriMap);
        results.add(ProcessorResult.success(token.copyWith(id: entry[AEGIS_ID])));
      } on LocalizedException catch (e) {
        results.add(ProcessorResult.failed(localization != null ? e.localizedMessage(localization) : e.unlocalizedMessage));
      } catch (e) {
        Logger.error('Failed to parse token.', name: 'AegisImportFileProcessor#_processPlain', error: e, stackTrace: StackTrace.current);
        results.add(ProcessorResult.failed(e.toString()));
      }
    }
    return Future.value(results);
  }

  Future<List<ProcessorResult<Token>>> _processPlainV3(Map<String, dynamic> json) {
    final results = <ProcessorResult<Token>>[];
    final localization = globalContextSync != null ? AppLocalizations.of(globalContextSync!)! : null;
    final entries = json['db']['entries'] as List;
    for (Map<String, dynamic> entry in entries) {
      try {
        if (doesThrow(() => TokenTypes.values.byName((entry['type'] as String).toUpperCase()))) {
          // TODO: support other token types
          Logger.warning('Unsupported token type: ${entry['type']}', name: '_processPlain#OtpAuthImportFileProcessor');
          results.add(ProcessorResult.failed(localization?.unsupported('token type', entry['type']) ?? 'Unsupported token type: ${entry['type']}'));
          continue;
        }
        Map<String, dynamic> info = entry['info'];
        final entryUriMap = {
          URI_TYPE: entry[AEGIS_TYPE],
          URI_LABEL: entry[AEGIS_LABEL],
          URI_ISSUER: entry[AEGIS_ISSUER],
          URI_SECRET: Encodings.base32.decode(info[AEGIS_SECRET]),
          URI_ALGORITHM: info[AEGIS_ALGORITHM],
          URI_DIGITS: info[AEGIS_DIGITS],
          URI_PERIOD: info[AEGIS_PERIOD],
          URI_COUNTER: info[AEGIS_COUNTER],
          URI_PIN: info[AEGIS_PIN],
          URI_ORIGIN: TokenOriginSourceType.backupFile.toTokenOrigin(
            originName: TokenImportOrigins.aegisAuthenticator.appName,
            isPrivacyIdeaToken: false,
            data: jsonEncode(entry),
          ),
        };
        results.add(ProcessorResult.success(Token.fromUriMap(entryUriMap)));
      } on LocalizedException catch (e) {
        results.add(ProcessorResultFailed(localization != null ? e.localizedMessage(localization) : e.unlocalizedMessage));
      } catch (e) {
        Logger.error('Failed to parse token.', name: 'AegisImportFileProcessor#_processPlain', error: e, stackTrace: StackTrace.current);
        results.add(ProcessorResultFailed(e.toString()));
      }
    }

    return Future.value(results);
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

  Future<List<ProcessorResult<Token>>> _processEncrypted(Map<String, dynamic> json, String? password) async {
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
