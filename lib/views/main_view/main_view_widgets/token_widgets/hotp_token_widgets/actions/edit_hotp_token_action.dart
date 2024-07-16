import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../model/enums/introduction.dart';
import '../../../../../../model/tokens/hotp_token.dart';
import '../../../../../../utils/customization/action_theme.dart';
import '../../../../../../utils/globals.dart';
import '../../../../../../utils/lock_auth.dart';
import '../../../../../../utils/riverpod/riverpod_providers/state_notifier_providers/introduction_provider.dart';
import '../../../../../../widgets/focused_item_as_overlay.dart';
import '../../default_token_actions/default_edit_action_dialog.dart';
import '../../token_action.dart';

class EditHOTPTokenAction extends TokenAction {
  final HOTPToken token;

  const EditHOTPTokenAction({
    super.key,
    required this.token,
  });

  @override
  CustomSlidableAction build(BuildContext context, WidgetRef ref) => CustomSlidableAction(
      backgroundColor: Theme.of(context).extension<ActionTheme>()!.editColor,
      foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
      onPressed: (context) async {
        if (token.isLocked && await lockAuth(localizedReason: AppLocalizations.of(context)!.editLockedToken) == false) {
          return;
        }
        _showDialog();
      },
      child: FocusedItemAsOverlay(
        tooltipWhenFocused: AppLocalizations.of(context)!.introEditToken,
        childIsMoving: true,
        alignment: Alignment.bottomCenter,
        isFocused: ref.watch(introductionProvider).isConditionFulfilled(ref, Introduction.editToken),
        onComplete: () => ref.read(introductionProvider.notifier).complete(Introduction.editToken),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.edit),
            Text(
              AppLocalizations.of(context)!.edit,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ],
        ),
      ));

  void _showDialog() => showDialog(
        useRootNavigator: false,
        context: globalNavigatorKey.currentContext!,
        builder: (BuildContext context) => DefaultEditActionDialog(
          token: token,
          additionalChildren: [
            TextFormField(
              initialValue: token.algorithm.name,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.algorithm),
              enabled: false,
            ),
          ],
        ),
      );
}
