/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

class DefaultInkWell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool highlight;

  const DefaultInkWell({
    required this.child,
    this.highlight = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Material(
        // Material to draw on for the InkWell
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: highlight ? Theme.of(context).dividerColor : null,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: InkWell(
            customBorder: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            onTap: onTap,
            child: child,
          ),
        ),
      );
}
