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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/riverpod_states/settings_state.dart';
import '../../../../model/riverpod_states/token_filter.dart';
import '../../../../model/token_folder.dart';
import '../../../../model/tokens/push_token.dart';
import '../../../../model/tokens/token.dart';
import '../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../../utils/globals.dart';
import '../../../../utils/lock_auth.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../utils/riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/custom_trailing.dart';
import '../drag_target_divider.dart';
import '../token_widgets/token_widget_builder.dart';
import 'token_folder_actions.dart/delete_token_folder_action.dart';
import 'token_folder_actions.dart/lock_token_folder_action.dart';
import 'token_folder_actions.dart/rename_token_folder_action.dart';

class TokenFolderExpandable extends ConsumerStatefulWidget {
  final TokenFolder folder;
  final TokenFilter? filter;
  final bool? expandOverride;

  const TokenFolderExpandable({super.key, required this.folder, this.filter, this.expandOverride});

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
      value: widget.expandOverride ?? widget.folder.isExpanded ? 0 : 1.0,
      vsync: this,
    );
    expandableController = ExpandableController(initialExpanded: widget.expandOverride ?? widget.folder.isExpanded);
    expandableController.addListener(() {
      if (expandableController.expanded) {
        animationController.reverse();
      } else {
        animationController.forward();
      }
      if (widget.expandOverride != null) return;
      if (widget.folder.isExpanded != expandableController.expanded) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          globalRef?.read(tokenFolderProvider.notifier).updateFolder(widget.folder, (p0) => p0.copyWith(isExpanded: expandableController.expanded));
        });
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
    final hidePushTokens = ref.watch(settingsProvider).whenOrNull(data: (data) => data.hidePushTokens) ?? SettingsState.hidePushTokensDefault;
    final tokens = ref.watch(tokenProvider).tokensInFolder(widget.folder, exclude: hidePushTokens ? [PushToken] : []);

    tokens.sort((a, b) => a.compareTo(b));
    final draggingSortable = ref.watch(draggingSortableProvider);
    if (widget.expandOverride == null) {
      if (tokens.isEmpty && expandableController.expanded) {
        expandableController.value = false;
      } else if (widget.folder.isExpanded != expandableController.expanded) {
        expandableController.value = widget.folder.isExpanded;
      }
    } else {
      expandableController.value = widget.expandOverride!;
    }
    return ExpandablePanel(
      theme: const ExpandableThemeData(hasIcon: false, tapBodyToCollapse: false, tapBodyToExpand: false),
      controller: expandableController,
      header: GestureDetector(
        onTap: () async {
          if (widget.expandOverride != null) return;
          if (expandableController.value) {
            expandableController.value = false;
            return;
          }
          if (tokens.isEmpty || (tokens.length == 1 && tokens.first == draggingSortable)) return;
          if (widget.folder.isLocked && await lockAuth(localizedReason: AppLocalizations.of(context)!.expandLockedFolder) == false) {
            return;
          }
          if (!mounted) return;
          expandableController.value = true;
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
            child: DragTarget<Token>(
              onWillAcceptWithDetails: (details) {
                if (details.data.folderId != widget.folder.folderId) {
                  if (widget.folder.isLocked || tokens.isEmpty) return true;
                  if (expandableController.value) return true;
                  _expandTimer?.cancel();
                  _expandTimer = Timer(const Duration(milliseconds: 500), () {
                    if (!mounted) return;
                    expandableController.value = true;
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
                              : Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder,
                                      color: Theme.of(context).listTileTheme.iconColor,
                                    ),
                                    if (widget.folder.isLocked)
                                      Positioned.fill(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            return Container(
                                              padding: EdgeInsets.only(left: widget.folder.isExpanded ? 2 : 0, top: 1),
                                              child: Icon(
                                                widget.folder.isExpanded ? MdiIcons.lockOpenVariant : MdiIcons.lock,
                                                color: Theme.of(context).extension<ActionTheme>()?.lockColor,
                                                size: constraints.maxHeight / 2.1,
                                                shadows: [
                                                  Shadow(
                                                    color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
                                                    offset: const Offset(0.5, 0.5),
                                                    blurRadius: 2,
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
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
                      if (draggingSortable != tokens[i] && (i != 0 || draggingSortable is Token))
                        widget.filter == null
                            ? DragTargetDivider<Token>(
                                dependingFolder: widget.folder,
                                previousSortable: (i - 1) < 0 ? null : tokens[i - 1],
                                nextSortable: tokens[i],
                              )
                            : const Divider(),
                      TokenWidgetBuilder.fromToken(tokens[i]),
                    ],
                    if (tokens.isNotEmpty && draggingSortable is Token)
                      widget.filter == null
                          ? DragTargetDivider<Token>(dependingFolder: widget.folder, previousSortable: tokens.last, nextSortable: null)
                          : const Divider(),
                    if (tokens.isNotEmpty && draggingSortable is! Token) const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
    );
  }
}
