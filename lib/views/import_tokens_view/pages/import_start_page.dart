// ignore_for_file: prefer_const_constructors

import 'dart:isolate';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

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

void _decodeQrFileIsolate(List<dynamic> args) async {
  final sendPort = args[0] as SendPort;
  final XFile file = args[1] as XFile;
  final bool isSecondTry = args.length > 2 ? args[2] as bool : false;
  var image = img.decodeImage(await file.readAsBytes());
  if (image == null) {
    Isolate.exit(sendPort, null);
  }
  // Rotate image by 90 degrees
  if (isSecondTry) {
    image = img.copyRotate(image, angle: 90);
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
    if (file == null) return;
    Result qrResult;
    try {
      qrResult = await _startDecodeQrFile(file);
    } on FormatReaderException catch (_) {
      try {
        qrResult = await _startDecodeQrFile(file, isSecondTry: true);
      } on FormatReaderException catch (_) {
        setState(() => _errorText = localizations.qrFileDecodeError);
        return;
      }
    } catch (e) {
      setState(() => _errorText = localizations.invalidQrFile(widget.appName));
      return;
    }
    final Uri uri;
    try {
      uri = Uri.parse(qrResult.text);
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
          data: t.resultData.origin?.data ?? qrResult.text,
        ),
      );
    }).toList();
    _routeImportPlainTokensPage(importResults: processorResults);
  }

  Future<Result> _startDecodeQrFile(XFile file, {bool isSecondTry = false}) async {
    final receivePort = ReceivePort();
    try {
      await Isolate.spawn(_decodeQrFileIsolate, [receivePort.sendPort, file, isSecondTry]);
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
