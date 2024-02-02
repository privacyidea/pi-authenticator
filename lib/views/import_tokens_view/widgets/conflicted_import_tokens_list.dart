import 'package:flutter/material.dart';

import 'conflicted_import_tokens_tile.dart';

class ConflictedImportTokensList extends StatelessWidget {
  const ConflictedImportTokensList({
    required this.importEntries,
    required this.updateImportTokenEntry,
    this.title,
    this.titlePadding = const EdgeInsets.all(0),
    this.leadingDivider = false,
    super.key,
  });

  final String? title;
  final EdgeInsetsGeometry titlePadding;
  final bool leadingDivider;

  final List<ImportTokenEntry> importEntries;
  final void Function(ImportTokenEntry oldEntry, ImportTokenEntry newEntry) updateImportTokenEntry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (leadingDivider) ...[
          const SizedBox(height: 16),
          const Divider(
            thickness: 2,
            height: 2,
            indent: 4,
            endIndent: 4,
          ),
          const SizedBox(height: 16),
        ],
        if (title != null) ...[
          Padding(
            padding: titlePadding,
            child: Text(
              title!,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
        ],
        for (final entry in importEntries)
          ConflictedImportTokensTile(
            selectTokenCallback: (newEntry) => updateImportTokenEntry(entry, newEntry),
            importTokenEntry: entry,
            initialScreenSize: MediaQuery.of(context).size,
            key: Key(
              entry.hashCode.toString(),
            ),
          ),
      ],
    );
  }
}
