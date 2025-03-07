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
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../model/version.dart';

class InfoUtils {
  static bool initCalled = false;
  static bool isInitialized = false;
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static final _packageInfo = PackageInfo.fromPlatform();

  static String getDeviceBrand() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) {
      return _androidInfo!.brand;
    } else if (Platform.isIOS) {
      return _iosInfo!.model;
    } else {
      return 'Unknown';
    }
  }

  static String getDeviceModel() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) {
      return _androidInfo!.model;
    } else if (Platform.isIOS) {
      return _iosInfo!.model;
    } else {
      return 'Unknown';
    }
  }

  static Future<void> init() async {
    if (initCalled) return;
    initCalled = true;
    final packageInfo = await _packageInfo;
    _appName = packageInfo.appName;
    _packageName = packageInfo.packageName;
    _appVersion = Version.parse(packageInfo.version);
    _appBuildNumber = packageInfo.buildNumber;
    _androidInfo = !kIsWeb && Platform.isAndroid ? await _deviceInfo.androidInfo : null;
    _iosInfo = !kIsWeb && Platform.isIOS ? await _deviceInfo.iosInfo : null;
    _deviceBrand = getDeviceBrand();
    _deviceModel = getDeviceModel();
    isInitialized = true;
  }

  static String get appName => initCalled ? _appName : throw Exception('AppInfoUtils not initialized');
  static late final String _appName;

  static String get packageName => initCalled ? _packageName : throw Exception('AppInfoUtils not initialized');
  static late final String _packageName;

  static String get currentVersionAndBuildNumber => initCalled ? 'v$currentVersion+$currentBuildNumber' : throw Exception('AppInfoUtils not initialized');

  static Version get currentVersion => initCalled ? _appVersion : throw Exception('AppInfoUtils not initialized');
  static String get currentVersionString => initCalled ? _appVersion.toString() : throw Exception('AppInfoUtils not initialized');
  static late final Version _appVersion;

  static String get currentBuildNumber => initCalled ? _appBuildNumber : throw Exception('AppInfoUtils not initialized');
  static late final String _appBuildNumber;

  static String get deviceBrand => initCalled ? _deviceBrand : throw Exception('AppInfoUtils not initialized');
  static late final String _deviceBrand;

  static String get deviceModel => initCalled ? _deviceModel : throw Exception('AppInfoUtils not initialized');
  static late final String _deviceModel;

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

  static AndroidDeviceInfo? get androidInfo => initCalled ? _androidInfo : throw Exception('AppInfoUtils not initialized');
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
          '\nisPhysicalDevice: ${androidInfo!.isPhysicalDevice}';

  static IosDeviceInfo? get iosInfo => initCalled ? _iosInfo : throw Exception('AppInfoUtils not initialized');
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
