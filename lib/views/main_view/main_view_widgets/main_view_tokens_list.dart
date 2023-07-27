import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/tokens/push_token.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/push_provider.dart';
import '../../../utils/riverpod_providers.dart';
import '../../../utils/view_utils.dart';
import '../../../widgets/drag_item_scroller.dart';
import '../deactivateable_refresh_indicator.dart';
import 'category_widgets/add_token_category.dart';
import 'drag_target_divider.dart';
import 'no_token_screen.dart';
import 'sortable_widget_builder.dart';

class MainViewTokensList extends ConsumerStatefulWidget {
  final List<Token> tokens;

  const MainViewTokensList(this.tokens, {Key? key}) : super(key: key);

  @override
  ConsumerState<MainViewTokensList> createState() => _MainViewTokensListState();
}

class _MainViewTokensListState extends ConsumerState<MainViewTokensList> {
  final listViewKey = GlobalKey();

  final ScrollController scrollController = ScrollController();

  Duration? lastTimeStamp;

  @override
  Widget build(BuildContext context) {
    final tokenCategorys = ref.watch(tokenCategoryProvider).categorys;
    final tokenState = ref.watch(tokenProvider);
    final allowToRefresh = tokenState.tokens.any((token) => token is PushToken);
    final draggingSortable = ref.watch(draggingSortableProvider);
    final tokenStateWithNoCategory = tokenState.tokensWithoutCategory();

    List<SortableMixin> sortables = [...tokenCategorys, ...tokenStateWithNoCategory];
    sortables.sort((a, b) => a.compareTo(b));

    return DeactivateableRefreshIndicator(
      allowToRefresh: allowToRefresh,
      onRefresh: () async {
        showMessage(
          message: AppLocalizations.of(context)!.pollingChallenges,
          duration: const Duration(seconds: 1),
          context: context,
        );
        bool success = await PushProvider.pollForChallenges();
        if (!success) {
          showMessage(
            message: AppLocalizations.of(context)!.pollingFailNoNetworkConnection,
            duration: const Duration(seconds: 3),
            context: context,
          );
        }
      },
      child: DragItemScroller(
        listViewKey: listViewKey,
        scrollController: scrollController,
        itemIsDragged: draggingSortable != null,
        child: CustomScrollView(
          key: listViewKey,
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  for (var i = 0; i < sortables.length; i++) ...[
                    if (draggingSortable != sortables[i] && (i != 0 || draggingSortable != null))
                      DragTargetDivider(dependingCategory: null, nextSortable: sortables[i]),
                    SortableWidgetBuilder.fromSortable(sortables[i]),
                  ],
                  if (sortables.isNotEmpty && draggingSortable != null)
                    const DragTargetDivider(dependingCategory: null, nextSortable: null, isLastDivider: true),
                  (sortables.isEmpty) ? const NoTokenScreen() : const AddTokenCategory(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
