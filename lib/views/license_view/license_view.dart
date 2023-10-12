import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/riverpod_providers.dart';

class LicenseView extends ConsumerWidget {
  static const String routeName = '/license';
  final String appName;
  final Widget appImage;
  final String websiteLink;

  const LicenseView({required this.appName, required this.websiteLink, required this.appImage, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platformInfo = ref.watch(platformInfoProvider);
    return LicensePage(
      applicationName: appName,
      applicationIcon: Padding(
        padding: const EdgeInsets.all(32),
        child: appImage,
      ),
      applicationLegalese: websiteLink,
      applicationVersion: '${platformInfo.appVersion}+${platformInfo.buildNumber}',
    );
  }
}
