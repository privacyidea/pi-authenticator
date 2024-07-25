import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/container_credentials.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../interfaces/api_endpoint.dart';
import '../model/enums/encodings.dart';
import '../model/enums/token_types.dart';
import '../utils/riverpod/riverpod_providers/state_notifier_providers/token_container_state_provider.dart';

final Map<String, Map<String, TokenTemplate>> _data = {
  '123': {
    'tokenID65381723659': TokenTemplate(
      data: {
        URI_LABEL: '123 container token 1',
        URI_SECRET: Encodings.base32.decode('SECRET'),
        URI_TYPE: TokenTypes.TOTP.name,
      },
    )
  }
};

class TokenContainerApiEndpoint implements ApiEndpioint<TokenContainer, CredentialsState> {
  @override
  final ContainerCredential credential;
  TokenContainerApiEndpoint({required this.credential});

  @override
  Future<TokenContainer> fetch() {
    throw UnimplementedError();
  }

  @override
  Future<TokenContainer> sync(TokenContainer containerState) async {
    Logger.warning('Syncing container with server', name: 'TokenContainerApiEndpoint');
    if (_data.containsKey(containerState.serial) == false) {
      return containerState.copyTransformInto<TokenContainerNotFound>(args: {'message': 'Container not found'});
    }
    Logger.warning('Container found', name: 'TokenContainerApiEndpoint');
    final localTemplates = containerState.localTokenTemplates;
    for (var localTemplate in localTemplates) {
      final oldLabel = localTemplate.data[URI_LABEL] as String;
      if (oldLabel.startsWith(containerState.serial) == true) {
        final merged = localTemplate.copyAddAll({
          URI_LABEL: oldLabel.replaceRange(oldLabel.length - 2, oldLabel.length - 1, '😀'),
        });
        _data[containerState.serial]![localTemplate.id!] = merged;
      }
    }
    final serverTemplatesMerged = _data[containerState.serial]!.values.toList();
    return TokenContainerSynced(
      lastSyncAt: DateTime.now(),
      serial: containerState.serial,
      description: 'Synced with server',
      syncedTokenTemplates: serverTemplatesMerged,
      localTokenTemplates: [],
    );
  }


}
