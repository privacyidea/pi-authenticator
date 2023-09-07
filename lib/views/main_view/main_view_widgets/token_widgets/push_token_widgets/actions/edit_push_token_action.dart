import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../../model/tokens/push_token.dart';
import '../../../../../../utils/app_customizer.dart';
import '../../../../../../utils/customizations.dart';
import '../../../../../../utils/lock_auth.dart';
import '../../../../../../utils/riverpod_providers.dart';
import '../../../../../../repo/secure_token_repository.dart';
import '../../../../../../widgets/default_dialog.dart';
import '../../../../../../widgets/enable_text_form_field_after_many_taps.dart';
import '../../token_action.dart';

class EditPushTokenAction extends TokenAction {
  final PushToken token;

  const EditPushTokenAction({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  CustomSlidableAction build(BuildContext context) => CustomSlidableAction(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? applicationCustomizer.renameColorLight : applicationCustomizer.renameColorDark,
      foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
      onPressed: (context) async {
        if (token.isLocked && await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.editLockedToken) == false) {
          return;
        }
        _showDialog();
      },
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
      ));

  void _showDialog() {
    final tokenLabel = TextEditingController(text: token.label);
    final pushUrl = TextEditingController(text: token.url.toString());
    final imageUrl = TextEditingController(text: token.tokenImage);
    final tokenSersial = token.serial;
    final publicTokenKey = token.publicTokenKey;

    showDialog(
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
                final newToken = token.copyWith(
                  label: tokenLabel.text,
                  url: Uri.parse(pushUrl.text),
                  tokenImage: imageUrl.text,
                );
                globalRef?.read(tokenProvider.notifier).addOrReplaceToken(newToken);
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
