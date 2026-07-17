/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/globals.dart';
import '../utils/logger.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/app_constraints_notifier.dart';
import '../utils/utils.dart';
import 'pulse_icon.dart';
import 'tooltip_container.dart';

class FocusedItemAsOverlay extends StatelessWidget {
  final bool isFocused;
  final Widget child;
  final String tooltipWhenFocused;
  final Alignment alignment;

  final void Function() onComplete;

  const FocusedItemAsOverlay({
    super.key,
    required this.isFocused,
    required this.child,
    required this.tooltipWhenFocused,
    required this.onComplete,
    this.alignment = Alignment.topCenter,
  });
  @override
  Widget build(BuildContext context) {
    return isFocused
        ? _FocusedItemOverlay(
            onComplete: onComplete,
            tooltipWhenFocused: tooltipWhenFocused,
            alignment: alignment,
            child: child,
          )
        : child;
  }
}

class _FocusedItemOverlay extends StatefulWidget {
  final Widget child;
  final String? tooltipWhenFocused;
  final Alignment alignment;
  final void Function()? onComplete;
  const _FocusedItemOverlay({
    required this.child,
    this.tooltipWhenFocused,
    this.onComplete,
    required this.alignment,
  });

  @override
  State<_FocusedItemOverlay> createState() => _FocusedItemOverlayState();
}

class _FocusedItemOverlayState extends State<_FocusedItemOverlay> {
  static const tooltipPadding = EdgeInsets.all(8);
  static const tooltipMargin = EdgeInsets.all(4);
  static const tooltipBorderWidth = 2.0;

  // Stop tracking the anchor after ~1 second without any position change.
  // Route transitions and relayouts have settled by then and the backdrop
  // blocks scrolling, so the anchor can no longer move.
  static const int _maxStableFrames = 60;

  Timer? _delayTimer;
  Timer? _movementTimer;

  Offset lastChildPosition = Offset.zero;

  double _circlePadding = 0;
  BorderRadius _pulseRadius = BorderRadius.zero;

  OverlayEntry? _overlayEntryText;
  OverlayEntry? _overlayEntryChild;
  OverlayEntry? _overlayEntryBackdrop;

