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
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/rollout_state_extension.dart';

import '../../../model/token_container.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../widgets/pi_slidable.dart';
import '../../main_view/main_view_widgets/token_widgets/token_widget_tile.dart';
import '../container_view.dart';
import 'container_actions/delete_container_action.dart';
import 'container_actions/edit_container_action.dart';

class ContainerWidget extends ConsumerWidget {
  final TokenContainer container;
  final bool isPreview;

  final List<Widget> stack;

  const ContainerWidget({
    required this.container,
    this.isPreview = false,
    this.stack = const <Widget>[],
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ClipRRect(
        child: PiSliable(
          groupTag: groupTag,
          identifier: container.serial,
          actions: [
            DeleteContainerAction(container: container, key: Key('${container.serial}-DeleteContainerAction')),
            EditContainerAction(container: container, key: Key('${container.serial}-EditContainerAction')),
          ],
          stack: stack,
          child: TokenWidgetTile(
            title: Text(
              container.serial,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitles: [
              AppLocalizations.of(context)!.issuer(container.issuer),
              '${container.finalizationState.rolloutMsg(AppLocalizations.of(context)!)}',
            ],
            trailing: _getTrailing(context, ref),
          ),
        ),
      );

  Widget _getTrailing(BuildContext context, WidgetRef ref) {
    if (container is TokenContainerFinalized) {
      return IconButton(
        icon: const Icon(Icons.sync),
        onPressed: () {
          final tokenState = ref.read(tokenProvider);
          ref.read(tokenContainerProvider.notifier).syncTokens(tokenState);
        },
      );
    }
    if (container.finalizationState.isFailed) {
      return IconButton(
        icon: const Icon(Icons.sync_problem),
        onPressed: () {
          ref.read(tokenContainerProvider.notifier).finalize(container);
        },
      );
    }
    return SizedBox();
  }
}
