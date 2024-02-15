import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../model/enums/introduction.dart';
import '../../../../../../model/tokens/push_token.dart';
import '../../../../../../repo/secure_token_repository.dart';
import '../../../../../../utils/app_customizer.dart';
import '../../../../../../utils/globals.dart';
import '../../../../../../utils/lock_auth.dart';
import '../../../../../../utils/riverpod_providers.dart';
import '../../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../../../../widgets/enable_text_form_field_after_many_taps.dart';
import '../../../../../../widgets/focused_item_as_overlay.dart';
import '../../token_action.dart';

class EditPushTokenAction extends TokenAction {
  final PushToken token;

  const EditPushTokenAction({
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

  void _showDialog() {
    final tokenLabel = TextEditingController(text: token.label);
    final pushUrl = TextEditingController(text: token.url.toString());
    final imageUrl = TextEditingController(text: token.tokenImage);
    final tokenSersial = token.serial;
    final publicTokenKey = token.publicTokenKey;

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
                globalRef?.read(tokenProvider.notifier).updateToken(
                      token,
                      (p0) => p0.copyWith(
                        label: tokenLabel.text,
                        url: Uri.parse(pushUrl.text),
                        tokenImage: imageUrl.text,
                      ),
                    );
                Navigator.of(context).pop();
              }),
        ],
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: tokenSersial,
                decoration: const InputDecoration(labelText: 'Serial'),
                enabled: false,
              ),
              EnableTextFormFieldAfterManyTaps(
                  controller: pushUrl,
                  decoration: const InputDecoration(labelText: 'URL'),
                  validator: (value) {
                    if (value!.isEmpty) return 'URL';
                    return null;
                  }),
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
                  if (value!.isEmpty) return AppLocalizations.of(context)!.imageUrl;
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ExpansionTile(
                title: Text(
                  AppLocalizations.of(context)!.publicKey,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                children: [
                  Text(
                    publicTokenKey ?? AppLocalizations.of(context)!.noPublicKey,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const Divider(),
              ExpansionTile(
                title: Text(
                  AppLocalizations.of(context)!.firebaseToken,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                children: [
                  FutureBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data != null ? snapshot.data.toString() : AppLocalizations.of(context)!.noFbToken,
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      } else {
                        return const Text(
                          '',
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        );
                      }
                    },
                    future: SecureTokenRepository.getCurrentFirebaseToken(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
