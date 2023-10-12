import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LicenseView extends StatelessWidget {
  static const String routeName = '/license';
  final String appName;
  final Widget appImage;
  final String websiteLink;

  const LicenseView({required this.appName, required this.websiteLink, required this.appImage, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder(
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
      );
}
