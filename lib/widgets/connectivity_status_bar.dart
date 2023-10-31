import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/text_size.dart';

import '../utils/riverpod_providers.dart';

class ConnectivityStatusBar extends ConsumerStatefulWidget {
  final Widget child;
  const ConnectivityStatusBar({super.key, required this.child});

  @override
  ConsumerState<ConnectivityStatusBar> createState() => _ConnectivityStatusBarState();
}

class _ConnectivityStatusBarState extends ConsumerState<ConnectivityStatusBar> {
  (String, String?)? previousStatusMessage;
  (String, String?)? currentStatusMessage;

  late Function(DismissDirection) onDismissed;

  OverlayEntry? statusbarOverlay;
  ScaffoldFeatureController? snackbarController;

  @override
  Widget build(BuildContext context) {
    final newStatusMessage = ref.watch(statusMessageProvider);
    if (newStatusMessage != previousStatusMessage && newStatusMessage != currentStatusMessage) {
      previousStatusMessage = newStatusMessage;
      _addToQueueIfNotInQueue(newStatusMessage);
    }
    return widget.child;
  }

  @override
  void initState() {
    onDismissed = (direction) {
      setState(() {
        currentStatusMessage = null;
        statusbarOverlay!.remove();
        statusbarOverlay = null;
        log("Removing statusbar overlay");
        _tryPop();
      });
    };

    super.initState();
  }

  Queue<(String, String?)> statusbarQueue = Queue();

  void _addToQueueIfNotInQueue((String, String?)? statusMessage) {
    if (statusMessage == null) return;
    if (!statusbarQueue.contains(statusMessage) && currentStatusMessage != statusMessage) {
      statusbarQueue.add(statusMessage);
    }
    _tryPop();
  }

  void _tryPop() {
    if (currentStatusMessage == null && statusbarQueue.isNotEmpty) {
      currentStatusMessage = statusbarQueue.removeFirst();
      _showStatusbarOverlay(currentStatusMessage!);
    }
  }

  void _showStatusbarOverlay((String, String?) statusMessage) {
    final statusText = statusMessage.$1;
    final statusSubText = statusMessage.$2;
    if (statusbarOverlay != null) {
      statusbarOverlay?.remove();
      statusbarOverlay = null;
    }

    statusbarOverlay =
        OverlayEntry(builder: (context) => StatusBarOverlayEntry(onDismissed: onDismissed, statusText: statusText, statusSubText: statusSubText));
    log("Showing statusbar overlay");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Overlay.of(context).insert(statusbarOverlay!);
    });
  }
}

class StatusBarOverlayEntry extends StatefulWidget {
  final String statusText;
  final String? statusSubText;
  final Function(DismissDirection) onDismissed;

  const StatusBarOverlayEntry({super.key, required this.statusText, required this.onDismissed, this.statusSubText});

  @override
  State<StatusBarOverlayEntry> createState() => _StatusBarOverlayEntryState();
}

class _StatusBarOverlayEntryState extends State<StatusBarOverlayEntry> with SingleTickerProviderStateMixin {
  bool isFirstFrame = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isFirstFrame) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          isFirstFrame = true;
        });
      });
    }
    return AnimatedPositioned(
      top: isFirstFrame ? 30 : -textSizeOf(widget.statusText, Theme.of(context).textTheme.bodyLarge!).height - 10,
      left: 10,
      right: 10,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 250),
      child: Material(
        color: Colors.transparent,
        child: Dismissible(
          onDismissed: (direction) {
            widget.onDismissed(direction);
          },
          key: const Key('statusbarOverlay'),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.error,
            ),
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                widget.statusText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
