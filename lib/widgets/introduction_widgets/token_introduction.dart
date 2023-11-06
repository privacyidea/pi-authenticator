import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/widgets/focused_item_as_overlay.dart';

import '../../model/enums/introduction_enum.dart';
import '../../utils/riverpod_providers.dart';

class TokenIntroduction extends ConsumerWidget {
  final Widget child;
  const TokenIntroduction({required this.child, super.key});

  @override
  Widget build(context, ref) {
    return FocusedItemAsOverlay(
      tooltipWhenFocused: AppLocalizations.of(context)!.introTokenSwipe,
      alignment: Alignment.bottomCenter,
      onComplete: () {
        ref.read(introductionProvider.notifier).complete(Introduction.tokenSwipe);
      },
      isFocused: ref.watch(introductionProvider).isTokenSwipeConditionFulfilled(ref),
      overlayChild: Column(
        children: [child],
      ),
      child: child,
    );
  }
}
