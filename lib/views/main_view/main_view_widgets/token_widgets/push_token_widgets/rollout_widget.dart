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

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/extensions/enums/push_token_rollout_state_extension.dart';
import '../../../../../model/tokens/push_token.dart';

class RolloutWidget extends StatelessWidget {
  final PushToken token;
  const RolloutWidget({required this.token, super.key});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator.adaptive(),
          Text(
            token.rolloutState.rolloutMsg(AppLocalizations.of(context)!),
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ],
      );
}
