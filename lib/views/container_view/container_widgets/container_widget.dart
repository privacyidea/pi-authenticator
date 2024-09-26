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

import '../../../model/token_container.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../widgets/pi_slideable.dart';
import '../../main_view/main_view_widgets/token_widgets/token_widget_tile.dart';
import '../container_view.dart';
import 'container_actions/delete_container_action.dart';
import 'container_actions/edit_container_action.dart';

class ContainerWidget extends ConsumerWidget {
  final TokenContainer containerCredential;

  final List<Widget> stack;

  const ContainerWidget({
    required this.containerCredential,
    this.stack = const <Widget>[],
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ClipRRect(
        child: PiSlideable(
          groupTag: groupTag,
          identifier: containerCredential.serial,
          actions: [
            DeleteContainerAction(container: containerCredential, key: Key('${containerCredential.serial}-DeleteContainerAction')),
            EditContainerAction(container: containerCredential, key: Key('${containerCredential.serial}-EditContainerAction')),
          ],
          stack: stack,
          tile: TokenWidgetTile(
            title: Text(containerCredential.serial),
            subtitles: [
              'issuer: ${containerCredential.issuer}',
              'finalizationState: ${containerCredential.finalizationState.name}',
            ],
            trailing: containerCredential is TokenContainerFinalized
                ? IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: () {
                      final tokenState = ref.read(tokenProvider);
                      ref.read(tokenContainerProvider.notifier).syncTokens(tokenState);
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      ref.read(tokenContainerProvider.notifier).deleteContainer(containerCredential);
                    },
                  ),
          ),
        ),
      );
}
