import 'dart:math';

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
    final screenSize = MediaQuery.of(context).size;
    final height = min(screenSize.width * 2, screenSize.height * 0.8);
    return SizedBox(
      height: height,
      child: DefaultDialog(
        title: Text(
          localizations.patchNotesDialogTitle,
          style: Theme.of(context).textTheme.titleLarge,
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ...newNotes[version]!.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key.getName(localizations),
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
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
