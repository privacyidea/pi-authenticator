import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../model/tokens/token.dart';
import '../../../../utils/riverpod_providers.dart';
import '../../../../utils/text_size.dart';
import 'token_widget_actions/default_delete_action.dart';
import 'token_widget_actions/default_edit_action.dart';
import 'token_widget_actions/default_lock_action.dart';
import 'token_widget_actions/token_action.dart';

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
    final Token? draggingToken = ref.watch(draggingSortableProvider) is Token ? ref.watch(draggingSortableProvider) as Token : null;
    final List<TokenAction> actions = [
      deleteAction ?? DefaultDeleteAction(token: token, key: Key('${token.id}deleteAction')),
      editAction ?? DefaultEditAction(token: token, key: Key('${token.id}editAction')),
    ];
    if ((token.pin == null || token.pin == false)) {
      actions.add(
        lockAction ?? DefaultLockAction(token: token, key: Key('${token.id}lockAction')),
      );
    }
    return LongPressDraggable(
      onDragStarted: () {
        ref.read(draggingSortableProvider.notifier).state = token;
      },
      onDragCompleted: () {
        globalRef?.read(draggingSortableProvider.notifier).state = null;
      },
      onDraggableCanceled: (velocity, offset) {
        globalRef?.read(draggingSortableProvider.notifier).state = null;
      },
      dragAnchorStrategy: (Draggable<Object> d, BuildContext context, Offset point) {
        final textSize = textSizeOf(token.label, Theme.of(context).textTheme.titleLarge!);
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
              )),
        ],
      ),
      data: token,
      child: draggingToken == token
          ? const SizedBox()
          : Slidable(
              key: ValueKey(token.id),
              groupTag: 'myTag', // This is used to only let one be open at a time.
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 1,
                children: actions,
              ),
              child: Stack(
                children: [
                  tile,
                  for (var item in stack) Positioned.fill(child: item),
                ],
              ),
            ),
    );
  }
}
