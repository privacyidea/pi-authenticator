import 'dart:developer';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/token_import_source.dart';
import '../../../qr_scanner_view/qr_scanner_view.dart';
import '../../import_tokens_view.dart';
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
    zx.startCameraProcessing();
    _currentContext = context;
    super.initState();
  }

  @override
  void dispose() {
    zx.stopCameraProcessing();
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
            padding: const EdgeInsets.symmetric(horizontal: ImportTokensView.pagePaddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.file_present,
                  size: ImportTokensView.iconSize,
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                Text(widget.selectedSource.importHint(context), textAlign: TextAlign.center),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text(
                      AppLocalizations.of(context)!.startQrScan,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    onPressed: () => _scanQr(() => _currentContext, widget.selectedSource),
                  ),
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text(
                      AppLocalizations.of(context)!.selectFile,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    onPressed: () => _pickQrFile(() => _currentContext, widget.selectedSource),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickQrFile(BuildContext? Function() getCurrentContext, TokenImportQrScanSource tokenSource) async {
    final XFile? file = await openFile();
    if (file == null) return;
    log('Selected file: ${file.path}');
    log('FileBytes: ${(await file.readAsBytes()).length}');
    final result = await zx.readBarcodeImagePath(file);
    log('ResultDuration: ${result.duration}');
    log('ResultError: ${result.error}');
    log('ResultFormat: ${result.format}');
    log('ResultIsInverted: ${result.isInverted}');
    log('ResultIsMirrored: ${result.isMirrored}');
    log('ResultIsValid: ${result.isValid}');
    log('ResultPosition: ${result.position}');
    log('ResultRawBytes: ${result.rawBytes}');
    log('ResultText: ${result.text}');

    if (result.rawBytes == null) {
      _routeInvalidQrCode(getCurrentContext, tokenSource);
      return;
    }
    final resultString = result.text ?? '';

    final Uri uri;
    try {
      uri = Uri.parse(resultString);
    } on FormatException catch (_) {
      log('Invalid QR code: $resultString', name: 'ImportStartQrScanPage');
      return;
    }

    _processUri(getCurrentContext, uri, tokenSource);
  }

  void _scanQr(BuildContext? Function() getCurrentContext, TokenImportQrScanSource tokenSource) async {
    final currentContext = getCurrentContext();
    if (currentContext == null || currentContext.mounted == false) return;
    final result = await Navigator.of(currentContext).pushNamed(QRScannerView.routeName);
    if (result is! String) return;
    final Uri uri;
    try {
      uri = Uri.parse(result);
    } on FormatException catch (_) {
      _routeInvalidQrCode(getCurrentContext, tokenSource);
      return;
    }
    _processUri(getCurrentContext, uri, tokenSource);
  }

  void _processUri(BuildContext? Function() getCurrentContext, Uri uri, TokenImportQrScanSource tokenSource) async {
    final tokens = await tokenSource.processor.processUri(uri);
    if (tokens.isEmpty) return _routeInvalidQrCode(getCurrentContext, tokenSource);
  }

  void _routeInvalidQrCode(BuildContext? Function() getCurrentContext, TokenImportQrScanSource tokenSource) {
    final currentContext = getCurrentContext();
    if (currentContext == null || currentContext.mounted == false) return;
    Navigator.of(currentContext)
        .pushReplacement(MaterialPageRoute(builder: (context) => ImportInvalidQrScanPage(selectedSource: tokenSource, startQrScan: _scanQr)));
  }
}
