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

import '../../../../../../../model/riverpod_states/settings_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../model/enums/introduction.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../../../../widgets/focused_item_as_overlay.dart';
import '../../../license_view/license_view.dart';
import '../../../push_token_view/push_tokens_view.dart';
import '../app_bar_item.dart';

class LicensePushViewButton extends ConsumerWidget {
  const LicensePushViewButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      (ref.watch(settingsProvider).whenOrNull(data: (data) => data.hidePushTokens) ?? SettingsState.hidePushTokensDefault)
          ? FocusedItemAsOverlay(
              isFocused:
                  ref.watch(introductionNotifierProvider).whenOrNull(data: (data) => data.isConditionFulfilled(ref, Introduction.hidePushTokens)) ?? false,
              tooltipWhenFocused: AppLocalizations.of(context)!.introHidePushTokens,
              onComplete: () => ref.read(introductionNotifierProvider.notifier).complete(Introduction.hidePushTokens),
              child: AppBarItem(
                a11y: AppLocalizations.of(context)!.a11yPushTokensButton,
                onPressed: () => Navigator.pushNamed(context, PushTokensView.routeName),
                icon: const Icon(Icons.notifications),
              ),
            )
          : AppBarItem(
              a11y: AppLocalizations.of(context)!.a11yLicensesButton,
              onPressed: () => Navigator.of(context).pushNamed(LicenseView.routeName),
              icon: const Icon(Icons.info_outline),
            );
}
