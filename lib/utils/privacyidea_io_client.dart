/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2025 NetKnights GmbH

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

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../../../model/pi_server_response.dart';
import '../model/api_results/pi_server_results/pi_server_result_value.dart';
import '../utils/logger.dart';
import '../utils/view_utils.dart';
import 'http_status_checker.dart';

class PrivacyideaIOClient {
  const PrivacyideaIOClient();

  /// Dummy network request can be used to trigger the network access permission
  /// on iOS devices. Doing this at an appropriate place in the code can prevent
  /// SocketExceptions.
  Future<bool> triggerNetworkAccessPermission({required Uri url, bool sslVerify = true, bool isRetry = false}) async {
    if (kIsWeb) return false;
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = ((X509Certificate cert, String host, int port) => !sslVerify);
    httpClient.userAgent = 'privacyIDEA-App'
        '/${(await PackageInfo.fromPlatform()).version}'
        ' ${Platform.operatingSystem}'
        '/${Platform.operatingSystemVersion}';

    IOClient ioClient = IOClient(httpClient);

    try {
      await ioClient.post(url, body: '').timeout(const Duration(seconds: 15));
    } on ClientException {
      Logger.warning('ClientException');
      ioClient.close();
      showErrorStatusMessage(
        message: (localization) => localization.connectionFailed,
        details: (localization) => localization.checkYourNetwork,
      );
      return false;
    } on ArgumentError catch (e, _) {
      Logger.warning('ArgumentError: $e');
      ioClient.close();
      showErrorStatusMessage(
        message: (localization) => localization.connectionFailed,
        details: (localization) => localization.invalidUrl,
      );
      return false;
    } catch (e, _) {
      if (e is! SocketException && e is! TimeoutException) {
        rethrow;
      }
      if (isRetry) {
        Logger.warning('SocketException while retrying');
        showErrorStatusMessage(
          message: (localization) => localization.connectionFailed,
          details: (localization) => localization.checkYourNetwork,
        );

        ioClient.close();
        return false;
      }
      ioClient.close();
      return Future.delayed(
        const Duration(seconds: 10),
        () => triggerNetworkAccessPermission(url: url, sslVerify: sslVerify, isRetry: true),
      );
    } finally {
      ioClient.close();
    }
    return true;
  }

  /// Custom POST request allows to not verify certificates.
  Future<Response> doPost({required Uri url, required Map<String, String?> body, bool sslVerify = true}) async {
    if (kIsWeb) return Response('Platform not supported', 405);
    Logger.info('Sending post request (SSLVerify: $sslVerify)');

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
      response = await ioClient.post(url, body: body).timeout(const Duration(seconds: 15));
    } on HandshakeException catch (e, _) {
      Logger.info('Handshake failed. sslVerify: $sslVerify');
      return ResponseBuilder.fromStatusCode(525);
    } on TimeoutException catch (e, _) {
      Logger.info('Post request timed out');
      return ResponseBuilder.fromStatusCode(408);
    } on SocketException catch (e, _) {
      Logger.info('Post request failed ($e)');
      return ResponseBuilder.fromMessage(e.message);
    } on ClientException catch (e, _) {
      Logger.info('Post request failed ($e)');
      return ResponseBuilder.fromMessage(e.message);
    } catch (e, _) {
      Logger.warning('Something unexpected happened');
      return ResponseBuilder.fromStatusCode(520);
    } finally {
      ioClient.close();
      Logger.info('Post request finished');
    }

    if (HttpStatusChecker.isError(response.statusCode)) {
      Logger.warning(
        'Received unexpected response',
        error: 'Status code: ${response.statusCode}' '\nPosted body: $body' '\nResponse: ${response.body}\n',
        stackTrace: StackTrace.current,
      );
    }
    ioClient.close();

    return response;
  }

  Future<Response> doGet({required Uri url, required Map<String, String?> parameters, bool sslVerify = true}) async {
    if (kIsWeb) return Response('', 405);
    Logger.info('Sending get request (SSLVerify: $sslVerify)');
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
      response = await ioClient.get(uri).timeout(const Duration(seconds: 15));
    } on HandshakeException catch (e, _) {
      Logger.info('Handshake failed. sslVerify: $sslVerify');
      return ResponseBuilder.fromStatusCode(525);
    } on TimeoutException catch (e, _) {
      Logger.info('Post request timed out');
      return ResponseBuilder.fromStatusCode(408);
    } on SocketException catch (e, _) {
      Logger.info('Post request failed ($e)');
      return ResponseBuilder.fromMessage(e.message);
    } on ClientException catch (e, _) {
      Logger.info('Post request failed ($e)');
      return ResponseBuilder.fromMessage(e.message);
    } catch (e, _) {
      Logger.warning('Something unexpected happened');
      return ResponseBuilder.fromStatusCode(520);
    } finally {
      ioClient.close();
      Logger.info('Post request finished');
    }

    if (HttpStatusChecker.isError(response.statusCode)) {
      Logger.warning('Received unexpected response: ${response.statusCode}');
    }

    return response;
  }
}

extension ResponseBuilder on Response {
  static Response fromMessage(String message) => _getResponseFromMessage(message);
  static Response fromStatusCode(int statusCode) => _getResponseFromStatusCode(statusCode);

  static Response _getResponseFromMessage(String message) => Response(message, messageToCode[message] ?? 520);
  static Response _getResponseFromStatusCode(int statusCode) => Response(codeToMessage[statusCode] ?? 'Unknown Error', statusCode);

