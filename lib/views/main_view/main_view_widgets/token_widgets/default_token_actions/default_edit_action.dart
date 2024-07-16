import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/enums/introduction.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/customization/action_theme.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod/riverpod_providers/state_notifier_providers/introduction_provider.dart';
import '../../../../../utils/riverpod/riverpod_providers/state_notifier_providers/token_provider.dart';
import '../../../../../widgets/focused_item_as_overlay.dart';
import '../token_action.dart';
import 'default_edit_action_dialog.dart';

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
          tooltipWhenFocused: AppLocalizations.of(context)!.editToken,
          childIsMoving: true,
          isFocused: ref.watch(introductionProvider).isConditionFulfilled(ref, Introduction.editToken),
          onComplete: () => ref.read(introductionProvider.notifier).complete(Introduction.editToken),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.edit),
              Text(
                AppLocalizations.of(context)!.save,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ],
          ),
        ));
  }

  void _showDialog() {
    showDialog(
      useRootNavigator: false,
      context: globalNavigatorKey.currentContext!,
      builder: (BuildContext context) {
        return DefaultEditActionDialog(
          token: token,
          onSaveButtonPressed: ({required newLabel, newImageUrl}) async {
            if (newLabel.isEmpty) return;
            final edited = await globalRef?.read(tokenProvider.notifier).updateToken(token, (p0) => p0.copyWith(label: newLabel, tokenImage: newImageUrl));
            if (edited == null) {
              Logger.error('Token editing failed', name: 'DefaultEditAction#_showDialog');
              return;
            }
            Logger.info(
              'Token edited: ${token.label} -> ${edited.label}, ${token.tokenImage} -> ${edited.tokenImage}',
              name: 'DefaultEditAction#_showDialog',
            );
            if (context.mounted) Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
