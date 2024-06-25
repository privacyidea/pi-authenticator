import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../model/enums/introduction.dart';
import '../../../../../../model/tokens/totp_token.dart';
import '../../../../../../utils/customization/action_theme.dart';
import '../../../../../../utils/globals.dart';
import '../../../../../../utils/lock_auth.dart';
import '../../../../../../utils/riverpod_providers.dart';
import '../../../../../../widgets/focused_item_as_overlay.dart';
import '../../default_token_actions/default_edit_action_dialog.dart';
import '../../token_action.dart';

class EditTOTPTokenAction extends TokenAction {
  final TOTPToken token;

  const EditTOTPTokenAction({
    super.key,
    required this.token,
  });

  @override
  CustomSlidableAction build(context, ref) => CustomSlidableAction(
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
            TextFormField(
              initialValue: token.period.toString().split('.').first,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.period),
              enabled: false,
            ),
          ],
        ),
      );
}
