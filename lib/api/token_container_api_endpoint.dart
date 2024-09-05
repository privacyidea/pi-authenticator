// /*
//  * privacyIDEA Authenticator
//  *
//  * Author: Frank Merkel <frank.merkel@netknights.it>
//  *
//  * Copyright (c) 2024 NetKnights GmbH
//  *
//  * Licensed under the Apache License, Version 2.0 (the 'License');
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an 'AS IS' BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
// import 'package:http/io_client.dart';

// import '../model/extensions/enums/encodings_extension.dart';
// import '../model/token_container.dart';
// import '../model/tokens/container_credentials.dart';
// import '../utils/identifiers.dart';
// import '../utils/logger.dart';

// import '../interfaces/api_endpoint.dart';
// import '../model/enums/encodings.dart';
// import '../model/enums/token_types.dart';
// import '../model/riverpod_states/credentials_state.dart';


// class TokenContainerApiEndpoint implements ApiEndpioint<TokenContainer, CredentialsState> {
//   @override
//   final ContainerCredential credential;
//   final IOClient _client = IOClient();
//   TokenContainerApiEndpoint({required this.credential});

//   @override
//   Future<TokenContainer> fetch() {
//     throw UnimplementedError();
//   }

//   String _buildContainerBo

//   @override
//   Future<TokenContainer> sync(TokenContainer containerState) async {
//     Logger.info('Syncing container with server', name: 'TokenContainerApiEndpoint#sync');
//     final serverTemplates = _data[containerState.serial];
//     if (serverTemplates == null) {
//       return containerState.copyTransformInto<TokenContainerNotFound>(args: {'message': 'Container not found'});
//     }
//     for (var templateSerial in serverTemplates.keys) {
//       final template = serverTemplates[templateSerial];
//       if (template?.serial == null) {
//         // Add serial(key of map) to template
//         serverTemplates[templateSerial] = template!.copyAddAll({URI_SERIAL: templateSerial});
//       }
//     }
//     final localTemplates = containerState.localTokenTemplates;
//     Logger.debug('Local templates: ${localTemplates.length}', name: 'TokenContainerApiEndpoint#sync');
//     for (var localTemplate in localTemplates) {
//       final oldLabel = localTemplate.data[URI_LABEL] as String;
//       Logger.debug('Old label: "$oldLabel" starts with "${containerState.serial}" ?', name: 'TokenContainerApiEndpoint#sync');
//       if (oldLabel.startsWith(containerState.serial) == true) {
//         var merged = localTemplate.copyAddAll({
//           URI_LABEL: '123 😀',
//         });
//         Logger.debug('New label: "${merged.data[URI_LABEL]}"', name: 'TokenContainerApiEndpoint#sync');
//         if (merged.serial == null) {
//           merged = merged.copyWith(data: merged.copyAddAll({URI_SERIAL: 'tokenID${DateTime.now().millisecondsSinceEpoch}'}).data);
//         }
//         Logger.debug('MergedData: ${merged.data}', name: 'TokenContainerApiEndpoint#sync');
//         final localTemplateSerial = merged.serial!;
//         serverTemplates[localTemplateSerial] = merged;
//       }
//     }
//     Logger.debug('Server templates: $serverTemplates', name: 'TokenContainerApiEndpoint#sync');
//     _data[containerState.serial] = serverTemplates;
//     Logger.debug('_data: $_data', name: 'TokenContainerApiEndpoint#sync');
//     final serverTemplatesMerged = _data[containerState.serial]!.values.toList();
//     final newContainerState = TokenContainerSynced(
//       lastSyncAt: DateTime.now(),
//       serial: containerState.serial,
//       description: 'Synced with server',
//       syncedTokenTemplates: serverTemplatesMerged,
//       localTokenTemplates: [],
//     );
//     Logger.debug('Synced container: $newContainerState', name: 'TokenContainerApiEndpoint#sync');
//     return newContainerState;
//   }
// }
