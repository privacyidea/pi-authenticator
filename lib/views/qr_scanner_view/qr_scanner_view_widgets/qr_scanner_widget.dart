import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:zxing2/qrcode.dart';

import '../../../utils/image_converter.dart';
import 'qr_code_scanner_overlay.dart';

/// Args: [SendPort] sendPort, [BinaryBitmap] bitmap
/// Returns: [Result] result or [null] if no QR code was found or [Exception] if an error occurred
void _isolatedDecodeQRCode(List args) {
  final SendPort sendPort = args[0] as SendPort;
  final BinaryBitmap bitmap = args[1] as BinaryBitmap;
  try {
    final result = QRCodeReader().decode(bitmap);
    sendPort.send(result);
  } on NotFoundException catch (_) {
    sendPort.send(null);
  } catch (e) {
    sendPort.send(e);
  }
}

class QRScannerWidget extends StatefulWidget {
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
    final controller = CameraController(backCamera, ResolutionPreset.low, enableAudio: false);
    await controller.initialize();
    controller.startImageStream((image) {
      if (_alreadyDetected || _scanTimer != null) return;
      _scanTimer = _scanQrCode(image)..whenComplete(() => _scanTimer = null);
    });
    return controller;
  }

  Future<void> _scanQrCode(CameraImage cameraImage) async {
    final image = ImageConverter.fromCameraImage(cameraImage, 0).toImage();

    LuminanceSource source = RGBLuminanceSource(
      image.width,
      image.height,
      image.convert(numChannels: 4).getBytes(order: ChannelOrder.abgr).buffer.asInt32List(),
    );
    var bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));
    Result result;
    try {
      final decodeResult = await _decodeQRCode(bitmap);
      if (decodeResult == null) return;
      result = decodeResult;
    } catch (e, s) {
      Logger.warning('Error decoding QR Code', error: e, stackTrace: s, name: 'QRScannerWidget#_scanQrCode');
      return;
    }
    _alreadyDetected = true;
    return _navigatorReturn(result.text);
  }

  Future<Result?> _decodeQRCode(BinaryBitmap bitmap) async {
    final receivePort = ReceivePort();
    try {
      Isolate.spawn(_isolatedDecodeQRCode, [receivePort.sendPort, bitmap]);
    } catch (e) {
      receivePort.close();
    }
    final result = await receivePort.first;
    if (result is Exception) {
      throw result;
    }
    return result as Result?;
  }

  void _navigatorReturn(String qrCode) {
    if (!mounted) return;
    Navigator.of(context).pop(qrCode);
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
              decoration: const ShapeDecoration(shape: ScannerOverlayShape()),
            )
          ],
        ),
      );
}
