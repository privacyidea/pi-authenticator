/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

/// Collection of often used procedures to filter and transform lists of tokens.
extension TokenListExtension on List<Token> {
  /// Returns all tokens that are not offline tokens.
  List<Token> get noOffline => where((token) => token.isOffline == false).toList();

  /// Returns all tokens that are privacyIDEA tokens.
  List<Token> get piTokens {
    final piTokens = where((token) => token.isPrivacyIdeaTokenna == true).toList();
    Logger.debug('${piTokens.length}/$length tokens with "isPrivacyIdeaToken == true"');
    return piTokens;
  }

  /// Returns all tokens that are exportable.
  List<Token> get exportableTokens {
    final exportableTokens = where((token) => token.isExportable).toList();
    Logger.debug('${exportableTokens.length}/$length tokens with "isPrivacyIdeaToken == false"');
    return exportableTokens;
  }

  /// Returns all tokens that are privacyIDEA tokens or have no information about it.
  List<Token> get filterNonPiTokens {
    final nonPiTokens = where((token) => token.isPrivacyIdeaTokenna != false).toList();
    Logger.debug('${nonPiTokens.length}/$length tokens with "isPrivacyIdeaToken != false"');
    return nonPiTokens;
  }

  /// Returns all tokens that are not linked to a container.
  List<Token> get notLinkedTokenss {
    final maybePiTokens = where((token) => token.containerSerial == null).toList();
    Logger.debug('${maybePiTokens.length}/$length unlinked tokens (not in container)');
    return maybePiTokens;
  }

  /// Returns all tokens that could be a token of a container.
  List<Token> get maybeContainerTokens {
    final maybeContainerToken = filterNonPiTokens.notLinkedTokenss;
    Logger.debug('${maybeContainerToken.length}/$length tokens that could be an container');
    return maybeContainerToken;
  }

  /// Returns all tokens that could be a token of the container.
  List<Token> maybeContainerTokensOf(String containerSerial) {
    final maybeContainerTokenOf = maybeContainerTokens.where((token) => !token.checkedContainer.contains(containerSerial)).toList();
    Logger.debug('${maybeContainerTokens.length}/$length tokens that could be in container $containerSerial');
    return maybeContainerTokenOf;
  }

  /// Returns all tokens with a serial.
  List<Token> get withSerial => where((token) => token.serial != null).toList();

  /// Returns all tokens without a serial.
  List<Token> get withoutSerial => where((token) => token.serial == null).toList();

  /// Returns all tokens with a specific folderId.
  List<Token> inFolder([TokenFolder? folder]) {
    if (folder == null) return where((token) => token.folderId != null).toList();
    return where((token) => token.folderId == folder.folderId).toList();
  }

  /// Returns all tokens without a folderId.
  List<Token> inNoFolder() => where((token) => token.folderId == null).toList();

  /// Returns all tokens with a specific containerSerial.
  List<Token> ofContainer(String containerSerial) {
    final filtered = where((token) => token.origin?.source == TokenOriginSourceType.container && token.containerSerial == containerSerial).toList();
    Logger.debug('${filtered.length}/$length tokens with containerSerial: $containerSerial');
    return filtered;
  }

  /// Sorts out all tokens that type is in the given list.
  List<Token> whereNotType(List<Type> types) => where((token) => !types.contains(token.runtimeType)).toList();

  List<Token> filterDuplicates() {
    final uniqueTokens = <Token>[];
    for (var token in this) {
      if (!uniqueTokens.any((uniqureToken) => uniqureToken.isSameTokenAs(token) == true)) {
        uniqueTokens.add(token);
      }
    }
    return uniqueTokens;
  }

  /// Transforms all tokens into templates.
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
