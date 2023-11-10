import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/token_folder.dart';
import '../../../model/tokens/push_token.dart';
import '../../../utils/push_provider.dart';
import '../../../utils/riverpod_providers.dart';
import '../../../utils/view_utils.dart';
import '../../../widgets/deactivateable_refresh_indicator.dart';
import '../../../widgets/drag_item_scroller.dart';
import '../../../widgets/push_request_overlay.dart';
import 'drag_target_divider.dart';
import 'no_token_screen.dart';
import 'sortable_widget_builder.dart';

class MainViewTokensList extends ConsumerStatefulWidget {
  final GlobalKey<NestedScrollViewState> nestedScrollViewKey;

  const MainViewTokensList({super.key, required this.nestedScrollViewKey});

  @override
  ConsumerState<MainViewTokensList> createState() => _MainViewTokensListState();
}

class _MainViewTokensListState extends ConsumerState<MainViewTokensList> {
  final listViewKey = GlobalKey();
  final scrollController = ScrollController();

  Duration? lastTimeStamp;

  @override
  Widget build(BuildContext context) {
    final tokenFolders = ref.watch(tokenFolderProvider).folders;
    final tokenState = ref.watch(tokenProvider);
    final allowToRefresh = tokenState.hasPushTokens;
    final draggingSortable = ref.watch(draggingSortableProvider);
    bool filterPushTokens = ref.watch(settingsProvider).hidePushTokens && tokenState.hasHOTPTokens;

    final tokenStateWithNoFolder = tokenState.tokensWithoutFolder(exclude: filterPushTokens ? [PushToken] : []);
    final tokenWithPushRequest = tokenState.tokenWithPushRequest();

    List<SortableMixin> sortables = [...tokenFolders, ...tokenStateWithNoFolder];

    return Stack(
      children: [
        if (sortables.isEmpty) const NoTokenScreen(),
        DeactivateableRefreshIndicator(
          allowToRefresh: allowToRefresh,
          onRefresh: () async {
            showMessage(
              message: AppLocalizations.of(context)!.pollingChallenges,
              duration: const Duration(seconds: 1),
            );
            await PushProvider().pollForChallenges(isManually: true);
          },
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
        if (tokenWithPushRequest != null) PushRequestOverlay(tokenWithPushRequest),
      ],
    );
  }

  List<Widget> _buildSortableWidgets(List<SortableMixin> sortables, SortableMixin? draggingSortable) {
    List<Widget> widgets = [];
    if (sortables.isEmpty) return [];
    sortables.sort((a, b) => a.compareTo(b));
    // just for small space between appBar and first element
    widgets.add(const SizedBox(height: 20));
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
        widgets.add(DragTargetDivider(dependingFolder: null, nextSortable: sortables[i]));
      }
      widgets.add(SortableWidgetBuilder.fromSortable(sortables[i]));
    }
    if (draggingSortable != null) {
      widgets.add(const DragTargetDivider(dependingFolder: null, nextSortable: null, isLastDivider: true));
    }
    widgets.add(const SizedBox(height: 80));
    return widgets;
  }
}
