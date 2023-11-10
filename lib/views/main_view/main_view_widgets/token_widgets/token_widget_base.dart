import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/mixins/sortable_mixin.dart';
import '../../../../model/tokens/token.dart';
import '../../../../utils/riverpod_providers.dart';
import '../../../../utils/text_size.dart';

class TokenWidgetBase extends ConsumerWidget {
  final Widget tile;
  final Token token;
  final List<Widget> stack;
  final IconData dragIcon;

  const TokenWidgetBase({
    required this.tile,
    required this.token,
    this.stack = const <Widget>[],
    this.dragIcon = Icons.drag_handle,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SortableMixin? draggingSortable = ref.watch(draggingSortableProvider);

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
            child: tile,
          )
        : draggingSortable == token
            ? const SizedBox()
            : tile;
  }
}
