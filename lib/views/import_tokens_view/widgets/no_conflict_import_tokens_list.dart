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

import '../../../model/token_import/token_import_entry.dart';
import 'no_conflict_import_tokens_tile.dart';

class NoConflictImportTokensList extends StatefulWidget {
  const NoConflictImportTokensList({
    required this.importEntries,
    this.title,
    this.titlePadding = const EdgeInsets.all(0),
    this.borderColor = Colors.green,
    this.leadingDivider = false,
    this.onTap,
    super.key,
  });

  final String? title;
  final EdgeInsetsGeometry titlePadding;
  final Color? borderColor;
  final bool leadingDivider;
  final void Function(TokenImportEntry oldEntry, TokenImportEntry newEntry)? onTap;

  final List<TokenImportEntry> importEntries;

  @override
  State<NoConflictImportTokensList> createState() => _NoConflictImportTokensListState();
}

class _NoConflictImportTokensListState extends State<NoConflictImportTokensList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.leadingDivider) ...[
          const SizedBox(height: 16),
          const Divider(
            thickness: 2,
            height: 2,
            indent: 4,
            endIndent: 4,
          ),
          const SizedBox(height: 16),
        ],
        if (widget.title != null) ...[
          Padding(
            padding: widget.titlePadding,
            child: Text(
              widget.title!,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
        ],
        for (final tokenEntry in widget.importEntries)
          GestureDetector(
            onTap: widget.onTap != null
                ? () {
                    final newTokenEntry = tokenEntry.copySelect(tokenEntry.selectedToken == null ? tokenEntry.newToken : null);
                    widget.onTap!(tokenEntry, newTokenEntry);
                  }
                : null,
            child: NoConflictImportTokensTile(
              token: tokenEntry.newToken,
              selected: tokenEntry.selectedToken,
              borderColor: widget.borderColor,
            ),
          )
      ],
    );
  }
}
