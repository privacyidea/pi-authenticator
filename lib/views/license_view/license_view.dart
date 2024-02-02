import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:privacyidea_authenticator/views/view_interface.dart';

import '../../widgets/push_request_listener.dart';

class LicenseView extends StatelessView {
  @override
  RouteSettings get routeSettings => const RouteSettings(name: routeName);
  static const String routeName = '/license';
  final String appName;
  final Widget appImage;
  final String websiteLink;

  const LicenseView({required this.appName, required this.websiteLink, required this.appImage, super.key});

  @override
  Widget build(BuildContext context) => PushRequestListener(
        child: FutureBuilder(
          future: PackageInfo.fromPlatform(),
          builder: (context, platformInfo) => LicensePage(
            applicationName: appName,
            applicationIcon: Padding(
              padding: const EdgeInsets.all(32),
              child: appImage,
            ),
            applicationLegalese: websiteLink,
            applicationVersion: platformInfo.data == null ? '' : '${platformInfo.data?.version}+${platformInfo.data?.buildNumber}',
          ),
        ),
      );
}
