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
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/globals.dart';
import '../../license_view/license_view.dart';
import '../settings_view_widgets/settings_group.dart';
import '../settings_view_widgets/settings_list_tile_button.dart';

class SettingsGroupGeneral extends StatelessWidget {
  const SettingsGroupGeneral({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: AppLocalizations.of(context)!.settingsGroupGeneral,
      children: [
        SettingsListTileButton(
          onPressed: () async {
            if (!await launchUrl(policyStatementUri)) {
              throw Exception('Could not launch $policyStatementUri');
            }
          },
          title: Text(
            AppLocalizations.of(context)!.privacyPolicy,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
        SettingsListTileButton(
          onPressed: () {
            Navigator.pushNamed(context, LicenseView.routeName);
          },
          title: Text(
            AppLocalizations.of(context)!.licensesAndVersion,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
        SettingsListTileButton(
          onPressed: () => launchUrl(piAuthenticatorGitHubUri),
          title: Text(
            AppLocalizations.of(context)!.thisAppIsOpenSource,
            //'This Application is a Open Source Project. Visit us on GitHub.',
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
          ),
          icon: const Icon(SimpleIcons.github),
        ),
      ],
    );
  }
}
