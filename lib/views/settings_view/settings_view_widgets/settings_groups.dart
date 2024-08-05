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

/// Widget that defines the structure and look of groups on the settings screen.
class SettingsGroup extends StatelessWidget {
  final String _title;
  final List<Widget> _children;
  final bool _isActive;

  const SettingsGroup({super.key, required String title, required List<Widget> children, bool isActive = true})
      : _title = title,
        _children = children,
        _isActive = isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          leading: Text(
            _title,
            style: theme.textTheme.titleLarge?.copyWith(color: _isActive ? null : Colors.grey),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(children: _children),
        ),
      ],
    );
  }
}
