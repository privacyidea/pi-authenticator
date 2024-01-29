import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../model/token_import_source.dart';
import 'pages/import_from_file_pages/import_select_file_page.dart';
import 'pages/import_from_qr_pages/import_start_qr_scan_page.dart';

class ImportTokensView extends ConsumerStatefulWidget {
  static const routeName = '/import_tokens';

  final TokenImportSource? selectedSource;
  const ImportTokensView({this.selectedSource, super.key});

  @override
  ConsumerState<ImportTokensView> createState() => _ImportTokensViewState();
}

class _ImportTokensViewState extends ConsumerState<ImportTokensView> {
  String? fileContent;
  TextEditingController? passwordController;
  bool fileContentIsValid = false;
  bool wrongPassword = false;
  bool passwordIsNeeded = false;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController(text: '');
  }

  void onPressed(TokenImportSource tokenImportSource) => switch (tokenImportSource.runtimeType) {
        const (TokenImportQrScanSource) => onPressedQrScan(tokenImportSource as TokenImportQrScanSource),
        const (TokenImportFileSource) => onPressedFile(tokenImportSource as TokenImportFileSource),
        _ => throw Exception('Unknown token import source type: ${tokenImportSource.runtimeType}'),
      };

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
                    onPressed: () => onPressed(item),
                    child: Text(item.appName),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () => onPressed(item),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void onPressedQrScan(TokenImportQrScanSource tokenImportSource) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImportStartQrScanPage(selectedSource: tokenImportSource),
      ),
    );
  }

  void onPressedFile(TokenImportFileSource tokenImportSource) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImportSelectFilePage(selectedSource: tokenImportSource),
      ),
    );
  }
}
