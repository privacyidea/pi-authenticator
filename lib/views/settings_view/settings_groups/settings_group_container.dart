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
import 'package:privacyidea_authenticator/views/container_view/container_view.dart';

import '../settings_view_widgets/settings_groups.dart';

class SettingsGroupContainer extends StatelessWidget {
  const SettingsGroupContainer({super.key});

  @override
  Widget build(BuildContext context) => SettingsGroup(
        title: 'Container',
        children: [
          TextButton(
            child: ListTile(
              title: Text(
                'Container',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              style: ListTileStyle.list,
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            onPressed: () => Navigator.of(context).pushNamed(ContainerView.routeName),
          ),
        ],
      );
}
