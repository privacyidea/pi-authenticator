import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

import '../../../utils/image_converter.dart';
import '../../../utils/logger.dart';
import 'qr_code_scanner_overlay.dart';

Result? _decodeQRCode(BinaryBitmap bitmap) {
  try {
    final result = QRCodeReader().decode(bitmap);
    return result;
  } catch (_) {
    return null;
  }
}

/// Args: [SendPort] sendPort, [CameraImage] cameraImage, [int] rotation, [double] borderPaddingPercent
void _scanQrCodeIsolate(List args) {
  final SendPort sendPort = args[0] as SendPort;
  final CameraImage cameraImage = args[1] as CameraImage;
  final int rotation = args[2] as int;
  final double borderPaddingPercent = args[3] as double;

  try {
    final imgSize = min(cameraImage.width, cameraImage.height);
    final cropPadding = (imgSize * borderPaddingPercent / 100).round();
    final cropHorizontal = (cameraImage.width - imgSize + cropPadding) ~/ 2;
    final cropVertical = (cameraImage.height - imgSize + cropPadding) ~/ 2;
    final image = ImageConverter.fromCameraImage(
      cameraImage,
      rotation,
      cropTop: cropVertical,
      cropBottom: cropVertical,
      cropLeft: cropHorizontal,
      cropRight: cropHorizontal,
    ).toImage();

    LuminanceSource source = RGBLuminanceSource(
      image.width,
      image.height,
      image.convert(numChannels: 4).getBytes(order: img.ChannelOrder.abgr).buffer.asInt32List(),
    );
    var bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));
    Result? result = _decodeQRCode(bitmap);
    if (result == null) {
      sendPort.send(null);
      return;
    }
    sendPort.send(result);
    return;
  } catch (e) {
    Logger.error('Error while scanning QR code: $e, name: _QRScannerWidgetState#_scanQrCode');
    sendPort.send(e);
    return;
  }
}

class QRScannerWidget extends StatefulWidget {
  final borderPaddingPercent = 40.0;
  const QRScannerWidget({super.key});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  late Future<CameraController?> _cameraController;
  bool _alreadyDetected = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _cameraController = _initCamera();
    _startScan();
  }

  @override
  void dispose() {
    _cameraController.then((controller) {
      _cameraController = Future.value(null);
      return controller?.dispose();
    });
    super.dispose();
  }

  Future<CameraController?> _initCamera() async {
    final cameras = await availableCameras();
    var usedCamera = cameras.firstWhereOrNull((camera) => camera.lensDirection == CameraLensDirection.back);
    usedCamera ??= cameras.firstOrNull;
    if (usedCamera == null) return null;
    final cameraController = CameraController(
      usedCamera,
      !kIsWeb && Platform.isAndroid ? ResolutionPreset.max : ResolutionPreset.medium,
      imageFormatGroup: !kIsWeb && Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      enableAudio: false,
    );
    await cameraController.initialize();
    return cameraController;
  }

  Future<void> _startScan() async {
    final controller = await _cameraController;
    if (controller == null) {
      Logger.info('No camera available', name: 'QRScannerWidget#_startScan');
      return;
    }
    if (kIsWeb) {
      Logger.info('Starting qr code scan on web', name: 'QRScannerWidget#_initCamera');
      _startWebScan();
      return;
    }
    Logger.info('Starting qr code scan', name: 'QRScannerWidget#_initCamera');
    final int rotation = controller.description.sensorOrientation;
    controller.startImageStream((image) {
      if (_alreadyDetected || _isScanning) return;
      _isScanning = true;
      _scanQrCode(image, rotation, widget.borderPaddingPercent).whenComplete(() => _isScanning = false);
    });
  }

  Future<void> _startWebScan() async {
    while (!_alreadyDetected && mounted) {
      await _webScan();
    }
    if (!mounted) {
      Logger.info('QR Scanner Widget not mounted anymore', name: 'QRScannerWidget#_startWebScan');
      return;
    }
    Logger.info('QR Scanner Widget already detected', name: 'QRScannerWidget#_startWebScan');
  }

  Future<void> _webScan() async {
    final file = await (await _cameraController)?.takePicture();
    if (file == null) {
      Logger.info('Could not take picture: Camera not available', name: 'QRScannerWidget#_webScan');
      return;
    }
    final image = img.decodeImage(await file.readAsBytes());
    if (image == null) return;
    final source = RGBLuminanceSource(
      image.width,
      image.height,
      image.convert(numChannels: 4).getBytes(order: img.ChannelOrder.abgr).buffer.asInt32List(),
    );
    final bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));
    final result = _decodeQRCode(bitmap);
    if (result == null) return;
    _alreadyDetected = true;
    return _navigatorReturn(result.text);
  }

  Future<void> _scanQrCode(CameraImage cameraImage, int rotation, double borderPaddingPercent) async {
    try {
      final result = await _startIsolateScanQrCode(cameraImage, rotation, borderPaddingPercent);
      if (result == null) return;
      _alreadyDetected = true;
      return _navigatorReturn(result.text);
    } catch (e, s) {
      Logger.error('Unexpected error while scanning QR Code', error: e, stackTrace: s, name: 'QRScannerWidget#_scanQrCode');
      _alreadyDetected = true;
      return _navigatorReturn('');
    }
  }

  Future<Result?> _startIsolateScanQrCode(CameraImage cameraImage, final int rotation, final double borderPaddingPercent) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(_scanQrCodeIsolate, [receivePort.sendPort, cameraImage, rotation, borderPaddingPercent]);
    final result = await receivePort.first;
    if (result == null) return null;
    if (result is! Result) {
      throw result;
    }
    receivePort.close();
    isolate.kill();
    return result;
  }

  void _navigatorReturn(String qrCode) {
    if (!mounted) return;
    Navigator.of(context).maybePop(qrCode);
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder(
              future: _cameraController,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final controller = snapshot.data;
                  if (controller == null) {
                    return const Center(child: Material(child: Text('No camera available')));
                  }
                  return CameraPreview(controller);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            Container(
              decoration: ShapeDecoration(shape: ScannerOverlayShape(borderPaddingPercent: widget.borderPaddingPercent)),
            ),
          ],
        ),
      );
}
