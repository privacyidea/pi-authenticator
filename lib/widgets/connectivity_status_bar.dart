import 'dart:collection';

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
  Queue<(String, String?)> statusbarQueue = Queue();

  late Function(DismissDirection) onDismissed;

  OverlayEntry? statusbarOverlay;
  ScaffoldFeatureController? snackbarController;

  @override
  Widget build(BuildContext context) {
    final newStatusMessage = ref.watch(statusMessageProvider);
    // if (newStatusMessage != previousStatusMessage && newStatusMessage != currentStatusMessage) {
    // previousStatusMessage = newStatusMessage;
    _addToQueueIfNotInQueue(newStatusMessage);
    // }
    return widget.child;
  }

  @override
  void initState() {
    onDismissed = (direction) {
      setState(() {
        currentStatusMessage = null;
        statusbarOverlay!.remove();
        statusbarOverlay = null;
        ref.read(statusMessageProvider.notifier).state = null;
        _tryPop();
      });
    };

    super.initState();
  }

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

    statusbarOverlay = OverlayEntry(
      builder: (context) => StatusBarOverlayEntry(
        onDismissed: onDismissed,
        statusText: statusText,
        statusSubText: statusSubText,
      ),
    );
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
  bool isFirstFrame = true;
  static const double margin = 10;
  static const double padding = 10;
  static const Duration showDuration = Duration(seconds: 5);
  late AnimationController autoDismissAnimationController;
  late Animation autoDismissAnimation;
  late Function(DismissDirection) onDismissed;

  @override
  void initState() {
    autoDismissAnimationController = AnimationController(vsync: this, duration: showDuration);
    final curvedAnimation = CurvedAnimation(parent: autoDismissAnimationController, curve: Curves.easeOut);
    autoDismissAnimation = Tween<double>(begin: 1, end: 0).animate(curvedAnimation)
      ..addListener(() {
        setState(() {});
      });
    autoDismissAnimation.addListener(() {
      if (mounted) {
        setState(() {});
        if (autoDismissAnimation.isCompleted) {
          onDismissed(DismissDirection.endToStart);
        }
      }
    });

    onDismissed = (DismissDirection direction) {
      autoDismissAnimationController.stop();
      widget.onDismissed(direction);
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstFrame) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) {
          setState(() {
            isFirstFrame = false;
          });
        }
      });
    }

    final maxWidth = MediaQuery.of(context).size.width - margin * 2 - padding * 2;
    final statusTextStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white) ?? const TextStyle();
    final statusSubTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white) ?? const TextStyle();
    final statusTextHeight = textSizeOf(widget.statusText, statusTextStyle, maxWidth: maxWidth).height;
    final statusSubTextHeight = widget.statusSubText != null ? textSizeOf(widget.statusSubText!, statusSubTextStyle, maxWidth: maxWidth).height : 0;
    return AnimatedPositioned(
      onEnd: () {
        if (mounted) {
          setState(() {
            autoDismissAnimationController.forward();
          });
        }
      },
      top: isFirstFrame ? -statusTextHeight - statusSubTextHeight - 10 : 30,
      left: margin,
      right: margin,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 250),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            if (mounted) {
              if (autoDismissAnimationController.isAnimating) {
                autoDismissAnimationController.stop();
              } else {
                autoDismissAnimationController.forward();
              }
            }
          },
          child: Dismissible(
            onDismissed: (direction) {
              if (mounted) {
                onDismissed(direction);
              }
            },
            key: const Key('statusbarOverlay'),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(padding),
                    color: Theme.of(context).colorScheme.error,
                  ),
                  padding: const EdgeInsets.all(padding),
                  child: Center(
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Column(
                        children: [
                          SizedBox(
                            width: maxWidth,
                            child: Center(
                              child: Text(
                                widget.statusText,
                                style: statusTextStyle,
                              ),
                            ),
                          ),
                          if (widget.statusSubText != null)
                            SizedBox(
                              width: maxWidth,
                              child: Center(
                                child: Text(
                                  widget.statusSubText!,
                                  style: statusSubTextStyle,
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: padding / 3 * 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1.5),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      height: 3,
                      width: autoDismissAnimation.value * (maxWidth + padding / 3 * 2),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
