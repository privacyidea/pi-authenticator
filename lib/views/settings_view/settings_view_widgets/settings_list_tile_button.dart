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

class SettingsListTileButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget title;
  final Widget? icon;
  static const double tileHeight = 40;

  const SettingsListTileButton({super.key, required this.title, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SizedBox(
              height: tileHeight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(child: title),
                  if (icon != null)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minHeight: tileHeight, minWidth: tileHeight),
                      onPressed: onPressed,
                      splashRadius: 26,
                      icon: icon!,
                    )
                ],
              ),
            ),
          ),
        ),
      );
}
