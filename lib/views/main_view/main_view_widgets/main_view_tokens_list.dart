import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/token_category.dart';
import '../../../model/tokens/push_token.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/push_provider.dart';
import '../../../utils/riverpod_providers.dart';
import '../../../utils/view_utils.dart';
import '../../../widgets/drag_item_scroller.dart';
import '../deactivateable_refresh_indicator.dart';
import 'drag_target_divider.dart';
import 'no_token_screen.dart';
import 'sortable_widget_builder.dart';

class MainViewTokensList extends ConsumerStatefulWidget {
  final List<Token> tokens;
  final GlobalKey<NestedScrollViewState> nestedScrollViewKey;

  const MainViewTokensList(this.tokens, {Key? key, required this.nestedScrollViewKey}) : super(key: key);

  @override
  ConsumerState<MainViewTokensList> createState() => _MainViewTokensListState();
}

class _MainViewTokensListState extends ConsumerState<MainViewTokensList> {
  final listViewKey = GlobalKey();
  final scrollController = ScrollController();

  Duration? lastTimeStamp;

  @override
  Widget build(BuildContext context) {
    final tokenCategorys = ref.watch(tokenCategoryProvider).categorys;
    final tokenState = ref.watch(tokenProvider);
    final allowToRefresh = tokenState.tokens.any((token) => token is PushToken);
    final draggingSortable = ref.watch(draggingSortableProvider);
    final tokenStateWithNoCategory = tokenState.tokensWithoutCategory();

    List<SortableMixin> sortables = [...tokenCategorys, ...tokenStateWithNoCategory];

    return DeactivateableRefreshIndicator(
      allowToRefresh: allowToRefresh,
      onRefresh: () async {
        showMessage(
          message: AppLocalizations.of(context)!.pollingChallenges,
          duration: const Duration(seconds: 1),
        );
        final errorMessage = await PushProvider.pollForChallenges(showMessageForEachToken: true);
        if (errorMessage != null) showMessage(message: errorMessage);
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
    );
  }

  List<Widget> _buildSortableWidgets(List<SortableMixin> sortables, SortableMixin? draggingSortable) {
    List<Widget> widgets = [];
    if (sortables.isEmpty) {
      widgets.add(const NoTokenScreen());
      return widgets;
    }
    sortables.sort((a, b) => a.compareTo(b));
    for (var i = 0; i < sortables.length; i++) {
      final isFirst = i == 0;
      final isDraggingTheCurrent = draggingSortable == sortables[i];
      final previousWasExpandedCategory = i > 0 && sortables[i - 1] is TokenCategory && (sortables[i - 1] as TokenCategory).isExpanded;
      // 1. Add a divider if the current sortable is not the one which is dragged
      // 2. Dont add a divider if the current sortable is the first
      // 3. Dont add a divider if the previous sortable was an expanded category
      // 4. Ignore 2. and 3. if there is a sortable that is dragged
      //           1                     2                     3                         4
      if (!isDraggingTheCurrent && ((!isFirst && !previousWasExpandedCategory) || draggingSortable != null)) {
        widgets.add(DragTargetDivider(dependingCategory: null, nextSortable: sortables[i]));
      }
      widgets.add(SortableWidgetBuilder.fromSortable(sortables[i]));
    }
    if (draggingSortable != null) {
      widgets.add(const DragTargetDivider(dependingCategory: null, nextSortable: null, isLastDivider: true));
    }
    widgets.add(const SizedBox(height: 80));
    return widgets;
  }
}
