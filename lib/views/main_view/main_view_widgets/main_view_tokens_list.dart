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

import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/riverpod_states/settings_state.dart';
import '../../../model/token_folder.dart';
import '../../../model/tokens/push_token.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import '../../../widgets/default_refresh_indicator.dart';
import '../../../widgets/drag_item_scroller.dart';
import '../../../widgets/introduction_widgets/token_introduction.dart';
import 'drag_target_divider.dart';
import 'no_token_screen.dart';
import 'sortable_widget_builder.dart';

class MainViewTokensList extends ConsumerStatefulWidget {
  final GlobalKey<NestedScrollViewState> nestedScrollViewKey;

  const MainViewTokensList({super.key, required this.nestedScrollViewKey});

  @override
  ConsumerState<MainViewTokensList> createState() => _MainViewTokensListState();

  static List<Widget> buildSortableWidgets(List<SortableMixin> sortables, SortableMixin? draggingSortable) {
    List<Widget> widgets = [];
    if (sortables.isEmpty) return [];
    sortables.sort((a, b) => a.compareTo(b));
    bool introductionAdded = false;
    for (var i = 0; i < sortables.length; i++) {
      final isFirst = i == 0;
      final isDraggingTheCurrent = draggingSortable == sortables[i];
      final previousWasExpandedFolder = i > 0 && sortables[i - 1] is TokenFolder && (sortables[i - 1] as TokenFolder).isExpanded;
      final currentIsExpandedFolder = sortables[i] is TokenFolder && (sortables[i] as TokenFolder).isExpanded;
      // 1. Add a divider if the current sortable is not the one which is dragged
      // 2. Don't add a divider if the current sortable is the first
      // 3. Don't add a divider after an expanded folder
      // 4. Ignore 2. and 3. if there is a sortable that is dragged
      // 5. Do not add a divider before a folder
      //           1                     2                      3                           4
      if (!isDraggingTheCurrent && ((!isFirst && !previousWasExpandedFolder) || draggingSortable != null)) {
        widgets.add(
          DragTargetDivider(
            // The divider should be invisible if the upcoming folder is expanded
            opacity: currentIsExpandedFolder && draggingSortable == null ? 0 : 1,
            dependingFolder: null,
            previousSortable: i == 0 ? null : sortables.elementAtOrNull(i - 1),
            nextSortable: sortables[i],
          ),
        );
      }
      if (introductionAdded == false && sortables[i] is Token) {
        widgets.add(
          TokenIntroduction(
            key: Key('mainview_introduction_${sortables[i].runtimeType}${sortables[i].sortIndex}'),
            child: SortableWidgetBuilder.fromSortable(sortables[i]),
          ),
        );
        introductionAdded = true;
      } else {
        widgets.add(SortableWidgetBuilder.fromSortable(sortables[i], key: Key('mainview_${sortables[i].runtimeType}${sortables[i].hashCode}')));
      }
    }

    return widgets;
  }
}

class _MainViewTokensListState extends ConsumerState<MainViewTokensList> {
  final listViewKey = GlobalKey();
  final scrollController = ScrollController();
  Duration? lastTimeStamp;

  @override
  Widget build(BuildContext context) {
    final draggingSortable = ref.watch(draggingSortableProvider);
    final allSortables = [...ref.watch(tokenProvider).tokens, ...ref.watch(tokenFolderProvider).folders];
    final allowToRefresh = allSortables.any((element) => element is PushToken);
    final hidePushTokens = ref.watch(settingsProvider).whenOrNull(data: (data) => data.hidePushTokens) ?? SettingsState.hidePushTokensDefault;
    final filterPushTokens = hidePushTokens && allowToRefresh;
    final showSortables = <SortableMixin>[]; // List of sortables that should be shown in the list

    for (var element in allSortables) {
      if (element is! Token) {
        showSortables.add(element);
        continue;
      }
      if (element is PushToken && filterPushTokens == true) continue;
      if (element.folderId != null) continue;
      showSortables.add(element);
    }
    if ((showSortables.isEmpty)) return const NoTokenScreen();

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
                      previousSortable: showSortables.last,
                      nextSortable: null,
                      isLastDivider: true,
                      bottomPaddingIfLast: 0,
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
                  ...MainViewTokensList.buildSortableWidgets(showSortables, draggingSortable),
                  (draggingSortable != null)
                      ? DragTargetDivider(
                          dependingFolder: null,
                          previousSortable: showSortables.last,
                          nextSortable: null,
                          isLastDivider: true,
                          bottomPaddingIfLast: 80,
                        )
                      : const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  ScrollPhysics _getScrollPhysics(bool allowToRefresh) =>
      allowToRefresh ? const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()) : const BouncingScrollPhysics();
}
