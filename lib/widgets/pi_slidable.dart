/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';

import '../views/main_view/main_view_widgets/token_widgets/slideable_action.dart';

final piSlidablesRef = StateProvider<List<SlidableController>>((ref) => []);

class PiSlidable extends ConsumerStatefulWidget {
  final String groupTag;
  final String identifier;
  final List<ConsumerSlideableAction> actions;
  final List<Widget> stack;
  final Widget child;

  const PiSlidable({
    required this.groupTag,
    required this.identifier,
    required this.actions,
    required this.child,
    this.stack = const <Widget>[],
    super.key,
  });

  @override
  ConsumerState<PiSlidable> createState() => _PiSlidableState();
}

class _PiSlidableState extends ConsumerState<PiSlidable>
    with TickerProviderStateMixin {
  late SlidableController controller;

  @override
  void initState() {
    super.initState();
    controller = SlidableController(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(piSlidablesRef.notifier)
          .update((state) => [...state, controller]);
    });
  }

  @override
  void dispose() {
    final localController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalRef
          ?.read(piSlidablesRef.notifier)
          .update((state) => state.where((c) => c != localController).toList());
    });
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childStack = Stack(children: [widget.child, ...widget.stack]);

    if (widget.actions.isEmpty) return childStack;

    return ClipRRect(
      child: Slidable(
        controller: controller,
        key: ValueKey('${widget.groupTag}-${widget.identifier}'),
        groupTag: widget.groupTag,
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 1,
          children: widget.actions,
        ),
        child: childStack,
      ),
    );
  }
}
