// ignore_for_file: prefer_const_constructors

import 'dart:isolate';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:privacyidea_authenticator/model/enums/token_import_type.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/scheme_processor_interface.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/token_import_scheme_processor_interface.dart';
import 'package:zxing2/qrcode.dart';
// ignore: implementation_imports
import 'package:zxing2/src/format_reader_exception.dart';

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
                  widget.selectedEntity.type.icon,
                  color: _errorText != null ? Theme.of(context).colorScheme.error : null,
                  size: ImportTokensView.iconSize,
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                _errorText != null
                    ? Text(
                        _errorText!,
                        textAlign: TextAlign.center,
                      )
                    : Text(widget.selectedEntity.importHint(context), textAlign: TextAlign.center),
                if (widget.selectedEntity.type == TokenImportType.link) ...[
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
                            widget.selectedEntity.type.getButtonText(context),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                          onPressed: () {
                            setState(() => _errorText = null);
                            setState(() {
                              future = Future(() => switch (widget.selectedEntity.type) {
                                    const (TokenImportType.backupFile) => _pickBackupFile(widget.selectedEntity.processor),
                                    const (TokenImportType.qrScan) => _scanQrCode(widget.selectedEntity.processor),
                                    const (TokenImportType.qrFile) => _pickQrFile(widget.selectedEntity.processor),
                                    const (TokenImportType.link) => _validateLink(widget.selectedEntity.processor),
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
    final tokens = await fileProcessor.processFile(file: file);
    if (tokens.isEmpty) {
      if (mounted == false) return;
      setState(() => _errorText = AppLocalizations.of(context)!.invalidBackupFile(widget.appName));
      return;
    }
    _routeImportPlainTokensPage(tokens: tokens);
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
    List<Token> tokens = await schemeProcessor.processUri(uri);
    tokens = tokens.map((token) => TokenOriginSourceType.qrScan.addOriginToToken(token: token, data: result, appName: widget.appName)).toList();
    _routeImportPlainTokensPage(tokens: tokens);
    return;
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

  Future<void> _pickQrFile(TokenImportProcessor? processor) async {
    assert(processor is TokenImportSchemeProcessor);
    final schemeProcessor = processor as SchemeProcessor;
    final XFile? file = await openFile();
    if (file == null) return;
    Result result;
    try {
      result = await _startDecodeQrFile(file);
    } on FormatReaderException catch (_) {
      setState(() => _errorText = AppLocalizations.of(context)!.qrFileDecodeError);
      return;
    } catch (e) {
      setState(() => _errorText = AppLocalizations.of(context)!.invalidQrFile(widget.appName));
      return;
    }
    final Uri uri;
    try {
      uri = Uri.parse(result.text);
    } on FormatException catch (_) {
      setState(() => _errorText = AppLocalizations.of(context)!.invalidQrFile(widget.appName));
      return;
    }
    List<Token> tokens = await schemeProcessor.processUri(uri);
    if (tokens.isEmpty) {
      setState(() => _errorText = AppLocalizations.of(context)!.invalidQrFile(widget.appName));
      return;
    }
    tokens = tokens.map((token) => TokenOriginSourceType.qrFile.addOriginToToken(token: token, data: result.text, appName: widget.appName)).toList();

    _routeImportPlainTokensPage(tokens: tokens);
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
    List<Token> tokens = await schemeProcessor.processUri(uri);
    if (tokens.isEmpty) {
      setState(() => _errorText = AppLocalizations.of(context)!.invalidLink(widget.appName));
      return;
    }
    tokens = tokens.map((token) => TokenOriginSourceType.link.addOriginToToken(token: token, data: _linkController.text, appName: widget.appName)).toList();
    if (mounted == false) return;
    setState(() => FocusScope.of(context).unfocus());
    _routeImportPlainTokensPage(tokens: tokens);
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
