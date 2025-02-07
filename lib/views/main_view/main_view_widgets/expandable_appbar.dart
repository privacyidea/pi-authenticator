/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
import 'package:flutter/material.dart';

import 'filter_token_widget.dart';

class ExpandableAppBar extends StatefulWidget {
  final Widget appBar;
  final Widget body;
  final bool startExpand;

  const ExpandableAppBar({
    required this.appBar,
    required this.body,
    required this.startExpand,
    super.key,
  });

  @override
  State<ExpandableAppBar> createState() => _ExpandableAppBarState();
}

class _ExpandableAppBarState extends State<ExpandableAppBar> {
  static const double maxExpansion = 50 + minExpansion;
  static const double minExpansion = 0;
  // static const double latchHeight = 14;
  bool searchActive = false;
  double currentExpansion = minExpansion;
  double expandTarget = minExpansion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        currentExpansion = widget.startExpand ? 0.1 : minExpansion;
        expandTarget = widget.startExpand ? maxExpansion : minExpansion;
      });
    });
  }

  void _onVertivalDragUpdate(DragUpdateDetails details) {
    if (expandTarget == maxExpansion && details.delta.dy > 0) return;
    if (expandTarget == minExpansion && details.delta.dy < 0) return;
    setState(() {
      if (expandTarget + details.delta.dy > maxExpansion) {
        expandTarget = maxExpansion;
      } else if (expandTarget + details.delta.dy < minExpansion) {
        expandTarget = minExpansion;
      } else {
        expandTarget += details.delta.dy;
      }
    });
  }

  void _stopExpansion(DragEndDetails details) {
    if ((minExpansion + maxExpansion) / 2 < expandTarget) {
      setState(() {
        expandTarget = maxExpansion;
      });
    } else {
      setState(() {
        expandTarget = minExpansion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startExpand) {
      expandTarget = maxExpansion;
    } else {
      expandTarget = minExpansion;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentExpansion != expandTarget && mounted) {
        setState(() {
          currentExpansion = expandTarget;
        });
      }
    });
    return GestureDetector(
      onVerticalDragUpdate: _onVertivalDragUpdate,
      onVerticalDragEnd: _stopExpansion,
      child: Column(
        verticalDirection: VerticalDirection.up,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(child: widget.body),
          AnimatedContainer(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: Theme.of(context).canvasColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            duration: Duration(milliseconds: 250 * (currentExpansion - expandTarget).abs() ~/ maxExpansion),
            height: expandTarget,
            onEnd: () {
              if (!mounted) return;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (currentExpansion == minExpansion) {
                  setState(() {
                    searchActive = false;
                  });
                } else {
                  setState(() {
                    searchActive = true;
                  });
                }
              });
            },
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: SearchTokenWidget(
                      searchActive: expandTarget != minExpansion || searchActive,
                    ),
                  ),
                ),
              ],
            ),
          ),
          widget.appBar,
        ],
      ),
    );
  }
}
