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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/riverpod_states/token_filter.dart';
import '../../../model/token_folder.dart';
import '../../../model/tokens/push_token.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import '../../../utils/riverpod/riverpod_providers/state_providers/token_filter_provider.dart';
import 'main_view_tokens_list.dart';

class MainViewTokensListFiltered extends ConsumerWidget {
  const MainViewTokensListFiltered({super.key});

  static List<Widget> _buildSortableWidgets({
    required List<SortableMixin> sortables,
    SortableMixin? draggingSortable,
    required bool hidePushTokens,
    TokenFilter? filter,
  }) {
    if (sortables.isEmpty) return [];
    sortables = sortables.toList();
    if (hidePushTokens) sortables.removeWhere((t) => t is PushToken);
    sortables = filter?.filterSortables(sortables) ?? sortables;
    final tokenFolderIds = sortables.whereType<Token>().map((e) => e.folderId).toList();
    sortables.removeWhere((e) => e is TokenFolder && !tokenFolderIds.contains(e.folderId));

    return MainViewTokensList.buildSortableWidgets(sortables: sortables, draggingSortable: draggingSortable);
  }

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
    final allTokens = ref.watch(tokenProvider).valueOrNull?.tokens ?? [];
    final filteredTokens = filter.filterTokens(allTokens);
    List<SortableMixin> sortables = [...tokenFolders, ...filteredTokens];
    final draggingSortable = ref.watch(draggingSortableProvider);

    sortables.sort((a, b) => a.compareTo(b));
    final List<Widget> widgets = MainViewTokensListFiltered._buildSortableWidgets(
      sortables: sortables,
      draggingSortable: draggingSortable,
      filter: filter,
      hidePushTokens: ref.watch(hidePushTokensProvider),
    );

    return widgets;
  }
}
