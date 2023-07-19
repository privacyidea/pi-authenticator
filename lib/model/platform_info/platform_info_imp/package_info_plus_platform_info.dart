import 'package:package_info_plus/package_info_plus.dart';

import '../platform_info.dart';

class PackageInfoPlusPlatformInfo extends PlatformInfo {
  final PackageInfo _packageInfo;

  PackageInfoPlusPlatformInfo(this._packageInfo);

  @override
  String get appName => _packageInfo.appName;

  @override
  String get buildNumber => _packageInfo.buildNumber;

  @override
  String get installerStore => _packageInfo.installerStore ?? 'Not available';

  @override
  String get packageName => _packageInfo.packageName;

  @override
  String get appVersion => _packageInfo.version;

  static Future<PlatformInfo> loadInfos() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return PackageInfoPlusPlatformInfo(packageInfo);
  }
}
