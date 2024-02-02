import 'package:flutter/material.dart';

import '../../../utils/logger.dart';
import '../../../utils/push_provider.dart';

/// This widget is polling for challenges and closes itself when the polling is done.
class PollLoadingIndicator extends StatelessWidget {
  static double widgetSize = 40;
  static OverlayEntry? _overlayEntry;
  static void pollForChallenges(BuildContext context) {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (context) => const PollLoadingIndicator._(),
    );
    Overlay.of(context).insert(_overlayEntry!);
    Logger.info('Start polling for challenges', name: 'poll_loading_indicator.dart#initState');
    PushProvider().pollForChallenges(isManually: true).then((_) {
      Logger.info('Stop polling for challenges', name: 'poll_loading_indicator.dart#initState');
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  const PollLoadingIndicator._();

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const CircularProgressIndicator()),
    );
  }
}
