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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/mains/main_netknights.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../settings_view_widgets/settings_group.dart';

class SettingsGroupBackroundImage extends ConsumerWidget {
  const SettingsGroupBackroundImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (PrivacyIDEAAuthenticator.currentCustomization?.backgroundImage == null) return const SizedBox();
    return SettingsGroup(
      title: AppLocalizations.of(context)!.backgroundImage,
      onPressed: () => ref.read(settingsProvider.notifier).toggleShowBackgroundImage(),
      trailingWidget: FutureBuilder(
          future: ref.watch(settingsProvider.selectAsync((v) => v.showBackgroundImage)),
          builder: (context, snapshot) {
            if (snapshot.hasError || snapshot.data == null) {
              return const SizedBox();
            }
            return Switch(
              value: snapshot.data!,
              onChanged: (value) => ref.read(settingsProvider.notifier).setShowBackgroundImage(value),
            );
          }),
    );
  }
}
