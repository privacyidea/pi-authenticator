import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import '../utils/logger.dart';

import '../utils/utils.dart';
import 'pulse_icon.dart';
import 'tooltip_container.dart';

class FocusedItemAsOverlay extends StatelessWidget {
  final bool isFocused;
  final bool childIsMoving;
  final Widget child;
  final Widget? overlayChild;
  final String tooltipWhenFocused;
  final Alignment alignment;

  final void Function() onComplete;

  const FocusedItemAsOverlay({
    super.key,
    required this.isFocused,
    required this.child,
    required this.tooltipWhenFocused,
    required this.onComplete,
    this.childIsMoving = false,
    this.overlayChild,
    this.alignment = Alignment.topCenter,
  });
  @override
  Widget build(BuildContext context) {
    return isFocused
        ? _FocusedItemOverlay(
            onComplete: onComplete,
            tooltipWhenFocused: tooltipWhenFocused,
            childIsMoving: childIsMoving,
            overlayChild: overlayChild,
            alignment: alignment,
            child: child,
          )
        : child;
  }
}

class _FocusedItemOverlay extends StatefulWidget {
  final bool childIsMoving;
  final Widget child;
  final Widget? overlayChild;
  final String? tooltipWhenFocused;
  final Alignment alignment;
  final void Function()? onComplete;
  const _FocusedItemOverlay({
    required this.child,
    this.tooltipWhenFocused,
    this.onComplete,
    required this.childIsMoving,
    this.overlayChild,
    required this.alignment,
  });

  @override
  State<_FocusedItemOverlay> createState() => _FocusedItemOverlayState();
}

class _FocusedItemOverlayState extends State<_FocusedItemOverlay> {
  static const tooltipPadding = EdgeInsets.all(8);
  static const tooltipMargin = EdgeInsets.all(4);
  static const tooltipBorderWidth = 2.0;

  Timer? _delayTimer;

  Offset lastChildPosition = Offset.zero;

