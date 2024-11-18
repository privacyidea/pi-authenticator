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
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';

import '../../../../../../../utils/default_inkwell.dart';
import '../../../../model/mixins/sortable_mixin.dart';
import '../../../../model/tokens/token.dart';
import '../../../../utils/globals.dart';
import '../../../../utils/logger.dart';
import '../../../../utils/riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/pi_slidable.dart';
import 'default_token_actions/default_delete_action.dart';
import 'default_token_actions/default_edit_action.dart';
import 'default_token_actions/default_lock_action.dart';
import 'slideable_action.dart';
import 'token_widget.dart';

class TokenWidgetBase extends ConsumerStatefulWidget {
  final Widget tile;
  final Token token;
  final ConsumerSlideableAction? deleteAction;
  final ConsumerSlideableAction? editAction;
  final ConsumerSlideableAction? lockAction;
  final List<Widget> stack;
  final IconData dragIcon;

  const TokenWidgetBase._({
    required this.tile,
    required this.token,
    this.deleteAction,
    this.editAction,
    this.lockAction,
    this.stack = const <Widget>[],
    this.dragIcon = Icons.drag_handle,
    super.key,
  });

  factory TokenWidgetBase({
    required Widget tile,
    required Token token,
    ConsumerSlideableAction? deleteAction,
    ConsumerSlideableAction? editAction,
    ConsumerSlideableAction? lockAction,
    List<Widget> stack = const <Widget>[],
    IconData dragIcon = Icons.drag_handle,
    Key? key,
  }) {
    return TokenWidgetBase._(
      tile: tile,
      token: token,
      deleteAction: deleteAction,
      editAction: editAction,
      lockAction: lockAction,
      stack: stack,
      dragIcon: dragIcon,
      key: key,
    );
  }

  @override
  ConsumerState<TokenWidgetBase> createState() => _TokenWidgetBaseState();
}

class _TokenWidgetBaseState extends ConsumerState<TokenWidgetBase> {
  bool tokenIsDeleteable = false;

  @override
  Widget build(BuildContext context) {
    final SortableMixin? draggingSortable = ref.watch(draggingSortableProvider);
    final Future<bool?> tokenDeleteable;
    if (widget.token.containerSerial == null) {
      tokenDeleteable = Future.value(true);
    } else {
      tokenDeleteable = ref.watch(tokenContainerProvider.selectAsync((state) => state.containerOf(widget.token.containerSerial!)?.policies.tokensDeletable));
    }

    tokenDeleteable.then((value) {
      setState(() {
        tokenIsDeleteable = value ?? true;
      });
    });

    final List<ConsumerSlideableAction> actions = [
      widget.deleteAction ??
          DefaultDeleteAction(
            token: widget.token,
            isEnabled: tokenIsDeleteable,
            key: Key('${widget.token.id}deleteAction'),
          ),
      widget.editAction ?? DefaultEditAction(token: widget.token, key: Key('${widget.token.id}editAction')),
    ];
    if ((widget.token.pin == false)) {
      actions.add(
        widget.lockAction ?? DefaultLockAction(token: widget.token, key: Key('${widget.token.id}lockAction')),
      );
    }

    if (draggingSortable == widget.token) return const SizedBox();
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DefaultInkWell(
        onTap: () {},
        child: widget.tile,
      ),
    );

    if (draggingSortable != null) {
      return PiSliable(
        groupTag: TokenWidget.groupTag,
        identifier: widget.token.id,
        actions: actions,
        stack: widget.stack,
        child: child,
      );
    }

    return PiSliable(
      groupTag: TokenWidget.groupTag,
      identifier: widget.token.id,
      actions: actions,
      stack: widget.stack,
      child: LongPressDraggable(
        maxSimultaneousDrags: 1,
        onDragStarted: () => ref.read(draggingSortableProvider.notifier).state = widget.token,
        onDragCompleted: () {
          Logger.info('Draggable completed');
          // Will be handled by the sortableNotifier
        },
        onDraggableCanceled: (velocity, offset) {
          Logger.info('Draggable canceled');
          globalRef?.read(draggingSortableProvider.notifier).state = null;
        },
        dragAnchorStrategy: (Draggable<Object> d, BuildContext context, Offset point) {
          final textSize = textSizeOf(
            text: widget.token.label,
            style: Theme.of(context).textTheme.titleMedium!,
            textScaler: MediaQuery.of(context).textScaler,
            maxLines: 1,
          );
          return Offset(max(textSize.width / 2, 30), textSize.height / 2 + 30);
        },
        feedback: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.dragIcon, size: 60),
            Material(
                color: Colors.transparent,
                child: Text(
                  widget.token.label,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                )),
          ],
        ),
        data: widget.token,
        child: Material(
          color: Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}
