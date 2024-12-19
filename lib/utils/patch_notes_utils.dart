/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
    final Map<Version, Map<PatchNoteType, List<String>>> newNotes = {};
    final allNotes = getLocalizedPatchNotes(AppLocalizations.of(context)!);
    for (Version noteVersion in allNotes.keys) {
      if (noteVersion > latestStartedVersion) newNotes[noteVersion] = allNotes[noteVersion]!;
    }
    while (newNotes.length > 2) {
      newNotes.remove(newNotes.keys.fold(null, (oldest, e) => e > oldest ? oldest : e));
    }
    return newNotes;
  }

  static void showPatchNotesIfNeeded(BuildContext context, Version latestStartedVersion) {
    if (latestStartedVersion < InfoUtils.currentVersion) {
      Logger.info('Showing patch notes between $latestStartedVersion and ${InfoUtils.currentVersion}');
      return _showPatchNotes(context: context, latestStartedVersion: latestStartedVersion);
    }
    Logger.info('No patch notes to show. Latest version: $latestStartedVersion. Current version: ${InfoUtils.currentVersion}');
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
