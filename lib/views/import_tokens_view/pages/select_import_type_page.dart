/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/enums/token_import_type.dart';
import '../../../model/extensions/enums/token_import_type_extension.dart';
import '../../../model/token_import/token_import_origin.dart';
import '../../../model/token_import/token_import_source.dart';
import '../../../model/tokens/token.dart';
import '../import_tokens_view.dart';
import 'import_start_page.dart';

class SelectImportTypePage extends StatelessWidget {
  final TokenImportOrigin tokenImportOrigin;

  const SelectImportTypePage({super.key, required this.tokenImportOrigin});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tokenImportOrigin.appName,
          overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ImportTokensView.pagePaddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    FluentIcons.arrow_enter_20_filled,
                    size: ImportTokensView.iconSize,
                  ),
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                Text(
                  localizations.selectImportType,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                for (final importEntity in tokenImportOrigin.importSources) ...[
                  if (importEntity != tokenImportOrigin.importSources.first) const SizedBox(height: ImportTokensView.itemSpacingHorizontal / 2),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: Text(
                              switch (importEntity.type) {
                                const (TokenImportType.backupFile) => localizations.selectFile,
                                const (TokenImportType.qrScan) => localizations.scanQrCode,
                                const (TokenImportType.qrFile) => localizations.selectFile,
                                const (TokenImportType.link) => localizations.enterLink,
                              },
                              style: Theme.of(context).textTheme.headlineSmall,
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.center,
                              softWrap: false,
                            ),
                          ),
                          Expanded(
                            child: Icon(importEntity.type.icon),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      onPressed: () => _routeStartPage(context: context, importSource: importEntity),
                    ),
                  ),
                ],
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _routeStartPage({required TokenImportSource importSource, required BuildContext context}) async {
    final tokensToImport = await Navigator.of(context).push<List<Token>>(
      MaterialPageRoute(
        builder: (context) => ImportStartPage(appName: tokenImportOrigin.appName, selectedSource: importSource),
      ),
    );
    if (tokensToImport != null) {
      if (!context.mounted) return;
      Navigator.of(context).pop(tokensToImport);
    }
  }
}
