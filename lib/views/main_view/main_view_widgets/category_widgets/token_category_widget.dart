import 'dart:async';
import 'dart:math';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../model/token_category.dart';
import '../../../../model/tokens/token.dart';
import '../../../../utils/riverpod_providers.dart';
import '../../../../utils/text_size.dart';
import '../../../../widgets/custom_trailing.dart';
import '../drag_target_divider.dart';
import '../token_widgets/token_widget_builder.dart';
import 'token_category_actions.dart/delete_token_category_action.dart';
import 'token_category_actions.dart/rename_token_category_action.dart';

class TokenCategoryWidget extends ConsumerStatefulWidget {
  final TokenCategory category;

  const TokenCategoryWidget(this.category, {Key? key}) : super(key: key);

  @override
  ConsumerState<TokenCategoryWidget> createState() => _TokenCategoryWidgetState();
}

class _TokenCategoryWidgetState extends ConsumerState<TokenCategoryWidget> with SingleTickerProviderStateMixin {
  Timer? _expandTimer;
  late final AnimationController animationController;
  late final ExpandableController expandableController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      value: 1.0,
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
  Widget build(BuildContext context) {
    final tokens = ref.watch(tokenProvider).tokensInCategory(widget.category);
    final draggingSortable = ref.watch(draggingSortableProvider);
    final TokenCategory? draggingCategory = draggingSortable is TokenCategory ? draggingSortable : null;
    return LongPressDraggable(
      dragAnchorStrategy: (draggable, context, position) {
        final textSize = textSizeOf(widget.category.label, Theme.of(context).textTheme.titleLarge!);
        return Offset(max(textSize.width / 2, 30), textSize.height / 2 + 30);
      },
      onDragStarted: () {
        ref.read(draggingSortableProvider.notifier).state = widget.category;
      },
      onDragCompleted: () {
        globalRef?.read(draggingSortableProvider.notifier).state = null;
      },
      onDraggableCanceled: (velocity, offset) {
        globalRef?.read(draggingSortableProvider.notifier).state = null;
      },
      data: widget.category,
      childWhenDragging: const SizedBox(),
      feedback: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder, size: 60),
          Material(
            color: Colors.transparent,
            child: Text(widget.category.label, style: Theme.of(context).textTheme.titleLarge),
          ),
        ],
      ),
      child: (draggingCategory == widget.category)
          ? const SizedBox()
          : ExpandablePanel(
              theme: const ExpandableThemeData(hasIcon: false),
              controller: expandableController,
              header: Slidable(
                key: ValueKey('tokenCategory-${widget.category.categoryId}'),
                groupTag: 'myTag',
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 1,
                  children: [
                    DeleteTokenCategoryAction(category: widget.category),
                    RenameTokenCategoryAction(category: widget.category),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: DragTarget(
                    onWillAccept: (data) {
                      if (data is Token && data.categoryId != widget.category.categoryId) {
                        _expandTimer?.cancel();
                        _expandTimer = Timer(const Duration(milliseconds: 500), () {
                          if (!expandableController.expanded) expandableController.toggle();
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
                        padding: const EdgeInsets.only(right: 16),
                        height: 50,
                        decoration: BoxDecoration(
                          color: willAccept.isNotEmpty ? Theme.of(context).dividerColor : null,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                            bottomLeft: Radius.circular(0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            RotationTransition(
                                turns: Tween(begin: 0.25, end: 0.0).animate(animationController),
                                child: SizedBox.square(
                                  dimension: 25,
                                  child: (tokens.isNotEmpty) ? const Icon(Icons.arrow_forward_ios_sharp) : null,
                                )),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.category.label,
                                style: Theme.of(context).textTheme.titleLarge,
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
                                    if (tokens.isNotEmpty)
                                      FadeTransition(
                                        opacity: animationController,
                                        child: Icon(
                                          Icons.folder,
                                          color: Theme.of(context).listTileTheme.iconColor,
                                        ),
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
              collapsed: Container(),
              expanded: Container(
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
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
