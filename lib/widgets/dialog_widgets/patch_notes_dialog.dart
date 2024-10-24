import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../model/enums/patch_note_type.dart';
import '../../model/extensions/enums/patch_note_type_extension.dart';
import '../../model/version.dart';
import '../../utils/app_info_utils.dart';
import '../../utils/globals.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'default_dialog.dart';

class PatchNotesDialog extends StatelessWidget {
  final Map<Version, Map<PatchNoteType, List<String>>> newNotes;

  const PatchNotesDialog({super.key, required this.newNotes});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final height = min(screenSize.width * 2, screenSize.height * 0.8);
    final sortedKeys = newNotes.keys.toList()..sort((a, b) => b.compareTo(a));
    return SizedBox(
      height: height,
      child: DefaultDialog(
        title: Text(
          localizations.patchNotesDialogTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var version in sortedKeys)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${localizations.versionTitle}: ${version.toString()}'),
                    const SizedBox(height: 16),
                    ...newNotes[version]!.entries.map(
                      (entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key.localizedName(localizations),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: theme.primaryColor),
                            ),
                            const SizedBox(height: 8),
                            ...entry.value.map(
                              (note) => Padding(
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
                                      child: Text(note, style: Theme.of(context).textTheme.bodyLarge),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    if (sortedKeys.last != version) const Divider()
                  ],
                )
            ],
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
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
