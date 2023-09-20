import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';

class LicenseView extends ConsumerWidget {
  static const String routeName = '/license';
  const LicenseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationCustomizer = ref.watch(applicationCustomizerProvider);
    final platformInfo = ref.watch(platformInfoProvider);
    return LicensePage(
      applicationName: applicationCustomizer.appName,
      applicationIcon: Padding(
        padding: const EdgeInsets.all(32),
        child: applicationCustomizer.appImage,
      ),
      applicationLegalese: applicationCustomizer.websiteLink,
      applicationVersion: '${platformInfo.appVersion}+${platformInfo.buildNumber}',
    );
  }
}
