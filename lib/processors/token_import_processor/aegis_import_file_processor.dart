// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'package:privacyidea_authenticator/model/enums/encodings.dart';

import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../../utils/crypto_utils.dart';
import 'token_file_import_processor_interface.dart';

class AegisImportFileProcessor extends TokenFileImportProcessor {
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
  Future<List<Token>> process({required XFile file, String? password}) async {
    final String fileContent = await file.readAsString();
    final json = jsonDecode(fileContent) as Map<String, dynamic>;
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
    }
    return tokens;
  }

  List<Token> _processEncrypted(Map<String, dynamic> json, String? password) {
    final List<Token> tokens = [];
    final String dbEncrypted = json['db'];
    final Map<String, dynamic> header = json['header'];
    return tokens;
  }

  final examplePlain = [
    {
      "type": "totp",
      "uuid": "ec530668-b9b6-4a87-bcad-e9872a71f844",
      "name": "ybyb",
      "issuer": "ynynsn",
      "note": "dhdn",
      "favorite": false,
      "icon": null,
      "info": {"secret": "AJSVANABSA", "algo": "SHA1", "digits": 6, "period": 30}
    },
    {
      "type": "hotp",
      "uuid": "2943a67b-0a1d-4d7b-b369-cb08b7a33852",
      "name": "sbsbb",
      "issuer": "",
      "note": "",
      "favorite": false,
      "icon": null,
      "info": {"secret": "BAJJG", "algo": "SHA1", "digits": 6, "counter": 0}
    },
    {
      "type": "steam",
      "uuid": "6b1003c9-1751-4c9e-8902-360f9ab72319",
      "name": "Steam",
      "issuer": "bynyn",
      "note": "y\n",
      "favorite": false,
      "icon": null,
      "info": {"secret": "YNYMYMYN", "algo": "SHA1", "digits": 5, "period": 30}
    },
    {
      "type": "motp",
      "uuid": "021c5fdd-fbe9-44ab-b685-ab8b27368a65",
      "name": "motp",
      "issuer": "",
      "note": "",
      "favorite": false,
      "icon": null,
      "info": {"secret": "VKVKVKVKVKVKVKVKVKVKVKVKVI", "algo": "MD5", "digits": 6, "period": 10, "pin": "1234"}
    }
  ];
}
