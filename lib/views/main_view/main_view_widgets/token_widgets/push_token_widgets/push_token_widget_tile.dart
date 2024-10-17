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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/enums/introduction.dart';
import '../../../../../model/tokens/push_token.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import '../../../../../widgets/custom_trailing.dart';
import '../../../../../widgets/focused_item_as_overlay.dart';
import '../token_widget_tile.dart';

class PushTokenWidgetTile extends ConsumerWidget {
  final PushToken token;
  final bool isPreview;
  const PushTokenWidgetTile(this.token, {this.isPreview = false, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TokenWidgetTile(
      key: Key('${token.hashCode}TokenWidgetTile'),
      token: token,
      title: token.label,
      titleTooltip: AppLocalizations.of(context)!.containerSerial,
      trailing: FocusedItemAsOverlay(
        tooltipWhenFocused: AppLocalizations.of(context)!.introPollForChallenges,
        alignment: Alignment.centerLeft,
        isFocused: ref.watch(introductionNotifierProvider).when(
              data: (value) => value.isConditionFulfilled(ref, Introduction.pollForChallenges),
              error: (Object error, StackTrace stackTrace) => false,
              loading: () => false,
            ),
        onComplete: () {
          ref.read(introductionNotifierProvider.notifier).complete(Introduction.pollForChallenges);
        },
        child: const CustomTrailing(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Icon(
              size: 100,
              Icons.notifications,
            ),
          ),
        ),
      ),
    );
  }
}
