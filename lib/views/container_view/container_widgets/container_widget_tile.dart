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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/sync_state_extension.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../../../../../model/extensions/enums/rollout_state_extension.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/riverpod_states/token_state.dart';
import '../../../model/token_container.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../widgets/button_widgets/cooldown_button.dart';

class ContainerWidgetTile extends ConsumerWidget {
  final TokenContainer container;

  const ContainerWidgetTile({required this.container, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 2),
        titleAlignment: ListTileTitleAlignment.center,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topLeft,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: AppLocalizations.of(context)!.containerSerial,
              triggerMode: TooltipTriggerMode.longPress,
              child: Text(
                container.serial,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var line in [
                      AppLocalizations.of(context)!.issuerLabel(container.issuer),
                      '${container.finalizationState.rolloutMsgLocalized(AppLocalizations.of(context)!)}',
                    ])
                      Text(
                        line,
                        style: Theme.of(context).listTileTheme.subtitleTextStyle,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.contain,
                child: ContainerWidgetTileTrailing(container: container),
              ),
            ),
          ],
        ),
      );
}

class RolloverContainerTokensDialog extends ConsumerStatefulWidget {
  final TokenContainerFinalized container;

  static Future<void> showDialog(BuildContext context, TokenContainerFinalized container) async {
    await showAsyncDialog(builder: (context) => RolloverContainerTokensDialog(container: container));
  }

  const RolloverContainerTokensDialog({required this.container, super.key});

  @override
  ConsumerState<RolloverContainerTokensDialog> createState() => _RolloverContainerTokensDialogState();
}

class _RolloverContainerTokensDialogState extends ConsumerState<RolloverContainerTokensDialog> {
  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      title: Text(AppLocalizations.of(context)!.renewSecretsDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocalizations.of(context)!.renewSecretsDialogText),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final tokenState = ref.read(tokenProvider);
            _renewSecrets(tokenState: tokenState);
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.renewSecrets),
        ),
      ],
    );
  }

  Future<void> _renewSecrets({required TokenState tokenState}) async {
    try {
      await ref.read(tokenContainerProvider.notifier).rolloverTokens(tokenState: tokenState, container: widget.container);
    } catch (e) {
      showStatusMessage(message: 'Failed to renew secrets', subMessage: e.toString());
    }
  }
}

class SyncContainerButton extends ConsumerWidget {
  final TokenContainerFinalized container;

  const SyncContainerButton({required this.container, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final container = ref.watch(tokenContainerProvider).asData?.value.currentOf(this.container);
    return CooldownButton(
      styleType: CooldownButtonStyleType.iconButton,
      childWhenCooldown: CircularProgressIndicator.adaptive(),
      isPressable: container != null && container.syncState.isIdle,
      onPressed: container != null
          ? () async {
              final tokenState = ref.read(tokenProvider);
              await ref.read(tokenContainerProvider.notifier).syncTokens(tokenState: tokenState, containersToSync: [container], isManually: true);
            }
          : null,
      child: const Icon(Icons.sync, size: 40),
    );
  }
}

class ContainerWidgetTileTrailing extends ConsumerWidget {
  final TokenContainer container;

  const ContainerWidgetTileTrailing({required this.container, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (container is TokenContainerFinalized) {
      final actions = <Widget>[
        SyncContainerButton(container: container as TokenContainerFinalized),
      ];
      if (container.policies.rolloverAllowed) {
        actions.add(RolloverContainerTokensButton(container: container as TokenContainerFinalized));
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
    if (container.finalizationState.isFailed) {
      return CooldownButton(
        styleType: CooldownButtonStyleType.iconButton,
        childWhenCooldown: CircularProgressIndicator.adaptive(),
        onPressed: () async {
          await ref.read(tokenContainerProvider.notifier).finalize(container, isManually: true);
        },
        child: const Icon(Icons.link_rounded),
      );
    }
    return CircularProgressIndicator.adaptive();
  }
}

class RolloverContainerTokensButton extends ConsumerWidget {
  final TokenContainerFinalized container;
  static const double size = 40;

  const RolloverContainerTokensButton({required this.container, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final container = ref.watch(tokenContainerProvider).asData?.value.currentOf(this.container);
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
