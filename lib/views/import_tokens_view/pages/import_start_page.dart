// ignore_for_file: prefer_const_constructors

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:image/image.dart' as img_lib;

import '../../../l10n/app_localizations.dart';
import '../../../model/enums/token_import_type.dart';
import '../../../model/enums/token_origin_source_type.dart';
import '../../../model/extensions/enums/token_import_type_extension.dart';
import '../../../model/extensions/enums/token_origin_source_type.dart';
import '../../../model/processor_result.dart';
import '../../../model/token_import/token_import_source.dart';
import '../../../model/tokens/token.dart';
import '../../../processors/mixins/token_import_processor.dart';
import '../../../processors/scheme_processors/token_import_scheme_processors/token_import_scheme_processor_interface.dart';
import '../../../processors/token_import_file_processor/token_import_file_processor_interface.dart';
import '../../../utils/logger.dart';
import '../../qr_scanner_view/qr_scanner_view.dart';
import '../import_tokens_view.dart';
import 'import_encrypted_data_page.dart';
import 'import_plain_tokens_page.dart';

class ImportStartPage extends StatefulWidget {
  final String appName;
  final TokenImportSource selectedSource;

  const ImportStartPage({
    super.key,
    required this.appName,
    required this.selectedSource,
  });

  @override
  State<ImportStartPage> createState() => _ImportStartPageState();
}

class _ImportStartPageState extends State<ImportStartPage> {
  final _linkController = TextEditingController();

  String? _errorText;

  Future? future;

