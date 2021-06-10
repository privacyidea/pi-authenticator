/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:package_info/package_info.dart';

/// Custom POST request allows to not verify certificates
Future<Response> doPost(
    {required Uri url, required Map<String, String?> body, bool sslVerify = true}) async {
  log("Sending post request",
      name: "utils.dart",
      error: "URI: $url, SSLVerify: $sslVerify, Body: $body");

  HttpClient httpClient = HttpClient();
  httpClient.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => !sslVerify);
  httpClient.userAgent = "privacyIDEA-App /"
      " ${Platform.operatingSystem}"
      " ${(await PackageInfo.fromPlatform()).version}";

  IOClient ioClient = IOClient(httpClient);

  Response response = await ioClient.post(url, body: body);

  log("Received response",
      name: "utils.dart",
      error: 'Status code: ${response.statusCode}\n Body: ${response.body}');

  ioClient.close();

  return response;
}

Future<Response> doGet(
    {required Uri url, required Map<String, String> parameters, bool? sslVerify = true}) async {

  HttpClient httpClient = HttpClient();
  httpClient.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => !sslVerify!);
  httpClient.userAgent = "privacyIDEA-App /"
      " ${Platform.operatingSystem}"
      " ${(await PackageInfo.fromPlatform()).version}";

  IOClient ioClient = IOClient(httpClient);
  // TODO Make this more general!
  // TODO Are the parameters the headers?
  Uri urlWithParameters = Uri.parse('$url?serial=${parameters['serial']}'
      '&timestamp=${parameters['timestamp']}'
      '&signature=${parameters['signature']}');
  Response response = await ioClient.get(urlWithParameters);

//  String urlWithParameters = '$url';
//  parameters.forEach((key, value) => urlWithParameters += '&$key=$value');
//  print('$urlWithParameters');
//  Response response = await ioClient.get(urlWithParameters);

  log("Received response",
      name: "utils.dart",
      error: 'Status code: ${response.statusCode}\n Body: ${response.body}');

  ioClient.close();
  return response;
}
