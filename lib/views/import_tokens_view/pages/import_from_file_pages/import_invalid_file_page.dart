import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/token_import_source.dart';

class ImportInvalidFilePage extends StatefulWidget {
  final TokenImportSource selectedSource;
  final void Function(BuildContext? Function()) pickAFile;

  const ImportInvalidFilePage({super.key, required this.selectedSource, required this.pickAFile});

  @override
  State<ImportInvalidFilePage> createState() => _ImportInvalidFilePageState();
}

class _ImportInvalidFilePageState extends State<ImportInvalidFilePage> {
  BuildContext? _currentContext;
  @override
  void initState() {
    _currentContext = context;
    super.initState();
  }

  @override
  void dispose() {
    _currentContext = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedSource.appName),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.file_present,
                  color: Theme.of(context).colorScheme.error,
                  size: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.fileNoValidBackupFrom(widget.selectedSource.appName),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => widget.pickAFile(() => _currentContext),
                  child: Text(AppLocalizations.of(context)!.selectFile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
