import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mutex/mutex.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/interfaces/repo/container_repository.dart';
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
  Future<TokenContainer?> build({
    required String containerSerial,
  }) async {
    await _stateMutex.acquire();
    final credential = ref.read(credentialsProvider).value?.credentialsOf(containerSerial);
    if (credential == null) {
      _stateMutex.release();
      return null;
    }
    _repository = HybridTokenContainerRepository(
      localRepository: SecureTokenContainerRepository(containerId: containerSerial),
      remoteRepository: RemoteTokenContainerRepository(apiEndpoint: TokenContainerApiEndpoint(credential: credential)),
    );
    final initialState = _repository.loadContainerState();
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
    ref.read(tokenProvider.notifier).updateContainerTokens(savedState);
    state = AsyncValue.data(savedState);
    _stateMutex.release();
    return savedState;
  }

  void addLocalTemplates(List<TokenTemplate> maybePiTokenTemplates) {
    throw UnimplementedError();
  }
}

// final tokenContainerProvider = StateNotifierProvider.family<TokenContainerNotifier, TokenContainer, String>((ref, containerId) {
//   Logger.info("New tokenContainerStateProvider created", name: 'tokenContainerStateProvider');
//   final credentialsState = ref.watch(credentialsProvider);
//   Logger.warning("credentialsState: $credentialsState", name: 'tokenContainerStateProvider');
//   return TokenContainerNotifier(
//     ref: ref,
//     repository: HybridTokenContainerRepository(
//         localRepository: SecureTokenContainerRepository(containerId: 'local'),
//         remoteRepository: RemoteTokenContainerRepository(apiEndpoint: TokenContainerApiEndpoint(credentialsState: credentialsState))),
//   );
// });

@riverpod
class CredentialsProvider extends _$CredentialsProvider {
  final _stateMutex = Mutex();
  final _repoMutex = Mutex();
  late ContainerCredentialsRepository _repo;

  @override
  Future<CredentialsState> build() async {
    _repo = SecureContainerCredentialsRepository();
    return _repo.loadCredentialsState();
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

// final credentialsProvider = StateNotifierProvider<CredentialsNotifier, CredentialsState>((ref) {
//   Logger.info("New credentialsProvider created", name: 'credentialsProvider');
//   return CredentialsNotifier(repo: MockContainerCredentialsRepository());
// });

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

class CredentialsNotifier extends StateNotifier<CredentialsState> {
  final Mutex _repoMutex = Mutex();
  final ContainerCredentialsRepository _repo;
  late Future<CredentialsState> initState = _initState();

  Future<CredentialsState> _initState() async {
    final credentials = await _repo.loadCredentialsState();
    state = credentials;
    return credentials;
  }

  CredentialsNotifier({required ContainerCredentialsRepository repo, CredentialsState? initialState})
      : _repo = repo,
        super(initialState ?? const CredentialsState(credentials: [])) {
    _initState();
  }

  Future<CredentialsState> addCredentials(ContainerCredential credentials) async {
    final newState = await _saveCredentialsToRepo(credentials);
    state = newState;
    return newState;
  }

  Future<CredentialsState> deleteCredentials(ContainerCredential credentials) async {
    final newState = await _deleteCredentialsFromRepo(credentials);
    state = newState;
    return newState;
  }

  Future<CredentialsState> _saveCredentialsToRepo(ContainerCredential credentials) async {
    return await _repoMutex.protect(() async => await _repo.saveCredential(credentials));
  }

  Future<CredentialsState> _deleteCredentialsFromRepo(ContainerCredential credentials) async {
    return await _repoMutex.protect(() async => await _repo.deleteCredential(credentials.id));
  }
}

class SecureContainerCredentialsRepository extends ContainerCredentialsRepository {
  String get containerCredentialsKey => 'containerCredentials';
  String _keyOfId(String id) => '$containerCredentialsKey.$id';
  final Mutex _m = Mutex();
  Future<T> _protect<T>(Future<T> Function() f) => _m.protect(f);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _write(String key, String value) => _protect(() => _storage.write(key: key, value: value));
  Future<String?> _read(String key) async => await _protect(() async => await _storage.read(key: key));
  Future<Map<String, String>> _readAll() async => await _protect(() async => await _storage.readAll());
  Future<void> _delete(String key) => _protect(() => _storage.delete(key: key));

  @override
  Future<CredentialsState> loadCredentialsState() async {
    final credentialsJsonString = await _readAll();
    if (credentialsJsonString.isEmpty) return const CredentialsState(credentials: []);
    return CredentialsState.fromJsonStringList(credentialsJsonString.values.toList());
  }

  @override
  Future<CredentialsState> saveCredentialsState(CredentialsState credentialsState) async {
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
