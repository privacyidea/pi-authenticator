import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';

import '../interfaces/api_endpoint.dart';
import '../model/states/token_container_state.dart';
import '../model/tokens/container_credentials.dart';

class TokenContainerApiEndpoint implements ApiEndpioint<TokenContainerState, ContainerCredentials> {
  final Map<String, Map<String, TokenTemplate>> _data = {};

  @override
  final ContainerCredentials credentials;

  TokenContainerApiEndpoint({required this.credentials});

  @override
  Future<TokenContainerState> fetch() {
    throw UnimplementedError();
  }

  @override
  Future<TokenContainerState> sync(TokenContainerState containerState) async {
    if (_data.containsKey(containerState.serial) == false) {
      return containerState.copyTransformInto<TokenContainerStateDeleted>(data: 'Container not found');
    }
    final localTemplates = containerState.localTokenTemplates;
    for (var localTemplate in localTemplates) {
      if (localTemplate.id?.startsWith(containerState.serial) == true) {
        final merged = localTemplate.copyWith({
          URI_LABEL: (localTemplate.data[URI_LABEL] as String).replaceFirst(r'.', '😀'),
        });
        _data[containerState.serial]![localTemplate.id!] = merged;
      }
    }
    final serverTemplatesMerged = _data[containerState.serial]!.values.toList();
    return TokenContainerStateSynced(
      serial: containerState.serial,
      description: 'Synced with server',
      type: 'synced',
      syncedTokenTemplates: serverTemplatesMerged,
    );
  }
}
