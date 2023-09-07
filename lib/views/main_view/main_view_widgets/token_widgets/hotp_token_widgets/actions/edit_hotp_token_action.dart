import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../../model/tokens/hotp_token.dart';
import '../../../../../../utils/app_customizer.dart';
import '../../../../../../utils/customizations.dart';
import '../../../../../../utils/lock_auth.dart';
import '../../../../../../utils/riverpod_providers.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../../widgets/default_dialog.dart';
import '../../token_action.dart';

class EditHOTPTokenAction extends TokenAction {
  final HOTPToken token;

  const EditHOTPTokenAction({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  SlidableAction build(BuildContext context) => SlidableAction(
      label: AppLocalizations.of(context)!.edit,
      backgroundColor: Theme.of(context).brightness == Brightness.light ? applicationCustomizer.renameColorLight : applicationCustomizer.renameColorDark,
      foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
      icon: Icons.edit,
      onPressed: (context) async {
        if (token.isLocked && await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.editLockedToken) == false) {
          return;
        }
        _showDialog();
      });

  void _showDialog() {
    final tokenLabel = TextEditingController(text: token.label);
    final imageUrl = TextEditingController(text: token.tokenImage);
    final algorithm = token.algorithm;

    showDialog(
      context: globalNavigatorKey.currentContext!,
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: DefaultDialog(
          scrollable: true,
          title: Text(AppLocalizations.of(context)!.editToken),
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
                  final newToken = token.copyWith(label: tokenLabel.text, tokenImage: imageUrl.text, algorithm: algorithm);
                  globalRef?.read(tokenProvider.notifier).addOrReplaceToken(newToken);
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
                    initialValue: enumAsString(algorithm),
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.algorithm),
                    enabled: false,
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
