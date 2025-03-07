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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../../../widgets/custom_trailing.dart';

class TokenFolderExpandableHeaderIcon extends StatelessWidget {
  final bool showEmptyFolderIcon;
  final bool isLocked;
  final bool isExpanded;

  const TokenFolderExpandableHeaderIcon({super.key, required this.showEmptyFolderIcon, required this.isLocked, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    if (showEmptyFolderIcon) {
      return CustomTrailing(
        child: Center(
          child: Icon(
            Icons.folder_open,
            color: Theme.of(context).listTileTheme.iconColor,
          ),
        ),
      );
    }

    return CustomTrailing(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                weight: 0.1,
                isExpanded ? FontAwesomeIcons.folderOpen : FontAwesomeIcons.solidFolderClosed,
                color: Theme.of(context).listTileTheme.iconColor,
              ),
              if (isLocked)
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        padding: EdgeInsets.only(left: isExpanded ? 2 : 0.0, top: 6),
                        child: Center(
                          child: Transform(
                            transform: isExpanded
                                ? Matrix4.fromList([
                                    01.0, 0.00, 0, 0, //
                                    -0.5, 0.85, 0, 0, //
                                    00.0, 0.00, 1, 0, //
                                    05.5, 2.00, 0, 1, //
                                  ])
                                : Matrix4.identity(),
                            child: Icon(
                              isExpanded ? MdiIcons.lockOpenVariant : MdiIcons.lock,
                              color: Theme.of(context).extension<ActionTheme>()?.lockColor,
                              size: constraints.maxHeight / 2.1,
                              shadows: [
                                Shadow(
                                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
                                  offset: const Offset(0.5, 0.5),
                                  blurRadius: 2,
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
