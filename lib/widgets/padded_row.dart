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

class PaddedRow extends StatelessWidget {
  final double peddingPercent;
  final Widget child;

  /// Creates a row with padding on both sides of the child.
  /// Example with 0.25 padding:
  /// [ 0.125 | child | 0.125 ]
  ///
  /// Assert that [peddingPercent] is higher than 0 and lower than 1.
  const PaddedRow({super.key, required this.child, this.peddingPercent = 0.25}) : assert(peddingPercent > 0 && peddingPercent < 1);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: (peddingPercent * 50).toInt(),
            child: const SizedBox(),
          ),
          Expanded(
            flex: 100 - (peddingPercent * 100).toInt(),
            child: child,
          ),
          Expanded(
            flex: (peddingPercent * 50).toInt(),
            child: const SizedBox(),
          ),
        ],
      );
}
