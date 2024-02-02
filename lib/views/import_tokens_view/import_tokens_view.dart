import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../model/token_import_origin.dart';
import 'pages/import_start_page.dart';
import 'pages/select_import_type_page.dart';

class ImportTokensView extends ConsumerStatefulWidget {
  static const routeName = '/import_tokens';

  static const double pagePaddingHorizontal = 40;
  static const double itemSpacingHorizontal = 20;
  static const double itemSpacingVertical = 10;
  static const double iconSize = 100;

  final TokenImportOrigin? selectedSource;

  const ImportTokensView({this.selectedSource, super.key});

  @override
  ConsumerState<ImportTokensView> createState() => _ImportTokensViewState();
}

class _ImportTokensViewState extends ConsumerState<ImportTokensView> {
  void _onPressed(TokenImportOrigin tokenImportOrigin) {
    if (tokenImportOrigin.importEntitys.length == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImportStartPage(
            appName: tokenImportOrigin.appName,
            selectedEntity: tokenImportOrigin.importEntitys.first,
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SelectImportTypePage(tokenImportSource: tokenImportOrigin)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectImportSource),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (final item in TokenImportSourceList.appList)
                ListTile(
                  // leading: Image.asset(appList[index].iconPath!),
                  title: TextButton(
                    onPressed: () => _onPressed(item),
                    child: Text(item.appName),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () => _onPressed(item),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
