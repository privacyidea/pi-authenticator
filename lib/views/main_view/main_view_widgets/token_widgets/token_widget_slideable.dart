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
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../model/tokens/token.dart';
import 'token_action.dart';

class TokenWidgetSlideable extends StatelessWidget {
  final Token token;
  final List<TokenAction> actions;
  final List<Widget> stack;
  final Widget tile;

  const TokenWidgetSlideable({
    required this.token,
    required this.actions,
    required this.stack,
    required this.tile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      children: [
        tile,
        for (var item in stack) item,
      ],
    );
    return actions.isNotEmpty
        ? Slidable(
            key: ValueKey(token.id),
            groupTag: 'myTag', // This is used to only let one be open at a time.
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 1,
              children: actions,
            ),
            child: child,
          )
        : child;
  }
}
