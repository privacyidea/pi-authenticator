import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/token_folder.dart';
import '../../../../utils/riverpod_providers.dart';
import '../../../../utils/utils.dart';
import 'token_folder_expandable.dart';

class TokenFolderWidget extends ConsumerWidget {
  final TokenFolder folder;

  const TokenFolderWidget(this.folder, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draggingSortable = ref.watch(draggingSortableProvider);
    final draggingSortableNotifier = ref.read(draggingSortableProvider.notifier);
    final TokenFolder? draggingFolder = draggingSortable is TokenFolder ? draggingSortable : null;
    return draggingSortable == null
        ? LongPressDraggable(
            maxSimultaneousDrags: 1,
            dragAnchorStrategy: (draggable, context, position) {
              final textSize = textSizeOf(
                text: folder.label,
                style: Theme.of(context).textTheme.titleLarge!,
                textScaler: MediaQuery.of(context).textScaler,
                maxLines: 1,
              );
              return Offset(max(textSize.width / 2, 30), textSize.height / 2 + 30);
            },
            onDragStarted: () => draggingSortableNotifier.state = folder,
            onDragCompleted: () async {
              await Future.delayed(const Duration(milliseconds: 50));
              // FIXME: The folder may appear before reordering the list. (race condition) This results in a flickering effect. Waiting here is a workaround so the list is updated before the folder visible again. We should find a better solution.
              draggingSortableNotifier.state = null;
            },
            onDraggableCanceled: (velocity, offset) => draggingSortableNotifier.state = null,
            data: folder,
            childWhenDragging: const SizedBox(),
            feedback: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.folder, size: 60),
                Material(
                  color: Colors.transparent,
                  child: Text(
                    folder.label,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ],
            ),
            child: TokenFolderExpandable(
              folder: folder,
              key: Key('TokenFolderExpandable#${folder.folderId}'),
            ),
          )
        : (draggingFolder == folder)
            ? const SizedBox()
            : TokenFolderExpandable(folder: folder);
  }
}
