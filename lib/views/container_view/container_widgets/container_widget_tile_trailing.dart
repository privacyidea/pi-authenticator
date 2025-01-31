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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/rollout_state_extension.dart';

import '../../../model/enums/rollout_state.dart';
import '../../../model/token_container.dart';
import '../../../utils/logger.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../widgets/button_widgets/cooldown_button.dart';
import 'buttons/rollover_container_tokens_button.dart';
import 'buttons/sync_container_button.dart';

class ContainerWidgetTileTrailing extends ConsumerWidget {
  final TokenContainer container;
  final bool isPreview;

  const ContainerWidgetTileTrailing({required this.container, required this.isPreview, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final container = this.container;
    if (container is TokenContainerFinalized) {
      return _buildFinalizedContainer(container, context);
    }
    if (container is TokenContainerUnfinalized) {
      return _buildUnfinalizedContainer(container, context, ref);
    }
    throw UnimplementedError('Unknown container type: ${container.runtimeType}');
  }

  Widget _buildFinalizedContainer(TokenContainerFinalized container, BuildContext context) {
    final actions = <Widget>[
      SyncContainerButton(container: container),
    ];
    Logger.debug('Is preview: $isPreview');
    if (container.policies.rolloverAllowed && !isPreview) {
      actions.add(RolloverContainerTokensButton(container: container));
    }
    if (actions.length == 1) return actions.first;
    return DropdownButton(
      underline: SizedBox(),
      value: 0,
      items: [
        for (var i = 0; i < actions.length; i++)
          DropdownMenuItem(
            value: i,
            child: actions[i],
          ),
      ],
      onChanged: (int? value) {},
    );
  }

  Widget _buildUnfinalizedContainer(TokenContainerUnfinalized container, BuildContext context, WidgetRef ref) {
    if (container.finalizationState.isFailed || container.finalizationState == FinalizationState.notStarted) {
      return CooldownButton(
        styleType: CooldownButtonStyleType.iconButton,
        childWhenCooldown: CircularProgressIndicator.adaptive(),
        onPressed: () async {
          await ref.read(tokenContainerProvider.notifier).finalize(container, isManually: true);
        },
        child: const Icon(Icons.link_rounded),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircularProgressIndicator.adaptive(),
    );
  }
}
