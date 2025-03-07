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

class DefaultIconButton extends StatelessWidget {
  final IconData icon;
  final Function()? onPressed;
  final String semanticsLabel;
  final Color? color;
  final double size;
  final double padding;

  const DefaultIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticsLabel,
    this.color,
    this.size = 24,
    this.padding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: color,
          iconSize: size,
          splashRadius: size + padding,
        ),
      ),
    );
  }
}
