import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';
import '../interfaces/repo/container_credentials_repository.dart';

import '../model/enums/algorithms.dart';
import '../model/riverpod_states/credentials_state.dart';
import '../model/tokens/container_credentials.dart';
import '../utils/logger.dart';

class SecureContainerCredentialsRepository extends ContainerCredentialsRepository {
  String get containerCredentialsKey => 'containerCredentials';
  String _keyOfSerial(String id) => '$containerCredentialsKey.$id';
  final Mutex _m = Mutex();
  Future<T> _protect<T>(Future<T> Function() f) => _m.protect(f);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _write(String key, String value) => _protect(() => _storage.write(key: key, value: value));
  Future<String?> _read(String key) async => await _protect(() async => await _storage.read(key: key));
  Future<Map<String, String>> _readAll() async =>
      await _protect(() async => (await _storage.readAll())..removeWhere((key, value) => !key.startsWith(containerCredentialsKey)));
  Future<void> _delete(String key) => _protect(() => _storage.delete(key: key));

  @override
  Future<CredentialsState> loadCredentialsState() async {
    final credentialsJsonString = await _readAll();
    Logger.warning('Loaded credentials: $credentialsJsonString', name: 'SecureContainerCredentialsRepository');
    if (credentialsJsonString.isEmpty) {
      final credentialState = CredentialsState(credentials: [
        ContainerCredential.finalized(
          serial: '123',
          ecKeyAlgorithm: EcKeyAlgorithm.secp256k1,
          hashAlgorithm: Algorithms.SHA256,
          issuer: '',
          nonce: '',
          timestamp: DateTime.now(),
          finalizationUrl: Uri(),
          publicServerKey: '',
          publicClientKey: '',
          privateClientKey: '',
        ),
      ]);
      Logger.warning('Returning default credentials: $credentialState', name: 'SecureContainerCredentialsRepository');
      return credentialState;
    }
    return CredentialsState.fromJsonStringList(credentialsJsonString.values.toList());
  }

  @override
  Future<CredentialsState> saveCredentialsState(CredentialsState credentialsState) async {
    Logger.warning('Saving credentials: $credentialsState', name: 'SecureContainerCredentialsRepository');
    final futures = <Future>[];
    for (var credential in credentialsState.credentials) {
      futures.add(saveCredential(credential));
    }
    await Future.wait(futures);
    return await loadCredentialsState();
  }

  @override
  Future<CredentialsState> deleteCredential(String id) async {
    await _delete(_keyOfSerial(id));
    return await loadCredentialsState();
  }

  @override
  Future<CredentialsState> deleteAllCredentials() async {
    final credentialKeys = (await _readAll()).keys.where((key) => key.startsWith(containerCredentialsKey));
    final futures = <Future>[];
    for (var key in credentialKeys) {
      futures.add(_delete(key));
    }
    await Future.wait(futures);
    return await loadCredentialsState();
  }

  @override
  Future<ContainerCredential?> loadCredential(String id) async {
    final credentialJsonString = await _read(_keyOfSerial(id));
    if (credentialJsonString == null) return null;
    return ContainerCredential.fromJson(jsonDecode(credentialJsonString));
  }

  @override
  Future<CredentialsState> saveCredential(ContainerCredential credential) async {
    final credentialJsonString = jsonEncode(credential.toJson());
    await _write(_keyOfSerial(credential.serial), credentialJsonString);
    return await loadCredentialsState();
  }
}
