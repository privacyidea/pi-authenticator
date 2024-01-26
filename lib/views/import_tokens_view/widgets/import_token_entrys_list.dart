import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'import_token_entrys_list_tile.dart';

class ImportTokenEntrysList extends ConsumerStatefulWidget {
  const ImportTokenEntrysList({
    super.key,
    required this.importTokenEntries,
    required this.selectCallback,
  });

  final List<ImportTokenEntry> importTokenEntries;
  final void Function(List<ImportTokenEntry>) selectCallback;

  @override
  ConsumerState<ImportTokenEntrysList> createState() => _ImportTokensListState();
}

class _ImportTokensListState extends ConsumerState<ImportTokenEntrysList> {
  late List<ImportTokenEntry> importTokenEntries;

  @override
  void initState() {
    super.initState();
    importTokenEntries = widget.importTokenEntries;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in importTokenEntries)
          ImportTokenEntryListTile(
            selectCallback: (newEntry) {
              setState(() {
                importTokenEntries[importTokenEntries.indexOf(entry)] = newEntry;
              });
              widget.selectCallback(importTokenEntries);
            },
            importTokenEntry: entry,
            initialScreenSize: screenSize,
            key: Key(
              entry.hashCode.toString(),
            ),
          ),
      ],
    );
  }
}
