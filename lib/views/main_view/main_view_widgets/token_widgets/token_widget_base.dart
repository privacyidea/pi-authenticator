import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/mixins/sortable_mixin.dart';
import '../../../../model/tokens/token.dart';
import '../../../../utils/globals.dart';
import '../../../../utils/logger.dart';
import '../../../../utils/riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import '../../../../utils/utils.dart';
import 'default_token_actions/default_delete_action.dart';
import 'default_token_actions/default_edit_action.dart';
import 'default_token_actions/default_lock_action.dart';
import 'token_action.dart';
import 'token_widget_slideable.dart';

class TokenWidgetBase extends ConsumerWidget {
  final Widget tile;
  final Token token;
  final TokenAction? deleteAction;
  final TokenAction? editAction;
  final TokenAction? lockAction;
  final List<Widget> stack;
  final IconData dragIcon;

  const TokenWidgetBase({
    required this.tile,
    required this.token,
    this.deleteAction,
    this.editAction,
    this.lockAction,
    this.stack = const <Widget>[],
    this.dragIcon = Icons.drag_handle,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SortableMixin? draggingSortable = ref.watch(draggingSortableProvider);
    final List<TokenAction> actions = [
      deleteAction ?? DefaultDeleteAction(token: token, key: Key('${token.id}deleteAction')),
      editAction ?? DefaultEditAction(token: token, key: Key('${token.id}editAction')),
    ];
    if ((token.pin == false)) {
      actions.add(
        lockAction ?? DefaultLockAction(token: token, key: Key('${token.id}lockAction')),
      );
    }
    return draggingSortable == null
        ? LongPressDraggable(
            maxSimultaneousDrags: 1,
            onDragStarted: () => ref.read(draggingSortableProvider.notifier).state = token,
            onDragCompleted: () {
              Logger.info('Draggable completed', name: 'TokenWidgetBase#build');
              // Will be handled by the sortableNotifier
            },
            onDraggableCanceled: (velocity, offset) {
              Logger.info('Draggable canceled', name: 'TokenWidgetBase#build');
              globalRef?.read(draggingSortableProvider.notifier).state = null;
            },
            dragAnchorStrategy: (Draggable<Object> d, BuildContext context, Offset point) {
              final textSize = textSizeOf(
                text: token.label,
                style: Theme.of(context).textTheme.titleLarge!,
                textScaler: MediaQuery.of(context).textScaler,
                maxLines: 1,
              );
              return Offset(max(textSize.width / 2, 30), textSize.height / 2 + 30);
            },
            feedback: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(dragIcon, size: 60),
                Material(
                    color: Colors.transparent,
                    child: Text(
                      token.label,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    )),
              ],
            ),
            data: token,
            child: ClipRRect(
              child: TokenWidgetSlideable(
                token: token,
                actions: actions,
                stack: stack,
                tile: tile,
              ),
            ),
          )
        : draggingSortable == token
            ? const SizedBox()
            : ClipRRect(
                child: TokenWidgetSlideable(
                  token: token,
                  actions: actions,
                  stack: stack,
                  tile: tile,
                ),
              );
  }
}
