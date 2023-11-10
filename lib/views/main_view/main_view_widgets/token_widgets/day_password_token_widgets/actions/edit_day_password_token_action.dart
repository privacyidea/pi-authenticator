import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../model/tokens/day_password_token.dart';
import '../../../../../../utils/customizations.dart';
import '../../../../../../utils/lock_auth.dart';
import '../../../../../../utils/riverpod_providers.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../../widgets/default_dialog.dart';
import '../../token_action.dart';

class EditDayPassowrdTokenAction extends TokenAction {
  final DayPasswordToken token;

  const EditDayPassowrdTokenAction({
    required this.token,
  });

  @override
  void handle(BuildContext context) async {
    if (token.isLocked && await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.editLockedToken) == false) {
      return;
    }
    _showDialog();
  }

  void _showDialog() {
    final tokenLabel = TextEditingController(text: token.label);
    final imageUrl = TextEditingController(text: token.tokenImage);
    final period = token.period;
    final algorithm = token.algorithm;

    showDialog(
      useRootNavigator: false,
      context: globalNavigatorKey.currentContext!,
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: DefaultDialog(
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
                    initialValue: enumAsString(algorithm),
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.algorithm),
                    enabled: false,
                  ),
                  TextFormField(
                    initialValue: period.toString().split('.').first,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.period),
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
