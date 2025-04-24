import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/animations/unscaled_animation_controller.dart';

import '../l10n/app_localizations.dart';
import '../utils/customization/theme_extentions/status_colors.dart';
import '../utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import '../utils/utils.dart';

class StatusBar extends ConsumerStatefulWidget {
  final Widget child;
  const StatusBar({super.key, required this.child});

  @override
  ConsumerState<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends ConsumerState<StatusBar> {
  StatusMessage? previousStatusMessage;
  StatusMessage? currentStatusMessage;
  Queue<StatusMessage> statusbarQueue = Queue();

  late Function(DismissDirection) onDismissed;

  OverlayEntry? statusbarOverlay;
  ScaffoldFeatureController? snackbarController;

  @override
  Widget build(BuildContext context) {
    final newStatusMessage = ref.watch(statusMessageProvider);
    _addToQueueIfNotInQueue(newStatusMessage);
    return widget.child;
  }

  @override
  void initState() {
    onDismissed = (direction) {
      if (!mounted) return;
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

  void _addToQueueIfNotInQueue(StatusMessage? statusMessage) {
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

  void _showStatusbarOverlay(StatusMessage statusMessage) {
    final localizations = AppLocalizations.of(context)!;
    final statusText = statusMessage.message(localizations);
    final statusSubText = statusMessage.details?.call(localizations);
    if (statusbarOverlay != null) {
      statusbarOverlay?.remove();
      statusbarOverlay = null;
    }

    statusbarOverlay = OverlayEntry(
      builder: (context) => StatusBarOverlayEntry(
        onDismissed: onDismissed,
        statusText: statusText,
        statusSubText: statusSubText,
        isError: statusMessage.isError,
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
  final bool isError;
  final Function(DismissDirection) onDismissed;

  const StatusBarOverlayEntry({super.key, required this.statusText, required this.onDismissed, this.statusSubText, required this.isError});

  @override
  State<StatusBarOverlayEntry> createState() => _StatusBarOverlayEntryState();
}

class _StatusBarOverlayEntryState extends State<StatusBarOverlayEntry> with SingleTickerProviderStateMixin {
  bool isFirstFrame = true;
  static const double margin = 10;
  static const double padding = 10;
  static const Duration showDuration = Duration(seconds: 5);
  late UnscaledAnimationController controller;
  late Animation autoDismissAnimation;
  late Function(DismissDirection) onDismissed;

  @override
  void initState() {
    controller = UnscaledAnimationController(duration: showDuration);
    final curvedAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOut);
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
      controller.stop();
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
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    final statusTextHeight = textSizeOf(
      text: widget.statusText,
      style: statusTextStyle,
      maxWidth: maxWidth,
      textScaler: MediaQuery.of(context).textScaler,
      maxLines: 1,
    ).height;
    final statusSubTextHeight = widget.statusSubText != null
        ? textSizeOf(
            text: widget.statusSubText!,
            style: statusSubTextStyle,
            maxWidth: maxWidth,
            textScaler: MediaQuery.of(context).textScaler,
            maxLines: 1,
          ).height
        : 0;
    return AnimatedPositioned(
      onEnd: () {
        if (mounted) {
          setState(() {
            controller.forward();
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
              if (controller.isAnimating) {
                controller.stop();
              } else {
                controller.forward();
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
                    color: widget.isError ? statusColors.error : statusColors.success,
                  ),
                  padding: const EdgeInsets.all(padding),
                  child: SizedBox(
                    width: maxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.statusText,
                          style: statusTextStyle,
                          textAlign: TextAlign.center,
                        ),
                        if (widget.statusSubText != null)
                          Text(
                            widget.statusSubText!,
                            style: statusSubTextStyle,
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
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
