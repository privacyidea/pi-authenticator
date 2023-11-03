import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';
import 'pulse_icon.dart';
import 'tooltip_box.dart';

import '../utils/text_size.dart';

class FocusedItemAsOverlay extends StatelessWidget {
  final bool isFocused;
  final bool childIsMoving;
  final Widget child;
  final Widget? overlayChild;
  final String? tooltipWhenFocused;

  final void Function() onTap;

  const FocusedItemAsOverlay({
    super.key,
    required this.isFocused,
    required this.child,
    this.tooltipWhenFocused,
    required this.onTap,
    this.childIsMoving = false,
    this.overlayChild,
  });
  @override
  Widget build(BuildContext context) {
    return isFocused
        ? _FocusedItemOverlay(
            onTap: onTap,
            tooltipWhenFocused: tooltipWhenFocused,
            childIsMoving: childIsMoving,
            overlayChild: overlayChild,
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
  final void Function()? onTap;
  const _FocusedItemOverlay({required this.child, this.tooltipWhenFocused, this.onTap, required this.childIsMoving, this.overlayChild});

  @override
  State<_FocusedItemOverlay> createState() => _FocusedItemOverlayState();
}

class _FocusedItemOverlayState extends State<_FocusedItemOverlay> with LifecycleMixin {
  static const tooltipPadding = EdgeInsets.all(8);
  static const tooltipMargin = EdgeInsets.all(4);
  static const tooltipBorder = 2.0;

  Offset lastChildPosition = Offset.zero;

  OverlayEntry? _overlayEntry;
  OverlayEntry? _overlayEntryChild;

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _showOverlay();
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

  // Is also called when the orientation changes. FIXME: Find a better way to handle this.
  @override
  void onAppResume() {
    log('onAppResume');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateOverlay();
    });
    super.onAppResume();
  }

  @override
  void didUpdateWidget(covariant _FocusedItemOverlay oldWidget) {
    log('didUpdateWidget');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateOverlay();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _disposeOverlay();
    });
    super.dispose();
  }

  void _showOverlay() {
    if (mounted == false) return;
    if (ModalRoute.of(context)?.isCurrent == false) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _showOverlay();
      });
      return;
    }
    if (widget.tooltipWhenFocused != null) {
      final textSize = textSizeOf(widget.tooltipWhenFocused!, Theme.of(context).textTheme.bodyLarge!);

      final overlaySize = Size(
        textSize.width + tooltipPadding.left + tooltipPadding.right + tooltipMargin.left + tooltipMargin.right + tooltipBorder * 2,
        textSize.height + tooltipPadding.bottom + tooltipPadding.top + tooltipMargin.bottom + tooltipMargin.top + tooltipBorder * 2,
      );
      final clampedOffset = getClampedOffset(overlaySize: overlaySize, context: context);
      _overlayEntry = OverlayEntry(
        builder: (overlayContext) => Positioned(
          left: clampedOffset.dx,
          top: clampedOffset.dy,
          width: overlaySize.width,
          height: overlaySize.height,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: TooltipBox(
              widget.tooltipWhenFocused!,
              padding: tooltipPadding,
              margin: tooltipMargin,
              border: tooltipBorder,
              textStyle: Theme.of(context).textTheme.bodyLarge!,
            ),
          ),
        ),
      );
    } else {
      _overlayEntry = OverlayEntry(
        builder: (overlayContext) => BackdropFilter(filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), child: const SizedBox()),
      );
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final boxsize = renderBox.size;

    final renderBoxOffset = renderBox.localToGlobal(Offset.zero);

    const circlePadding = 25;
    const circleThinkness = 2.0;

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
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Theme.of(context).primaryColor, width: circleThinkness),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                widget.onTap?.call();
              },
              child: Container(
                height: double.maxFinite,
                width: double.maxFinite,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    Overlay.of(context).insert(_overlayEntryChild!);
  }

  void _updateOverlay() {
    log('_updateOverlay');
    _overlayEntry?.remove();
    _overlayEntryChild?.remove();
    _showOverlay();
  }

  void _disposeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _overlayEntryChild?.remove();
    _overlayEntryChild = null;
  }
}

Size getTextSize(BuildContext context, {required String tooltip}) {
  return textSizeOf(tooltip, Theme.of(context).textTheme.bodyLarge!);
}

Offset getClampedOffset({required Size overlaySize, required BuildContext context}) {
  final screenSize = MediaQuery.of(context).size;
  final renderBox = context.findRenderObject() as RenderBox;
  final offset = renderBox.localToGlobal(Offset.zero);
  final preferredOffset = Offset(
    offset.dx + renderBox.size.width / 2 - overlaySize.width / 2,
    offset.dy - renderBox.size.height / 2 - overlaySize.height - 12,
  );
  const minOffset = Offset(0, 0);
  final maxOffset = Offset(
    screenSize.width - overlaySize.width,
    screenSize.height - overlaySize.height,
  );
  return Offset(
    preferredOffset.dx.clamp(minOffset.dx, maxOffset.dx),
    preferredOffset.dy.clamp(minOffset.dy, maxOffset.dy),
  );
}
