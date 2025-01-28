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

import '../../../../../../../model/extensions/enums/rollout_state_extension.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/token_container.dart';
import 'container_widget_tile_trailing.dart';

class ContainerWidgetTile extends ConsumerWidget {
  final TokenContainer container;
  final bool isPreview;

  const ContainerWidgetTile({required this.container, this.isPreview = false, super.key});

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
                child: ContainerWidgetTileTrailing(container: container, isPreview: isPreview),
              ),
            ),
          ],
        ),
      );
}
