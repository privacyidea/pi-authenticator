/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2024 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'package:flutter/material.dart';

import '../../../widgets/button_widgets/default_icon_button.dart';

/// Widget that defines the structure and look of groups on the settings screen.
class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isActive;
  final void Function()? onPressed;
  final IconData? trailingIcon;

  const SettingsGroup({
    super.key,
    required this.title,
    this.children = const [],
    this.isActive = true,
    this.onPressed,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                onPressed != null
                    ? GestureDetector(
                        onTap: isActive ? onPressed : null,
                        child: ListTile(
                          dense: true,
                          leading: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(color: isActive ? null : Colors.grey),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                          trailing: DefaultIconButton(
                            tooltip: title,
                            onPressed: isActive ? onPressed! : null,
                            icon: trailingIcon ?? Icons.arrow_forward_ios,
                          ),
                        ),
                      )
                    : ListTile(
                        dense: true,
                        leading: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(color: isActive ? null : Colors.grey),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                  child: Column(children: children),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
