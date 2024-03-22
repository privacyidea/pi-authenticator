// ignore_for_file: prefer_const_constructors

import 'dart:isolate';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:privacyidea_authenticator/model/enums/token_import_type.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/token_import_scheme_processor_interface.dart';
import 'package:zxing2/qrcode.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/token_import/token_import_origin.dart';
import '../../../model/tokens/token.dart';
import '../../../processors/mixins/token_import_processor.dart';
import '../../../processors/token_import_file_processor/token_import_file_processor_interface.dart';
import '../../../utils/logger.dart';
import '../../qr_scanner_view/qr_scanner_view.dart';
import '../import_tokens_view.dart';
import 'import_encrypted_data_page.dart';
import 'import_plain_tokens_page.dart';

void _decodeQrFileIsolate(List<dynamic> args) async {
  final sendPort = args[0] as SendPort;
  final XFile file = args[1] as XFile;
  final image = img.decodeImage(await file.readAsBytes());
  if (image == null) {
    Isolate.exit(sendPort, null);
  }

  LuminanceSource source = RGBLuminanceSource(
    image.width,
    image.height,
    image.convert(numChannels: 4).getBytes(order: img.ChannelOrder.abgr).buffer.asInt32List(),
  );
  var bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));
  try {
    final result = QRCodeReader().decode(bitmap);
    Isolate.exit(sendPort, result);
  } catch (e) {
    Isolate.exit(sendPort, e);
  }
}

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
                    : Text(widget.selectedSource.importHint(context), textAlign: TextAlign.center),
                if (widget.selectedSource.type == TokenImportType.link) ...[
                  const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                  TextField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.tokenLink,
                    ),
                  ),
                ],
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                future == null
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: Text(
                            widget.selectedSource.type.getButtonText(context),
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
    final XTypeGroup typeGroup = XTypeGroup(label: AppLocalizations.of(context)!.selectFile);
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file == null) {
      Logger.warning("No file selected", name: "_pickAFile#ImportSelectFilePage");
      return;
    }
    if (await fileProcessor.fileIsValid(file: file) == false) {
      if (mounted == false) return;
      setState(() => _errorText = AppLocalizations.of(context)!.invalidBackupFile(widget.appName));
      return;
    }
    setState(() => _errorText = null);
    if (await fileProcessor.fileNeedsPassword(file: file)) {
      _routeEncryptedData<XFile, String?>(data: file, processor: fileProcessor);
      return;
    }
    var importResults = await fileProcessor.processFile(file: file);
    if (importResults.isEmpty) {
      if (mounted == false) return;
      setState(() => _errorText = AppLocalizations.of(context)!.invalidBackupFile(widget.appName));
      return;
    }
    String fileString;
    try {
      fileString = await file.readAsString();
      // ignore: empty_catches
    } catch (e) {
      fileString = 'No data';
    }

    importResults = importResults.map<ProcessorResult<Token>>((result) {
      if (!result.success || result.resultData == null) return result;
      return ProcessorResult(
        success: true,
        resultData: TokenOriginSourceType.backupFile.addOriginToToken(
          appName: widget.appName,
          token: result.resultData!,
          isPrivacyIdeaToken: false,
          data: result.resultData!.origin?.data ?? fileString,
        ),
      );
    }).toList();

    _routeImportPlainTokensPage(importResults: importResults);
  }

  Future<void> _scanQrCode(TokenImportProcessor? processor) async {
    assert(processor is TokenImportSchemeProcessor);
    final schemeProcessor = processor as TokenImportSchemeProcessor;
    final result = await Navigator.of(context).pushNamed(QRScannerView.routeName);
    if (result is! String) return;
    final Uri uri;
    try {
      uri = Uri.parse(result);
    } on FormatException catch (_) {
      if (mounted == false) return;
      setState(() => _errorText = AppLocalizations.of(context)!.invalidQrScan(widget.appName));
      return;
    }
    var results = await schemeProcessor.processUri(uri);
    results = results
        .map<ProcessorResult<Token>>((result) => result.success
            ? ProcessorResult<Token>(
                success: true,
                resultData: TokenOriginSourceType.qrScan.addOriginToToken(
                  appName: widget.appName,
                  isPrivacyIdeaToken: false,
                  token: result.resultData!,
                  data: result.resultData!.origin?.data ?? uri.toString(),
                ))
            : result)
        .toList();
    _routeImportPlainTokensPage(importResults: results);
    return;
  }

  Future<void> _pickQrFile(TokenImportProcessor? processor) async {
    assert(processor is TokenImportSchemeProcessor);
    final schemeProcessor = processor as TokenImportSchemeProcessor;
    final XFile? file = await openFile();
    if (file == null) return;
    Result qrResult;
    try {
      qrResult = await _startDecodeQrFile(file);
    } on FormatReaderException catch (_) {
      setState(() => _errorText = AppLocalizations.of(context)!.qrFileDecodeError);
      return;
    } catch (e) {
      setState(() => _errorText = AppLocalizations.of(context)!.invalidQrFile(widget.appName));
      return;
    }
    final Uri uri;
    try {
      uri = Uri.parse(qrResult.text);
    } on FormatException catch (_) {
      setState(() => _errorText = AppLocalizations.of(context)!.invalidQrFile(widget.appName));
      return;
    }
    var processorResults = await schemeProcessor.processUri(uri);
    if (processorResults.isEmpty) {
      setState(() => _errorText = AppLocalizations.of(context)!.invalidQrFile(widget.appName));
      return;
    }
    processorResults = processorResults.map<ProcessorResult<Token>>((result) {
      if (!result.success || result.resultData == null) return result;
      return ProcessorResult(
        success: true,
        resultData: TokenOriginSourceType.qrFile.addOriginToToken(
          appName: widget.appName,
          token: result.resultData!,
          isPrivacyIdeaToken: false,
          data: result.resultData!.origin?.data ?? qrResult.text,
        ),
      );
    }).toList();
    _routeImportPlainTokensPage(importResults: processorResults);
  }

  Future<Result> _startDecodeQrFile(XFile file) async {
    final receivePort = ReceivePort();
    try {
      await Isolate.spawn(_decodeQrFileIsolate, [receivePort.sendPort, file]);
    } catch (_) {
      receivePort.close();
      rethrow;
    }
    final result = await receivePort.first;
    if (result is! Result) {
      throw result;
    }
    receivePort.close();
    return result;
  }

  Future<void> _validateLink(TokenImportProcessor? processor) async {
    if (_linkController.text.isEmpty) {
      return;
    }
    assert(processor is TokenImportSchemeProcessor);
    final schemeProcessor = processor as TokenImportSchemeProcessor;
    final Uri uri;
    try {
      uri = Uri.parse(_linkController.text);
    } on FormatException catch (_) {
      setState(() => _errorText = AppLocalizations.of(context)!.invalidLink(widget.appName));
      return;
    }
    var results = await schemeProcessor.processUri(uri);
    if (results.isEmpty) {
      setState(() => _errorText = AppLocalizations.of(context)!.invalidLink(widget.appName));
      return;
    }
    results = results.map<ProcessorResult<Token>>((result) {
      if (!result.success || result.resultData == null) return result;
      return ProcessorResult(
          success: true,
          resultData: TokenOriginSourceType.linkImport.addOriginToToken(
            appName: widget.appName,
            token: result.resultData!,
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
