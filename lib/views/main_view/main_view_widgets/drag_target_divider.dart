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
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/token_folder.dart';
import '../../../utils/utils.dart';
import '../../../widgets/drag_item_scroller.dart';

/// DragTargetDivider is used to create a divider that can be used to move a sortable up or down in the list
/// It will accept a Sortable from the type T
class DragTargetDivider<T extends SortableMixin> extends ConsumerStatefulWidget {
  final TokenFolder? dependingFolder;
  final SortableMixin? previousSortable;
  final SortableMixin? nextSortable;
  final double dividerBaseHeight;
  final double dividerExpandedHeight;
  final double bottomPadding;
  final double opacity;
  final bool isExpandalbe;

  const DragTargetDivider({
    super.key,
    required this.dependingFolder,
    required this.previousSortable,
    required this.nextSortable,
    this.bottomPadding = 0,
    this.dividerBaseHeight = 1.5,
    this.dividerExpandedHeight = 40,
    this.opacity = 1,
    this.isExpandalbe = true,
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
          dragSortableOnAccept(
            previousSortable: widget.previousSortable,
            dragedSortable: details.data,
            nextSortable: widget.nextSortable,
            dependingFolder: widget.dependingFolder,
            ref: ref,
          );
        },
        builder: (context, _, __) {
          final dividerHeight = expansionController.value * widget.dividerExpandedHeight + (1 - expansionController.value) * widget.dividerBaseHeight;
          return DefaultDivider(
            dividerHeight: dividerHeight,
            opacity: widget.opacity,
            padding: EdgeInsets.only(bottom: max(widget.bottomPadding - dividerHeight + widget.dividerBaseHeight, 0.0)),
            margin: EdgeInsets.symmetric(horizontal: 8 - expansionController.value * 2, vertical: 8),
          );
        },
      );
}

bool _onWillAccept(SortableMixin? data, WidgetRef ref) {
  if (ref.read(dragItemScrollerStateProvider)) return false;
  return true;
}

class DefaultDivider extends StatelessWidget {
  final double dividerHeight;
  final double opacity;
  final EdgeInsets? padding;
  final EdgeInsets margin;

  const DefaultDivider({
    this.dividerHeight = 1.5,
    this.opacity = 1,
    this.padding,
    this.margin = const EdgeInsets.all(8),
    super.key,
  });

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: opacity,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Container(
            height: dividerHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(dividerHeight / 4),
            ),
            margin: margin,
          ),
        ),
      );
}
