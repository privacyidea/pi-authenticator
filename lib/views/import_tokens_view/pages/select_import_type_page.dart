// ignore_for_file: prefer_const_constructors

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/enums/token_import_type.dart';
import '../../../model/token_import_origin.dart';
import '../import_tokens_view.dart';
import 'import_start_page.dart';

class SelectImportTypePage extends StatelessWidget {
  final TokenImportOrigin tokenImportSource;

  const SelectImportTypePage({super.key, required this.tokenImportSource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tokenImportSource.appName),
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
                  AppLocalizations.of(context)!.selectImportType,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                for (final importEntity in tokenImportSource.importEntitys)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: Text(
                              switch (importEntity.type) {
                                const (TokenImportType.backupFile) => AppLocalizations.of(context)!.selectFile,
                                const (TokenImportType.qrScan) => AppLocalizations.of(context)!.scanQrCode,
                                const (TokenImportType.qrFile) => AppLocalizations.of(context)!.selectFile,
                                const (TokenImportType.link) => AppLocalizations.of(context)!.enterLink,
                              },
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.center,
                              softWrap: false,
                            ),
                          ),
                          Expanded(
                            child: Icon(importEntity.type.icon),
                          ),
                          Expanded(child: SizedBox()),
                        ],
                      ),
                      onPressed: () => _routeStartPage(context: context, importEntity: importEntity),
                    ),
                  ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _routeStartPage({required TokenImportEntity importEntity, required BuildContext context}) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ImportStartPage(appName: tokenImportSource.appName, selectedEntity: importEntity)));
}
