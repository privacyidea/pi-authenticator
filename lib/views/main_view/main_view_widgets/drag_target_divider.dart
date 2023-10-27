import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/token_folder.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/riverpod_providers.dart';
import '../../../widgets/drag_item_scroller.dart';

/// DragTargetDivider is used to create a divider that can be used to move a sortable up or down in the list
/// It will accept a Sortable from the type T
class DragTargetDivider<T extends SortableMixin> extends ConsumerStatefulWidget {
  final TokenFolder? dependingFolder;
  final SortableMixin? nextSortable;
  final bool ignoreFolderId;
  final bool isLastDivider;

  const DragTargetDivider({
    super.key,
    required this.dependingFolder,
    required this.nextSortable,
    this.ignoreFolderId = false,
    this.isLastDivider = false,
  });

  @override
  ConsumerState<DragTargetDivider> createState() => _DragTargetDividerState<T>();
}

class _DragTargetDividerState<T extends SortableMixin> extends ConsumerState<DragTargetDivider> with SingleTickerProviderStateMixin {
  late AnimationController expansionController;

  @override
  void initState() {
    super.initState();
    expansionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    expansionController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    expansionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = DragTarget(
      onWillAccept: (data) {
        if (data is T == false) return false;
        if (ref.read(dragItemScrollerStateProvider)) return false;
        expansionController.forward();
        return true;
      },
      onLeave: (data) {
        expansionController.reverse();
      },
      onAccept: (dragedSortable) {
        expansionController.reset();
        // Higher index = lower in the list
        dragedSortable as SortableMixin;
        final allTokens = ref.read(tokenProvider).tokens;
        final allFolders = ref.read(tokenFolderProvider).folders;
        final allSortables = [...allTokens, ...allFolders];
        allSortables.sort((a, b) => a.compareTo(b));
        final oldIndex = allSortables.indexOf(dragedSortable);
        if (oldIndex == -1) return; // If the draged item is not in the list we dont need to do anything
        int newIndex;
        if (widget.nextSortable == null) {
          // If the draged item is moved to the end of the list the nextSortable is null. The newIndex will be set to the last index
          newIndex = allSortables.length - 1;
        } else {
          if (oldIndex < allSortables.indexOf(widget.nextSortable!)) {
            // If the draged item is moved down it dont pass the nextSortable so the newIndex is before the nextSortable
            newIndex = allSortables.indexOf(widget.nextSortable!) - 1;
          } else {
            // If the draged item is moved up it pass the nextSortable so the newIndex is after the nextSortable
            newIndex = allSortables.indexOf(widget.nextSortable!);
          }
        }
        final dragedItemMovedUp = newIndex < oldIndex;
        // When the draged item is a Token we need to update the folderId so its in the correct folder
        if (dragedSortable is Token && !widget.ignoreFolderId) {
          late int? previousFolderId = widget.dependingFolder?.folderId;
          allSortables[oldIndex] = dragedSortable.copyWith(folderId: () => previousFolderId);
        }

        final modifiedSortables = [];
        for (var i = 0; i < allSortables.length; i++) {
          if (i < oldIndex && i < newIndex) {
            modifiedSortables.add(allSortables[i].copyWith(sortIndex: i)); // This is before dragedSortable and newIndex so no changes needed
            continue;
          }
          if (i > oldIndex && i > newIndex) {
            modifiedSortables.add(allSortables[i].copyWith(sortIndex: i)); // This is after dragedSortable and newIndex so no changes needed
            continue;
          }
          if (i == oldIndex) {
            modifiedSortables.add(allSortables[i].copyWith(sortIndex: newIndex)); // This is dragedSortable so it needs to be moved to newIndex
            continue;
          }
          modifiedSortables.add(allSortables[i].copyWith(
              sortIndex: i + (dragedItemMovedUp ? 1 : -1))); // This is between dragedSortable and newIndex so it needs to be moved up (-1) or down (+1)
          continue;
        }

        globalRef?.read(tokenProvider.notifier).updateTokens(
            allTokens, (p0) => p0.copyWith(sortIndex: modifiedSortables.whereType<Token>().firstWhereOrNull((updated) => updated.id == p0.id)?.sortIndex));
        globalRef?.read(tokenFolderProvider.notifier).updateFolders(modifiedSortables.whereType<TokenFolder>().toList());
      },
      builder: (context, accepted, rejected) {
        final dividerHeight = expansionController.value * 40 + 1.5;
        return Container(
          height: dividerHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(dividerHeight / 4),
          ),
          margin: EdgeInsets.only(left: 8 - expansionController.value * 2, right: 8 - expansionController.value * 2, top: 8, bottom: 8),
        );
      },
    );

    return widget.isLastDivider
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [body, SizedBox(height: 40 - 40 * expansionController.value)],
          )
        : body;
  }
}
