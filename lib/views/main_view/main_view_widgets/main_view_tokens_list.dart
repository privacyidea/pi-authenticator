import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/token_folder.dart';
import '../../../model/tokens/push_token.dart';
import '../../../utils/logger.dart';
import '../../../utils/push_provider.dart';
import '../../../utils/riverpod_providers.dart';
import '../../../utils/view_utils.dart';
import '../../../widgets/deactivateable_refresh_indicator.dart';
import '../../../widgets/drag_item_scroller.dart';
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
            PollLoadingIndicator.pollForChallenges(context);
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
      ],
    );
  }

  List<Widget> _buildSortableWidgets(List<SortableMixin> sortables, SortableMixin? draggingSortable) {
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

/// This widget is polling for challenges and closes itself when the polling is done.
/// Usage: showDialog(context: context, builder: (_) => const PollLoadingIndicator());
class PollLoadingIndicator extends StatelessWidget {
  static double widgetSize = 40;
  static OverlayEntry? _overlayEntry;
  static void pollForChallenges(BuildContext context) {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (context) => const PollLoadingIndicator._(),
    );
    Overlay.of(context).insert(_overlayEntry!);
    Logger.info('Start polling for challenges', name: 'poll_loading_indicator.dart#initState');
    PushProvider().pollForChallenges(isManually: true).then((_) {
      Logger.info('Stop polling for challenges', name: 'poll_loading_indicator.dart#initState');
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  const PollLoadingIndicator._();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      top: size.height * 0.08,
      left: (size.width - widgetSize) / 2,
      width: widgetSize,
      height: widgetSize,
      child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const CircularProgressIndicator()),
    );
  }
}
