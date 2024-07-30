import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/interfaces/repo/container_repository.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../api/token_container_api_endpoint.dart';
import '../../../../model/states/token_state.dart';
import '../../../../model/token_container.dart';
import '../../../../repo/token_container_state_repositorys/hybrid_token_container_state_repository.dart';
import '../../../../repo/token_container_state_repositorys/remote_token_container_state_repository.dart';
import '../../../../repo/token_container_state_repositorys/secure_token_container_state_repository.dart.dart';
import '../../../../model/tokens/container_credentials.dart';
import 'token_provider.dart';

part 'token_container_state_provider.g.dart';

@riverpod
class TokenContainerProvider extends _$TokenContainerProvider {
  late final TokenContainerRepository _repository;
  final Mutex _stateMutex = Mutex(); // Mutex to protect the state from being accessed while still waiting for the newest state to be delivered
  final Mutex _repoMutex = Mutex(); // Mutex to protect the repository from being accessed while still waiting for the newest state to be delivered

  @override
  Future<TokenContainer> build({
    required ContainerCredential credential,
  }) async {
    Logger.info('New tokenContainerStateProvider created', name: 'TokenContainerProvider#build');
    await _stateMutex.acquire();
    _repository = HybridTokenContainerRepository(
      localRepository: SecureTokenContainerRepository(containerId: credential.serial),
      remoteRepository: RemoteTokenContainerRepository(apiEndpoint: TokenContainerApiEndpoint(credential: credential)),
    );
    final initialState = _repository.loadContainerState();
    Logger.debug('Initial state: $initialState', name: 'TokenContainerProvider#build');
    _stateMutex.release();
    return initialState;
  }

  Future<TokenContainer> _saveToRepo(TokenContainer state) async {
    await _repoMutex.acquire();
    final newState = await _repository.saveContainerState(state);
    _repoMutex.release();
    return newState;
  }

  Future<TokenContainer> handleTokenState(TokenState tokenState) async {
    await _stateMutex.acquire();
    final localTokens = tokenState.tokens.maybePiTokens;
    final oldState = state.value;
    if (oldState == null) throw Exception('TokenContainer is null');
    final containerTokens = tokenState.containerTokens(oldState.serial);
    final localTokenTemplates = localTokens.toTemplates();
    final containerTokenTemplates = containerTokens.toTemplates();
    final newState = oldState.copyWith(localTokenTemplates: localTokenTemplates, syncedTokenTemplates: containerTokenTemplates);
    final savedState = await _saveToRepo(newState);
    if (savedState is! TokenContainerSynced) {
      Logger.error('Failed to save state to repo', name: 'TokenContainerProvider#handleTokenState');
      return savedState;
    }
    await ref.read(tokenProvider.notifier).updateContainerTokens(savedState);
    state = AsyncValue.data(savedState);
    _stateMutex.release();
    return savedState;
  }

  /// Adds the given [maybePiTokenTemplates] to the localTokenTemplates of the container
  /// and saves the new state to the repository. The rpository decides waht to do with the new state.
  /// The saved state from the repo can contain the maybePiTokenTemplates or not.
  Future<TokenContainer> tryAddLocalTemplates(List<TokenTemplate> maybePiTokenTemplates) async {
    Logger.info(
      'Trying to add (${maybePiTokenTemplates.length}) local templates to container (${credential.serial}).',
      name: 'TokenContainerProvider#tryAddLocalTemplates',
    );
    Logger.debug('Local templates (${maybePiTokenTemplates.length})', name: 'TokenContainerProvider#tryAddLocalTemplates');
    await _stateMutex.acquire();
    final oldState = (await future);
    final newLocalTokenTemplates = [...maybePiTokenTemplates];
    final newState = oldState.copyWith(localTokenTemplates: newLocalTokenTemplates);
    final savedState = await _saveToRepo(newState);
    Logger.debug(
      'Saved TokenContainer: Synced(${savedState.syncedTokenTemplates.length}) | Local(${savedState.localTokenTemplates.length})',
      name: 'TokenContainerProvider#tryAddLocalTemplates',
    );
    await ref.read(tokenProvider.notifier).updateContainerTokens(savedState);
    state = AsyncValue.data(savedState);
    _stateMutex.release();
    return savedState;
  }

