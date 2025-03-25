/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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

import '../../l10n/app_localizations.dart';
import '../../widgets/push_request_listener.dart';
import '../view_interface.dart';
import 'settings_groups/settings_group_background_image.dart';
import 'settings_groups/settings_group_container.dart';
import 'settings_groups/settings_group_enable_screenshot.dart';
import 'settings_groups/settings_group_error_log.dart';
import 'settings_groups/settings_group_feedback.dart';
import 'settings_groups/settings_group_general.dart';
import 'settings_groups/settings_group_import_export_tokens.dart';
import 'settings_groups/settings_group_language.dart';
import 'settings_groups/settings_group_push_token.dart';
import 'settings_groups/settings_group_theme.dart';

class SettingsView extends ConsumerView {
  @override
  RouteSettings get routeSettings => const RouteSettings(name: routeName);
  static const String routeName = '/settings';

  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => PushRequestListener(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.settings,
              overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
              maxLines: 2, // Title can be shown on small screens too.
            ),
          ),
          body: const SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsGroupFeedback(),
                SettingsGroupImportExportTokens(),
                SettingsGroupPushToken(),
                SettingsGroupContainer(),
                SettingsGroupTheme(),
                SettingsGroupBackroundImage(),
                SettingsGroupLanguage(),
                SettingsGroupAllowScreenshot(),
                SettingsGroupErrorLog(),
                SettingsGroupGeneral(),
              ],
            ),
          ),
        ),
      );
}
