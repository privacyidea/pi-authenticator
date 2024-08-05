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

import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/riverpod_states/token_filter.dart';
import '../../../model/token_folder.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/logger.dart';
import '../../../utils/riverpod/riverpod_providers/state_notifier_providers/token_folder_provider.dart';
import '../../../utils/riverpod/riverpod_providers/state_notifier_providers/token_provider.dart';
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
    final tokensInNoFolder = filter.filterTokens(ref.watch(tokenProvider).tokensWithoutFolder());
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
        widgets.addAll(_buildFilteredFolder(ref: ref, folder: sortable, filter: filter));
      }
    }
    return widgets;
  }

  List<Widget> _buildFilteredFolder({required WidgetRef ref, required TokenFolder folder, required TokenFilter filter}) {
    if (filter.filterTokens(ref.watch(tokenProvider).tokensInFolder(folder)).isEmpty) return [];
    final expanded = filter.searchQuery.isNotEmpty && !folder.isLocked ? true : null; // Auto expand if search query is not empty and folder is not locked.
    Logger.warning('Expanded: $expanded', name: 'main_view_tokens_list_filtered.dart#_buildFilteredFolder');
    final List<Widget> widgets = [];
    widgets.add(
      TokenFolderExpandable(folder: folder, filter: filter, expandOverride: expanded, key: ValueKey('filteredFolder:${folder.folderId}')),
    );
    widgets.add(const Divider());
    return widgets;
  }
}