  Future<TokenContainer> handleDeletedTokenTemplates(List<TokenTemplate> deletedPiTokenTemplates) async {
    Logger.info(
      'Removing (${deletedPiTokenTemplates.length}) deleted token templates from container (${credential.serial}).',
      name: 'TokenContainerProvider#handleDeletedTokenTemplates',
    );
    Logger.debug('Deleted token templates (${deletedPiTokenTemplates.length})', name: 'TokenContainerProvider#handleDeletedTokenTemplates');
    await _stateMutex.acquire();
    final oldState = (await future);
    final newLocalTokenTemplates = oldState.localTokenTemplates.where((template) => !deletedPiTokenTemplates.contains(template)).toList();
    final newState = oldState.copyWith(localTokenTemplates: newLocalTokenTemplates);
    final savedState = await _saveToRepo(newState);
    Logger.debug(
      'Saved TokenContainer: Synced(${savedState.syncedTokenTemplates.length}) | Local(${savedState.localTokenTemplates.length})',
      name: 'TokenContainerProvider#handleDeletedTokenTemplates',
    );
    await ref.read(tokenProvider.notifier).updateContainerTokens(savedState);
    state = AsyncValue.data(savedState);
    _stateMutex.release();
    return savedState;
  }
}

@Riverpod(keepAlive: true)
class CredentialsProvider extends _$CredentialsProvider {
  final _stateMutex = Mutex();
  final _repoMutex = Mutex();
  late ContainerCredentialsRepository _repo;

  @override
  Future<CredentialsState> build() async {
    _repo = SecureContainerCredentialsRepository();
    Logger.warning('Building credentialsProvider', name: 'CredentialsProvider');
    return _repo.loadCredentialsState();
  }

  @override
  Future<CredentialsState> update(
    FutureOr<CredentialsState> Function(CredentialsState state) cb, {
    FutureOr<CredentialsState> Function(Object, StackTrace)? onError,
  }) async {
    Logger.warning('Updating credentialsProvider', name: 'CredentialsProvider');
    return super.update(cb, onError: onError);
  }

  Future<CredentialsState> addCredential(ContainerCredential credential) async {
    await _stateMutex.acquire();
    final newState = await _saveCredentialsToRepo(credential);
    state = AsyncValue.data(newState);
    _stateMutex.release();
    return newState;
  }

  Future<CredentialsState> _saveCredentialsToRepo(ContainerCredential credential) async {
    return await _repoMutex.protect(() async => await _repo.saveCredential(credential));
  }
}

class MockContainerCredentialsRepository extends ContainerCredentialsRepository {
  final state = CredentialsState(credentials: [
    ContainerCredential(
      id: '123',
      serial: '123',
    )
  ]);

  @override
  Future<CredentialsState> deleteAllCredentials() => Future.value(state);

  @override
  Future<CredentialsState> deleteCredential(String id) => Future.value(state);

  @override
  Future<ContainerCredential?> loadCredential(String id) => Future.value(state.credentials.firstOrNull);

  @override
  Future<CredentialsState> loadCredentialsState() => Future.value(state);

  @override
  Future<CredentialsState> saveCredential(ContainerCredential credential) => Future.value(state);

  @override
  Future<CredentialsState> saveCredentialsState(CredentialsState credentialsState) => Future.value(state);
}

@JsonSerializable()
class CredentialsState {
  final List<ContainerCredential> credentials;

  const CredentialsState({required this.credentials});

  factory CredentialsState.fromJson(Map<String, dynamic> json) => _$CredentialsStateFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialsStateToJson(this);

  factory CredentialsState.fromJsonStringList(List<String> jsonStrings) {
    final credentials = jsonStrings.map((jsonString) => ContainerCredential.fromJson(jsonDecode(jsonString))).toList();
    return CredentialsState(credentials: credentials);
  }

  @override
  String toString() {
    return 'CredentialsState{credentials: $credentials}';
  }

  ContainerCredential? credentialsOf(String containerSerial) => credentials.firstWhereOrNull((credential) => credential.serial == containerSerial);
}

class SecureContainerCredentialsRepository extends ContainerCredentialsRepository {
  String get containerCredentialsKey => 'containerCredentials';
  String _keyOfId(String id) => '$containerCredentialsKey.$id';
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
        ContainerCredential(
          id: '123',
          serial: '123',
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
    await _delete(_keyOfId(id));
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
    final credentialJsonString = await _read(_keyOfId(id));
    if (credentialJsonString == null) return null;
    return ContainerCredential.fromJson(jsonDecode(credentialJsonString));
  }

  @override
  Future<CredentialsState> saveCredential(ContainerCredential credential) async {
    final credentialJsonString = jsonEncode(credential.toJson());
    await _write(_keyOfId(credential.id), credentialJsonString);
    return await loadCredentialsState();
  }
}

abstract class ContainerCredentialsRepository {
  Future<CredentialsState> saveCredential(ContainerCredential credential);
  Future<CredentialsState> saveCredentialsState(CredentialsState credentialsState);
  Future<CredentialsState> loadCredentialsState();
  Future<ContainerCredential?> loadCredential(String id);
  Future<CredentialsState> deleteAllCredentials();
  Future<CredentialsState> deleteCredential(String id);
}
