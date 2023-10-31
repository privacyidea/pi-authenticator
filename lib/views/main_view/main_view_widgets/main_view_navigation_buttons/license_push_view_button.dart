import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/states/settings_state.dart';
import '../../../../utils/riverpod_providers.dart';
import '../../../../widgets/pulse_icon.dart';
import '../../../license_view/license_view.dart';
import '../../../push_token_view/push_tokens_view.dart';
import '../app_bar_item.dart';

class LicensePushViewButton extends ConsumerWidget {
  const LicensePushViewButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (ref.watch(settingsProvider).hidePushTokensState) {
        HidePushTokens.notHidden => AppBarItem(
            onPressed: () => Navigator.of(context).pushNamed(LicenseView.routeName),
            icon: const Icon(Icons.info_outline),
          ),
        HidePushTokens.isHiddenNotNoticed => PulseIcon(
            width: 24,
            height: 24,
            isPulsing: ref.watch(settingsProvider).hidePushTokensState == HidePushTokens.isHiddenNotNoticed,
            child: AppBarItem(
              onPressed: () {
                ref.read(settingsProvider.notifier).setHidePushTokens(hidePushTokensState: HidePushTokens.isHiddenAndNoticed);
                Navigator.pushNamed(context, PushTokensView.routeName);
              },
              icon: const FittedBox(child: Icon(Icons.notifications)),
            ),
          ),
        HidePushTokens.isHiddenAndNoticed => AppBarItem(
            onPressed: () {
              ref.read(settingsProvider.notifier).setHidePushTokens(hidePushTokensState: HidePushTokens.isHiddenAndNoticed);
              Navigator.pushNamed(context, PushTokensView.routeName);
            },
            icon: const FittedBox(child: Icon(Icons.notifications)),
          ),
      };
}
