import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../model/token_folder.dart';
import '../../../../../utils/app_customizer.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod_providers.dart';

class LockTokenFolderAction extends StatelessWidget {
  final TokenFolder folder;

  const LockTokenFolderAction({super.key, required this.folder});
  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      label: folder.isLocked ? AppLocalizations.of(context)!.unlock : AppLocalizations.of(context)!.lock,
      backgroundColor: Theme.of(context).brightness == Brightness.light ? applicationCustomizer.lockColorLight : applicationCustomizer.lockColorDark,
      foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
      icon: Icons.lock,
      onPressed: (context) async {
        if (await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.unlock) == false) return;
        globalRef?.read(tokenFolderProvider.notifier).updateFolder(folder.copyWith(isLocked: !folder.isLocked));
      },
    );
  }
}
