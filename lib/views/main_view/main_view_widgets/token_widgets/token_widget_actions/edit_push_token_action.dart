import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import '../../../../../model/tokens/push_token.dart';
import '../../../../../utils/customizations.dart';
import '../../../../../utils/lock_auth.dart';
import 'token_action.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../utils/app_customizer.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../utils/storage_utils.dart';

class EditPushTokenAction extends TokenAction {
  final PushToken token;
  final BuildContext creatorContext;

  const EditPushTokenAction({
    Key? key,
    required this.token,
    required this.creatorContext,
  }) : super(key: key);

  @override
  SlidableAction build(BuildContext context) {
    Logger.info('build');

    return SlidableAction(
        label: AppLocalizations.of(context)!.edit,
        backgroundColor: Theme.of(context).brightness == Brightness.light ? ApplicationCustomizer.renameColorLight : ApplicationCustomizer.renameColorDark,
        foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
        icon: Icons.edit,
        onPressed: (context) async {
          if (token.isLocked && await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.authenticateToUnLockToken) == false) {
            return;
          }
          _showDialog();
        });
  }

  void _showDialog() {
    final tokenLabel = TextEditingController(text: token.label);
    final tokenURL = TextEditingController(text: token.url.toString());
    final tokenSersial = token.serial;
    final publicTokenKey = token.publicTokenKey;

    showDialog(
      context: globalNavigatorKey.currentContext!,
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          titlePadding: const EdgeInsets.all(12),
          contentPadding: const EdgeInsets.all(0),
          title: Text(AppLocalizations.of(context)!.editToken),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: Text(AppLocalizations.of(context)!.save),
                onPressed: () async {
                  final newToken = token.copyWith(label: tokenLabel.text, url: Uri.parse(tokenURL.text));
                  globalRef?.read(tokenProvider.notifier).updateToken(newToken);
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
                    initialValue: tokenSersial,
                    decoration: const InputDecoration(labelText: 'Serial'),
                    enabled: false,
                  ),
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
                    controller: tokenURL,
                    decoration: const InputDecoration(labelText: 'URL'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'URL';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ExpansionTile(
                    title: Text(
                      AppLocalizations.of(context)!.publicKey,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    children: [
                      Text(publicTokenKey ?? AppLocalizations.of(context)!.noPublicKey, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const Divider(),
                  ExpansionTile(
                    title: Text(AppLocalizations.of(context)!.firebaseToken, style: Theme.of(context).textTheme.titleMedium),
                    children: [
                      FutureBuilder(
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(snapshot.data != null ? snapshot.data.toString() : AppLocalizations.of(context)!.noFbToken);
                          } else {
                            return const Text('');
                          }
                        },
                        future: StorageUtil.getCurrentFirebaseToken(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
