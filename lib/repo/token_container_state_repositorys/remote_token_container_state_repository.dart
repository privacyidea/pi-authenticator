import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../../api/token_container_api_endpoint.dart';
import '../../interfaces/repo/container_repository.dart';
import '../../model/token_container.dart';

class RemoteTokenContainerRepository implements TokenContainerRepository {
  final TokenContainerApiEndpoint apiEndpoint;
  final Mutex _m = Mutex();

  Future<TokenContainer> _protect(Future<TokenContainer> Function() f) async => _m.protect(f);

  RemoteTokenContainerRepository({required this.apiEndpoint});

  @override
  Future<TokenContainer> saveContainerState(TokenContainer containerState) async => await _saveContainerState(containerState);

  Future<TokenContainer> _saveContainerState(TokenContainer containerState) async {
    Logger.info('Saving container state', name: 'RemoteTokenContainerRepository');
    return await _protect(() async => await apiEndpoint.sync(containerState));
  }

  @override
  Future<TokenContainer> loadContainerState() {
    Logger.info('Loading container state', name: 'RemoteTokenContainerRepository');
    return _fetchContainerState();
  }

  Future<TokenContainer> _fetchContainerState() async => await _protect(() async => await apiEndpoint.fetch());


}
