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
import 'package:privacyidea_authenticator/model/token_container.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/customization/theme_extentions/status_colors.dart';
import '../../../utils/view_utils.dart';
import '../../button_widgets/delayed_elevated_button.dart';
import '../default_dialog.dart';

class ContainerShowContainerUrlDialog extends StatelessWidget {
  final TokenContainer container;

  const ContainerShowContainerUrlDialog(
    this.container, {
    super.key,
  });

  static Future<bool?> showDialog(TokenContainer container) => showAsyncDialog<bool>(
        builder: (context) => ContainerShowContainerUrlDialog(container),
        barrierDismissible: false,
      );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Color warningColor = Theme.of(context).extension<StatusColors>()!.warning;

    return DefaultDialog(
      title: Row(
        mainAxisAlignment: (container.sslVerify == false) ? MainAxisAlignment.spaceAround : MainAxisAlignment.start,
        children: [
          if (container.sslVerify == false) Icon(Icons.warning_amber_rounded, color: warningColor, size: 36),
          Flexible(child: Text(appLocalizations.showContainerUrlDialogTitle)),
          if (container.sslVerify == false) Icon(Icons.warning_amber_rounded, color: warningColor, size: 36),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appLocalizations.showContainerUrlDialogContent(container.serverUrl),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (container.sslVerify == false) SizedBox(height: 8),
          if (container.sslVerify == false)
            Text(
              appLocalizations.showContainerUrlDialogSslWarning,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: warningColor),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(appLocalizations.cancel),
        ),
        DelayedElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(appLocalizations.ok),
        ),
      ],
    );
  }
}
