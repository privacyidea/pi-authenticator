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
import '../../../widgets/pi_slidable.dart';
import '../container_view.dart';
import 'container_actions/delete_container_action.dart';
import 'container_actions/details_container_action.dart';
import 'container_widget_tile.dart';

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
  Widget build(BuildContext context, WidgetRef ref) => isPreview
      ? ContainerWidgetTile(container: container)
      : ClipRRect(
          child: PiSliable(
            groupTag: groupTag,
            identifier: container.serial,
            actions: [
              DeleteContainerAction(container: container, key: Key('${container.serial}-DeleteContainerAction')),
              DetailsContainerAction(container: container, key: Key('${container.serial}-EditContainerAction')),
            ],
            stack: stack,
            child: ContainerWidgetTile(container: container),
          ),
        );
}
