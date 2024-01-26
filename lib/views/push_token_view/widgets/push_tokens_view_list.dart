import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/token_folder.dart';
import '../../../utils/push_provider.dart';
import '../../../utils/riverpod_providers.dart';
import '../../../widgets/deactivateable_refresh_indicator.dart';
import '../../../widgets/drag_item_scroller.dart';
import '../../main_view/main_view_widgets/drag_target_divider.dart';
import '../../main_view/main_view_widgets/sortable_widget_builder.dart';

class PushTokensViwList extends ConsumerStatefulWidget {
  const PushTokensViwList({super.key});

  @override
  ConsumerState<PushTokensViwList> createState() => _PushTokensViwListState();
}

class _PushTokensViwListState extends ConsumerState<PushTokensViwList> {
  final listViewKey = GlobalKey();
  final scrollController = ScrollController();

  Duration? lastTimeStamp;

  @override
  Widget build(BuildContext context) {
    final tokenState = ref.watch(tokenProvider);
    final pushTokens = tokenState.pushTokens;
    final allowToRefresh = pushTokens.isNotEmpty;
    final draggingSortable = ref.watch(draggingSortableProvider);

    List<SortableMixin> sortables = [...pushTokens];
    return Stack(
      children: [
        DeactivateableRefreshIndicator(
          allowToRefresh: allowToRefresh,
          onRefresh: () async => PushProvider().pollForChallenges(isManually: true),
          child: SlidableAutoCloseBehavior(
            child: DragItemScroller(
              listViewKey: listViewKey,
              itemIsDragged: draggingSortable != null,
              scrollController: scrollController,
              child: CustomScrollView(
                key: listViewKey,
                physics: allowToRefresh ? const AlwaysScrollableScrollPhysics() : null,
                controller: scrollController,
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [..._buildSortableWidgets(sortables, draggingSortable)],
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

List<Widget> _buildSortableWidgets(List<SortableMixin> sortables, SortableMixin? draggingSortable) {
  List<Widget> widgets = [];
  if (sortables.isEmpty) return widgets;
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
      widgets.add(
        DragTargetDivider(dependingFolder: null, nextSortable: sortables[i], ignoreFolderId: true),
      );
    }
    widgets.add(SortableWidgetBuilder.fromSortable(sortables[i]));
  }
  if (draggingSortable != null) {
    widgets.add(const DragTargetDivider(dependingFolder: null, nextSortable: null, isLastDivider: true, ignoreFolderId: true));
  }
  widgets.add(const SizedBox(height: 80));
  return widgets;
}
