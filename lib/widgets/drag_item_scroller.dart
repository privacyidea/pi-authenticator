import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/riverpod_providers.dart';

final dragItemScrollerStateProvider = StateProvider<bool>((ref) => false);

class DragItemScroller extends StatefulWidget {
  static const maxScrollingSpeed = 800.0; // px per second
  static const minScrollingSpeed = 100.0; // px per second
  static const detectedRangeTop = 40.0; // px of child top
  static const detectedRangeBottom = 140.0; // px of child bottom
  static const refreshRate = 50; // fps

  final Widget child;
  final GlobalKey listViewKey;
  final ScrollController scrollController;
  final bool itemIsDragged;

  const DragItemScroller({
    required this.child,
    required this.listViewKey,
    required this.scrollController,
    required this.itemIsDragged,
    super.key,
  });

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

  _scrollJump() {
    if (currentSpeed == 0) return; // no speed, no jump
    if (currentSpeed < 0 && widget.scrollController.offset <= 0) return; // no jump up if at top
    if (currentSpeed > 0 && widget.scrollController.offset >= widget.scrollController.position.maxScrollExtent) return; // no jump down if at bottom
    final distanceOneFrame = currentSpeed / DragItemScroller.refreshRate; // px this frame
    final nextPosition =
        clampDouble(widget.scrollController.offset + distanceOneFrame, 0, widget.scrollController.position.maxScrollExtent); // calculate next position
    widget.scrollController.jumpTo(nextPosition); // jump to next position
  }

  _startScrolling(double speedInPercent, {bool moveUp = false}) {
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

  _stopScrolling() {
    currentSpeed = 0; // to stop set speed to 0
    if (globalRef?.read(dragItemScrollerStateProvider.notifier).state == true) {
      globalRef?.read(dragItemScrollerStateProvider.notifier).state = false; // set scrolling state to false
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        child: widget.child,
        onPointerMove: (PointerMoveEvent event) {
          if (widget.itemIsDragged == false) return;
          final render = widget.listViewKey.currentContext?.findRenderObject() as RenderBox;
          final position = render.localToGlobal(Offset.zero);
          final topY = position.dy; // top position of the widget
          final bottomY = topY + render.size.height; // bottom position of the widget
          if (event.position.dy < topY + DragItemScroller.detectedRangeTop && widget.scrollController.offset > 0) {
            // scroll up if the pointer is in the top range and the scrollController is not at the top
            final distanceToTop = event.position.dy - topY;
            final distanceToTopPercent = distanceToTop / DragItemScroller.detectedRangeTop;
            final moveSpeedPercent = clampDouble(1 - distanceToTopPercent, 0.0, 1.0);
            _startScrolling(moveSpeedPercent, moveUp: true);

            return;
          }
          if (event.position.dy > bottomY - DragItemScroller.detectedRangeBottom &&
              widget.scrollController.offset < widget.scrollController.position.maxScrollExtent) {
            // scroll down if the pointer is in the bottom range and the scrollController is not at the bottom
            final distanceToBottom = bottomY - event.position.dy; // distance to bottom of the widget in px
            final distanceToBottomPercent = distanceToBottom / DragItemScroller.detectedRangeBottom;
            final moveSpeedPercent = clampDouble(1 - distanceToBottomPercent, 0.0, 1.0);
            _startScrolling(moveSpeedPercent, moveUp: false);
            return;
          }
          _stopScrolling();
        });
  }
}
