import 'package:flutter/material.dart';

import '../../../utils/logger.dart';

/// This widget is polling for challenges and closes itself when the polling is done.
class LoadingIndicator extends StatelessWidget {
  static double widgetSize = 40;
  static OverlayEntry? _overlayEntry;

  static Future<T?> show<T>(BuildContext context, Future<T> Function() future) async {
    if (_overlayEntry != null) return null;
    _overlayEntry = OverlayEntry(
      builder: (context) => const LoadingIndicator._(),
    );
    Overlay.of(context).insert(_overlayEntry!);
    Logger.info('Showing loading indicator', name: 'loading_indicator.dart#show');

    final T result = await future().then((value) {
      Logger.info('Hiding loading indicator', name: 'loading_indicator.dart#show');
      _overlayEntry?.remove();
      _overlayEntry = null;
      return value;
    });
    return result;
  }

  const LoadingIndicator._();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      top: size.height * 0.08,
      left: (size.width - widgetSize) / 2,
      width: widgetSize,
      height: widgetSize,
      child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const CircularProgressIndicator()),
    );
  }
}
