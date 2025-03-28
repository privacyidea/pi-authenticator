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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/allow_screenshot_notifier.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_groups/settings_group_allow_screenshot/dialogs/allow_screenshot_dialog.dart';

import '../../../../l10n/app_localizations.dart';
import '../../settings_view_widgets/settings_group.dart';

class SettingsGroupAllowScreenshot extends ConsumerWidget {
  const SettingsGroupAllowScreenshot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.watch(allowScreenshotProvider.future),
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.data == null) {
          return const SizedBox();
        }
        final isAllowed = snapshot.data!;
        return SettingsGroup(
          title: isAllowed ? AppLocalizations.of(context)!.screenshotsAllowed : AppLocalizations.of(context)!.screenshotsNotAllowed,
          onPressed: () async {
            if (!isAllowed) {
              final allowed = await AllowScreenshotDialog.showDialog();
              if (allowed != true) return;
            }
            ref.read(allowScreenshotProvider.notifier).toggleAllowScreenshots();
          },
          trailingWidget: Switch(
            value: snapshot.data!,
            onChanged: (value) async {
              if (value) {
                final allowed = await AllowScreenshotDialog.showDialog();
                if (allowed != true) return;
                ref.read(allowScreenshotProvider.notifier).allowScreenshots();
              } else {
                ref.read(allowScreenshotProvider.notifier).disallowScreenshots();
              }
            },
          ),
        );
      },
    );
  }
}
