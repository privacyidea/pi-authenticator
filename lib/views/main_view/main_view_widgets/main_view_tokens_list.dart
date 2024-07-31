import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/token_folder.dart';
import '../../../model/tokens/push_token.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/riverpod/riverpod_providers/state_notifier_providers/settings_provider.dart';
import '../../../utils/riverpod/riverpod_providers/state_notifier_providers/sortable_provider.dart';
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
      // 1. Add a divider if the current sortable is not the one which is dragged
      // 2. Dont add a divider if the current sortable is the first
      // 3. Dont add a divider if the previous sortable was an expanded folder
      // 4. Ignore 2. and 3. if there is a sortable that is dragged
      //           1                     2                     3                         4
      if (!isDraggingTheCurrent && ((!isFirst && !previousWasExpandedFolder) || draggingSortable != null)) {
        widgets.add(DragTargetDivider(dependingFolder: null, previousSortable: sortables.last, nextSortable: sortables[i]));
      }
      if (introductionAdded == false && sortables[i] is Token) {
        widgets.add(TokenIntroduction(child: SortableWidgetBuilder.fromSortable(sortables[i])));
        introductionAdded = true;
      } else {
        widgets.add(SortableWidgetBuilder.fromSortable(sortables[i]));
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
    final allSortables = ref.watch(sortableProvider);
    final allowToRefresh = allSortables.any((element) => element is PushToken);
    bool filterPushTokens = ref.watch(settingsProvider).hidePushTokens && allowToRefresh;

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
                allowToRefresh: allowToRefresh,
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: _getScrollPhysics(allowToRefresh),
                    child: SizedBox(
                      height: constraints.maxHeight,
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
              ),
            ),
          ],
        ),
        DefaultRefreshIndicator(
          allowToRefresh: allowToRefresh,
          child: SlidableAutoCloseBehavior(
            child: DragItemScroller(
              listViewKey: listViewKey,
              itemIsDragged: draggingSortable != null,
              scrollController: scrollController,
              child: SingleChildScrollView(
                key: listViewKey,
                physics: _getScrollPhysics(allowToRefresh),
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        ...MainViewTokensList.buildSortableWidgets(showSortables, draggingSortable),
                      ],
                    ),
                    (draggingSortable != null)
                        ? DragTargetDivider(
                            dependingFolder: null,
                            previousSortable: showSortables.last,
                            nextSortable: null,
                            isLastDivider: true,
                            bottomPaddingIfLast: 80,
                          )
                        : const SizedBox(height: 80)
                  ],
                ),
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
