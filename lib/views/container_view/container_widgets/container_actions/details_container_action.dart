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

import '../../../../../../../views/container_view/container_widgets/container_actions/details_container_action_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../model/token_container.dart';
import '../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../main_view/main_view_widgets/token_widgets/slideable_action.dart';
import '../../../view_interface.dart';

class DetailsContainerAction extends ConsumerSlideableAction {
  final TokenContainer container;

  const DetailsContainerAction({
    required this.container,
    super.key,
  });

  void _showDetailsContainerDialog(BuildContext context) {
    showDialog(useRootNavigator: false, context: context, builder: (_) => DetailsContainerDialog(context, container: container));
  }

  @override
  CustomSlidableAction build(BuildContext context, WidgetRef ref) => CustomSlidableAction(
        onPressed: (BuildContext context) => _showDetailsContainerDialog(context),
        backgroundColor: Theme.of(context).extension<ActionTheme>()!.editColor,
        foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.edit),
            Text(
              AppLocalizations.of(context)!.details,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ],
        ),
      );
}
