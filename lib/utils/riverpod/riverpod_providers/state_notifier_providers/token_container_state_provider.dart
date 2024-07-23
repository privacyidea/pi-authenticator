import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';

import '../../../../api/token_container_api_endpoint.dart';
import '../../../../model/states/token_container_state.dart';
import '../../../../model/tokens/container_credentials.dart';
import '../../../../repo/token_container_state_repositorys/hybrid_token_container_state_repository.dart';
import '../../../../repo/token_container_state_repositorys/secure_token_container_state_repository.dart.dart';
import '../../../../repo/token_container_state_repositorys/remote_token_container_state_repository.dart';
import '../../../../state_notifiers/token_container_notifier.dart';
import '../../../logger.dart';

final tokenContainerProvider = StateNotifierProvider<TokenContainerNotifier, TokenContainerState>((ref) {
  Logger.info("New tokenContainerStateProvider created", name: 'tokenContainerStateProvider');
  final c = ref.watch(credentialsProvider);
  return TokenContainerNotifier(
    ref: ref,
    repository: HybridTokenContainerStateRepository(

        localRepository: SecureTokenContainerStateRepository(containerId: 'local'),
        remoteRepository: RemoteTokenContainerStateRepository(apiEndpoint: TokenContainerApiEndpoint(credentials: c!))
    ),
  );
});

final credentialsProvider = StateNotifierProvider<CredentialsNotifier, ContainerCredentials?>((ref) {
  Logger.info("New credentialsProvider created", name: 'credentialsProvider');
  return CredentialsNotifier(repo: SecureContainerCredentialsRepository());
});

class CredentialsNotifier extends StateNotifier<ContainerCredentials?> {
  final Mutex _repoMutex = Mutex();
  final ContainerCredentialsRepository _repo;
  late Future<ContainerCredentials?> initState = _initState();

  Future<ContainerCredentials?> _initState() async {
    final credentials = await _repo.loadCredentials();
    state = credentials;
    return credentials;
  }

  CredentialsNotifier({required ContainerCredentialsRepository repo})
      : _repo = repo,
        super(null);

  Future<void> setCredentials(ContainerCredentials credentials) async {
    await _saveCredentialsToRepo(credentials);
    state = credentials;
  }

  Future<void> deleteCredentials() async {
    _deleteCredentialsFromRepo();
    state = null;
  }

  Future<void> _saveCredentialsToRepo(ContainerCredentials credentials) async {
    await _repoMutex.protect(() async => await _repo.saveCredentials(credentials));
  }

  Future<void> _deleteCredentialsFromRepo() async {
    await _repoMutex.protect(() async => await _repo.deleteCredentials());
  }
}

class SecureContainerCredentialsRepository extends ContainerCredentialsRepository {
  static String containerCredentialsKey = 'containerCredentials';
  final Mutex _m = Mutex();
  Future<T> _protect<T>(Future<T> Function() f) => _m.protect(f);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _write(String key, String value) => _protect(() => _storage.write(key: key, value: value));
  Future<String?> _read(String key) async => await _protect(() async => await _storage.read(key: key));
  Future<void> _delete(String key) => _protect(() => _storage.delete(key: key));

  @override
  Future<ContainerCredentials?> loadCredentials() async {
    final credentials = await _read(containerCredentialsKey);
    if (credentials == null) return null;
    return ContainerCredentials.fromJson(jsonDecode(credentials));
  }

  @override
  Future<void> saveCredentials(ContainerCredentials credentials) async {
    await _write(containerCredentialsKey, jsonEncode(credentials.toJson()));
  }

  @override
  Future<void> deleteCredentials() async {
    await _delete(containerCredentialsKey);
  }
}

abstract class ContainerCredentialsRepository {
  Future<void> saveCredentials(ContainerCredentials credentials);
  Future<ContainerCredentials?> loadCredentials();
  Future<void> deleteCredentials();
}
