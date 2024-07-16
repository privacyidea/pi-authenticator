import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zxing2/zxing2.dart';

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
import '../../../utils/globals.dart';
import '../../../utils/logger.dart';
import '../../../utils/riverpod/riverpod_providers/state_notifier_providers/progress_state_provider.dart';
import '../../qr_scanner_view/qr_scanner_view.dart';
import '../import_tokens_view.dart';
import '../widgets/dialogs/qr_not_found_dialog.dart';
import 'import_encrypted_data_page.dart';
import 'import_plain_tokens_page.dart';

class ImportStartPage extends ConsumerStatefulWidget {
  final String appName;
  final TokenImportSource selectedSource;

  const ImportStartPage({
    super.key,
    required this.appName,
    required this.selectedSource,
  });

  @override
  ConsumerState<ImportStartPage> createState() => _ImportStartPageState();
}

class _ImportStartPageState extends ConsumerState<ImportStartPage> {
  final _linkController = TextEditingController();
  bool _copyShouldExist = false;

  String? _progessLabel;
  // Widget? _buttonWhileProcessing;
  String? _errorText;
  Future? future;

  @override
  void dispose() {
    _linkController.dispose();
    _deleteCopyOfXFile();
    future?.ignore();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalRef?.read(progressStateProvider.notifier).deleteProgress();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final currentLoadingProgress = ref.watch(progressStateProvider)?.progress;
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
                              future?.then((value) {
                                if (!mounted) return;
                                setState(() => future = null);
                              });
                            });
                          },
                        ),
                      )
                    : Column(
                        children: [
                          Stack(
                            children: [
                              LinearProgressIndicator(
                                minHeight: _progessLabel != null ? 16 : null,
                                value: currentLoadingProgress,
                                semanticsLabel: _progessLabel,
                              ),
                              if (_progessLabel != null)
                                Positioned.fill(
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.fitHeight,
                                      child: Text(
                                        _progessLabel!,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          shadows: <Shadow>[
                                            Shadow(
                                              color: Theme.of(context).colorScheme.onPrimary,
                                              blurRadius: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
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
      await _routeEncryptedData<XFile, String?>(data: file, processor: fileProcessor);
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

    Logger.info("Backup file imported successfully", name: "_pickBackupFile#ImportStartPage");
    await _routeImportPlainTokensPage(importResults: importResults);
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
    Logger.info("QR code scanned successfully", name: "_scanQrCode#ImportStartPage");
    _routeImportPlainTokensPage(importResults: results);
    return;
  }

  Future<XFile> _saveCopyOfXFile(XFile xFile) async {
    Logger.warning("Saving copy of file", name: "_saveCopyOfXFile#ImportStartPage");
    final path = '${(await getApplicationCacheDirectory()).path}/copy_of_xFile';
    await xFile.saveTo(path);
    _copyShouldExist = true;
    return XFile(path);
  }

  Future<void> _deleteCopyOfXFile() async {
    if (_copyShouldExist == false) return;
    File('${(await getApplicationCacheDirectory()).path}/copy_of_xFile').delete();
    _copyShouldExist = false;
  }

  Future<void> _pickQrFile(TokenImportProcessor? processor) async {
    assert(processor is TokenImportFileProcessor);
    final schemeProcessor = processor as TokenImportFileProcessor;
    final localizations = AppLocalizations.of(context)!;
    List<ProcessorResult<Token>>? processorResults;
    var xFile = await openFile();
    if (xFile == null) return;
    xFile = await _saveCopyOfXFile(xFile);

    if (!mounted) return;
    setState(() => _progessLabel = localizations.findingQrCodeInImage);
    if (await schemeProcessor.fileIsValid(xFile) == false) {
      if (!mounted) return;
      setState(() => _errorText = localizations.invalidQrFile(widget.appName));
      return;
    }
    try {
      try {
        processorResults = await schemeProcessor.processFile(xFile);
      } on NotFoundException catch (_) {
        if (!mounted) return;
        xFile = await QrNotFoundDialog(xFile: xFile).show(context);
        Logger.warning('Got cropped file: $xFile', name: '_pickQrFile#ImportStartPage');
        if (xFile != null) processorResults = await schemeProcessor.processFile(xFile);
        if (processorResults == null) {
          if (!mounted) return;
          setState(() => _errorText = localizations.qrNotFound);
          return;
        }
      }
    } on FormatReaderException catch (_) {
      if (!mounted) return;
      setState(() => _errorText = localizations.invalidQrFile(widget.appName));
      return;
    } on NotFoundException catch (_) {
      if (!mounted) return;
      setState(() => _errorText = localizations.qrNotFound);
      return;
    }

    Logger.info("QR file imported successfully", name: "_pickQrFile#ImportStartPage");
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
      if (!mounted) return;
      setState(() => _errorText = localizations.invalidLink(widget.appName));
      return;
    }
    var results = await schemeProcessor.processUri(uri);
    if (results.isEmpty) {
      if (!mounted) return;
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
    if (!mounted) return;
    setState(() => FocusScope.of(context).unfocus());
    Logger.info("Link imported successfully", name: "_validateLink#ImportStartPage");
    _routeImportPlainTokensPage(importResults: results);
  }

  Future<void> _routeImportPlainTokensPage({required List<ProcessorResult<Token>> importResults}) async {
    if (mounted == false) return;
    final tokensToImport = await Navigator.of(context).push<List<Token>>(
      MaterialPageRoute(builder: (context) {
        return ImportPlainTokensPage(
          titleName: widget.appName,
          processorResults: importResults,
          selectedType: widget.selectedSource.type,
        );
      }),
    );
    Logger.info('Imported tokens: ${tokensToImport?.length}', name: '_routeImportPlainTokensPage#ImportStartPage');
    if (tokensToImport != null) {
      if (!mounted) return;
      Navigator.of(context).pop(tokensToImport);
    }
  }

  Future<void> _routeEncryptedData<T, V extends String?>({required T data, required TokenImportProcessor<T, V> processor}) async {
    if (mounted == false) return;
    final tokensToImport = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return ImportEncryptedDataPage<T, V>(
          appName: widget.appName,
          data: data,
          selectedType: widget.selectedSource.type,
          processor: processor,
        );
      }),
    );
    Logger.info('Imported encrypted tokens: ${tokensToImport?.length}', name: '_routeEncryptedData#ImportStartPage');
    if (tokensToImport != null) {
      if (!mounted) return;
      Navigator.of(context).pop(tokensToImport);
    }
  }
}
