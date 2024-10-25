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
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../../../views/main_view/main_view_widgets/token_widgets/token_widget_builder.dart';
import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/riverpod_states/settings_state.dart';
import '../../../model/riverpod_states/token_filter.dart';
import '../../../model/token_folder.dart';
import '../../../model/tokens/push_token.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/sortable_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import '../../../widgets/default_refresh_indicator.dart';
import '../../../widgets/drag_item_scroller.dart';
import '../../../widgets/introduction_widgets/token_introduction.dart';
import 'drag_target_divider.dart';
import 'folder_widgets/token_folder_widget.dart';
import 'no_token_screen.dart';

class MainViewTokensList extends ConsumerStatefulWidget {
  final GlobalKey<NestedScrollViewState> nestedScrollViewKey;

  const MainViewTokensList({super.key, required this.nestedScrollViewKey});

  @override
  ConsumerState<MainViewTokensList> createState() => _MainViewTokensListState();

  static List<Widget> buildSortableWidgets({
    required List<SortableMixin> sortables,
    required SortableMixin? draggingSortable,
    bool hidePushTokens = false,
    bool isPushTokensView = false,
    TokenFilter? filter,
  }) {
    List<Widget> widgets = [];
    if (sortables.isEmpty) return [];
    sortables.sort((a, b) => a.compareTo(b));
    sortables = filter?.filterSortables(sortables) ?? sortables;
    bool introductionAdded = false;
    int skiped = 0;
    for (var i = 0; i < sortables.length; i++) {
      final sortable = sortables[i];
      if (hidePushTokens && sortable is PushToken) {
        skiped++;
        continue;
      }
      if (sortable is Token && sortable.folderId != null && !isPushTokensView) {
        skiped++;
        continue;
      }
      final isFirst = i == 0;
      final isDraggingTheCurrent = draggingSortable == sortable;
      final previousWasExpandedFolder = i > 0 && sortables[i - skiped - 1] is TokenFolder && (sortables[i - skiped - 1] as TokenFolder).isExpanded;
      final currentIsExpandedFolder = sortable is TokenFolder && sortable.isExpanded;
      final folderTokens = sortable is TokenFolder ? sortables.where((s) => s is Token && s.folderId == sortable.folderId).cast<Token>().toList() : null;
      if (hidePushTokens) folderTokens?.removeWhere((t) => t is PushToken);
      if (filter != null && folderTokens?.isEmpty == true) {
        skiped++;
        continue;
      }
      // 1. Add a divider if the current sortable is not the one which is dragged
      // 2. Don't add a divider if the current sortable is the first
      // 3. Don't add a divider after an expanded folder
      // 4. Ignore 2. and 3. if there is a sortable that is dragged
      //           1                     2                      3                           4
      if (!isDraggingTheCurrent && ((!isFirst && !previousWasExpandedFolder) || draggingSortable != null)) {
        widgets.add(
          DragTargetDivider(
            // The divider should be invisible if the upcoming folder is expanded
            opacity: currentIsExpandedFolder && draggingSortable == null ? 0 : 1,
            dependingFolder: null,
            previousSortable: i == 0 ? null : sortables.elementAtOrNull(i - 1),
            nextSortable: sortable,
          ),
        );
      }

      if (sortable is Token) {
        skiped = 0;
        widgets.add(
          introductionAdded
              ? TokenWidgetBuilder.fromToken(token: sortable)
              : TokenIntroduction(
                  key: Key('mainview_introduction_${sortable.runtimeType}${sortable.sortIndex}'),
                  child: TokenWidgetBuilder.fromToken(token: sortable),
                ),
        );
        introductionAdded = true;
        continue;
      }

      if (sortable is TokenFolder) {
        skiped = 0;
        widgets.add(
          TokenFolderWidget(
            folder: sortable,
            folderTokens: folderTokens!,
            key: Key('mainview_${sortable.runtimeType}${sortable.hashCode}'),
            filter: filter,
          ),
        );
        continue;
      }
    }
    widgets.add(
      (draggingSortable != null)
          ? DragTargetDivider(
              dependingFolder: null,
              previousSortable: sortables.last,
              nextSortable: null,
              bottomPadding: 110,
            )
          : const SizedBox(height: 110),
    );
    return widgets;
  }
}

class _MainViewTokensListState extends ConsumerState<MainViewTokensList> {
  final listViewKey = GlobalKey();
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final draggingSortable = ref.watch(draggingSortableProvider);
    final sortables = ref.watch(sortablesProvider);
    final hidePushTokens = ref.watch(settingsProvider).whenOrNull(data: (data) => data.hidePushTokens) ?? SettingsState.hidePushTokensDefault;
    if ((sortables.isEmpty)) return const NoTokenScreen();

    return Stack(
      children: [
        Column(
          children: [
            Flexible(
              child: DefaultRefreshIndicator(
                child: SizedBox(
                  height: 9999,
                  child: Opacity(
                    opacity: 0,
                    child: DragTargetDivider(
                      dependingFolder: null,
                      previousSortable: sortables.last,
                      nextSortable: null,
                      bottomPadding: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        DefaultRefreshIndicator(
          listViewKey: listViewKey,
          scrollController: scrollController,
          child: SlidableAutoCloseBehavior(
            child: DragItemScroller(
              listViewKey: listViewKey,
              itemIsDragged: draggingSortable != null,
              scrollController: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...MainViewTokensList.buildSortableWidgets(sortables: sortables, draggingSortable: draggingSortable, hidePushTokens: hidePushTokens),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
