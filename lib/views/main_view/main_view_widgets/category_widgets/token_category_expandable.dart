import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/category_widgets/token_category_actions.dart/delete_token_category_action.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/category_widgets/token_category_actions.dart/lock_token_category_action.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/category_widgets/token_category_actions.dart/rename_token_category_action.dart';
import '../../../../model/token_category.dart';
import '../../../../model/tokens/token.dart';
import '../../../../utils/lock_auth.dart';
import '../../../../utils/riverpod_providers.dart';
import '../../../../widgets/custom_trailing.dart';
import '../drag_target_divider.dart';
import '../token_widgets/token_widget_builder.dart';

class TokenCategoryExpandable extends ConsumerStatefulWidget {
  final TokenCategory category;

  const TokenCategoryExpandable({super.key, required this.category});

  @override
  ConsumerState<TokenCategoryExpandable> createState() => _TokenCategoryExpandableState();
}

class _TokenCategoryExpandableState extends ConsumerState<TokenCategoryExpandable> with SingleTickerProviderStateMixin {
  Timer? _expandTimer;
  late final AnimationController animationController;
  late final ExpandableController expandableController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      value: widget.category.isExpanded ? 0 : 1.0,
      vsync: this,
    );
    expandableController = ExpandableController(initialExpanded: widget.category.isExpanded);
    expandableController.addListener(() {
      globalRef?.read(tokenCategoryProvider.notifier).updateCategory(widget.category.copyWith(isExpanded: expandableController.expanded));
      if (expandableController.expanded) {
        animationController.reverse();
      } else {
        animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _expandTimer?.cancel();
    animationController.dispose();
    expandableController.dispose();
    super.dispose();
  }

  @override
  ExpandablePanel build(BuildContext context) {
    final tokens = ref.watch(tokenProvider).tokensInCategory(widget.category);
    final draggingSortable = ref.watch(draggingSortableProvider);
    if (tokens.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        expandableController.expanded = false;
      });
    }
    return ExpandablePanel(
      theme: const ExpandableThemeData(hasIcon: false, tapBodyToCollapse: false, tapBodyToExpand: false),
      controller: expandableController,
      header: GestureDetector(
        onTap: () async {
          if (widget.category.isExpanded) {
            expandableController.expanded = false;
            return;
          }
          if (tokens.isEmpty || (tokens.length == 1 && tokens.first == draggingSortable)) return;
          if (widget.category.isLocked && await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.uncollapseLockedCategory) == false) {
            return;
          }
          if (!mounted) return;
          expandableController.toggle();
        },
        child: Slidable(
          key: ValueKey('tokenCategory-${widget.category.categoryId}'),
          groupTag: 'myTag',
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 1,
            children: [
              DeleteTokenCategoryAction(category: widget.category),
              RenameTokenCategoryAction(category: widget.category),
              LockTokenCategoryAction(category: widget.category),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 0),
            child: DragTarget(
              onWillAccept: (data) {
                if (data is Token && data.categoryId != widget.category.categoryId) {
                  if (widget.category.isLocked) return true;
                  _expandTimer?.cancel();
                  _expandTimer = Timer(const Duration(milliseconds: 500), () {
                    if (!expandableController.expanded && tokens.isNotEmpty) expandableController.expanded = true;
                  });
                  return true;
                }
                return false;
              },
              onLeave: (data) => _expandTimer?.cancel(),
              onAccept: (data) {
                final updatedToken = (data as Token).copyWith(categoryId: () => widget.category.categoryId);
                ref.read(tokenProvider.notifier).updateToken(updatedToken);
              },
              builder: (context, willAccept, willReject) => Center(
                child: Container(
                  margin: widget.category.isExpanded ? null : const EdgeInsets.only(right: 8),
                  padding: widget.category.isExpanded ? const EdgeInsets.only(right: 8) : null,
                  height: 50,
                  decoration: BoxDecoration(
                    color: willAccept.isNotEmpty ? Theme.of(context).dividerColor : null,
                    borderRadius: BorderRadius.only(
                      topRight: widget.category.isExpanded ? const Radius.circular(0) : const Radius.circular(8),
                      topLeft: const Radius.circular(8),
                      bottomRight: widget.category.isExpanded ? const Radius.circular(0) : const Radius.circular(8),
                      bottomLeft: widget.category.isExpanded ? const Radius.circular(0) : const Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      RotationTransition(
                          turns: Tween(begin: 0.25, end: 0.0).animate(animationController),
                          child: SizedBox.square(
                            dimension: 25,
                            child: (tokens.isNotEmpty && tokens.first != draggingSortable) ? const Icon(Icons.arrow_forward_ios_sharp) : null,
                          )),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.category.label,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      CustomTrailing(
                        child: Center(
                          child: Stack(
                            children: [
                              Icon(
                                Icons.folder_open,
                                color: Theme.of(context).listTileTheme.iconColor,
                              ),
                              if (tokens.isNotEmpty && tokens.first != draggingSortable)
                                Icon(
                                  Icons.folder,
                                  color: Theme.of(context).listTileTheme.iconColor,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      collapsed: const SizedBox(),
      expanded: tokens.isEmpty || (tokens.length == 1 && tokens.first == draggingSortable)
          ? const SizedBox()
          : Container(
              margin: const EdgeInsets.only(left: 15, bottom: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).focusColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: Card(
                color: Theme.of(context).scaffoldBackgroundColor,
                //Only bottom left corner round the other corners sharp
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                margin: const EdgeInsets.only(
                  left: 4,
                  bottom: 2,
                ),
                semanticContainer: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (var i = 0; i < tokens.length; i++) ...[
                      if (draggingSortable != tokens[i] && (i != 0 || draggingSortable != null))
                        DragTargetDivider<Token>(dependingCategory: widget.category, nextSortable: tokens[i]),
                      TokenWidgetBuilder.fromToken(
                        tokens[i],
                        withDivider: i < tokens.length - 1,
                      ),
                    ],
                    if (tokens.isNotEmpty && draggingSortable is Token) DragTargetDivider<Token>(dependingCategory: widget.category, nextSortable: null),
                    if (tokens.isNotEmpty && draggingSortable is! Token) const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
    );
  }
}
