import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/widgets/focused_item_as_overlay.dart';

import '../../../../../model/enums/introduction_enum.dart';
import '../../../../../model/tokens/push_token.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../token_widget_tile.dart';

class PushTokenWidgetTile extends ConsumerWidget {
  final PushToken token;
  PushTokenWidgetTile(this.token) : super(key: ValueKey(token.id));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TokenWidgetTile(
      key: Key('${token.hashCode}TokenWidgetTile'),
      tokenIsLocked: token.isLocked,
      tokenImage: token.tokenImage,
      title: Text(
        token.label,
        textScaleFactor: 1.9,
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
