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

import '../../../model/tokens/token.dart';
import '../../main_view/main_view_widgets/token_widgets/token_widget_builder.dart';

class NoConflictImportTokensTile extends StatelessWidget {
  final Token token;
  final Token? selected;
  final void Function()? onTap;
  final Alignment? alignment;
  final double? width;
  final Color? borderColor;
  const NoConflictImportTokensTile({
    required this.token,
    required this.selected,
    this.onTap,
    this.alignment,
    this.width,
    this.borderColor = Colors.green,
    super.key,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Card(
          elevation: 2,
          color: selected == token ? borderColor : null,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [TokenWidgetBuilder.previewFromToken(token)],
                ),
              ),
            ),
          ),
        ),
      );
}
