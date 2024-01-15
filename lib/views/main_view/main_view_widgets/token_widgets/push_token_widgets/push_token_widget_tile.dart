import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/enums/introduction.dart';
import '../../../../../model/tokens/push_token.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/focused_item_as_overlay.dart';
import '../token_widget_tile.dart';

class PushTokenWidgetTile extends ConsumerWidget {
  final PushToken token;
  const PushTokenWidgetTile(this.token, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TokenWidgetTile(
      key: Key('${token.hashCode}TokenWidgetTile'),
      tokenIsLocked: token.isLocked,
      tokenImage: token.tokenImage,
      title: Text(
        token.label,
        textScaler: const TextScaler.linear(1.9),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitles: [
        if (token.issuer.isNotEmpty) token.issuer,
      ],
      trailing: FocusedItemAsOverlay(
        tooltipWhenFocused: AppLocalizations.of(context)!.introPollForChallenges,
        alignment: Alignment.centerLeft,
        isFocused: ref.watch(introductionProvider).isConditionFulfilled(ref, Introduction.pollForChallenges),
        onComplete: () {
          ref.read(introductionProvider.notifier).complete(Introduction.pollForChallenges);
        },
        child: const Icon(
          Icons.notifications,
          size: 26,
        ),
      ),
    );
  }
}
