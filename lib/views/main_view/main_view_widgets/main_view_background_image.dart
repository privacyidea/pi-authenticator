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

class MainViewBackgroundImage extends StatelessWidget {
  final Widget appImage;

  const MainViewBackgroundImage({super.key, required this.appImage});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final base = isDarkMode ? 0.3 : 0.08;
    final blendMode = isDarkMode ? BlendMode.darken : BlendMode.lighten;
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 4, 36, 60),
        child: FittedBox(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(scaffoldBackgroundColor.withOpacity(1 - base), blendMode),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(scaffoldBackgroundColor, BlendMode.color),
              child: appImage,
            ),
          ),
        ),
      ),
    );
  }
}
