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
import 'package:privacyidea_authenticator/model/extensions/enums/sync_state_extension.dart';

import '../../../../model/token_container.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../../widgets/button_widgets/cooldown_button.dart';
import '../dialogs/rollover_container_tokens_dialog.dart';

class RolloverContainerTokensButton extends ConsumerWidget {
  final TokenContainerFinalized container;
  static const double size = 40;

  const RolloverContainerTokensButton({required this.container, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final container = ref.watch(tokenContainerProvider).asData?.value.currentOf<TokenContainerFinalized>(this.container);
    return CooldownButton(
      styleType: CooldownButtonStyleType.iconButton,
      childWhenCooldown: CircularProgressIndicator.adaptive(),
      isPressable: container != null && container.syncState.isIdle,
      onPressed: container != null ? () => RolloverContainerTokensDialog.showDialog(context, this.container) : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.sync,
            size: size * 0.6,
          ),
          Icon(
            Icons.shield_outlined,
            size: size,
          ),
        ],
      ),
    );
  }
}
