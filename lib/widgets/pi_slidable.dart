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
import 'package:flutter_slidable/flutter_slidable.dart';

import '../views/main_view/main_view_widgets/token_widgets/slideable_action.dart';

class PiSliable extends StatelessWidget {
  final String groupTag;
  final String identifier;
  final List<ConsumerSlideableAction> actions;
  final List<Widget> stack;
  final Widget child;

  const PiSliable({
    required this.groupTag,
    required this.identifier,
    required this.actions,
    required this.child,
    this.stack = const <Widget>[],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final childStack = Stack(
      children: [
        child,
        for (var item in stack) item,
      ],
    );
    return actions.isNotEmpty
        ? ClipRRect(
            child: Slidable(
              key: ValueKey('$groupTag-$identifier'),
              groupTag: groupTag,
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 1,
                children: actions,
              ),
              child: childStack,
            ),
          )
        : childStack;
  }
}
