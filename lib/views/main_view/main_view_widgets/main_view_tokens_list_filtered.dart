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
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';

import '../../../model/mixins/sortable_mixin.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import '../../../utils/riverpod/riverpod_providers/state_providers/token_filter_provider.dart';

import 'main_view_tokens_list.dart';

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
    // final tokensInFolder = allTokens.inFolder();
    // final tokensInNoFolder = allTokens.inNoFolder();
    final filteredTokens = filter.filterTokens(allTokens);
    List<SortableMixin> sortables = [...tokenFolders, ...filteredTokens];
    final draggingSortable = ref.watch(draggingSortableProvider);

    sortables.sort((a, b) => a.compareTo(b));
    final List<Widget> widgets = MainViewTokensList.buildSortableWidgets(
      sortables: sortables,
      draggingSortable: draggingSortable,
      filter: filter,
      hidePushTokens: ref.watch(hidePushTokensProvider),
    );
    // for (int i = 0; i < sortables.length; i++) {
    //   final sortable = sortables[i];
    //   final nextIsFolder = i < sortables.length - 1 && sortables[i + 1] is TokenFolder;
    //   if (sortable is Token) {
    //     widgets.add(TokenWidgetBuilder.fromToken(sortable));
    //     if (i != sortables.length - 1) {
    //       widgets.add(DefaultDivider(opacity: nextIsFolder ? 0 : 1));
    //     }
    //   } else if (sortable is TokenFolder) {
    //     widgets.addAll(_buildFilteredFolders(ref: ref, folder: sortable, filter: filter, allFolderTokens: tokensInFolder, isLast: i == sortables.length - 1));
    //   }
    // }
    return widgets;
  }

  // List<Widget> _buildFilteredFolders({
  //   required WidgetRef ref,
  //   required TokenFolder folder,
  //   required TokenFilter filter,
  //   required List<Token> allFolderTokens,
  //   required bool isLast,
  // }) {
  //   final folderTokens = allFolderTokens.inFolder(folder);
  //   final filtered = filter.filterTokens(folderTokens);
  //   if (filtered.isEmpty) return [];
  //   // Auto expand if search query is not empty and folder is not locked.
  //   final expanded = filter.searchQuery.isNotEmpty && !folder.isLocked ? true : null;
  //   Logger.warning('Expanded: $expanded');
  //   return [
  //     TokenFolderExpandable(
  //         folder: folder,
  //         folderTokens: ,
  //         filter: filter,
  //         expandOverride: expanded,
  //         key: ValueKey(
  //           'filteredFolder:${folder.folderId}',
  //         )),
  //     if (!isLast) const Divider(),
  //   ];
  // }
}
