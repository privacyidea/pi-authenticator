import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'version.dart';

class AppInfoUtils {
  static bool isInitialized = false;
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static final packageInfo = PackageInfo.fromPlatform();

  static Future<void> init() async {
    _appName = (await packageInfo).appName;
    _packageName = (await packageInfo).packageName;
    _appVersion = Version.parse((await packageInfo).version);
    _appBuildNumber = (await packageInfo).buildNumber;
    _androidInfo = !kIsWeb && Platform.isAndroid ? await _deviceInfo.androidInfo : null;
    _iosInfo = !kIsWeb && Platform.isIOS ? await _deviceInfo.iosInfo : null;

    isInitialized = true;
  }

  static String get appName => isInitialized ? _appName : throw Exception('AppInfoUtils not initialized');
  static late final String _appName;

  static String get packageName => isInitialized ? _packageName : throw Exception('AppInfoUtils not initialized');
  static late final String _packageName;

  static String get currentVersionAndBuildNumber => isInitialized ? 'v$currentVersion+$currentBuildNumber' : throw Exception('AppInfoUtils not initialized');

  static Version get currentVersion => isInitialized ? _appVersion : throw Exception('AppInfoUtils not initialized');
  static String get currentVersionString => isInitialized ? _appVersion.toString() : throw Exception('AppInfoUtils not initialized');
  static late final Version _appVersion;

  static String get currentBuildNumber => isInitialized ? _appBuildNumber : throw Exception('AppInfoUtils not initialized');
  static late final String _appBuildNumber;

  static String get dartVersion => Platform.version;
  static String get platform => Platform.operatingSystem;

  static String get deviceInfoString {
    if (kIsWeb) return 'Web: Not available.';
    if (Platform.isAndroid) {
      return 'Android:\n$_androidDeviceInfoString';
    } else if (Platform.isIOS) {
      return 'iOS:\n$_iosDeviceInfoString';
    } else {
      return 'Unknown platform';
    }
  }

  static AndroidDeviceInfo? get androidInfo => isInitialized ? _androidInfo : throw Exception('AppInfoUtils not initialized');
  static late final AndroidDeviceInfo? _androidInfo;

  static String get androidDeviceInfoString => _androidDeviceInfoString;
  static final String _androidDeviceInfoString = androidInfo == null
      ? 'It\'s not an Android device.'
      : 'version.securityPatch: ${androidInfo!.version.securityPatch}'
          '\nversion.sdkInt: ${androidInfo!.version.sdkInt}'
          '\nversion.release: ${_androidInfo!.version.release}'
          '\nversion.previewSdkInt: ${androidInfo!.version.previewSdkInt}'
          '\nversion.incremental: ${androidInfo!.version.incremental}'
          '\nversion.codename: ${androidInfo!.version.codename}'
          '\nversion.baseOS: ${androidInfo!.version.baseOS}'
          '\nboard: ${androidInfo!.board}'
          '\nbootloader: ${androidInfo!.bootloader}'
          '\nbrand: ${androidInfo!.brand}'
          '\ndevice: ${androidInfo!.device}'
          '\ndisplay: ${androidInfo!.display}'
          '\nfingerprint: ${androidInfo!.fingerprint}'
          '\nhardware: ${androidInfo!.hardware}'
          '\nhost: ${androidInfo!.host}'
          '\nid: ${androidInfo!.id}'
          '\nmanufacturer: ${androidInfo!.manufacturer}'
          '\nmodel: ${androidInfo!.model}'
          '\nproduct: ${androidInfo!.product}'
          '\nsupported32BitAbis: ${androidInfo!.supported32BitAbis}'
          '\nsupported64BitAbis: ${androidInfo!.supported64BitAbis}'
          '\nsupportedAbis: ${androidInfo!.supportedAbis}'
          '\ntags: ${androidInfo!.tags}'
          '\ntype: ${androidInfo!.type}'
          '\nisPhysicalDevice: ${androidInfo!.isPhysicalDevice}'
          '\ndisplaySizeInches: ${((androidInfo!.displayMetrics.sizeInches * 10).roundToDouble() / 10)}'
          '\ndisplayWidthPixels: ${androidInfo!.displayMetrics.widthPx}'
          '\ndisplayWidthInches: ${androidInfo!.displayMetrics.widthInches}'
          '\ndisplayHeightPixels: ${androidInfo!.displayMetrics.heightPx}'
          '\ndisplayHeightInches: ${androidInfo!.displayMetrics.heightInches}'
          '\ndisplayXDpi: ${androidInfo!.displayMetrics.xDpi}'
          '\ndisplayYDpi: ${androidInfo!.displayMetrics.yDpi}'
          '\nserialNumber: ${androidInfo!.serialNumber}';

  static IosDeviceInfo? get iosInfo => isInitialized ? _iosInfo : throw Exception('AppInfoUtils not initialized');
  static late final IosDeviceInfo? _iosInfo;

  String get iosDeviceInfoString => _iosDeviceInfoString;
  static final String _iosDeviceInfoString = iosInfo == null
      ? 'It\'s not an iOS device.'
      : 'name: ${iosInfo!.name}'
          '\nsystemName: ${iosInfo!.systemName}'
          '\nsystemVersion: ${iosInfo!.systemVersion}'
          '\nmodel: ${iosInfo!.model}'
          '\nlocalizedModel: ${iosInfo!.localizedModel}'
          '\nidentifierForVendor: ${iosInfo!.identifierForVendor}'
          '\nisPhysicalDevice: ${iosInfo!.isPhysicalDevice}'
          '\nutsname.sysname: ${iosInfo!.utsname.sysname}'
          '\nutsname.nodename: ${iosInfo!.utsname.nodename}'
          '\nutsname.release: ${iosInfo!.utsname.release}'
          '\nutsname.version: ${iosInfo!.utsname.version}'
          '\nutsname.machine: ${iosInfo!.utsname.machine}';
}