  OverlayEntry? _overlayEntryText;
  OverlayEntry? _overlayEntryChild;
  OverlayEntry? _overlayEntryBackdrop;

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void initState() {
    Logger.warning("FocusedItemOverlay: initState");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateOverlay();

      if (widget.childIsMoving) {
        Timer.periodic(const Duration(milliseconds: 16), (timer) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (mounted == false) {
              timer.cancel();
              return;
            }
            final renderBoxOffset = (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero);
            if (lastChildPosition != renderBoxOffset) {
              _updateOverlay();
              lastChildPosition = renderBoxOffset;
            }
          });
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _disposeOverlay();
    });
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _FocusedItemOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateOverlay();
    });
  }

  void _updateOverlay() {
    if (mounted == false) return;
    if (ModalRoute.of(context)?.isCurrent == false) {
      _delayTimer ??= Timer(const Duration(milliseconds: 125), () {
        _delayTimer?.cancel();
        _delayTimer = null;
        _updateOverlay();
      });
      return;
    }
    _disposeOverlay();
    if (widget.tooltipWhenFocused != null) {
      final textSize = textSizeOf(
        widget.tooltipWhenFocused!,
        Theme.of(context).textTheme.bodyLarge!,
        maxWidth: MediaQuery.of(context).size.width / 3 * 2 -
            (tooltipPadding.left + tooltipPadding.right + tooltipMargin.left + tooltipMargin.right + tooltipBorderWidth * 2),
        maxLines: null,
      );

      final overlaySize = Size(
        textSize.width + tooltipPadding.left + tooltipPadding.right + tooltipMargin.left + tooltipMargin.right + tooltipBorderWidth * 2,
        textSize.height + tooltipPadding.bottom + tooltipPadding.top + tooltipMargin.bottom + tooltipMargin.top + tooltipBorderWidth * 2,
      );
      final clampedOffset = _getClampedOverlayOffset(
        overlaySize: overlaySize,
        alignment: widget.alignment,
        anchor: context.findRenderObject() as RenderBox?,
        screenSize: MediaQuery.of(context).size,
      );
      _overlayEntryText = OverlayEntry(
        builder: (overlayContext) => Positioned(
          left: clampedOffset.dx,
          top: clampedOffset.dy,
          width: overlaySize.width,
          height: overlaySize.height,
          child: TooltipContainer(
            widget.tooltipWhenFocused!,
            padding: tooltipPadding,
            margin: tooltipMargin,
            border: tooltipBorderWidth,
            textStyle: Theme.of(context).textTheme.bodyLarge!,
          ),
        ),
      );
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final boxsize = renderBox.size;

    final renderBoxOffset = renderBox.localToGlobal(Offset.zero);

    const circleThinkness = 2.0;
    final circlePadding = min(renderBoxOffset.dy - circleThinkness, min(renderBoxOffset.dx, 25.0));
    final BorderRadius borderRadius = BorderRadius.circular(max(circlePadding * 2, min(boxsize.width, boxsize.height) / 6));

    _overlayEntryChild = OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          Positioned(
            left: renderBoxOffset.dx - circlePadding / 2,
            top: renderBoxOffset.dy - circlePadding / 2,
            child: Stack(
              children: [
                Positioned.fill(
                  child: PulseIcon(
                    width: boxsize.width + circlePadding,
                    height: boxsize.height + circlePadding,
                    borderRadius: borderRadius,
                    child: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: renderBox.size.width,
                        height: renderBox.size.height,
                        child: widget.overlayChild ?? widget.child,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: boxsize.width + circlePadding,
                  height: boxsize.height + circlePadding,
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    border: Border.all(color: Theme.of(context).primaryColor, width: circleThinkness),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Tooltip(
              message: AppLocalizations.of(context)!.continueButton,
              child: GestureDetector(
                onTapDown: (details) {
                  widget.onComplete?.call();
                },
                child: Container(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    _overlayEntryBackdrop = OverlayEntry(
      builder: (overlayContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: const Center(
          child: SizedBox(),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntryBackdrop!);
    Overlay.of(context).insert(_overlayEntryChild!);
    if (_overlayEntryText != null) Overlay.of(context).insert(_overlayEntryText!);
  }

  void _disposeOverlay() {
    _overlayEntryBackdrop?.remove();
    _overlayEntryBackdrop = null;
    _overlayEntryChild?.remove();
    _overlayEntryChild = null;
    _overlayEntryText?.remove();
    _overlayEntryText = null;
  }
}

Offset _getClampedOverlayOffset({
  required Size overlaySize,
  required Alignment alignment,
  double padding = 12.0,
  required RenderBox? anchor,
  required Size screenSize,
}) {
  final anchorSize = anchor?.size ?? Size.zero;
  final anchorOffset = anchor?.localToGlobal(Offset.zero) ?? Offset.zero;
  final preferredOffset = Offset(
    anchorOffset.dx + (anchorSize.width - overlaySize.width) / 2 + alignment.x * ((anchorSize.width + overlaySize.width) / 2 + padding),
    anchorOffset.dy + (anchorSize.height - overlaySize.height) / 2 + alignment.y * ((anchorSize.height + overlaySize.height) / 2 + padding),
  );

  const minOffset = Offset(0, 0);
  final maxOffset = Offset(
    screenSize.width - overlaySize.width,
    screenSize.height - overlaySize.height,
  );

  double clampedX;
  double clampedY;
  if (minOffset.dx > maxOffset.dx) {
    clampedX = 0.0;
  } else {
    clampedX = preferredOffset.dx.clamp(minOffset.dx, maxOffset.dx);
  }
  if (minOffset.dy > maxOffset.dy) {
    clampedY = 0.0;
  } else {
    clampedY = preferredOffset.dy.clamp(minOffset.dy, maxOffset.dy);
  }

  return Offset(clampedX, clampedY);
}
