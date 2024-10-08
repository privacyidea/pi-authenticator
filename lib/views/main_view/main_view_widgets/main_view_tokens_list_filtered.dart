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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/extensions/token_folder_extension.dart';

import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/riverpod_states/token_filter.dart';
import '../../../model/token_folder.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/logger.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/state_providers/token_filter_provider.dart';
import 'folder_widgets/token_folder_expandable.dart';
import 'token_widgets/token_widget_builder.dart';

class MainViewTokensListFiltered extends ConsumerWidget {
  const MainViewTokensListFiltered({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ..._mapTokensToWidgets(ref: ref),
        ],
      ),
    );
  }

  List<Widget> _mapTokensToWidgets({required WidgetRef ref}) {
    final filter = ref.watch(tokenFilterProvider);
    if (filter == null) return [];
    final tokenFolders = ref.watch(tokenFolderProvider).folders;
    final allTokens = ref.watch(tokenProvider).tokens;
    final tokensInFolder = allTokens.inFolder();
    final tokensInNoFolder = allTokens.inNoFolder();
    List<SortableMixin> sortables = [...tokenFolders, ...tokensInNoFolder];

    sortables.sort((a, b) => a.compareTo(b));
    final List<Widget> widgets = [];
    for (int i = 0; i < sortables.length; i++) {
      final sortable = sortables[i];
      if (sortable is Token) {
        widgets.add(TokenWidgetBuilder.fromToken(sortable));
        if (i != sortables.length - 1) {
          widgets.add(const Divider());
        }
      } else if (sortable is TokenFolder) {
        widgets.addAll(_buildFilteredFolders(ref: ref, folder: sortable, filter: filter, allFolderTokens: tokensInFolder));
      }
    }
    return widgets;
  }

  List<Widget> _buildFilteredFolders({
    required WidgetRef ref,
    required TokenFolder folder,
    required TokenFilter filter,
    required List<Token> allFolderTokens,
  }) {
    final folderTokens = allFolderTokens.inFolder(folder);
    final filtered = filter.filterTokens(folderTokens);
    if (filtered.isEmpty) return [];
    // Auto expand if search query is not empty and folder is not locked.
    final expanded = filter.searchQuery.isNotEmpty && !folder.isLocked ? true : null;
    Logger.warning('Expanded: $expanded');
    return [
      TokenFolderExpandable(folder: folder, filter: filter, expandOverride: expanded, key: ValueKey('filteredFolder:${folder.folderId}')),
      const Divider(),
    ];
  }
}
