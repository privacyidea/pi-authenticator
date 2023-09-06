import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/utils/customizations.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';
import 'package:privacyidea_authenticator/widgets/default_dialog.dart';
import 'package:privacyidea_authenticator/widgets/press_button.dart';

import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/token_folder.dart';
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
    final tokenFolders = ref.watch(tokenFolderProvider).folders;
    final tokenState = ref.watch(tokenProvider);
    final allowToRefresh = tokenState.tokens.any((token) => token is PushToken);
    final draggingSortable = ref.watch(draggingSortableProvider);
    final tokenStateWithNoFolder = tokenState.tokensWithoutFolder();
    final tokenWithPushRequest = tokenState.tokenWithPushRequest();

    List<SortableMixin> sortables = [...tokenFolders, ...tokenStateWithNoFolder];

    return Stack(
      children: [
        DeactivateableRefreshIndicator(
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
        ),
        if (tokenWithPushRequest != null)
          DefaultDialog(
            title: Text(' ${tokenWithPushRequest.label}', style: Theme.of(context).textTheme.titleLarge!),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tokenWithPushRequest.pushRequests.peek()?.title ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    tokenWithPushRequest.pushRequests.peek()?.question ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 6,
                      child: PressButton(
                        onPressed: () async {
                          if (tokenWithPushRequest.isLocked &&
                              await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.authToAcceptPushRequest) == false) return;
                          final pr = tokenWithPushRequest.pushRequests.peek();
                          if (pr != null) {
                            globalRef?.read(pushRequestProvider.notifier).accept(pr);
                          }
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.accept.padRight(AppLocalizations.of(context)!.decline.length),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Flexible(
                                child: Icon(Icons.check_outlined),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Expanded(
                      flex: 6,
                      child: PressButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer)),
                          onPressed: () async {
                            if (tokenWithPushRequest.isLocked &&
                                await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.authToDeclinePushRequest) == false) {
                              return;
                            }
                            _showDialog(tokenWithPushRequest);
                          },
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.decline.padRight(AppLocalizations.of(context)!.accept.length),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Flexible(
                                  flex: 1,
                                  child: Icon(Icons.close_outlined),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
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

void _showDialog(PushToken token) => showDialog(
    context: globalNavigatorKey.currentContext!,
    builder: (BuildContext context) {
      return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 0, 16.0),
                            child: Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.requestTriggerdByUserQuestion,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 60,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: PressButton(
                              onPressed: () {
                                final pr = token.pushRequests.peek();
                                if (pr != null) {
                                  globalRef?.read(pushRequestProvider.notifier).decline(pr);
                                }
                                Navigator.of(context).pop();
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.yes,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      AppLocalizations.of(context)!.butDiscardIt,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Expanded(
                            flex: 3,
                            child: PressButton(
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer)),
                              onPressed: () {
                                //TODO: Notify issuer
                                final pr = token.pushRequests.peek();
                                if (pr != null) {
                                  globalRef?.read(pushRequestProvider.notifier).decline(pr);
                                }
                                Navigator.of(context).pop();
                              },
                              child: Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.no,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  FittedBox(
                                    child: Text(
                                      AppLocalizations.of(context)!.declineIt,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));
    });
