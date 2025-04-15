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
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/token_container.dart';
import '../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../main_view/main_view_widgets/token_widgets/slideable_action.dart';
import '../../../view_interface.dart';
import '../dialogs/transfer_container_action_dialog.dart';

class TransferContainerAction extends ConsumerSlideableAction {
  final TokenContainerFinalized container;

  const TransferContainerAction({
    required this.container,
    super.key,
  });

  void _showExportContainerDialog(BuildContext context) {
    showDialog(useRootNavigator: false, context: context, builder: (_) => TransferContainerDialog(container: container));
  }

  @override
  CustomSlidableAction build(BuildContext context, WidgetRef ref) => CustomSlidableAction(
        onPressed: (BuildContext context) => _showExportContainerDialog(context),
        backgroundColor: Theme.of(context).extension<TokenTileTheme>()!.transferColor,
        foregroundColor: Theme.of(context).extension<TokenTileTheme>()!.actionForegroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(MdiIcons.transfer),
            Text(
              AppLocalizations.of(context)!.transferButton,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ],
        ),
      );
}
