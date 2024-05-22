import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/token_folder.dart';
import '../../../model/tokens/push_token.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/push_provider.dart';
import '../../../utils/riverpod_providers.dart';
import '../../../widgets/deactivateable_refresh_indicator.dart';
import '../../../widgets/drag_item_scroller.dart';
import '../../../widgets/introduction_widgets/token_introduction.dart';
import 'drag_target_divider.dart';
import 'loading_indicator.dart';
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
      widgets.add(SortableWidgetBuilder.fromSortable(sortables[i]));
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

    final sortables = <SortableMixin>[];

    for (var element in allSortables) {
      if (element is! Token) {
        sortables.add(element);
        continue;
      }
      if (filterPushTokens == false && element.folderId == null) {
        sortables.add(element);
        continue;
      }
    }
    // final List<Token> tokens = allSortables.whereType<Token>().toList();
    // final tokensWithNoFolder = tokens.withoutFolder(exclude: filterPushTokens ? [PushToken] : []);

    // List<SortableMixin> sortables = [...tokenFolders, ...tokensWithNoFolder];
    return Stack(
      children: [
        if (sortables.isEmpty) const NoTokenScreen(),
        DeactivateableRefreshIndicator(
          allowToRefresh: allowToRefresh,
          onRefresh: () async => LoadingIndicator.show(context, () async => PushProvider.instance?.pollForChallenges(isManually: true)),
          child: SlidableAutoCloseBehavior(
            child: DragItemScroller(
              listViewKey: listViewKey,
              itemIsDragged: draggingSortable != null,
              scrollController: scrollController,
              child: CustomScrollView(
                key: listViewKey,
                physics: allowToRefresh ? const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()) : const BouncingScrollPhysics(),
                controller: scrollController,
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        TokenIntroduction(
                          child: Column(
                            children: [
                              ...MainViewTokensList.buildSortableWidgets(sortables, draggingSortable),
                            ],
                          ),
                        ),
                        ...(draggingSortable != null)
                            ? [
                                DragTargetDivider(
                                    dependingFolder: null, previousSortable: sortables.last, nextSortable: null, isLastDivider: true, bottomPaddingIfLast: 80),
                                Expanded(
                                  child: Opacity(
                                      opacity: 0,
                                      child: DragTargetDivider(
                                        dependingFolder: null,
                                        previousSortable: sortables.last,
                                        nextSortable: null,
                                        isLastDivider: true,
                                        bottomPaddingIfLast: 0,
                                      )),
                                )
                              ]
                            : [const SizedBox(height: 80)]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
