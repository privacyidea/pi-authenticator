import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/enums/introduction.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/app_customizer.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/focused_item_as_overlay.dart';
import '../token_action.dart';

class DefaultLockAction extends TokenAction {
  final Token token;

  const DefaultLockAction({required this.token, super.key});

  @override
  CustomSlidableAction build(context, ref) {
    return CustomSlidableAction(
      backgroundColor: Theme.of(context).extension<ActionTheme>()!.lockColor,
      foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
      onPressed: (context) async {
        Logger.info('Changing lock status of token.', name: 'token_widgets.dart#_changeLockStatus');
        if (await lockAuth(localizedReason: AppLocalizations.of(context)!.authenticateToUnLockToken) == false) return;

        globalRef?.read(tokenProvider.notifier).updateToken(token, (p0) => p0.copyWith(isLocked: !token.isLocked));
      },
      child: FocusedItemAsOverlay(
        tooltipWhenFocused: AppLocalizations.of(context)!.introLockToken,
        childIsMoving: true,
        alignment: Alignment.bottomCenter,
        isFocused: ref.watch(introductionProvider).isConditionFulfilled(ref, Introduction.lockToken),
        onComplete: () => ref.read(introductionProvider.notifier).complete(Introduction.lockToken),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.lock),
            Text(
              token.isLocked ? AppLocalizations.of(context)!.unlock : AppLocalizations.of(context)!.lock,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}
