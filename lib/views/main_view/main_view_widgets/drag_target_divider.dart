/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/extensions/sortable_list.dart';
import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/token_folder.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/riverpod/riverpod_providers/state_notifier_providers/token_folder_provider.dart';
import '../../../utils/riverpod/riverpod_providers/state_notifier_providers/token_provider.dart';
import '../../../widgets/drag_item_scroller.dart';

/// DragTargetDivider is used to create a divider that can be used to move a sortable up or down in the list
/// It will accept a Sortable from the type T
class DragTargetDivider<T extends SortableMixin> extends ConsumerStatefulWidget {
  final TokenFolder? dependingFolder;
  final SortableMixin? previousSortable;
  final SortableMixin? nextSortable;
  final double dividerBaseHeight;
  final double dividerExpandedHeight;
  final double bottomPaddingIfLast;
  final bool isExpandalbe;
  final bool ignoreFolderId;
  final bool isLastDivider;

  const DragTargetDivider({
    super.key,
    required this.dependingFolder,
    required this.previousSortable,
    required this.nextSortable,
    this.bottomPaddingIfLast = 0,
    this.dividerBaseHeight = 1.5,
    this.dividerExpandedHeight = 40,
    this.isExpandalbe = true,
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
  Widget build(BuildContext context) => DragTarget<T>(
        onWillAcceptWithDetails: (details) {
          final willAccept = _onWillAccept(details.data, ref);
          if (willAccept && widget.isExpandalbe) {
            expansionController.forward();
          }
          return willAccept;
        },
        onLeave: (data) {
          expansionController.reverse();
        },
        onAcceptWithDetails: (details) {
          expansionController.reset();
          _onAccept(
            previousSortable: widget.previousSortable,
            dragedSortable: details.data,
            nextSortable: widget.nextSortable,
            ignoreFolderId: widget.ignoreFolderId,
            dependingFolder: widget.dependingFolder,
            ref: ref,
          );
        },
        builder: (context, _, __) {
          final dividerHeight = expansionController.value * widget.dividerExpandedHeight + (1 - expansionController.value) * widget.dividerBaseHeight;
          return Padding(
            padding: EdgeInsets.only(bottom: widget.isLastDivider ? max(widget.bottomPaddingIfLast - dividerHeight + widget.dividerBaseHeight, 0) : 0),
            child: Container(
              height: dividerHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(dividerHeight / 4),
              ),
              margin: EdgeInsets.only(left: 8 - expansionController.value * 2, right: 8 - expansionController.value * 2, top: 8, bottom: 8),
            ),
          );
        },
      );
}

bool _onWillAccept(SortableMixin? data, WidgetRef ref) {
  if (ref.read(dragItemScrollerStateProvider)) return false;
  return true;
}

void _onAccept({
  required SortableMixin? previousSortable,
  required SortableMixin dragedSortable,
  required SortableMixin? nextSortable,
  required bool ignoreFolderId,
  TokenFolder? dependingFolder,
  required WidgetRef ref,
}) {
  final allTokens = ref.read(tokenProvider).tokens;
  final allFolders = ref.read(tokenFolderProvider).folders;
  var allSortables = [...allTokens, ...allFolders];

  if (dragedSortable is TokenFolder) {
    final tokensInFolder = ref.read(tokenProvider).tokens.where((element) => element.folderId == dragedSortable.folderId).toList();
    final allMovingItems = [dragedSortable, ...tokensInFolder];
    allSortables = allSortables.moveAllBetween(moveAfter: previousSortable, movedItems: allMovingItems, moveBefore: nextSortable);
  } else if (dragedSortable is Token) {
    allSortables = allSortables.moveBetween(moveAfter: previousSortable, movedItem: dragedSortable, moveBefore: nextSortable);
    allSortables = allSortables.map((e) {
      return e is Token && e.id == dragedSortable.id ? e.copyWith(folderId: () => dependingFolder?.folderId) : e;
    }).toList();
  }
  final modifiedTokens = allSortables.whereType<Token>().toList();
  final modifiedFolders = allSortables.whereType<TokenFolder>().toList();
  ref.read(tokenProvider.notifier).addOrReplaceTokens(modifiedTokens);
  ref.read(tokenFolderProvider.notifier).addOrReplaceFolders(modifiedFolders);
}