  @override
  Widget build(BuildContext context) {
    final pad = _circlePadding / 2;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The pulse is rendered behind the real widget (not in the overlay) so
        // the glow sits under the icon/text and stays pixel-aligned with it.
        Positioned(
          left: -pad,
          top: -pad,
          right: -pad,
          bottom: -pad,
          child: IgnorePointer(
            child: LayoutBuilder(
              builder: (context, constraints) => PulseIcon(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                borderRadius: _pulseRadius,
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }

  @override
  void initState() {
    Logger.info("FocusedItemOverlay: initState");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateOverlay();
      _startTrackingPosition();
    });
    super.initState();
  }

  void _startTrackingPosition() {
    int stablePositionCount = 0;
    _movementTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted == false) {
        timer.cancel();
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted == false) {
          timer.cancel();
          return;
        }

        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null || !renderBox.hasSize) return;

        final renderBoxOffset = renderBox.localToGlobal(Offset.zero);

        if (lastChildPosition != renderBoxOffset) {
          _updateOverlay();
          lastChildPosition = renderBoxOffset;
          stablePositionCount = 0; // Reset counter on movement
        } else {
          stablePositionCount++;
          if (stablePositionCount >= _maxStableFrames) {
            Logger.info(
              "FocusedItemOverlay: Movement stopped, cancelling timer.",
            );
            timer.cancel();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _delayTimer?.cancel();
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
    final screenSize =
        (globalRef?.read(appConstraintsProvider) ?? const BoxConstraints())
            .biggest;
    final textScaler = MediaQuery.of(context).textScaler;
    if (widget.tooltipWhenFocused != null) {
      final textSize = textSizeOf(
        text: widget.tooltipWhenFocused!,
        style: Theme.of(context).textTheme.bodyLarge!,
        maxWidth:
            screenSize.width / 3 * 2 -
            (tooltipPadding.left +
                tooltipPadding.right +
                tooltipMargin.left +
                tooltipMargin.right +
                tooltipBorderWidth * 2),
        textScaler: textScaler,
      );

      final overlaySize = Size(
        textSize.width +
            tooltipPadding.left +
            tooltipPadding.right +
            tooltipMargin.left +
            tooltipMargin.right +
            tooltipBorderWidth * 2,
        textSize.height +
            tooltipPadding.bottom +
            tooltipPadding.top +
            tooltipMargin.bottom +
            tooltipMargin.top +
            tooltipBorderWidth * 2,
      );
      final clampedOffset = _getClampedOverlayOffset(
        overlaySize: overlaySize,
        alignment: widget.alignment,
        anchor: context.findRenderObject() as RenderBox?,
        screenSize: screenSize,
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
            onComplete: widget.onComplete,
          ),
        ),
      );
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final boxsize = renderBox.size;
    final materialApp = globalContextSync?.findRenderObject();
    final renderBoxOffset = renderBox.localToGlobal(
      Offset.zero,
      ancestor: materialApp,
    );

    const circleThinkness = 2.0;
    final circlePadding = min(
      renderBoxOffset.dy - circleThinkness,
      min(renderBoxOffset.dx, 25.0),
    );
    final BorderRadius borderRadius = BorderRadius.circular(
      max(circlePadding * 2, min(boxsize.width, boxsize.height) / 6),
    );

    // Update state so the in-tree pulse matches the overlay hole size.
    _circlePadding = circlePadding;
    _pulseRadius = borderRadius;
    if (mounted) setState(() {});

    final holeRect = Rect.fromLTWH(
      renderBoxOffset.dx - circlePadding / 2,
      renderBoxOffset.dy - circlePadding / 2,
      max(boxsize.width + circlePadding, 0.0),
      max(boxsize.height + circlePadding, 0.0),
    );

    _overlayEntryChild = OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          Positioned(
            left: holeRect.left,
            top: holeRect.top,
            child: Container(
              width: holeRect.width,
              height: holeRect.height,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: circleThinkness,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                widget.onComplete?.call();
              },
              child: Text(
                AppLocalizations.of(context)!.continueButton,
                style: const TextStyle(fontSize: 0),
              ),
            ),
          ),
        ],
      ),
    );

    // Blur everything except a rounded hole over the anchor, so the real
    // widget shows through unaltered instead of being copied into the overlay.
    _overlayEntryBackdrop = OverlayEntry(
      builder: (overlayContext) => ClipPath(
        clipper: _HoleClipper(hole: borderRadius.toRRect(holeRect)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: const SizedBox.expand(),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntryBackdrop!);
    Overlay.of(context).insert(_overlayEntryChild!);
    if (_overlayEntryText != null) {
      Overlay.of(context).insert(_overlayEntryText!);
    }
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

/// Clips its child to the whole area minus a rounded [hole].
class _HoleClipper extends CustomClipper<Path> {
  final RRect hole;

  const _HoleClipper({required this.hole});

  @override
  Path getClip(Size size) => Path.combine(
    PathOperation.difference,
    Path()..addRect(Offset.zero & size),
    Path()..addRRect(hole),
  );

  @override
  bool shouldReclip(_HoleClipper oldClipper) => oldClipper.hole != hole;
}

Offset _getClampedOverlayOffset({
  required Size overlaySize,
  required Alignment alignment,
  double padding = 12.0,
  required RenderBox? anchor,
  required Size screenSize,
}) {
  final anchorSize = anchor?.size ?? Size.zero;
  final materialApp = globalContextSync?.findRenderObject();
  final anchorOffset =
      anchor?.localToGlobal(Offset.zero, ancestor: materialApp) ?? Offset.zero;
  final preferredOffset = Offset(
    anchorOffset.dx +
        (anchorSize.width - overlaySize.width) / 2 +
        alignment.x * ((anchorSize.width + overlaySize.width) / 2 + padding),
    anchorOffset.dy +
        (anchorSize.height - overlaySize.height) / 2 +
        alignment.y * ((anchorSize.height + overlaySize.height) / 2 + padding),
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
