/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2023 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/utils/customizations.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';

class PrivacyIdeaIOClient {
  const PrivacyIdeaIOClient();

  /// Dummy network request can be used to trigger the network access permission
  /// on iOS devices. Doing this at an appropriate place in the code can prevent
  /// SocketExceptions.
  Future<void> triggerNetworkAccessPermission({required Uri url, bool sslVerify = true}) async {
    if (kIsWeb) return;
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = ((X509Certificate cert, String host, int port) => !sslVerify);
    httpClient.userAgent = 'privacyIDEA-App'
        '/${(await PackageInfo.fromPlatform()).version}'
        ' ${Platform.operatingSystem}'
        '/${Platform.operatingSystemVersion}';

    IOClient ioClient = IOClient(httpClient);

    try {
      await ioClient.post(url, body: '');
    } on SocketException {
      if (globalNavigatorKey.currentState?.context == null) return;
      globalRef?.read(statusMessageProvider.notifier).state = (
        AppLocalizations.of(globalNavigatorKey.currentState!.context)!.connectionFailed,
        AppLocalizations.of(globalNavigatorKey.currentState!.context)!.checkYourNetwork,
      );
    } on ClientException {
      if (globalNavigatorKey.currentState?.context == null) return;
      globalRef?.read(statusMessageProvider.notifier).state = (
        AppLocalizations.of(globalNavigatorKey.currentState!.context)!.connectionFailed,
        AppLocalizations.of(globalNavigatorKey.currentState!.context)!.checkYourNetwork,
      );
    } finally {
      ioClient.close();
    }
  }

  /// Custom POST request allows to not verify certificates.
  Future<Response> doPost({required Uri url, required Map<String, String?> body, bool sslVerify = true}) async {
    if (kIsWeb) return Response('Platform not supported', 405);
    Logger.info('Sending post request (SSLVerify: $sslVerify)', name: 'utils.dart#doPost');

    List<MapEntry> entries = body.entries.where((element) => element.value == null).toList();
    if (entries.isNotEmpty) {
      List<String> nullEntries = [];
      for (MapEntry entry in entries) {
        nullEntries.add(entry.key);
      }
      throw ArgumentError('Can not send request because the argument [body] contains a null values'
          ' at entries $nullEntries, this is not permitted.');
    }

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = ((_, __, ___) => !sslVerify);
    httpClient.userAgent = 'privacyIDEA-App'
        '/${(await PackageInfo.fromPlatform()).version}'
        ' ${Platform.operatingSystem}'
        '/${Platform.operatingSystemVersion}';

    IOClient ioClient = IOClient(httpClient);

    Response response;
    try {
      response = await ioClient.post(url, body: body);
    } on SocketException catch (e, s) {
      response = Response('${e.runtimeType} : $s', 404);
    } on HandshakeException catch (e, s) {
      response = Response('${e.runtimeType} : $s', 525);
    }

    if (response.statusCode != 200) {
      Logger.warning(
        'Received unexpected response',
        name: 'utils.dart#doPost',
        error: 'Status code: ${response.statusCode}' '\nPosted body: $body' '\nResponse: ${response.body}\n',
      );
    }
    ioClient.close();

    return response;
  }

  Future<Response> doGet({required Uri url, required Map<String, String?> parameters, bool sslVerify = true}) async {
    if (kIsWeb) return Response('', 405);
    Logger.info('Sending get request (SSLVerify: $sslVerify)', name: 'utils.dart#doGet');
    List<MapEntry> entries = parameters.entries.where((element) => element.value == null).toList();
    if (entries.isNotEmpty) {
      List<String> nullEntries = [];
      for (MapEntry entry in entries) {
        nullEntries.add(entry.key);
      }
      throw ArgumentError("Can not send request because the argument [parameters] contains "
          "null values at entries $nullEntries, this is not permitted.");
    }

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = ((X509Certificate cert, String host, int port) => !sslVerify);
    httpClient.userAgent = 'privacyIDEA-App /'
        ' ${Platform.operatingSystem}'
        ' ${(await PackageInfo.fromPlatform()).version}';

    IOClient ioClient = IOClient(httpClient);

    StringBuffer buffer = StringBuffer(url);

    if (parameters.isNotEmpty) {
      buffer.write('?');
      buffer.writeAll(parameters.entries.map((e) => '${e.key}=${e.value}'), '&');
    }

    Response response;
    Uri uri = Uri.parse(buffer.toString());
    try {
      response = await ioClient.get(uri);
    } on SocketException catch (e, s) {
      response = Response('${e.runtimeType} : $s', 404);
    } on HandshakeException catch (e, s) {
      Logger.warning('Handshake failed. sslVerify: $sslVerify', name: 'utils.dart#doGet', error: e, stackTrace: s);
      showMessage(message: 'Handshake failed, please check the server certificate and try again.');
      rethrow;
    }

    if (response.statusCode != 200) {
      Logger.warning('Received unexpected response', name: 'utils.dart#doGet');
    }

    ioClient.close();
    return response;
  }
}
