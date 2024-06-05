import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../model/enums/patch_note_type.dart';
import '../model/version.dart';
import '../widgets/dialog_widgets/patch_notes_dialog.dart';
import 'app_info_utils.dart';
import 'globals.dart';
import 'logger.dart';

class PatchNotesUtils {
  static Map<Version, Map<PatchNoteType, List<String>>> _getNewPatchNotes({required BuildContext context, required Version latestStartedVersion}) {
    final context = globalNavigatorKey.currentContext;
    if (context == null) return {};
    final Map<Version, Map<PatchNoteType, List<String>>> newNotes = {};
    final allNotes = getLocalizedPatchNotes(AppLocalizations.of(context)!);
    for (Version noteVersion in allNotes.keys) {
      if (noteVersion > latestStartedVersion) newNotes[noteVersion] = allNotes[noteVersion]!;
    }
    return newNotes;
  }

  static void showPatchNotesIfNeeded(BuildContext context, Version latestStartedVersion) {
    if (latestStartedVersion < AppInfoUtils.currentVersion) {
      Logger.info('Showing patch notes between $latestStartedVersion and ${AppInfoUtils.currentVersion}', name: 'main_view.dart#showPatchNotesIfNeeded');
      return _showPatchNotes(context: context, latestStartedVersion: latestStartedVersion);
    }
    Logger.info(
      'No patch notes to show. Latest version: $latestStartedVersion. Current version: ${AppInfoUtils.currentVersion}',
      name: 'main_view.dart#showPatchNotesIfNeeded',
    );
  }

  static void _showPatchNotes({required BuildContext context, required Version latestStartedVersion}) {
    final newNotes = _getNewPatchNotes(context: context, latestStartedVersion: latestStartedVersion);
    if (newNotes.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => PatchNotesDialog(newNotes: newNotes),
      barrierDismissible: false,
      useRootNavigator: false,
    );
  }
}