  @override
  void dispose() {
    _linkController.dispose();
    future?.ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                  widget.selectedSource.type.icon,
                  color: _errorText != null ? Theme.of(context).colorScheme.error : null,
                  size: ImportTokensView.iconSize,
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                _errorText != null
                    ? Text(
                        _errorText!,
                        textAlign: TextAlign.center,
                      )
                    : Text(widget.selectedSource.importHint(localizations), textAlign: TextAlign.center),
                if (widget.selectedSource.type == TokenImportType.link) ...[
                  const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                  TextField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      labelText: localizations.tokenLink,
                    ),
                  ),
                ],
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                future == null
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: Text(
                            widget.selectedSource.type.buttonText(localizations),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                          onPressed: () {
                            setState(() => _errorText = null);
                            setState(() {
                              future = Future(() => switch (widget.selectedSource.type) {
                                    const (TokenImportType.backupFile) => _pickBackupFile(widget.selectedSource.processor),
                                    const (TokenImportType.qrScan) => _scanQrCode(widget.selectedSource.processor),
                                    const (TokenImportType.qrFile) => _pickQrFile(widget.selectedSource.processor),
                                    const (TokenImportType.link) => _validateLink(widget.selectedSource.processor),
                                  });
                              future!.then((value) {
                                if (mounted == false) return;
                                setState(() => future = null);
                              });
                            });
                          },
                        ),
                      )
                    : const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickBackupFile(TokenImportProcessor? processor) async {
    assert(processor is TokenImportFileProcessor);
    final fileProcessor = processor as TokenImportFileProcessor;
    final localizations = AppLocalizations.of(context)!;
    final XTypeGroup typeGroup = XTypeGroup(label: localizations.selectFile);
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file == null) {
      Logger.warning("No file selected", name: "_pickAFile#ImportSelectFilePage");
      return;
    }
    if (await fileProcessor.fileIsValid(file) == false) {
      if (mounted == false) return;
      setState(() => _errorText = localizations.invalidBackupFile(widget.appName));
      return;
    }
    setState(() => _errorText = null);
    if (await fileProcessor.fileNeedsPassword(file)) {
      _routeEncryptedData<XFile, String?>(data: file, processor: fileProcessor);
      return;
    }
    var importResults = await fileProcessor.processFile(file);
    if (importResults.isEmpty) {
      if (mounted == false) return;
      setState(() => _errorText = localizations.invalidBackupFile(widget.appName));
      return;
    }
    String fileString;
    try {
      fileString = await file.readAsString();
      // ignore: empty_catches
    } catch (e) {
      fileString = 'No data';
    }

    importResults = importResults.map<ProcessorResult<Token>>((t) {
      if (t is! ProcessorResultSuccess<Token>) return t;
      return ProcessorResultSuccess(
        TokenOriginSourceType.backupFile.addOriginToToken(
          appName: widget.appName,
          token: t.resultData,
          isPrivacyIdeaToken: false,
          data: t.resultData.origin?.data ?? fileString,
        ),
      );
    }).toList();

    _routeImportPlainTokensPage(importResults: importResults);
  }

  Future<void> _scanQrCode(TokenImportProcessor? processor) async {
    assert(processor is TokenImportSchemeProcessor);
    final localizations = AppLocalizations.of(context)!;
    final schemeProcessor = processor as TokenImportSchemeProcessor;
    final result = await Navigator.of(context).pushNamed(QRScannerView.routeName);
    if (result is! String) return;
    final Uri uri;
    try {
      uri = Uri.parse(result);
    } on FormatException catch (_) {
      if (mounted == false) return;
      setState(() => _errorText = localizations.invalidQrScan(widget.appName));
      return;
    }
    var results = await schemeProcessor.processUri(uri);
    results = results.map<ProcessorResult<Token>>((t) {
      if (t is! ProcessorResultSuccess<Token>) return t;
      return ProcessorResultSuccess(
        TokenOriginSourceType.qrScan.addOriginToToken(
          appName: widget.appName,
          isPrivacyIdeaToken: false,
          token: t.resultData,
          data: t.resultData.origin?.data ?? uri.toString(),
        ),
      );
    }).toList();
    _routeImportPlainTokensPage(importResults: results);
    return;
  }

  Future<void> _pickQrFile(TokenImportProcessor? processor) async {
    assert(processor is TokenImportSchemeProcessor);
    final schemeProcessor = processor as TokenImportSchemeProcessor;
    final localizations = AppLocalizations.of(context)!;
    final XFile? file = await openFile();
    final zx = Zxing();
    if (file == null) return;
    var image = img_lib.decodeImage(await file.readAsBytes());
    if (image == null) {
      setState(() => _errorText = localizations.invalidQrFile(widget.appName));
      return;
    }
    final qrResult = await zx.readBarcodeImagePath(
      file,
      DecodeParams(
        format: Format.qrCode,
        width: image.width,
        height: image.height,
      ),
    );
    final qrText = qrResult.text;
    if (qrText == null) {
      setState(() => _errorText = localizations.invalidQrFile(widget.appName));
      return;
    }
    final Uri uri;
    try {
      uri = Uri.parse(qrText);
    } on FormatException catch (_) {
      setState(() => _errorText = localizations.invalidQrFile(widget.appName));
      return;
    }
    var processorResults = await schemeProcessor.processUri(uri);
    if (processorResults.isEmpty) {
      setState(() => _errorText = localizations.invalidQrFile(widget.appName));
      return;
    }
    processorResults = processorResults.map<ProcessorResult<Token>>((t) {
      if (t is! ProcessorResultSuccess<Token>) return t;
      return ProcessorResultSuccess(
        TokenOriginSourceType.qrFile.addOriginToToken(
          appName: widget.appName,
          token: t.resultData,
          isPrivacyIdeaToken: false,
          data: t.resultData.origin?.data ?? qrText,
        ),
      );
    }).toList();
    _routeImportPlainTokensPage(importResults: processorResults);
  }

  Future<void> _validateLink(TokenImportProcessor? processor) async {
    if (_linkController.text.isEmpty) {
      return;
    }
    assert(processor is TokenImportSchemeProcessor);
    final localizations = AppLocalizations.of(context)!;
    final schemeProcessor = processor as TokenImportSchemeProcessor;
    final Uri uri;
    try {
      uri = Uri.parse(_linkController.text);
    } on FormatException catch (_) {
      setState(() => _errorText = localizations.invalidLink(widget.appName));
      return;
    }
    var results = await schemeProcessor.processUri(uri);
    if (results.isEmpty) {
      setState(() => _errorText = localizations.invalidLink(widget.appName));
      return;
    }
    results = results.map<ProcessorResult<Token>>((t) {
      if (t is! ProcessorResultSuccess<Token>) return t;
      return ProcessorResultSuccess(TokenOriginSourceType.linkImport.addOriginToToken(
        appName: widget.appName,
        token: t.resultData,
        isPrivacyIdeaToken: false,
        data: _linkController.text,
      ));
    }).toList();

    if (mounted == false) return;
    setState(() => FocusScope.of(context).unfocus());
    _routeImportPlainTokensPage(importResults: results);
  }

  void _routeImportPlainTokensPage({required List<ProcessorResult<Token>> importResults}) {
    if (mounted == false) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return ImportPlainTokensPage(
          appName: widget.appName,
          processorResults: importResults,
          selectedType: widget.selectedSource.type,
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
          selectedType: widget.selectedSource.type,
          processor: processor,
        );
      }),
    );
  }
}
