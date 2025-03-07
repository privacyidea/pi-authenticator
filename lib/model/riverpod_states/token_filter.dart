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
import '../../../../../../../model/mixins/sortable_mixin.dart';
import '../../../../../../../model/token_folder.dart';
import '../tokens/push_token.dart';
import '../tokens/token.dart';

class TokenFilter {
  String searchQuery;
  TokenFilter({required this.searchQuery});
  List<Token> filterTokens(List<Token> tokens) {
    final filteredTokens = <Token>[];
    final RegExp regExp;
    try {
      regExp = RegExp(searchQuery, caseSensitive: false);
    } catch (e) {
      return [];
    }
    for (final token in tokens) {
      if (regExp.hasMatch(token.label) || regExp.hasMatch(token.issuer) || token is PushToken && regExp.hasMatch(token.serial) || regExp.hasMatch(token.type)) {
        filteredTokens.add(token);
      }
    }
    return filteredTokens;
  }

  List<SortableMixin> filterSortables(List<SortableMixin> sortables) {
    final filteredSortables = <SortableMixin>[];
    final RegExp regExp;
    try {
      regExp = RegExp(searchQuery, caseSensitive: false);
    } catch (e) {
      return [];
    }
    for (final sortable in sortables) {
      if (sortable is TokenFolder) {
        filteredSortables.add(sortable);
        continue;
      }
      if (sortable is Token &&
          (regExp.hasMatch(sortable.label) ||
              regExp.hasMatch(sortable.issuer) ||
              sortable is PushToken && regExp.hasMatch(sortable.serial) ||
              regExp.hasMatch(sortable.type))) {
        filteredSortables.add(sortable);
      }
    }
    return filteredSortables;
  }
}
