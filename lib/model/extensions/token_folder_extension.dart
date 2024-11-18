/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import '../../utils/logger.dart';
import '../enums/token_origin_source_type.dart';
import '../token_folder.dart';
import '../token_template.dart';
import '../tokens/token.dart';

extension TokenListExtension on List<Token> {
  List<Token> get piTokens {
    final piTokens = where((token) => token.isPrivacyIdeaToken == true).toList();
    Logger.debug('${piTokens.length}/$length tokens with "isPrivacyIdeaToken == true"');
    return piTokens;
  }

  List<Token> get nonPiTokens {
    final nonPiTokens = where((token) => token.isPrivacyIdeaToken == false).toList();
    Logger.debug('${nonPiTokens.length}/$length tokens with "isPrivacyIdeaToken == false"');
    return nonPiTokens;
  }

  List<Token> get notLinkedTokens {
    final maybePiTokens = where((token) => token.isPrivacyIdeaToken != false && token.containerSerial == null).toList();
    Logger.debug('${maybePiTokens.length}/$length unlinked tokens (not in container)');
    return maybePiTokens;
  }

  List<Token> inFolder([TokenFolder? folder]) {
    if (folder == null) return where((token) => token.folderId != null).toList();
    return where((token) => token.folderId == folder.folderId).toList();
  }

  List<Token> inNoFolder() => where((token) => token.folderId == null).toList();

  List<Token> ofContainer(String containerSerial) {
    final filtered = where((token) => token.origin?.source == TokenOriginSourceType.container && token.containerSerial == containerSerial).toList();
    Logger.debug('${filtered.length}/$length tokens with containerSerial: $containerSerial');
    return filtered;
  }

  List<Token> whereNotType(List<Type> types) => where((token) => !types.contains(token.runtimeType)).toList();

  List<TokenTemplate> toTemplates() {
    if (isEmpty) return [];
    final templates = <TokenTemplate>[];
    for (var token in this) {
      final template = token.toTemplate();
      if (template != null) templates.add(template);
    }
    return templates;
  }
}
