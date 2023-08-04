import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../../model/tokens/day_password_token.dart';
import '../../../../../utils/utils.dart';
import '../../../../../utils/customizations.dart';
import '../../../../../utils/lock_auth.dart';
import 'token_action.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../utils/app_customizer.dart';
import '../../../../../utils/riverpod_providers.dart';

class EditDayPassowrdTokenAction extends TokenAction {
  final DayPasswordToken token;

  const EditDayPassowrdTokenAction({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  SlidableAction build(BuildContext context) => SlidableAction(
      label: AppLocalizations.of(context)!.edit,
      backgroundColor: Theme.of(context).brightness == Brightness.light ? ApplicationCustomizer.renameColorLight : ApplicationCustomizer.renameColorDark,
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
    final period = token.period;
    final algorithm = token.algorithm;

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
                  final newToken = token.copyWith(label: tokenLabel.text, tokenImage: imageUrl.text, period: period, algorithm: algorithm);
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
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Image URL';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: enumAsString(algorithm),
                    decoration: const InputDecoration(labelText: 'Algorithm'),
                    enabled: false,
                  ),
                  TextFormField(
                    initialValue: period.toString().split('.').first,
                    decoration: const InputDecoration(labelText: 'Period'),
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
