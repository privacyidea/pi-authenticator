/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageViewIndicator extends ConsumerStatefulWidget {
  final PageController controller;
  final List<Widget> icons;
  const PageViewIndicator({super.key, required this.controller, required this.icons});

  @override
  ConsumerState<PageViewIndicator> createState() => _PageViewDotIndicatorState();
}

class _PageViewDotIndicatorState extends ConsumerState<PageViewIndicator> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        _currentPage = widget.controller.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthPerIcon = constraints.maxWidth / (widget.icons.length + 1);
        final space = widthPerIcon * 0.1;
        final double iconWidth = widthPerIcon - space;
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.icons.length; i++) ...[
              GestureDetector(
                onTap: () {
                  final pageDifference = (i - _currentPage).abs();
                  widget.controller.animateToPage(i, duration: Duration(milliseconds: 200 * pageDifference + 150), curve: Curves.easeInOut);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _currentPage == i ? iconWidth * 2 : iconWidth,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: widget.icons[i],
                ),
              ),
              if (i < widget.icons.length - 1) SizedBox(width: space),
            ]
          ],
        );
      },
    );
  }
}
