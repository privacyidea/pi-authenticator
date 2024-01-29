import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/token_import_source.dart';
import '../../../../utils/logger.dart';
import '../../../qr_scanner_view/qr_scanner_view.dart';
import 'import_invalid_qr_scan_page.dart';

class ImportStartQrScanPage extends StatefulWidget {
  final TokenImportQrScanSource selectedSource;
  const ImportStartQrScanPage({required this.selectedSource, super.key});

  @override
  State<ImportStartQrScanPage> createState() => _ImportStartQrScanPageState();
}

class _ImportStartQrScanPageState extends State<ImportStartQrScanPage> {
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
        title: Text(widget.selectedSource!.appName),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.file_present,
                  size: 100,
                ),
                const SizedBox(height: 20),
                Text(widget.selectedSource.importHint(context), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _startQrScan(() => _currentContext),
                  child: Text(AppLocalizations.of(context)!.startQrScan),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startQrScan(BuildContext? Function() getCurrentContext) async {
    final currentContext = getCurrentContext();
    if (currentContext == null || currentContext.mounted == false) return;
    final result = await Navigator.of(currentContext).pushNamed(QRScannerView.routeName);
    if (result is! String) return;
    final Uri uri;
    try {
      uri = Uri.parse(result);
    } on FormatException catch (_) {
      _routeInvalidQrCode(getCurrentContext);
      return;
    }

    final tokens = await widget.selectedSource.processor?.processUri(uri);
    if (tokens == null || tokens.isEmpty) {
      _routeInvalidQrCode(getCurrentContext);
      return;
    }
  }

  void _routeInvalidQrCode(BuildContext? Function() getCurrentContext) {
    final currentContext = getCurrentContext();
    if (currentContext == null || currentContext.mounted == false) return;
    Navigator.of(currentContext)
        .pushReplacement(MaterialPageRoute(builder: (context) => ImportInvalidQrScanPage(selectedSource: widget.selectedSource, startQrScan: _startQrScan)));
  }
}
