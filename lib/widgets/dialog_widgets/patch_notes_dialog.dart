import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../model/enums/patch_note_type.dart';
import '../../utils/app_info_utils.dart';
import '../../utils/riverpod_providers.dart';
import '../../utils/version.dart';
import 'default_dialog.dart';

class PatchNotesDialog extends StatelessWidget {
  final Map<Version, Map<PatchNoteType, List<String>>> newNotes;

  const PatchNotesDialog({super.key, required this.newNotes});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return DefaultDialog(
      title: Text(
        localizations.patchNotesDialogTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: theme.primaryColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: newNotes.keys.map((version) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${localizations.version}: ${version.toString()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                ...newNotes[version]!.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key.getName(localizations),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...entry.value.map((note) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 3, right: 4),
                                  child: Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    note,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            globalRef?.read(settingsProvider.notifier).setLatestStartedVersion(AppInfoUtils.currentVersion);
            Navigator.of(context).pop();
          },
          child: Text(
            localizations.ok,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: theme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
