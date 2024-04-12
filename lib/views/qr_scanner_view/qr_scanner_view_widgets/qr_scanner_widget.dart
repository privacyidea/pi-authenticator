import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img_lib;
import 'package:zxing2/qrcode.dart';

import '../../../utils/image_converter.dart';
import '../../../utils/logger.dart';
import 'qr_code_scanner_overlay.dart';

class QRScannerWidget extends StatefulWidget {
  final borderPaddingPercent = 40.0;
  const QRScannerWidget({super.key});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  late Future<CameraController> _controller;
  bool _alreadyDetected = false;
  bool _currentlyScanning = false;

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
    final rotation = backCamera.sensorOrientation;
    final controller = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    await controller.initialize();
    controller.startImageStream((image) {
      if (_alreadyDetected || _currentlyScanning) return;
      _currentlyScanning = true;
      _scanQrCode(image, rotation, widget.borderPaddingPercent).whenComplete(() => _currentlyScanning = false);
    });
    return controller;
  }

  Future<void> _scanQrCode(CameraImage cameraImage, int rotation, double borderPaddingPercent) async {
    img_lib.Image? image;
    try {
      image = (await _convertImage(cameraImage, rotation, borderPaddingPercent));
    } catch (e, s) {
      Logger.error('Unexpected error while converting image', name: 'QRScannerWidget#_scanQrCode', error: e, stackTrace: s);
      return _navigatorReturn('');
    }
    Result? result;
    if (image == null) return;
    try {
      result = await _analyzeImage(image);
    } catch (e, s) {
      Logger.error('Unexpected error while analyzing image', name: 'QRScannerWidget#_scanQrCode', error: e, stackTrace: s);
      return _navigatorReturn('');
    }
    if (result == null) return;
    _alreadyDetected = true;
    return _navigatorReturn(result.text);
  }

  Future<Result?> _analyzeImage(img_lib.Image image) async {
    LuminanceSource source = RGBLuminanceSource(
      image.width,
      image.height,
      image.convert(numChannels: 4).getBytes(order: img_lib.ChannelOrder.abgr).buffer.asInt32List(),
    );
    final bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));
    try {
      return await compute((message) => QRCodeReader().decode(bitmap), image);
    } catch (_) {
      return null;
    }
  }

  Future<img_lib.Image?> _convertImage(CameraImage cameraImage, int rotation, double borderPaddingPercent) async {
    final height = rotation % 180 == 0 ? cameraImage.height : cameraImage.width;
    final width = rotation % 180 == 0 ? cameraImage.width : cameraImage.height;
    final squareSize = min(width, height);
    final chropVertical = (height - squareSize) + (squareSize * borderPaddingPercent / 100).round();
    final chropHorizontal = (width - squareSize) + (squareSize * borderPaddingPercent / 100).round();
    return ImageConverter.fromCameraImage(
      cameraImage,
      cropTop: chropVertical ~/ 2,
      cropBottom: chropVertical ~/ 2,
      cropLeft: chropHorizontal ~/ 2,
      cropRight: chropHorizontal ~/ 2,
    );
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
