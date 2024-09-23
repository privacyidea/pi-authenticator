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

import '../../../utils/logger.dart';

/// This widget is polling for challenges and closes itself when the polling is done.
class LoadingIndicator extends StatelessWidget {
  static double widgetSize = 40;
  static OverlayEntry? _overlayEntry;

  static Future<T?> show<T>(BuildContext context, Future<T> Function() future) async {
    if (_overlayEntry != null) return null;
    _overlayEntry = OverlayEntry(
      builder: (context) => const LoadingIndicator._(),
    );
    Overlay.of(context).insert(_overlayEntry!);
    Logger.info('Showing loading indicator');

    final T result = await future().then((value) {
      Logger.info('Hiding loading indicator');
      _overlayEntry?.remove();
      _overlayEntry = null;
      return value;
    });
    return result;
  }

  const LoadingIndicator._();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      top: size.height * 0.08,
      left: (size.width - widgetSize) / 2,
      width: widgetSize,
      height: widgetSize,
      child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const CircularProgressIndicator()),
    );
  }
}
