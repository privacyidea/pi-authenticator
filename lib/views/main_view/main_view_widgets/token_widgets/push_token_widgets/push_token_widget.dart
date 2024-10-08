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
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/push_token_rollout_state_extension.dart';

import '../../../../../model/mixins/sortable_mixin.dart';
import '../../../../../model/tokens/push_token.dart';
import '../token_widget.dart';
import '../token_widget_base.dart';
import 'actions/edit_push_token_action.dart';
import 'push_token_widget_tile.dart';
import 'rollout_failed_widget.dart';
import 'rollout_widget.dart';

class PushTokenWidget extends TokenWidget {
  final PushToken token;
  final SortableMixin? previousSortable;
  final bool withDivider;

  const PushTokenWidget(
    this.token, {
    this.withDivider = true,
    this.previousSortable,
    super.key,
  });

  @override
  TokenWidgetBase build(BuildContext context) => TokenWidgetBase(
        key: Key(token.id),
        token: token,
        tile: PushTokenWidgetTile(token),
        dragIcon: Icons.notifications,
        editAction: EditPushTokenAction(token: token, key: Key('${token.id}editAction')),
        stack: [
          if (!token.isRolledOut)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: token.rolloutState.rollOutInProgress ? RolloutWidget(token: token) : StartRolloutWidget(token: token),
                ),
              ),
            ),
        ],
      );
}
