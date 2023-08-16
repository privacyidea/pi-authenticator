import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'token_category_expandable.dart';

import '../../../../model/token_category.dart';
import '../../../../utils/riverpod_providers.dart';
import '../../../../utils/text_size.dart';

class TokenCategoryWidget extends ConsumerWidget {
  final TokenCategory category;

  const TokenCategoryWidget(this.category, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draggingSortable = ref.watch(draggingSortableProvider);
    final TokenCategory? draggingCategory = draggingSortable is TokenCategory ? draggingSortable : null;
    return draggingSortable == null
        ? LongPressDraggable(
            maxSimultaneousDrags: 1,
            dragAnchorStrategy: (draggable, context, position) {
              final textSize = textSizeOf(category.label, Theme.of(context).textTheme.titleLarge!);
              return Offset(max(textSize.width / 2, 30), textSize.height / 2 + 30);
            },
            onDragStarted: () {
              ref.read(draggingSortableProvider.notifier).state = category;
            },
            onDragCompleted: () {
              globalRef?.read(draggingSortableProvider.notifier).state = null;
            },
            onDraggableCanceled: (velocity, offset) {
              globalRef?.read(draggingSortableProvider.notifier).state = null;
            },
            data: category,
            childWhenDragging: const SizedBox(),
            feedback: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.folder, size: 60),
                Material(
                  color: Colors.transparent,
                  child: Text(
                    category.label,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ],
            ),
            child: TokenCategoryExpandable(category: category),
          )
        : (draggingCategory == category)
            ? const SizedBox()
            : TokenCategoryExpandable(category: category);
  }
}
