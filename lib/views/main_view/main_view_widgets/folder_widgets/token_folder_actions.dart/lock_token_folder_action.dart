import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/token_folder.dart';
import '../../../../../utils/app_customizer.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod_providers.dart';

class LockTokenFolderAction extends StatelessWidget {
  final TokenFolder folder;

  const LockTokenFolderAction({super.key, required this.folder});
  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      backgroundColor: Theme.of(context).extension<ActionTheme>()!.lockColor,
      foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
      onPressed: (context) async {
        if (await lockAuth(localizedReason: AppLocalizations.of(context)!.unlock) == false) return;
        globalRef?.read(tokenFolderProvider.notifier).updateFolder(folder.copyWith(isLocked: !folder.isLocked));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.lock),
          Text(
            folder.isLocked ? AppLocalizations.of(context)!.unlock : AppLocalizations.of(context)!.lock,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}
