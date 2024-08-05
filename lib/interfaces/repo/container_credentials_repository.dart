import '../../model/riverpod_states/credentials_state.dart';
import '../../model/tokens/container_credentials.dart';

abstract class ContainerCredentialsRepository {
  Future<CredentialsState> saveCredential(ContainerCredential credential);
  Future<CredentialsState> saveCredentialsState(CredentialsState credentialsState);
  Future<CredentialsState> loadCredentialsState();
  Future<ContainerCredential?> loadCredential(String id);
  Future<CredentialsState> deleteAllCredentials();
  Future<CredentialsState> deleteCredential(String id);
}
