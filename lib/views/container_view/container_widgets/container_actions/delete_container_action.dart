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
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/token_container.dart';
import '../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../main_view/main_view_widgets/token_widgets/slideable_action.dart';
import '../../../view_interface.dart';

class DeleteContainerAction extends ConsumerSlideableAction {
  final TokenContainer container;

  const DeleteContainerAction({
    required this.container,
    super.key,
  });

  @override
  CustomSlidableAction build(BuildContext context, WidgetRef ref) => CustomSlidableAction(
        onPressed: (BuildContext context) => ref.read(tokenContainerProvider.notifier).deleteContainer(container),
        backgroundColor: Theme.of(context).extension<ActionTheme>()!.deleteColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.delete_forever),
            Text(
              AppLocalizations.of(context)!.delete,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ],
        ),
      );
  void _showDeleteDialog(BuildContext context, WidgetRef ref) {}
}
