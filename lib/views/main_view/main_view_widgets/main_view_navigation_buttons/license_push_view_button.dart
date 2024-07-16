import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/enums/introduction.dart';
import '../../../../utils/riverpod/riverpod_providers/state_notifier_providers/introduction_provider.dart';
import '../../../../utils/riverpod/riverpod_providers/state_notifier_providers/settings_provider.dart';
import '../../../../widgets/focused_item_as_overlay.dart';
import '../../../license_view/license_view.dart';
import '../../../push_token_view/push_tokens_view.dart';
import '../app_bar_item.dart';

class LicensePushViewButton extends ConsumerWidget {
  const LicensePushViewButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidePushTokens = ref.watch(settingsProvider).hidePushTokens;
    return hidePushTokens
        ? FocusedItemAsOverlay(
            isFocused: ref.watch(introductionProvider).isConditionFulfilled(ref, Introduction.hidePushTokens),
            tooltipWhenFocused: AppLocalizations.of(context)!.introHidePushTokens,
            onComplete: () => ref.read(introductionProvider.notifier).complete(Introduction.hidePushTokens),
            child: AppBarItem(
              tooltip: AppLocalizations.of(context)!.pushTokens,
              onPressed: () => Navigator.pushNamed(context, PushTokensView.routeName),
              icon: const Icon(Icons.notifications),
            ),
          )
        : AppBarItem(
            tooltip: AppLocalizations.of(context)!.licenses,
            onPressed: () => Navigator.of(context).pushNamed(LicenseView.routeName),
            icon: const Icon(Icons.info_outline),
          );
  }
}
