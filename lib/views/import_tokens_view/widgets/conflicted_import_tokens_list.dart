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
import 'conflicted_import_tokens_tile.dart';

class ConflictedImportTokensList extends StatelessWidget {
  const ConflictedImportTokensList({
    required this.importEntries,
    required this.onTap,
    this.title,
    this.titlePadding = const EdgeInsets.all(0),
    this.leadingDivider = false,
    super.key,
  });

  final String? title;
  final EdgeInsetsGeometry titlePadding;
  final bool leadingDivider;

  final List<TokenImportEntry> importEntries;
  final void Function(TokenImportEntry oldEntry, TokenImportEntry newEntry) onTap;

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
        for (var i = 0; i < importEntries.length; i++)
          ConflictedImportTokensTile(
            selectTokenCallback: (newEntry) => onTap(importEntries[i], newEntry),
            importTokenEntry: importEntries[i],
            initialScreenSize: MediaQuery.of(context).size,
            key: Key('ConflictedImportTokensTile_$i'),
          ),
      ],
    );
  }
}
