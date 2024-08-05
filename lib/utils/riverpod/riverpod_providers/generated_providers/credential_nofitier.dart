import 'package:mutex/mutex.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../interfaces/repo/container_credentials_repository.dart';
import '../../../../model/riverpod_states/credentials_state.dart';
import '../../../../model/tokens/container_credentials.dart';
import '../../../../repo/secure_container_credentials_repository.dart';
import '../../../logger.dart';

part 'credential_nofitier.g.dart';

@Riverpod(keepAlive: true)
class CredentialsNotifier extends _$CredentialsNotifier {
  final _stateMutex = Mutex();
  final _repoMutex = Mutex();
  late ContainerCredentialsRepository _repo;

  @override
  Future<CredentialsState> build() async {
    _repo = SecureContainerCredentialsRepository();
    Logger.warning('Building credentialsProvider', name: 'CredentialsNotifier');
    return _repo.loadCredentialsState();
  }

  @override
  Future<CredentialsState> update(
    FutureOr<CredentialsState> Function(CredentialsState state) cb, {
    FutureOr<CredentialsState> Function(Object, StackTrace)? onError,
  }) async {
    Logger.warning('Updating credentialsProvider', name: 'CredentialsNotifier');
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
