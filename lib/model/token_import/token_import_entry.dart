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
import '../tokens/token.dart';

class TokenImportEntry {
  final Token newToken;
  final Token? oldToken;
  Token? selectedToken;

  TokenImportEntry._(this.newToken, this.oldToken, this.selectedToken);

  TokenImportEntry({required this.newToken, this.oldToken})
    : selectedToken = oldToken == null ? newToken : null;

  /// The token to store for this entry, or null while no side is chosen.
  ///
  /// A chosen new token replaces the data of the stored one, but not where the
  /// user keeps it: its id, folder and place in the list stay, and so does a
  /// lock it had. The container link is not carried over, an imported token
  /// is not the one the server manages.
  Token? get tokenToKeep {
    final selected = selectedToken;
    final old = oldToken;
    if (selected == null || old == null || !identical(selected, newToken)) {
      return selected;
    }
    final isLocked = old.isLocked || selected.isLocked;
    return selected.copyWith(
      id: old.id,
      sortIndex: old.sortIndex,
      folderId: () => old.folderId,
      isLocked: isLocked,
      isHidden: isLocked,
    );
  }

  TokenImportEntry copySelect(Token? selectedToken) {
    assert(
      selectedToken == null ||
          selectedToken == newToken ||
          selectedToken == oldToken,
    );
    return TokenImportEntry._(newToken, oldToken, selectedToken);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenImportEntry &&
          runtimeType == other.runtimeType &&
          newToken == other.newToken &&
          oldToken == other.oldToken &&
          selectedToken == other.selectedToken;

  @override
  int get hashCode => Object.hashAll([newToken, oldToken, selectedToken]);

  @override
  String toString() =>
      'TokenImportEntry{newToken: $newToken, \noldToken: $oldToken, \nselectedToken: $selectedToken}';
}
