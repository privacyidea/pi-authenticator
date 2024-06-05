import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/globals.dart';
import '../../feedback_view/feedback_view.dart';
import '../../license_view/license_view.dart';
import '../settings_view_widgets/settings_groups.dart';
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
        SettingsListTileButton(
          onPressed: () {
            Navigator.pushNamed(context, FeedbackView.routeName);
          },
          title: Text(
            'Feedback',
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          icon: const Icon(FluentIcons.chat_32_regular),
        ),
      ],
    );
  }
}
