// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:privacyidea_authenticator/model/enums/token_import_type.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/token_import_scheme_processor_interface.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/token_import_origin.dart';
import '../../../model/tokens/token.dart';
import '../../../processors/mixins/token_import_processor.dart';
import '../../../processors/token_import_file_processor/token_import_file_processor_interface.dart';
import '../../../utils/logger.dart';
import '../../qr_scanner_view/qr_scanner_view.dart';
import '../import_tokens_view.dart';
import 'import_encrypted_data_page.dart';
import 'import_plain_tokens_page.dart';

class ImportStartPage extends StatefulWidget {
  final String appName;
  final TokenImportEntity selectedEntity;

  const ImportStartPage({
    super.key,
    required this.appName,
    required this.selectedEntity,
  });

  @override
  State<ImportStartPage> createState() => _ImportStartPageState();
}

class _ImportStartPageState extends State<ImportStartPage> {
  final _linkController = TextEditingController();

  bool? _dataIsValid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appName),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ImportTokensView.pagePaddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  widget.selectedEntity.type.icon,
                  color: _dataIsValid == false ? Theme.of(context).colorScheme.error : null,
                  size: ImportTokensView.iconSize,
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                _dataIsValid == false
                    ? Text(
                        AppLocalizations.of(context)!.scanNoValidBackupFrom(widget.appName),
                        textAlign: TextAlign.center,
                      )
                    : Text(widget.selectedEntity.importHint(context), textAlign: TextAlign.center),
                if (widget.selectedEntity.type == TokenImportType.link) ...[
                  const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                  TextField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      labelText: 'Not Implemented', // AppLocalizations.of(context)!.link,
                    ),
                  ),
                ],
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text(
                      widget.selectedEntity.type.getButtonText(context),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    onPressed: () => switch (widget.selectedEntity.type) {
                      const (TokenImportType.backupFile) => _pickBackupFile(widget.selectedEntity.processor),
                      const (TokenImportType.qrScan) => _scanQrCode(widget.selectedEntity.processor),
                      const (TokenImportType.qrFile) => _pickQrFile(widget.selectedEntity.processor),
                      const (TokenImportType.link) => _validateLink(widget.selectedEntity.processor),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickBackupFile(TokenImportProcessor? processor) async {
    assert(processor is TokenImportFileProcessor);
    final fileProcessor = processor as TokenImportFileProcessor;
    final XTypeGroup typeGroup = XTypeGroup(label: AppLocalizations.of(context)!.selectFile);
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file == null) {
      Logger.warning("No file selected", name: "_pickAFile#ImportSelectFilePage");
      return;
    }
    if (await fileProcessor.fileIsValid(file: file) == false) {
      setState(() => _dataIsValid = false);
      return;
    }
    setState(() => _dataIsValid = true);
    if (await fileProcessor.fileNeedsPassword(file: file)) {
      _routeEncryptedData<XFile, String?>(data: file, processor: fileProcessor);
      return;
    }
    final tokens = await fileProcessor.processFile(file: file);
    _routeImportPlainTokensPage(tokens: tokens);
  }

  void _scanQrCode(TokenImportProcessor? processor) async {
    assert(processor is TokenImportSchemeProcessor);
    final schemeProcessor = processor as TokenImportSchemeProcessor;
    final result = await Navigator.of(context).pushNamed(QRScannerView.routeName);
    if (result is! String) return;
    final Uri uri;
    try {
      uri = Uri.parse(result);
    } on FormatException catch (_) {
      setState(() => _dataIsValid = false);
      return;
    }
    _routeImportPlainTokensPage(tokens: await schemeProcessor.processUri(uri));
  }

  void _pickQrFile(TokenImportProcessor? processor) async {
    // final XFile? file = await openFile();
    // if (file == null) return;
    // log('Selected file: ${file.path}');
    // log('FileBytes: ${(await file.readAsBytes()).length}');
    // final result = await zx.readBarcodeImagePath(file);
    // log('ResultDuration: ${result.duration}');
    // log('ResultError: ${result.error}');
    // log('ResultFormat: ${result.format}');
    // log('ResultIsInverted: ${result.isInverted}');
    // log('ResultIsMirrored: ${result.isMirrored}');
    // log('ResultIsValid: ${result.isValid}');
    // log('ResultPosition: ${result.position}');
    // log('ResultRawBytes: ${result.rawBytes}');
    // log('ResultText: ${result.text}');

    // if (result.rawBytes == null) {
    //   _routeInvalidQrCode(getCurrentContext, tokenSource);
    //   return;
    // }
    // final resultString = result.text ?? '';

    // final Uri uri;
    // try {
    //   uri = Uri.parse(resultString);
    // } on FormatException catch (_) {
    //   log('Invalid QR code: $resultString', name: 'ImportStartQrScanPage');
    //   return;
    // }

    // _routeImportPlainTokensPage(getCurrentContext, tokenSource, uri);
  }

  void _validateLink(TokenImportProcessor? processor) async {
    assert(processor is TokenImportSchemeProcessor);
    final schemeProcessor = processor as TokenImportSchemeProcessor;
    final Uri uri;
    try {
      uri = Uri.parse(_linkController.text);
    } on FormatException catch (_) {
      setState(() => _dataIsValid = false);
      return;
    }
    _routeImportPlainTokensPage(tokens: await schemeProcessor.processUri(uri));
  }

  void _routeImportPlainTokensPage({required List<Token> tokens}) {
    if (mounted == false) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return ImportPlainTokensPage(
          appName: widget.appName,
          importedTokens: tokens,
          selectedType: widget.selectedEntity.type,
        );
      }),
    );
  }

  void _routeEncryptedData<T, V extends String?>({required T data, required TokenImportProcessor<T, V> processor}) {
    if (mounted == false) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return ImportEncryptedDataPage<T, V>(
          appName: widget.appName,
          data: data,
          selectedType: widget.selectedEntity.type,
          processor: processor,
        );
      }),
    );
  }
}
