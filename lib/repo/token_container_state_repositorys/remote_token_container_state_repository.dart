import 'package:collection/collection.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';

import '../../api/token_container_api_endpoint.dart';
import '../../interfaces/repo/container_repository.dart';
import '../../model/states/token_container_state.dart';

class RemoteTokenContainerStateRepository implements TokenContainerStateRepository {
  final TokenContainerApiEndpoint apiEndpoint;
  final Mutex _m = Mutex();

  Future<void> _protect(Future<void> Function() f) => _m.protect(f);

  RemoteTokenContainerStateRepository({required this.apiEndpoint});

  @override
  Future<TokenContainerState> saveContainerState(TokenContainerState containerState) {
    throw UnimplementedError();
  }

  @override
  Future<TokenContainerState> loadContainerState() => _fetchContainerState();

  Future<TokenContainerState> _fetchContainerState() async {
    TokenContainerState? state;
    await _protect(() async => state = await apiEndpoint.fetch());
    return state!;
  }

  @override
  Future<TokenTemplate?> loadTokenTemplate(String tokenTemplateId) async {
    final state = await loadContainerState();
    final template = state.tokenTemplates.firstWhereOrNull((element) => element.id == tokenTemplateId);
    return template;
  }

  @override
  Future<TokenTemplate> saveTokenTemplate(TokenTemplate tokenTemplate) async {
    final state = await loadContainerState();
    final templateIndex = state.tokenTemplates.indexWhere((element) => element.id == tokenTemplate.id);
    if (templateIndex == -1) {
      state.tokenTemplates.add(tokenTemplate);
    } else {
      state.tokenTemplates[templateIndex] = tokenTemplate;
    }
    await saveContainerState(state);
    return tokenTemplate;
  }
}
