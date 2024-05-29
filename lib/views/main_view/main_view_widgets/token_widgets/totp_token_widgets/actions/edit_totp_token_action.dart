import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../model/enums/introduction.dart';
import '../../../../../../model/tokens/totp_token.dart';
import '../../../../../../utils/customization/action_theme.dart';
import '../../../../../../utils/globals.dart';
import '../../../../../../utils/lock_auth.dart';
import '../../../../../../utils/riverpod_providers.dart';
import '../../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../../../../widgets/focused_item_as_overlay.dart';
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

  void _showDialog() {
    final tokenLabel = TextEditingController(text: token.label);
    final imageUrl = TextEditingController(text: token.tokenImage);
    final period = token.period;
    final algorithm = token.algorithm;

    showDialog(
      useRootNavigator: false,
      context: globalNavigatorKey.currentContext!,
      builder: (BuildContext context) => DefaultDialog(
        scrollable: true,
        title: Text(
          AppLocalizations.of(context)!.editToken,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        actions: [
          TextButton(
            child: Text(
              AppLocalizations.of(context)!.cancel,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
              child: Text(
                AppLocalizations.of(context)!.save,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              onPressed: () async {
                globalRef
                    ?.read(tokenProvider.notifier)
                    .updateToken(token, (p0) => p0.copyWith(label: tokenLabel.text, tokenImage: imageUrl.text, period: period, algorithm: algorithm));
                Navigator.of(context).pop();
              }),
        ],
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: tokenLabel,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!.name;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: imageUrl,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.imageUrl),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!.imageUrl;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: algorithm.name,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.algorithm),
                  enabled: false,
                ),
                TextFormField(
                  initialValue: period.toString().split('.').first,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.period),
                  enabled: false,
                ),
                if (token.origin != null)
                  TextFormField(
                    initialValue: token.origin!.originName,
                    decoration: const InputDecoration(labelText: 'Origin'),
                    enabled: false,
                  ),
                TextFormField(
                  initialValue: token.isPrivacyIdeaToken == false ? 'Yes' : 'No',
                  decoration: const InputDecoration(labelText: 'Is exportable?'),
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
