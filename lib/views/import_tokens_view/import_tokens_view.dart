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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../model/token_import/token_import_origin.dart';
import '../../model/tokens/token.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../utils/token_import_origins.dart';
import '../view_interface.dart';
import 'pages/import_start_page.dart';
import 'pages/select_import_type_page.dart';

/// The view to import tokens from different sources.
/// The user can select the source from which the tokens should be imported.
/// Pops with `true` if the tokens were imported successfully.
class ImportTokensView extends ConsumerStatefulView {
  @override
  RouteSettings get routeSettings => const RouteSettings(name: routeName);
  static const routeName = '/import_tokens';

  static const double pagePaddingHorizontal = 40;
  static const double itemSpacingHorizontal = 20;
  static const double itemSpacingVertical = 10;
  static const double iconSize = 100;

  const ImportTokensView({super.key});

  @override
  ConsumerState<ImportTokensView> createState() => _ImportTokensViewState();
}

class _ImportTokensViewState extends ConsumerState<ImportTokensView> {
  Future<void> _onPressed(TokenImportOrigin tokenImportOrigin) async {
    List<Token>? tokensToImport;
    if (tokenImportOrigin.importSources.length == 1) {
      tokensToImport = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImportStartPage(
            appName: tokenImportOrigin.appName,
            selectedSource: tokenImportOrigin.importSources.first,
          ),
        ),
      );
    } else {
      tokensToImport = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SelectImportTypePage(tokenImportOrigin: tokenImportOrigin),
        ),
      );
    }
    if (tokensToImport == null) return;
    if (tokensToImport.isNotEmpty) ref.read(tokenProvider.notifier).addOrReplaceTokens(tokensToImport);
    if (mounted) return Navigator.of(context).pop(tokensToImport.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.selectImportSource,
            overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
            maxLines: 2, // Title can be shown on small screens too.
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final item in TokenImportOrigins.appList)
                  ListTile(
                    // leading: Image.asset(appList[index].iconPath!),
                    title: TextButton(
                      onPressed: () => _onPressed(item),
                      child: Text(item.appName),
                    ),
                    trailing: Theme(
                      data: ThemeData(
                        iconTheme: const IconThemeData(
                          color: Colors.red,
                        ),
                        primaryIconTheme: const IconThemeData(
                          color: Colors.blue,
                        ),
                        iconButtonTheme: const IconButtonThemeData(
                          style: ButtonStyle(
                            foregroundColor: WidgetStatePropertyAll(Colors.green),
                            backgroundColor: WidgetStatePropertyAll(Colors.green),
                            iconColor: WidgetStatePropertyAll(Colors.green),
                            iconSize: WidgetStatePropertyAll(50),
                          ),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () => _onPressed(item),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
