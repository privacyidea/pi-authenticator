import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:image/image.dart';
import 'package:zxing2/qrcode.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

import 'qr_code_scanner_overlay.dart';

class QRScannerWidget extends StatefulWidget {
  // final _key = GlobalKey<QrCameraState>();
  const QRScannerWidget({super.key});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  bool alreadyDetected = false;
  late Future<CameraController> _controller;

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
    final controller = CameraController(backCamera, ResolutionPreset.medium, enableAudio: false);
    await controller.initialize();
    controller.startImageStream((image) => _scanQrCode(image));
    return controller;
  }

  bool currentlyScanning = false;

  void _scanQrCode(CameraImage cameraImage) async {
    if (alreadyDetected || currentlyScanning) return;
    currentlyScanning = true;
    log('Scanning QR Code');
    Uint8List imageBytes = cameraImage.planes[0].bytes;

    final image = decodeImage(imageBytes);
    if (image == null) {
      currentlyScanning = false;
      return;
    }
    log('Image decoded');

    LuminanceSource source = RGBLuminanceSource(
      image.width,
      image.height,
      image.convert(numChannels: 4).getBytes(order: ChannelOrder.abgr).buffer.asInt32List(),
    );
    var bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));

    var reader = QRCodeReader();

    Result result;
    try {
      result = reader.decode(bitmap);
    } catch (e) {
      log(e.toString());
      return;
    }
    log('QR Code detected: ${result.text}');

    final controller = await _controller;
    controller.stopImageStream();
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
