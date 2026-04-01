import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../utils/animations/unscaled_animation_controller.dart';
import '../utils/customization/theme_extentions/status_colors.dart';
import '../utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import '../utils/utils.dart';

class StatusBar extends ConsumerWidget {
  final Widget child;
  const StatusBar({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(statusProvider, (previous, next) {
      if (next.current != null && previous?.current != next.current) {
        _showOverlay(context, ref, next.current!);
      }
    });
    return child;
  }

  void _showOverlay(
    BuildContext context,
    WidgetRef ref,
    StatusMessage message,
  ) {
    final l10n = AppLocalizations.of(context)!;
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (context) => StatusBarOverlayEntry(
        statusText: message.message(l10n),
        statusSubText: message.details?.call(l10n),
        isError: message.isError,
        onDismissed: (_) {
          entry?.remove();
          ref.read(statusProvider.notifier).dismiss();
        },
      ),
    );

    Overlay.of(context).insert(entry);
  }
}

class StatusBarOverlayEntry extends StatefulWidget {
  final String statusText;
  final String? statusSubText;
  final bool isError;
  final Function(DismissDirection) onDismissed;

  const StatusBarOverlayEntry({
    super.key,
    required this.statusText,
    required this.onDismissed,
    this.statusSubText,
    required this.isError,
  });

  @override
  State<StatusBarOverlayEntry> createState() => _StatusBarOverlayEntryState();
}

class _StatusBarOverlayEntryState extends State<StatusBarOverlayEntry>
    with SingleTickerProviderStateMixin {
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
    final curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );
    autoDismissAnimation =
        Tween<double>(begin: 1, end: 0).animate(curvedAnimation)
          ..addListener(() {
            setState(() {});
          });
    autoDismissAnimation.addStatusListener((status) {
      if (mounted) {
        setState(() {});
        if (status.isCompleted) {
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

    final maxWidth =
        MediaQuery.of(context).size.width - margin * 2 - padding * 2;
    final statusTextStyle =
        Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white) ??
        const TextStyle();
    final statusSubTextStyle =
        Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white) ??
        const TextStyle();
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
                    color: widget.isError
                        ? statusColors.error
                        : statusColors.success,
                  ),
                  padding: const EdgeInsets.all(padding),
                  child: SizedBox(
                    width: maxWidth,
                    child: Column(
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
                      margin: const EdgeInsets.symmetric(
                        horizontal: padding / 3 * 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1.5),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      height: 3,
                      width:
                          autoDismissAnimation.value *
                          (maxWidth + padding / 3 * 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
