import '../platform_info.dart';

/// This class is used as a Placeholder for the PlatformInfos while the real infos are not yet loaded.
class DummyPlatformInfo extends PlatformInfo {
  @override
  String get appName => 'Dummy App';

  @override
  String get buildNumber => '1';

  @override
  String get installerStore => 'Dummy Store';

  @override
  String get packageName => 'Dummy Package';

  @override
  String get appVersion => '1.0.0';

  DummyPlatformInfo();
}