  static final messageToCode = {
    'Continue': 100,
    'Switching Protocols': 101,
    'Processing': 102,
    'Early Hints': 103,
    'Connection Reset By Peer': 104,
    'Connection refused': 111,
    'OK': 200,
    'Created': 201,
    'Accepted': 202,
    'Non-Authoritative Information': 203,
    'No Content': 204,
    'Reset Content': 205,
    'Partial Content': 206,
    'Multi-Status': 207,
    'Already Reported': 208,
    'Multiple Choices': 300,
    'Moved Permanently': 301,
    'Found': 302,
    'See Other': 303,
    'Not Modified': 304,
    'Use Proxy': 305,
    'Temporary Redirect': 307,
    'Permanent Redirect': 308,
    'Bad Request': 400,
    'Unauthorized': 401,
    'Payment Required': 402,
    'Forbidden': 403,
    'Not Found': 404,
    'Method Not Allowed': 405,
    'Not Acceptable': 406,
    'Proxy Authentication Required': 407,
    'Request Timeout': 408,
    'Conflict': 409,
    'Gone': 410,
    'Length Required': 411,
    'Precondition Failed': 412,
    'Payload Too Large': 413,
    'Request-URI Too Long': 414,
    'Unsupported Media Type': 415,
    'Requested Range Not Satisfiable': 416,
    'Expectation Failed': 417,
    "I'm a teapot": 418,
    'Enhance Your Calm': 420,
    'Misdirected Request': 421,
    'Unprocessable Entity': 422,
    'Locked': 423,
    'Failed Dependency': 424,
    'Upgrade Required': 426,
    'Precondition Required': 428,
    'Too Many Requests': 429,
    'Request Header Fields Too Large': 431,
    'Connection Closed Without Response': 444,
    'Unavailable For Legal Reasons': 451,
    'Client Closed Request': 499,
    'Internal Server Error': 500,
    'Not Implemented': 501,
    'Bad Gateway': 502,
    'Service Unavailable': 503,
    'Connection failed': 503,
    'Gateway Timeout': 504,
    'HTTP Version Not Supported': 505,
    'Variant Also Negotiates': 506,
    'Insufficient Storage': 507,
    'Loop Detected': 508,
    'Not Extended': 510,
    'Network Authentication Required': 511,
    'Network Connect Timeout Error': 599,
    'Unknown Error': 520,
  };

  static final codeToMessage = {
    100: 'Continue',
    101: 'Switching Protocols',
    102: 'Processing',
    103: 'Early Hints',
    104: 'Connection Reset By Peer',
    111: 'Connection refused',
    200: 'OK',
    201: 'Created',
    202: 'Accepted',
    203: 'Non-Authoritative Information',
    204: 'No Content',
    205: 'Reset Content',
    206: 'Partial Content',
    207: 'Multi-Status',
    208: 'Already Reported',
    300: 'Multiple Choices',
    301: 'Moved Permanently',
    302: 'Found',
    303: 'See Other',
    304: 'Not Modified',
    305: 'Use Proxy',
    307: 'Temporary Redirect',
    308: 'Permanent Redirect',
    400: 'Bad Request',
    401: 'Unauthorized',
    402: 'Payment Required',
    403: 'Forbidden',
    404: 'Not Found',
    405: 'Method Not Allowed',
    406: 'Not Acceptable',
    407: 'Proxy Authentication Required',
    408: 'Request Timeout',
    409: 'Conflict',
    410: 'Gone',
    411: 'Length Required',
    412: 'Precondition Failed',
    413: 'Payload Too Large',
    414: 'Request-URI Too Long',
    415: 'Unsupported Media Type',
    416: 'Requested Range Not Satisfiable',
    417: 'Expectation Failed',
    418: "I'm a teapot",
    420: 'Enhance Your Calm',
    421: 'Misdirected Request',
    422: 'Unprocessable Entity',
    423: 'Locked',
    424: 'Failed Dependency',
    426: 'Upgrade Required',
    428: 'Precondition Required',
    429: 'Too Many Requests',
    431: 'Request Header Fields Too Large',
    444: 'Connection Closed Without Response',
    451: 'Unavailable For Legal Reasons',
    499: 'Client Closed Request',
    500: 'Internal Server Error',
    501: 'Not Implemented',
    502: 'Bad Gateway',
    503: 'Service Unavailable',
    504: 'Gateway Timeout',
    505: 'HTTP Version Not Supported',
    506: 'Variant Also Negotiates',
    507: 'Insufficient Storage',
    508: 'Loop Detected',
    510: 'Not Extended',
    511: 'Network Authentication Required',
    520: 'Unknown Error',
    521: 'Web Server Is Down',
    522: 'Connection Timed Out',
    523: 'Origin Is Unreachable',
    524: 'A Timeout Occurred',
    525: 'Handshake Failed',
    526: 'Invalid SSL Certificate',
    527: 'Railgun Error',
    528: 'Transport Error',
    529: 'Service is Overloaded',
    530: 'Site is Frozen',
    599: 'Network Connect Timeout Error',
  };
}

extension PiResponse on Response {
  PiServerResponse<T>? asPiServerResponse<T extends PiServerResultValue>() {
    try {
      return PiServerResponse<T>.fromResponse(this);
    } catch (e) {
      Logger.info('Response could not be parsed as PiServerResponse', error: e);
      return null;
    }
  }

  PiSuccessResponse<T>? asPiResponseSuccess<T extends PiServerResultValue>() {
    final piServerResponse = asPiServerResponse<T>();
    if (piServerResponse?.isSuccess != true) return null;
    return piServerResponse!.asSuccess;
  }

  PiErrorResponse<T>? asPiErrorResponse<T extends PiServerResultValue>() {
    final piServerResponse = asPiServerResponse<T>();
    if (piServerResponse?.isError != true) return null;
    return piServerResponse!.asError;
  }

  String? get piErrorMessage => asPiErrorResponse()?.piServerResultError.message;
  int? get piErrorCode => asPiErrorResponse()?.piServerResultError.code;
}
