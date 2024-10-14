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

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';

import '../../../../model/riverpod_states/token_filter.dart';
import '../../../../model/token_folder.dart';
import '../../../../utils/globals.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../../../utils/riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import 'token_folder_expandable_widgets/token_folder_expandable_header.dart';
import 'token_folder_expandable_widgets/token_folder_expandable_body.dart';

class TokenFolderExpandable extends ConsumerStatefulWidget {
  final TokenFolder folder;
  final List<Token> folderTokens;
  final TokenFilter? filter;
  final bool? expandOverride;

  const TokenFolderExpandable({
    super.key,
    required this.folder,
    required this.folderTokens,
    this.filter,
    this.expandOverride,
  });

  @override
  ConsumerState<TokenFolderExpandable> createState() => _TokenFolderExpandableState();
}

class _TokenFolderExpandableState extends ConsumerState<TokenFolderExpandable> with SingleTickerProviderStateMixin {
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
    animationController.dispose();
    expandableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokensFiltered = widget.folderTokens;
    tokensFiltered.sort((a, b) => a.compareTo(b));
    final draggingSortable = ref.watch(draggingSortableProvider);
    if (widget.expandOverride == null) {
      if (tokensFiltered.isEmpty && expandableController.expanded) {
        expandableController.value = false;
      } else if (widget.folder.isExpanded != expandableController.expanded) {
        expandableController.value = widget.folder.isExpanded;
      }
    } else {
      expandableController.value = widget.expandOverride!;
    }
    final isExpanded = expandableController.value;
    const double borderRadius = 6;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: borderRadius),
            margin: const EdgeInsets.only(bottom: 8, left: 14),
            decoration: BoxDecoration(
              color: isExpanded ? Theme.of(context).scaffoldBackgroundColor : Colors.transparent,
              borderRadius: isExpanded
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      bottomLeft: Radius.circular(borderRadius),
                    )
                  : const BorderRadius.all(Radius.circular(borderRadius)),
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
              fadeCurve: InstantCurve(),
              tapBodyToCollapse: false,
              tapBodyToExpand: false,
            ),
            controller: expandableController,
            header: TokenFolderExpandableHeader(
              tokens: tokensFiltered,
              expandableController: expandableController,
              animationController: animationController,
              expandOverride: widget.expandOverride,
              folder: widget.folder,
            ),
            collapsed: const SizedBox(),
            expanded: tokensFiltered.isEmpty || (tokensFiltered.length == 1 && tokensFiltered.first == draggingSortable)
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

class InstantCurve extends Curve {
  const InstantCurve();

  @override
  double transformInternal(double t) => t < 1 ? 1 : 0;
}
