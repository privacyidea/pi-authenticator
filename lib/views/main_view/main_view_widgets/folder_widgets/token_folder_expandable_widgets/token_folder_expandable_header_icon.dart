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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../../../widgets/custom_trailing.dart';

class TokenFolderExpandableHeaderIcon extends StatelessWidget {
  // The open lock, in fractions of the folder icon's height: the point
  // [_openLockAnchor] of the lock (its body's centre) is placed at
  // [_openLockCenter], the middle of the open flap, and the lock is skewed and
  // squashed so its sides follow the flap's slanted edges.
  static const _openLockCenter = Offset(0.626, 0.580);
  static const _openLockSize = 0.50;
  static const _openLockAnchor = FractionalOffset(0.42, 0.48);
  static const _openLockSkew = 0.3125;
  static const _openLockSquash = 1.00;

  final bool showEmptyFolderIcon;
  final bool isLocked;
  final bool isExpanded;

  const TokenFolderExpandableHeaderIcon({
    super.key,
    required this.showEmptyFolderIcon,
    required this.isLocked,
    required this.isExpanded,
  });

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
              FaIcon(
                weight: 0.1,
                isExpanded
                    ? FontAwesomeIcons.folderOpen
                    : FontAwesomeIcons.solidFolderClosed,
                color: Theme.of(context).listTileTheme.iconColor,
              ),
              if (isLocked)
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final folderSize = constraints.maxHeight;
                      final lockSize = isExpanded
                          ? folderSize * _openLockSize
                          : folderSize / 2.1;
                      final lock = Icon(
                        isExpanded ? MdiIcons.lockOpenVariant : Icons.lock,
                        color: Theme.of(
                          context,
                        ).extension<TokenTileTheme>()?.lockColor,
                        size: lockSize,
                        shadows: [
                          Shadow(
                            color: Theme.of(
                              context,
                            ).scaffoldBackgroundColor.withValues(alpha: 0.3),
                            offset: const Offset(0.5, 0.5),
                            blurRadius: 2,
                          ),
                        ],
                      );
                      if (!isExpanded) {
                        return Container(
                          padding: const EdgeInsets.only(top: 6),
                          child: Center(child: lock),
                        );
                      }
                      return Stack(
                        children: [
                          Positioned(
                            left:
                                folderSize * _openLockCenter.dx -
                                lockSize * _openLockAnchor.dx,
                            top:
                                folderSize * _openLockCenter.dy -
                                lockSize * _openLockAnchor.dy,
                            child: Transform(
                              alignment: _openLockAnchor,
                              transform: Matrix4.identity()
                                ..setEntry(0, 1, -_openLockSkew)
                                ..setEntry(1, 1, _openLockSquash),
                              child: lock,
                            ),
                          ),
                        ],
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
