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

import 'package:flutter/material.dart';

import '../utils/customization/theme_extentions/app_dimensions.dart';

class Gap extends StatelessWidget {
  final double? size;

  const Gap({this.size, super.key});

  @override
  Widget build(BuildContext context) {
    final size =
        this.size ??
        Theme.of(context).extension<AppDimensions>()?.spacingSmall ??
        8.0;
    return SizedBox(width: size, height: size);
  }
}
