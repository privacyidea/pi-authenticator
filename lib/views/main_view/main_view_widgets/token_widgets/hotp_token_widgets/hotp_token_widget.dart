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

import '../../../../../model/tokens/hotp_token.dart';
import '../token_widget.dart';
import '../token_widget_base.dart';
import 'actions/edit_hotp_token_action.dart';
import 'hotp_token_widget_tile.dart';

class HOTPTokenWidget extends TokenWidget {
  final HOTPToken token;
  final bool withDivider;

  const HOTPTokenWidget(
    this.token, {
    this.withDivider = true,
    super.key,
  });
  @override
  TokenWidgetBase build(BuildContext context) => TokenWidgetBase(
        token: token,
        tile: HOTPTokenWidgetTile(token, key: ValueKey(token.id)),
        dragIcon: Icons.replay,
        editAction: EditHOTPTokenAction(token: token),
      );
}
