/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zxing/flutter_zxing.dart' as zxing;
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:image/image.dart' as img_lib;
import 'package:image_picker/image_picker.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
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
import '../../../utils/object_validator.dart';
import '../../qr_scanner_view/qr_scanner_view.dart';
import '../import_tokens_view.dart';
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

  String? _errorText;
  Future<String?>? future;

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
                      labelText: localizations.tokenLinkImport,
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
                            style: Theme.of(context).textTheme.headlineSmall,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                          onPressed: () {
                            setState(() => _errorText = null);
                            setState(() {
                              future = Future(() => switch (widget.selectedSource.type) {
                                    const (TokenImportType.backupFile) => _pickBackupFile(widget.selectedSource.processor),
                                    const (TokenImportType.qrScan) => _scanQrCode(widget.selectedSource.processor),
                                    const (TokenImportType.qrFile) => _pickQrImage(widget.selectedSource.processor),
                                    const (TokenImportType.link) => _validateLink(widget.selectedSource.processor),
                                  });
                              future!.then((errorText) {
                                if (!mounted) return;
                                setState(() {
                                  future = null;
                                  _errorText = errorText;
                                });
                              });
                            });
                          },
                        ),
                      )
                    : const CircularProgressIndicator.adaptive(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _pickBackupFile(TokenImportProcessor? processor) async {
    assert(processor is TokenImportFileProcessor);
    final fileProcessor = processor as TokenImportFileProcessor;
    final localizations = AppLocalizations.of(context)!;
    final XTypeGroup typeGroup = XTypeGroup(label: localizations.selectFile);
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) {
      Logger.warning("No file selected");
      return null;
    }
    if (await fileProcessor.fileIsValid(file) == false) {
      return localizations.invalidBackupFile(widget.appName);
    }
    setState(() => _errorText = null);
    if (await fileProcessor.fileNeedsPassword(file)) {
      return _routeEncryptedData<XFile, String?>(data: file, processor: fileProcessor);
    }
    var importResults = await fileProcessor.processFile(file);
    if (importResults.isEmpty) {
      return localizations.invalidBackupFile(widget.appName);
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
        resultHandlerType: const ObjectValidator<TokenNotifier>(),
      );
    }).toList();

    Logger.info("Backup file imported successfully");
    return _routeImportPlainTokensPage(importResults: importResults);
  }

  Future<String?> _scanQrCode(TokenImportProcessor? processor) async {
    assert(processor is TokenImportSchemeProcessor);
    final localizations = AppLocalizations.of(context)!;
    final schemeProcessor = processor as TokenImportSchemeProcessor;
    final result = await Navigator.of(context).pushNamed(QRScannerView.routeName);
    if (result is! String) return localizations.invalidQrScan(widget.appName);
    final Uri uri;
    try {
      uri = Uri.parse(result);
    } on FormatException catch (_) {
      return localizations.invalidQrScan(widget.appName);
    }
    var results = await schemeProcessor.processUri(uri);
    if (results == null || results.isEmpty) {
      return localizations.invalidQrScan(widget.appName);
    }
    results = results.map<ProcessorResult<Token>>((t) {
      if (t is! ProcessorResultSuccess<Token>) return t;
      return ProcessorResultSuccess(
        TokenOriginSourceType.qrScan.addOriginToToken(
          appName: widget.appName,
          isPrivacyIdeaToken: false,
          token: t.resultData,
          data: t.resultData.origin?.data ?? uri.toString(),
        ),
        resultHandlerType: const ObjectValidator<TokenNotifier>(),
      );
    }).toList();
    Logger.info("QR code scanned successfully");
    return _routeImportPlainTokensPage(importResults: results);
  }

  Future<String?> _pickQrImage(TokenImportProcessor? processor) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) {
      Logger.info("No file selected");
      return null;
    }
    return await _processQrImage(processor: processor, file: file);
  }

  Future<String?> _processQrImage({
    required TokenImportProcessor? processor,
    required XFile file,
    bool tryHarder = false,
    bool tryInverted = false,
  }) async {
    assert(processor is TokenImportSchemeProcessor);
    final schemeProcessor = processor as TokenImportSchemeProcessor;
    final localizations = AppLocalizations.of(context)!;

    final DecodeParams params = DecodeParams(
      imageFormat: zxing.ImageFormat.rgb,
      format: Format.any,
      tryHarder: tryHarder,
      tryInverted: tryInverted,
      isMultiScan: false,
    );
    final text = (await zx.readBarcodeImagePath(file, params)).text;
    if (text == null) {
      if (!mounted) return null;
      if (tryHarder == false) {
        return _processQrImage(processor: processor, tryHarder: true, tryInverted: tryInverted, file: file);
      }
      if (tryInverted == false) {
        return _processQrImage(processor: processor, tryHarder: tryHarder, tryInverted: true, file: file);
      }
      return localizations.invalidQrFile(widget.appName);
    }
    final uri = Uri.tryParse(text);
    if (uri == null) return localizations.invalidQrFile(widget.appName);

    final processorResults = await schemeProcessor.processUri(uri);
    if (processorResults == null || processorResults.isEmpty) return _errorText;

    Logger.info("QR file imported successfully");
    return _routeImportPlainTokensPage(importResults: processorResults);
  }

  Future<String?> _validateLink(TokenImportProcessor? processor) async {
    final localizations = AppLocalizations.of(context)!;
    if (_linkController.text.isEmpty) return localizations.mustNotBeEmpty(localizations.tokenLinkImport);
    assert(processor is TokenImportSchemeProcessor);
    final schemeProcessor = processor as TokenImportSchemeProcessor;
    final Uri uri;
    try {
      uri = Uri.parse(_linkController.text);
    } on FormatException catch (_) {
      return localizations.invalidLink(widget.appName);
    }
    var results = await schemeProcessor.processUri(uri);
    if (results == null || results.isEmpty) {
      return localizations.invalidLink(widget.appName);
    }
    results = results.map<ProcessorResult<Token>>((t) {
      if (t is! ProcessorResultSuccess<Token>) return t;
      return ProcessorResultSuccess(
        TokenOriginSourceType.linkImport.addOriginToToken(
          appName: widget.appName,
          token: t.resultData,
          isPrivacyIdeaToken: false,
          data: _linkController.text,
        ),
        resultHandlerType: const ObjectValidator<TokenNotifier>(),
      );
    }).toList();
    if (!mounted) return null;
    setState(() => FocusScope.of(context).unfocus());
    Logger.info("Link imported successfully");
    return _routeImportPlainTokensPage(importResults: results);
  }

  Future<String?> _routeImportPlainTokensPage({required List<ProcessorResult<Token>> importResults}) async {
    if (mounted == false) return null;
    final tokensToImport = await Navigator.of(context).push<List<Token>>(
      MaterialPageRoute(builder: (context) {
        return ImportPlainTokensPage(
          titleName: widget.appName,
          processorResults: importResults,
          selectedType: widget.selectedSource.type,
        );
      }),
    );
    Logger.info('Imported tokens: ${tokensToImport?.length}');

    if (!mounted) return null;
    if (tokensToImport == null) return null;
    Navigator.of(context).pop(tokensToImport);
    return null;
  }

  Future<String?> _routeEncryptedData<T, V extends String?>({required T data, required TokenImportProcessor<T, V> processor}) async {
    if (mounted == false) return null;
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
    Logger.info('Imported encrypted tokens: ${tokensToImport?.length}');
    if (!mounted) return null;
    if (tokensToImport == null) return null;
    Navigator.of(context).pop(tokensToImport);
    return null;
  }
}

Future<Result?> _decodeQrImageIsolate(List<dynamic> args) async {
  var image = args[0] as img_lib.Image;
  final int rotation = args[1] as int;
  final int zoomLevel = args[2] as int;
  if (zoomLevel > 0) {
    final size = image.width < image.height ? image.width : image.height;
    final crop = (size * 0.02).floor() * zoomLevel;
    final x = (image.width - size) ~/ 2 + crop;
    final y = (image.height - size) ~/ 2 + crop;
    image = img_lib.copyCrop(image, x: x, y: y, width: size - crop, height: size - crop);
  }
  if (rotation > 0) {
    image = img_lib.copyRotate(image, angle: rotation);
  }

  LuminanceSource source = RGBLuminanceSource(
    image.width,
    image.height,
    image.convert(numChannels: 4).getBytes(order: img_lib.ChannelOrder.abgr).buffer.asInt32List(),
  );

  return QRCodeReader().decode(
    BinaryBitmap(GlobalHistogramBinarizer(source)),
    hints: DecodeHints()
      ..put(DecodeHintType.tryHarder)
      ..put(DecodeHintType.possibleFormats, [BarcodeFormat.qrCode]),
  );
}
