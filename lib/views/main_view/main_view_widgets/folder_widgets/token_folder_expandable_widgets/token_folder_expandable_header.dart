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
import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/token_folder.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import '../../../../../utils/utils.dart';
import '../token_folder_actions.dart/delete_token_folder_action.dart';
import '../token_folder_actions.dart/lock_token_folder_action.dart';
import '../token_folder_actions.dart/rename_token_folder_action.dart';
import 'token_folder_expandable_header_icon.dart';

class TokenFolderExpandableHeader extends ConsumerStatefulWidget {
  final TokenFolder folder;
  final List<Token> tokens;
  final ExpandableController expandableController;
  final bool? expandOverride;
  final AnimationController animationController;

  const TokenFolderExpandableHeader({
    required this.tokens,
    required this.expandableController,
    required this.expandOverride,
    required this.animationController,
    required this.folder,
    super.key,
  });

  @override
  ConsumerState<TokenFolderExpandableHeader> createState() => _TokenFolderExpandableHeaderState();
}

class _TokenFolderExpandableHeaderState extends ConsumerState<TokenFolderExpandableHeader> {
  Timer? _expandTimer;

  @override
  void dispose() {
    _expandTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = widget.expandableController.value;
    final draggingSortable = ref.watch(draggingSortableProvider);
    return Slidable(
      key: ValueKey('tokenFolder-${widget.folder.folderId}'),
      groupTag: 'myTag',
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 1,
        children: [
          DeleteTokenFolderAction(folder: widget.folder),
          RenameTokenFolderAction(folder: widget.folder),
          LockTokenFolderAction(folder: widget.folder),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 0),
        child: DragTarget<Token>(
          onWillAcceptWithDetails: (details) {
            if (details.data.folderId != widget.folder.folderId) {
              if (widget.folder.isLocked || widget.tokens.isEmpty) return true;
              if (isExpanded) return true;
              _expandTimer?.cancel();
              _expandTimer = Timer(const Duration(milliseconds: 500), () {
                if (!mounted) return;
                widget.expandableController.value = true;
              });
              return true;
            }
            return false;
          },
          onLeave: (data) => _expandTimer?.cancel(),
          onAcceptWithDetails: (details) => dragSortableOnAccept(
            previousSortable: widget.folder,
            dragedSortable: details.data,
            nextSortable: null,
            dependingFolder: widget.folder,
            ref: ref,
          ),
          builder: (context, willAccept, willReject) => Center(
            child: Container(
              margin: widget.folder.isExpanded ? null : const EdgeInsets.only(right: 8),
              padding: widget.folder.isExpanded ? const EdgeInsets.only(right: 8) : null,
              height: 50,
              decoration: BoxDecoration(
                color: willAccept.isNotEmpty
                    ? Theme.of(context).dividerColor
                    : isExpanded
                        ? Theme.of(context).scaffoldBackgroundColor
                        : null,
                borderRadius: BorderRadius.only(
                  topRight: widget.folder.isExpanded ? const Radius.circular(0) : const Radius.circular(8),
                  topLeft: const Radius.circular(8),
                  bottomRight: widget.folder.isExpanded ? const Radius.circular(0) : const Radius.circular(8),
                  bottomLeft: widget.folder.isExpanded ? const Radius.circular(0) : const Radius.circular(8),
                ),
              ),
              child: Material(
                // Material to draw on for the InkWell
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    if (widget.expandOverride != null) return;
                    if (isExpanded) {
                      widget.expandableController.value = false;
                      return;
                    }
                    if (widget.tokens.isEmpty || (widget.tokens.length == 1 && widget.tokens.first == draggingSortable)) return;
                    if (widget.folder.isLocked && await lockAuth(localizedReason: AppLocalizations.of(context)!.expandLockedFolder) == false) {
                      return;
                    }
                    if (!mounted) return;
                    widget.expandableController.value = true;
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      RotationTransition(
                          turns: Tween(begin: 0.25, end: 0.0).animate(widget.animationController),
                          child: SizedBox.square(
                            dimension: 25,
                            child: (widget.tokens.isEmpty || (widget.tokens.length == 1 && widget.tokens.first == draggingSortable))
                                ? null
                                : const Icon(Icons.arrow_forward_ios_sharp),
                          )),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          widget.folder.label,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      TokenFolderExpandableHeaderIcon(
                        showEmptyFolderIcon: (widget.tokens.isEmpty || (widget.tokens.length == 1 && widget.tokens.first == draggingSortable)),
                        isLocked: widget.folder.isLocked,
                        isExpanded: isExpanded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
