import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../focused_item_as_overlay.dart';

import '../../model/enums/introduction.dart';
import '../../utils/riverpod_providers.dart';

class TokenIntroduction extends ConsumerWidget {
  final Widget child;
  const TokenIntroduction({required this.child, super.key});

  @override
  Widget build(context, ref) {
    if (ref.watch(introductionProvider).isConditionFulfilled(ref, Introduction.tokenSwipe)) {
      return FocusedItemAsOverlay(
        isFocused: true,
        tooltipWhenFocused: AppLocalizations.of(context)!.introTokenSwipe,
        alignment: Alignment.bottomCenter,
        onComplete: () => ref.read(introductionProvider.notifier).complete(Introduction.tokenSwipe),
        overlayChild: Column(children: [child]),
        child: child,
      );
    }
    if (ref.watch(introductionProvider).isConditionFulfilled(ref, Introduction.dragToken)) {
      return FocusedItemAsOverlay(
        isFocused: true,
        tooltipWhenFocused: AppLocalizations.of(context)!.introDragToken,
        alignment: Alignment.bottomCenter,
        onComplete: () => ref.read(introductionProvider.notifier).complete(Introduction.dragToken),
        overlayChild: Column(children: [child]),
        child: child,
      );
    }
    return child;
  }
}
