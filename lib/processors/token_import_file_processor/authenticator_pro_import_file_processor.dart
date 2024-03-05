import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/src/types/interface.dart';
import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart';

import 'package:privacyidea_authenticator/model/tokens/token.dart';

import 'token_import_file_processor_interface.dart';

class AuthenticatorProImportFileProcessor extends TokenImportFileProcessor {
  static const String HEADER = "AUTHENTICATORPRO";
  static const String HEADER_LEGACY = "AuthenticatorPro";
  @override
  Future<bool> fileIsValid({required XFile file}) async {
    try {
      final content = await file.readAsString();
      json.decode(content);
      return true;
    } catch (e) {
      try {
        final content = await file.readAsBytes();
        final headerByteLength = utf8.encode(HEADER).length;
        final header = content.sublist(0, headerByteLength);
        final fileHeader = utf8.decode(header);
        if (fileHeader == HEADER || fileHeader == HEADER_LEGACY) {
          return true;
        }
        return false;
      } catch (e) {
        return false;
      }
    }
  }

  @override
  Future<bool> fileNeedsPassword({required XFile file}) async {
    try {
      final content = await file.readAsString();
      json.decode(content);
    } catch (e) {
      final content = await file.readAsBytes();
      final headerByteLength = utf8.encode(HEADER).length;
      content.sublist(0, headerByteLength);
      return true;
    }
    return false;
  }

  @override
  Future<List<Token>> processFile({required XFile file, String? password}) async {
    try {
      final bytes = await file.readAsBytes();
      Uint8Buffer uint8buffer = Uint8Buffer(data: bytes);
      final headerByteLength = utf8.encode(HEADER).length;
      final fileHeader = utf8.decode(uint8buffer.readBytes(headerByteLength));

      return switch (fileHeader) {
        HEADER => _process(uint8buffer: uint8buffer, password: password!),
        HEADER_LEGACY => _processLegacy(uint8buffer: uint8buffer, password: password!),
        _ => throw Exception('Invalid file header'),
      };
    } catch (e) {
      return _processPlain(file: file);
    }
  }

  Future<List<Token>> _process({required Uint8Buffer uint8buffer, required String password}) async {
    // const int KEY_SIZE = 32; // 32 bytes = 256 bits
    // const int MEMORY_COST = 16; // 2^16 KiB = 64 MiB
    // const int PARALLELISM = 4;
    // const int ITERATIONS = 3;
    const int SALT_SIZE = 16;
    const int IV_SIZE = 12;

    // AES/GCM/NoPadding
    final Cipher cypher = AesGcm.with256bits();
    final salt = uint8buffer.readBytes(SALT_SIZE);
    final iv = uint8buffer.readBytes(IV_SIZE);
    final data = uint8buffer.readBytesToEnd();

    final aesEncrypted = AesEncrypted(
      cypher: cypher,
      salt: salt,
      iv: iv,
      data: data,
    );
  }

  Future<List<Token>> _processLegacy({required Uint8Buffer uint8buffer, required String password}) async {
    const int ITERATIONS = 64000;
    const int KEY_SIZE = 32 * Byte.SIZE;
    const int SALT_SIZE = 20;

    // AES/CBC/PKCS5Padding

    final cypher = AesCbc.with256bits();
    final salt = uint8buffer.readBytes(SALT_SIZE);
    final iv = uint8buffer.readBytes(cypher.blockLength);
  }

  Future<List<Token>> _processPlain({required XFile file}) async {}
}

class Uint8Buffer {
  int currentPos = 0;
  Uint8List data;
  Uint8Buffer({required this.data});
  factory Uint8Buffer.fromList(List<int> list) {
    return Uint8Buffer(data: Uint8List.fromList(list));
  }

  void writeBytes(Uint8List bytes) {
    data = Uint8List.fromList([...data, ...bytes]);
  }

  Uint8List readBytes(int length) {
    final bytes = data.sublist(currentPos, currentPos + length);
    currentPos += length;
    return bytes;
  }

  Uint8List readBytesToEnd() {
    final bytes = data.sublist(currentPos);
    currentPos = data.length;
    return bytes;
  }
}

class AesEncrypted {
  final Cipher cypher;
  final Uint8List salt;
  final Uint8List iv;
  final Uint8List data;

  // final int iterations;
  final int parallelism;
  final int memoryCost;
  // final int keySize;

  final Pbkdf2 pbkdf2;

  AesEncrypted(
      {required this.parallelism,
      required this.memoryCost,
      required this.pbkdf2,
      required this.cypher,
      required this.salt,
      required this.iv,
      required this.data});

  Future<Uint8List> decrypt(String password) async {
    final SecretKey secretKey = await pbkdf2.deriveKeyFromPassword(password: password, nonce: salt);
    final Uint8List keyBytes = Uint8List.fromList(await secretKey.extractBytes());
    final Key key = Key(keyBytes);

    final encrypter = Encrypter(AES(key, mode: aesMode, padding: padding));
    final IV iv = IV(this.iv);
    try {
      return Uint8List.fromList(encrypter.decryptBytes(Encrypted(data), iv: iv));
    } catch (e) {
      throw Exception('Wrong password or corrupted data');
    }
  }
}
