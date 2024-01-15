import 'package:flutter/material.dart';

import '../../../model/tokens/token.dart';
import 'import_token_entrys_list.dart';
import 'import_token_entrys_list_tile.dart';
import 'import_tokens_list_tile.dart';

class ImportTokensList extends StatelessWidget {
  const ImportTokensList({
    this.importTokens,
    this.title,
    this.titlePadding = const EdgeInsets.all(0),
    this.borderColor = Colors.green,
    this.leadingDivider = false,
    super.key,
    this.importTokenEntries,
    this.selectCallback,
  });

  final List<Token>? importTokens;
  final String? title;
  final EdgeInsetsGeometry titlePadding;
  final Color? borderColor;
  final bool leadingDivider;

  final List<ImportTokenEntry>? importTokenEntries;
  final void Function(List<ImportTokenEntry> newImportTokenEntrys)? selectCallback;

  @override
  Widget build(BuildContext context) => Column(
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
          if (importTokenEntries != null && selectCallback != null)
            ImportTokenEntrysList(importTokenEntries: importTokenEntries!, selectCallback: selectCallback!),
          for (final token in importTokens ?? [])
            ImportTokensListTile(
              token: token,
              selected: token,
              borderColor: borderColor,
            )
        ],
      );
}
