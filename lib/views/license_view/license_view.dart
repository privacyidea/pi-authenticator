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
import 'package:package_info_plus/package_info_plus.dart';

import '../../widgets/push_request_listener.dart';
import '../view_interface.dart';

class LicenseView extends StatelessView {
  @override
  RouteSettings get routeSettings => const RouteSettings(name: routeName);
  static const String routeName = '/license';
  final String appName;
  final Widget appImage;
  final String websiteLink;

  const LicenseView({required this.appName, required this.websiteLink, required this.appImage, super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: PushRequestListener(
          child: FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, platformInfo) => LicensePage(
              applicationName: appName,
              applicationIcon: Padding(
                padding: const EdgeInsets.all(32),
                child: appImage,
              ),
              applicationLegalese: '© $websiteLink',
              applicationVersion: platformInfo.data == null ? '' : '${platformInfo.data?.version}+${platformInfo.data?.buildNumber}',
            ),
          ),
        ),
      );
}
