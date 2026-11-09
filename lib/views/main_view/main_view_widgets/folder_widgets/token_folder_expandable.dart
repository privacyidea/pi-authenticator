/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../model/tokens/token.dart';
import '../../../../model/riverpod_states/token_filter.dart';
import '../../../../model/token_folder.dart';
import '../../../../utils/globals.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../../../utils/riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import 'token_folder_expandable_widgets/token_folder_expandable_body.dart';
import 'token_folder_expandable_widgets/token_folder_expandable_header.dart';

class TokenFolderExpandable extends ConsumerStatefulWidget {
  final TokenFolder folder;
  final List<Token> folderTokens;
  final TokenFilter? filter;

  const TokenFolderExpandable({
    super.key,
    required this.folder,
    required this.folderTokens,
    this.filter,
  });

  @override
  ConsumerState<TokenFolderExpandable> createState() =>
      _TokenFolderExpandableState();
}

class _TokenFolderExpandableState extends ConsumerState<TokenFolderExpandable>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final ExpandableController expandableController;

  /// What this panel's last save asks for, until the stored folder shows it:
  /// the store lags a tap by a frame and a write, so a second tap would
  /// otherwise compare against a value that is about to change.
  bool? _savingExpanded;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      value: widget.folder.isExpanded ? 0 : 1.0,
      vsync: this,
    );
    expandableController = ExpandableController(
      initialExpanded: widget.folder.isExpanded,
    );
    expandableController.addListener(() {
      if (expandableController.expanded) {
        animationController.reverse();
      } else {
        animationController.forward();
      }

      final newIsExpanded = expandableController.expanded;
      // Following the stored folder (didUpdateWidget) needs no save.
      if (newIsExpanded == (_savingExpanded ?? widget.folder.isExpanded)) {
        return;
      }
      _savingExpanded = newIsExpanded;

      final folder = widget.folder;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        final saved = await globalRef
            ?.read(tokenFolderProvider.notifier)
            .updateFolder(folder, (p0) {
              return p0.copyWith(isExpanded: newIsExpanded);
            });
        // A failed save never reaches the stored folder.
        if (saved?.currentOf(folder)?.isExpanded != newIsExpanded &&
            _savingExpanded == newIsExpanded) {
          _savingExpanded = null;
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant TokenFolderExpandable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The stored folder can change without a tap on the panel: hiding the app
    // collapses locked folders, a home widget link expands one. Only such a
    // change is followed; a tap whose save is still pending must stay.
    final stored = widget.folder.isExpanded;
    if (_savingExpanded != null) {
      if (stored == _savingExpanded) _savingExpanded = null;
      return;
    }
    if (stored != oldWidget.folder.isExpanded &&
        stored != expandableController.expanded) {
      expandableController.expanded = stored;
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    expandableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokensFiltered = widget.folderTokens;
    tokensFiltered.sort((a, b) => a.compareTo(b));
    final draggingSortable = ref.watch(draggingSortableProvider);

    if (tokensFiltered.isEmpty && expandableController.expanded) {
      expandableController.value = false;
    }

    final isExpanded = expandableController.value;
    const double borderRadius = 6;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: borderRadius),
            margin: const EdgeInsets.only(bottom: 8, left: 14, right: 14),
            decoration: BoxDecoration(
              color: isExpanded
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Colors.transparent,
              borderRadius: const BorderRadius.all(
                Radius.circular(borderRadius),
              ),
              boxShadow: [
                if (isExpanded)
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ExpandablePanel(
            theme: const ExpandableThemeData(
              useInkWell: false,
              hasIcon: false,
              tapBodyToCollapse: false,
              tapBodyToExpand: false,
            ),
            controller: expandableController,
            header: TokenFolderExpandableHeader(
              key: ValueKey('folder_list_item_${widget.folder.folderId}'),
              tokens: tokensFiltered,
              expandableController: expandableController,
              animationController: animationController,
              folder: widget.folder,
            ),
            collapsed: const SizedBox(),
            expanded:
                tokensFiltered.isEmpty ||
                    (tokensFiltered.length == 1 &&
                        tokensFiltered.first == draggingSortable)
                ? const SizedBox()
                : TokenFolderExpandableBody(
                    tokens: tokensFiltered,
                    draggingSortable: draggingSortable,
                    folder: widget.folder,
                    isFilterd: widget.filter != null,
                  ),
          ),
        ),
      ],
    );
  }
}
