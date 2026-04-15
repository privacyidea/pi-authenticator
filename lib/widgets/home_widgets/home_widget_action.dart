/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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

import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/extensions/color_extension.dart';
import '../../utils/home_widget_utils.dart';
import 'interfaces/flutter_home_widget_base.dart';
import 'interfaces/flutter_home_widget_builder.dart';

class HomeWidgetAction extends FlutterHomeWidgetBase {
  final IconData icon;
  const HomeWidgetAction({
    required this.icon,
    super.key,
    required super.theme,
    required super.logicalSize,
    required super.utils,
    required super.aditionalSuffix,
  });

  @override
  Widget build(BuildContext context) =>
      (aditionalSuffix == HomeWidgetUtils.keySuffixActive)
      ? Icon(
          icon,
          size: min(logicalSize.width, logicalSize.height),
          color: theme.listTileTheme.iconColor,
        )
      : (aditionalSuffix == HomeWidgetUtils.keySuffixInactive)
      ? Icon(
          icon,
          size: min(logicalSize.width, logicalSize.height),
          color: theme.listTileTheme.iconColor?.mixWith(
            theme.scaffoldBackgroundColor,
          ),
        )
      : const SizedBox();
}

class HomeWidgetActionBuilder
    extends FlutterHomeWidgetBuilder<HomeWidgetAction> {
  final IconData icon;
  HomeWidgetActionBuilder({
    super.key,
    required this.icon,
    required super.lightTheme,
    required super.darkTheme,
    required super.logicalSize,
    required super.homeWidgetKey,
    required super.utils,
  }) : super(
         formWidget: (key, theme, logicalSize, additionalSuffix) =>
             HomeWidgetAction(
               icon: icon,
               key: key,
               theme: theme,
               logicalSize: logicalSize,
               aditionalSuffix: additionalSuffix ?? '',
               utils: utils,
             ),
       );

  @override
  Future<dynamic> renderFlutterWidgets({String additionalSuffix = ''}) async {
    await super.renderFlutterWidgets(
      additionalSuffix: '$additionalSuffix${HomeWidgetUtils.keySuffixActive}',
    );
    await super.renderFlutterWidgets(
      additionalSuffix: '$additionalSuffix${HomeWidgetUtils.keySuffixInactive}',
    );
  }
}
