import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/container_credentials.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../interfaces/api_endpoint.dart';
import '../model/enums/encodings.dart';
import '../model/enums/token_types.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_container_provider.dart';

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
    Logger.info('Syncing container with server', name: 'TokenContainerApiEndpoint#sync');
    final serverTemplates = _data[containerState.serial];
    if (serverTemplates == null) {
      return containerState.copyTransformInto<TokenContainerNotFound>(args: {'message': 'Container not found'});
    }
    for (var templateSerial in serverTemplates.keys) {
      final template = serverTemplates[templateSerial];
      if (template?.serial == null) {
        // Add serial(key of map) to template
        serverTemplates[templateSerial] = template!.copyAddAll({URI_SERIAL: templateSerial});
      }
    }
    final localTemplates = containerState.localTokenTemplates;
    Logger.debug('Local templates: ${localTemplates.length}', name: 'TokenContainerApiEndpoint#sync');
    for (var localTemplate in localTemplates) {
      final oldLabel = localTemplate.data[URI_LABEL] as String;
      Logger.debug('Old label: "$oldLabel" starts with "${containerState.serial}" ?', name: 'TokenContainerApiEndpoint#sync');
      if (oldLabel.startsWith(containerState.serial) == true) {
        var merged = localTemplate.copyAddAll({
          URI_LABEL: '123 😀',
        });
        Logger.debug('New label: "${merged.data[URI_LABEL]}"', name: 'TokenContainerApiEndpoint#sync');
        if (merged.serial == null) {
          merged = merged.copyWith(data: merged.copyAddAll({URI_SERIAL: 'tokenID${DateTime.now().millisecondsSinceEpoch}'}).data);
        }
        Logger.debug('MergedData: ${merged.data}', name: 'TokenContainerApiEndpoint#sync');
        final localTemplateSerial = merged.serial!;
        serverTemplates[localTemplateSerial] = merged;
      }
    }
    Logger.debug('Server templates: $serverTemplates', name: 'TokenContainerApiEndpoint#sync');
    _data[containerState.serial] = serverTemplates;
    Logger.debug('_data: $_data', name: 'TokenContainerApiEndpoint#sync');
    final serverTemplatesMerged = _data[containerState.serial]!.values.toList();
    final newContainerState = TokenContainerSynced(
      lastSyncAt: DateTime.now(),
      serial: containerState.serial,
      description: 'Synced with server',
      syncedTokenTemplates: serverTemplatesMerged,
      localTokenTemplates: [],
    );
    Logger.debug('Synced container: $newContainerState', name: 'TokenContainerApiEndpoint#sync');
    return newContainerState;
  }
}
