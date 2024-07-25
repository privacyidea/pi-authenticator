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
    Logger.warning('Saving container state', name: 'RemoteTokenContainerRepository');
    try {
      return await _protect(() async {
        var synced = await apiEndpoint.sync(containerState);
        return synced;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TokenContainer> loadContainerState() {
    Logger.warning('Loading container state', name: 'RemoteTokenContainerRepository');
    return _fetchContainerState();
  }

  Future<TokenContainer> _fetchContainerState() async => await _protect(() async => await apiEndpoint.fetch());

  // @override
  // Future<TokenTemplate?> loadTokenTemplate(String tokenTemplateId) async {
  //   final state = await loadContainerState();
  //   final template = state.tokenTemplates.firstWhereOrNull((element) => element.id == tokenTemplateId);
  //   return template;
  // }

  // @override
  // Future<TokenTemplate> saveTokenTemplate(TokenTemplate tokenTemplate) async {
  //   final state = await loadContainerState();
  //   if (templateIndex == -1) {
  //     state.tokenTemplates.add(tokenTemplate);
  //   } else {
  //     state.tokenTemplates[templateIndex] = tokenTemplate;
  //   }
  //   await saveContainerState(state);
  //   return tokenTemplate;
  // }
}
