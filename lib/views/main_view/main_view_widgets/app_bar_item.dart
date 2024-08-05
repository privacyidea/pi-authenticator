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

class AppBarItem extends StatelessWidget {
  const AppBarItem({super.key, required this.onPressed, required this.icon, required this.tooltip});

  final VoidCallback onPressed;
  final String tooltip;
  final Widget icon;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        padding: const EdgeInsets.all(0),
        splashRadius: 20,
        onPressed: onPressed,
        color: Theme.of(context).navigationBarTheme.iconTheme?.resolve({})?.color,
        icon: SizedBox(
          height: 24,
          width: 24,
          child: FittedBox(child: icon),
        ),
      );
}
