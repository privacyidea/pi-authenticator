import 'package:mutex/mutex.dart';

import '../../api/token_container_api_endpoint.dart';
import '../../interfaces/repo/container_repository.dart';
import '../../model/states/token_container_state.dart';

class RemoteTokenContainerStateRepository implements TokenContainerStateRepository {
  final TokenContainerApiEndpoint apiEndpoint;
  final Mutex _m = Mutex();

  Future<TokenContainerState> _protect(Future<TokenContainerState> Function() f) async => _m.protect(f);

  RemoteTokenContainerStateRepository({required this.apiEndpoint});

  @override
  Future<TokenContainerState> saveContainerState(TokenContainerState containerState) async => await _saveContainerState(containerState);

  Future<TokenContainerState> _saveContainerState(TokenContainerState containerState) async {
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
  Future<TokenContainerState> loadContainerState() => _fetchContainerState();

  Future<TokenContainerState> _fetchContainerState() async => await _protect(() async => await apiEndpoint.fetch());

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
