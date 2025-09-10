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

class PiSliable extends ConsumerStatefulWidget {
  final String groupTag;
  final String identifier;
  final List<ConsumerSlideableAction> actions;
  final List<Widget> stack;
  final Widget child;

  const PiSliable({required this.groupTag, required this.identifier, required this.actions, required this.child, this.stack = const <Widget>[], super.key});

  @override
  ConsumerState<PiSliable> createState() => _PiSliableState();
}

class _PiSliableState extends ConsumerState<PiSliable> with TickerProviderStateMixin {
  late SlidableController controller;

  @override
  void initState() {
    super.initState();
    controller = SlidableController(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted == false) return;
      final list = ref.read(piSlidablesRef);
      list.add(controller);
      ref.read(piSlidablesRef.notifier).state = list;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final list = globalRef?.read(piSlidablesRef);
      if (list == null) return;
      list.remove(controller);
      globalRef?.read(piSlidablesRef.notifier).state = list;
    });
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childStack = Stack(children: [widget.child, for (var item in widget.stack) item]);
    return widget.actions.isNotEmpty
        ? ClipRRect(
            child: Slidable(
              controller: controller,
              key: ValueKey('${widget.groupTag}-${widget.identifier}'),
              groupTag: widget.groupTag,
              endActionPane: ActionPane(motion: const DrawerMotion(), extentRatio: 1, children: widget.actions),
              child: childStack,
            ),
          )
        : childStack;
  }
}
