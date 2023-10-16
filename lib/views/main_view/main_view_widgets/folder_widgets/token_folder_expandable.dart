import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../model/token_folder.dart';
import '../../../../model/tokens/token.dart';
import '../../../../utils/lock_auth.dart';
import '../../../../utils/riverpod_providers.dart';
import '../../../../widgets/custom_trailing.dart';
import '../drag_target_divider.dart';
import '../token_widgets/token_widget_builder.dart';
import 'token_folder_actions.dart/delete_token_folder_action.dart';
import 'token_folder_actions.dart/lock_token_folder_action.dart';
import 'token_folder_actions.dart/rename_token_folder_action.dart';

class TokenFolderExpandable extends ConsumerStatefulWidget {
  final TokenFolder folder;

  const TokenFolderExpandable({super.key, required this.folder});

  @override
  ConsumerState<TokenFolderExpandable> createState() => _TokenFolderExpandableState();
}

class _TokenFolderExpandableState extends ConsumerState<TokenFolderExpandable> with SingleTickerProviderStateMixin {
  Timer? _expandTimer;
  late final AnimationController animationController;
  late final ExpandableController expandableController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      value: widget.folder.isExpanded ? 0 : 1.0,
      vsync: this,
    );
    expandableController = ExpandableController(initialExpanded: widget.folder.isExpanded);
    expandableController.addListener(() {
      globalRef?.read(tokenFolderProvider.notifier).updateFolder(widget.folder.copyWith(isExpanded: expandableController.expanded));
      if (expandableController.expanded) {
        animationController.reverse();
      } else {
        animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _expandTimer?.cancel();
    animationController.dispose();
    expandableController.dispose();
    super.dispose();
  }

  @override
  ExpandablePanel build(BuildContext context) {
    final tokens = ref.watch(tokenProvider).tokensInFolder(widget.folder, exclude: ref.watch(settingsProvider).hidePushTokens ? [PushToken] : []);
    final draggingSortable = ref.watch(draggingSortableProvider);
    if (tokens.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        expandableController.expanded = false;
      });
    }
    return ExpandablePanel(
      theme: const ExpandableThemeData(hasIcon: false, tapBodyToCollapse: false, tapBodyToExpand: false),
      controller: expandableController,
      header: GestureDetector(
        onTap: () async {
          if (widget.folder.isExpanded) {
            expandableController.expanded = false;
            return;
          }
          if (tokens.isEmpty || (tokens.length == 1 && tokens.first == draggingSortable)) return;
          if (widget.folder.isLocked && await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.uncollapseLockedFolder) == false) {
            return;
          }
          if (!mounted) return;
          expandableController.toggle();
        },
        child: Slidable(
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
            child: DragTarget(
              onWillAccept: (data) {
                if (data is Token && data.folderId != widget.folder.folderId) {
                  if (widget.folder.isLocked) return true;
                  _expandTimer?.cancel();
                  _expandTimer = Timer(const Duration(milliseconds: 500), () {
                    if (!expandableController.expanded && tokens.isNotEmpty) expandableController.expanded = true;
                  });
                  return true;
                }
                return false;
              },
              onLeave: (data) => _expandTimer?.cancel(),
              onAccept: (data) {
                final updatedToken = (data as Token).copyWith(folderId: () => widget.folder.folderId);
                ref.read(tokenProvider.notifier).addOrReplaceToken(updatedToken);
              },
              builder: (context, willAccept, willReject) => Center(
                child: Container(
                  margin: widget.folder.isExpanded ? null : const EdgeInsets.only(right: 8),
                  padding: widget.folder.isExpanded ? const EdgeInsets.only(right: 8) : null,
                  height: 50,
                  decoration: BoxDecoration(
                    color: willAccept.isNotEmpty ? Theme.of(context).dividerColor : null,
                    borderRadius: BorderRadius.only(
                      topRight: widget.folder.isExpanded ? const Radius.circular(0) : const Radius.circular(8),
                      topLeft: const Radius.circular(8),
                      bottomRight: widget.folder.isExpanded ? const Radius.circular(0) : const Radius.circular(8),
                      bottomLeft: widget.folder.isExpanded ? const Radius.circular(0) : const Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      RotationTransition(
                          turns: Tween(begin: 0.25, end: 0.0).animate(animationController),
                          child: SizedBox.square(
                            dimension: 25,
                            child:
                                (tokens.isEmpty || (tokens.length == 1 && tokens.first == draggingSortable)) ? null : const Icon(Icons.arrow_forward_ios_sharp),
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
                      CustomTrailing(
                        child: Center(
                          child: (tokens.isEmpty || (tokens.length == 1 && tokens.first == draggingSortable))
                              ? Icon(
                                  Icons.folder_open,
                                  color: Theme.of(context).listTileTheme.iconColor,
                                )
                              : Icon(
                                  Icons.folder,
                                  color: Theme.of(context).listTileTheme.iconColor,
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
      ),
      collapsed: const SizedBox(),
      expanded: tokens.isEmpty || (tokens.length == 1 && tokens.first == draggingSortable)
          ? const SizedBox()
          : Container(
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
                        DragTargetDivider<Token>(dependingFolder: widget.folder, nextSortable: tokens[i]),
                      TokenWidgetBuilder.fromToken(
                        tokens[i],
                        withDivider: i < tokens.length - 1,
                      ),
                    ],
                    if (tokens.isNotEmpty && draggingSortable is Token) DragTargetDivider<Token>(dependingFolder: widget.folder, nextSortable: null),
                    if (tokens.isNotEmpty && draggingSortable is! Token) const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
    );
  }
}
