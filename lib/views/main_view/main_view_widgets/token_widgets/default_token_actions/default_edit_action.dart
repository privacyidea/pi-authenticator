import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/enums/introduction.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/app_customizer.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../../../widgets/focused_item_as_overlay.dart';
import '../token_action.dart';

class DefaultEditAction extends TokenAction {
  final Token token;
  const DefaultEditAction({required this.token, super.key});

  @override
  CustomSlidableAction build(BuildContext context, WidgetRef ref) {
    return CustomSlidableAction(
        backgroundColor: Theme.of(context).extension<ActionTheme>()!.editColor,
        foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
        onPressed: (context) async {
          if (token.isLocked && await lockAuth(localizedReason: AppLocalizations.of(context)!.editLockedToken) == false) {
            return;
          }
          _showDialog();
        },
        child: FocusedItemAsOverlay(
          tooltipWhenFocused: AppLocalizations.of(context)!.renameToken,
          childIsMoving: true,
          isFocused: ref.watch(introductionProvider).isConditionFulfilled(ref, Introduction.editToken),
          onComplete: () => ref.read(introductionProvider.notifier).complete(Introduction.editToken),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.edit),
              Text(
                AppLocalizations.of(context)!.rename,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ],
          ),
        ));
  }

  void _showDialog() {
    TextEditingController nameInputController = TextEditingController(text: token.label);
    showDialog(
        useRootNavigator: false,
        context: globalNavigatorKey.currentContext!,
        builder: (BuildContext context) {
          return DefaultDialog(
            scrollable: true,
            title: Text(
              AppLocalizations.of(context)!.renameToken,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            content: TextFormField(
              autofocus: true,
              controller: nameInputController,
              onChanged: (value) {},
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
              validator: (value) {
                if (value!.isEmpty) {
                  return AppLocalizations.of(context)!.name;
                }
                return null;
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.rename,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                onPressed: () {
                  final newLabel = nameInputController.text.trim();
                  if (newLabel.isEmpty) return;
                  globalRef?.read(tokenProvider.notifier).updateToken(token, (p0) => p0.copyWith(label: newLabel));

                  Logger.info(
                    'Renamed token:',
                    name: 'token_widget_base.dart#TextButton#renameClicked',
                    error: '\'${token.label}\' changed to \'$newLabel\'',
                  );

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
