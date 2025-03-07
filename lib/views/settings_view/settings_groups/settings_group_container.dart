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

import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../../../../../views/container_view/container_view.dart';
import '../settings_view_widgets/settings_group.dart';

class SettingsGroupContainer extends ConsumerWidget {
  const SettingsGroupContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SettingsGroup(
        title: AppLocalizations.of(context)!.container,
        onPressed: () => Navigator.of(context).pushNamed(ContainerView.routeName),
        isActive: ref.watch(tokenContainerProvider).whenOrNull(data: (data) => data)?.containerList.isNotEmpty ?? false,
        trailingIcon: Icons.arrow_forward_ios, // TODO: Change to container icon when we have one
      );
}
