import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'package:camera/camera.dart';
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
    final chropPadding = (imgSize * borderPaddingPercent / 100).round();
    final chropHorizontal = (cameraImage.width - imgSize + chropPadding) ~/ 2;
    final chropVertical = (cameraImage.height - imgSize + chropPadding) ~/ 2;
    final image = ImageConverter.fromCameraImage(
      cameraImage,
      rotation,
      chropTop: chropVertical,
      chropBottom: chropVertical,
      chropLeft: chropHorizontal,
      chropRight: chropHorizontal,
    ).toImage();

    // await showAsyncDialog(builder: (context) => Center(child: Image.memory(Uint8List.fromList(img.encodePng(image)))));
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
  late Future<CameraController> _controller;
  bool _alreadyDetected = false;
  Future<void>? _scanTimer;

  @override
  void initState() {
    super.initState();
    _controller = _initCamera();
  }

  @override
  void dispose() {
    _controller.then((controller) => controller.dispose());
    super.dispose();
  }

  Future<CameraController> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
    final int rotation = backCamera.sensorOrientation;
    final controller = CameraController(backCamera, ResolutionPreset.high, enableAudio: false);
    await controller.initialize();
    controller.startImageStream((image) {
      if (_alreadyDetected || _scanTimer != null) return;
      _scanTimer = _scanQrCode(image, rotation, widget.borderPaddingPercent)..whenComplete(() => _scanTimer = null);
    });
    return controller;
  }

  Future<void> _scanQrCode(CameraImage cameraImage, int rotation, double borderPaddingPercent) async {
    try {
      final result = await _startIsolateScanQrCode(cameraImage, rotation, borderPaddingPercent);
      if (result == null) return;
      _alreadyDetected = true;
      return _navigatorReturn(result.text);
    } catch (e, s) {
      Logger.error('Unexpected error while scanning QR Code', error: e, stackTrace: s, name: 'QRScannerWidget#_scanQrCode');
      // Logger.warning('Error decoding QR Code', error: e, stackTrace: s, name: 'QRScannerWidget#_scanQrCode');
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
              future: _controller,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final controller = snapshot.data as CameraController;
                  return CameraPreview(controller);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            Container(
              decoration: ShapeDecoration(shape: ScannerOverlayShape(borderPaddingPercent: widget.borderPaddingPercent)),
            )
          ],
        ),
      );
}
