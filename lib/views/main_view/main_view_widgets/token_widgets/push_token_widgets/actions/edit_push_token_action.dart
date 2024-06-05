import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/default_token_actions/default_edit_action_dialog.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../model/enums/introduction.dart';
import '../../../../../../model/tokens/push_token.dart';
import '../../../../../../utils/customization/action_theme.dart';
import '../../../../../../utils/globals.dart';
import '../../../../../../utils/lock_auth.dart';
import '../../../../../../utils/riverpod_providers.dart';
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
  CustomSlidableAction build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context)!;
    return CustomSlidableAction(
        backgroundColor: Theme.of(context).extension<ActionTheme>()!.editColor,
        foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
        onPressed: (context) async {
          if (token.isLocked && await lockAuth(localizedReason: appLocalizations.editLockedToken) == false) {
            return;
          }
          _showDialog();
        },
        child: FocusedItemAsOverlay(
          tooltipWhenFocused: appLocalizations.introEditToken,
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
                appLocalizations.edit,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ],
          ),
        ));
  }

  String? _validatePushEndpointUrl(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.mustNotBeEmpty(AppLocalizations.of(context)!.pushEndpointUrl);
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty || uri.scheme.isEmpty || uri.path.isEmpty) {
      return AppLocalizations.of(context)!.exampleUrl;
    }
    return null;
  }

  void _showDialog() => showDialog(
        useRootNavigator: false,
        context: globalNavigatorKey.currentContext!,
        builder: (BuildContext context) {
          final pushUrl = TextEditingController(text: token.url.toString());
          final appLocalizations = AppLocalizations.of(context)!;
          return DefaultEditActionDialog(
            token: token,
            onSaveButtonPressed: ({required newLabel, newImageUrl}) async {
              globalRef?.read(tokenProvider.notifier).updateToken(
                    token,
                    (p0) => p0.copyWith(
                      label: newLabel,
                      url: Uri.parse(pushUrl.text),
                      tokenImage: newImageUrl,
                    ),
                  );
              Navigator.of(context).pop();
            },
            additionalChildren: [
              TextFormField(
                initialValue: token.serial,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).disabledColor),
                decoration: const InputDecoration(
                  labelText: 'Serial',
                ),
                readOnly: true,
              ),
              EnableTextFormFieldAfterManyTaps(
                controller: pushUrl,
                decoration: InputDecoration(labelText: appLocalizations.pushEndpointUrl),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => _validatePushEndpointUrl(value, context),
              ),
              const SizedBox(height: 10),
              ExpansionTile(
                title: Text(
                  appLocalizations.publicKey,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                children: [
                  SelectableText(
                    token.publicTokenKey ?? appLocalizations.noPublicKey,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const Divider(),
              ExpansionTile(
                title: Text(
                  appLocalizations.firebaseToken,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                children: [
                  SelectableText(
                    token.fbToken != null ? token.fbToken.toString() : appLocalizations.noFbToken,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                ],
              ),
            ],
          );
        },
      );
}
