import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/model/mixins/sortable_mixin.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_slideable.dart';

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
    final SortableMixin? draggingSortable = ref.watch(draggingSortableProvider);
    final List<TokenAction> actions = [
      deleteAction ?? DefaultDeleteAction(token: token, key: Key('${token.id}deleteAction')),
      editAction ?? DefaultEditAction(token: token, key: Key('${token.id}editAction')),
    ];
    if ((token.pin == null || token.pin == false)) {
      actions.add(
        lockAction ?? DefaultLockAction(token: token, key: Key('${token.id}lockAction')),
      );
    }
    return draggingSortable == null
        ? LongPressDraggable(
            maxSimultaneousDrags: 1,
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
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    )),
              ],
            ),
            data: token,
            child: TokenWidgetSlideable(
              token: token,
              actions: actions,
              stack: stack,
              tile: tile,
            ),
          )
        : draggingSortable == token
            ? const SizedBox()
            : TokenWidgetSlideable(
                token: token,
                actions: actions,
                stack: stack,
                tile: tile,
              );
  }
}
