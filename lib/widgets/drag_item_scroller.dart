import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../utils/globals.dart';
import '../utils/logger.dart';

final dragItemScrollerStateProvider = StateProvider<bool>((ref) => false);

class DragItemScroller extends StatefulWidget {
  static const maxScrollingSpeed = 800.0; // px per second
  static const minScrollingSpeed = 100.0; // px per second
  static const minScrollingSpeedDetectDistanceTop = 40.0; // px distance to top it starts to scroll up
  // When the dragitem reached the end of this zone, it has max speed. if this is smaller than minScrollingSpeedDetectDistanceTop, its possible it will never scroll up with max speed
  static const maxSpeedZoneHeightTop = 40.0;
  static const minScrollingSpeedDetectDistanceBottom = 120.0; // px distance to bottom it starts to scroll down
  // When the dragitem reached the end of this zone, it has max speed. if this is smaller than minScrollingSpeedDetectDistanceBottom, its possible it will never scroll down with max speed
  static const maxSpeedZoneHeightBottom = 40;
  static const refreshRate = 30; // fps

  final Widget child;
  final GlobalKey listViewKey;
  final bool itemIsDragged;
  final GlobalKey<NestedScrollViewState>? nestedScrollViewKey;
  final ScrollController? scrollController;

  const DragItemScroller({
    required this.child,
    required this.listViewKey,
    required this.itemIsDragged,
    this.nestedScrollViewKey,
    this.scrollController,
    super.key,
  }) : assert(nestedScrollViewKey != null || scrollController != null, 'Either nestedScrollViewKey or scrollController must be set');

  @override
  State<DragItemScroller> createState() => _DragItemScrollerState();
}

class _DragItemScrollerState extends State<DragItemScroller> {
  double currentSpeed = 0; // px per second

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      _scrollJump();
      await Future.delayed(const Duration(milliseconds: 1000 ~/ DragItemScroller.refreshRate)); // wait for next frame
      return mounted;
    });
  }

  bool canScroll(ScrollController? controller) =>
      controller != null && ((controller.offset > 0 && currentSpeed < 0) || (controller.offset < controller.position.maxScrollExtent && currentSpeed > 0));

  void _scrollJump() {
    if (currentSpeed == 0) return; // no speed, no jump
    final innerController = widget.nestedScrollViewKey?.currentState?.innerController ?? widget.scrollController;
    final outerController = widget.nestedScrollViewKey?.currentState?.outerController;
    if (canScroll(outerController)) {
      final distanceOneFrame = currentSpeed / DragItemScroller.refreshRate; // px this frame
      final nextPosition = clampDouble(outerController!.offset + distanceOneFrame, 0, outerController.position.maxScrollExtent);
      outerController.position.setPixels(nextPosition); // jump to next position
      return;
    }
    if (canScroll(innerController)) {
      final distanceOneFrame = currentSpeed / DragItemScroller.refreshRate; // px this frame
      final nextPosition = clampDouble(innerController!.offset + distanceOneFrame, 0, innerController.position.maxScrollExtent);
      innerController.position.jumpTo(nextPosition); // jump to next position
      return;
    }
  }

  void _startScrolling(double speedInPercent, {bool moveUp = false}) {
    double nextScrollingSpeed = max(DragItemScroller.minScrollingSpeed, DragItemScroller.maxScrollingSpeed * speedInPercent);
    if (moveUp) nextScrollingSpeed = -nextScrollingSpeed; // if moveUp is true, the speed is negative
    if (currentSpeed == nextScrollingSpeed) return;
    setState(() {
      currentSpeed = nextScrollingSpeed; // set new speed
    });

    if (globalRef?.read(dragItemScrollerStateProvider.notifier).state != true && currentSpeed != 0) {
      globalRef?.read(dragItemScrollerStateProvider.notifier).state = true; // set scrolling state to true if there is speed
    }
  }

  void _stopScrolling() {
    currentSpeed = 0; // to stop set speed to 0
    if (globalRef?.read(dragItemScrollerStateProvider.notifier).state == true) {
      globalRef?.read(dragItemScrollerStateProvider.notifier).state = false; // set scrolling state to false if there is no speed
    }
  }

  //stop scrolling if the widget is not dragged anymore
  @override
  void didUpdateWidget(covariant DragItemScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemIsDragged == true && widget.itemIsDragged == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.itemIsDragged == false) _stopScrolling();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: widget.child,
      onPointerMove: (PointerMoveEvent event) {
        if (widget.itemIsDragged == false) return;
        final innerController = widget.nestedScrollViewKey?.currentState?.innerController ?? widget.scrollController;
        final innerControllerOffset = innerController?.offset ?? widget.scrollController?.offset ?? 0.0;
        final innerControllerMaxScrollExtent = innerController?.position.maxScrollExtent ?? widget.scrollController?.position.maxScrollExtent ?? 0.0;
        final outerControllerOffset = widget.nestedScrollViewKey?.currentState?.outerController.offset ?? 0.0;
        final outerControllerMaxScrollExtent = widget.nestedScrollViewKey?.currentState?.outerController.position.maxScrollExtent ?? 0.0;
        final render = widget.listViewKey.currentContext?.findRenderObject() as RenderBox;
        final position = render.localToGlobal(Offset.zero);
        final topY = position.dy; // top position of the widget
        final bottomY = topY + render.size.height; // bottom position of the widget
        final minScrollingSpeedDetectDistanceTopWithOuterOffset = DragItemScroller.minScrollingSpeedDetectDistanceTop + outerControllerOffset;
        if (event.position.dy < topY + minScrollingSpeedDetectDistanceTopWithOuterOffset && (innerControllerOffset > 0 || outerControllerOffset > 0)) {
          // scroll up if the pointer is in the top range and the scrollController is not at the top
          final distanceToTop = event.position.dy - topY;
          final distanceToMaxSpeed = distanceToTop - (minScrollingSpeedDetectDistanceTopWithOuterOffset - DragItemScroller.maxSpeedZoneHeightTop);
          final scrollSpeedPercent = 1 - distanceToMaxSpeed / DragItemScroller.maxSpeedZoneHeightTop;
          Logger.info('scrollSpeedPercent: $scrollSpeedPercent');
          _startScrolling(clampDouble(scrollSpeedPercent, 0.0, 1.0), moveUp: true);

          return;
        }
        if (event.position.dy > bottomY - DragItemScroller.minScrollingSpeedDetectDistanceBottom &&
            (innerControllerOffset < innerControllerMaxScrollExtent || outerControllerOffset < outerControllerMaxScrollExtent)) {
          // scroll down if the pointer is in the bottom range and the scrollController is not at the bottom
          final distanceToBottom = bottomY - event.position.dy; // distance to bottom of the widget in px
          final distanceToMaxSpeed = distanceToBottom - (DragItemScroller.minScrollingSpeedDetectDistanceBottom - DragItemScroller.maxSpeedZoneHeightBottom);
          final scrollSpeedPercent = 1 - distanceToMaxSpeed / DragItemScroller.maxSpeedZoneHeightBottom;
          Logger.info('scrollSpeedPercent: $scrollSpeedPercent');
          _startScrolling(clampDouble(scrollSpeedPercent, 0.0, 1.0), moveUp: false);
          return;
        }
        _stopScrolling();
      },
    );
  }
}
