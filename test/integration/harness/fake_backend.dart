/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';

class RecordedRequest {
  final String method;
  final Uri url;
  final Map<String, String?> data;
  final bool sslVerify;

  const RecordedRequest({
    required this.method,
    required this.url,
    required this.data,
    required this.sslVerify,
  });

  bool get isPost => method == 'POST';

  @override
  String toString() => '$method $url $data';
}

typedef BackendHandler = FutureOr<Response> Function(RecordedRequest request);

/// The network as the app sees it through [PrivacyideaIOClient]: every
/// request is recorded and answered by the first handler that claims it.
///
/// A request no handler claims is answered with 404 and kept in
/// [unhandled], so a test notices traffic it did not expect.
class FakeBackend extends PrivacyideaIOClient {
  final List<RecordedRequest> requests = [];
  final List<RecordedRequest> unhandled = [];
  final List<(bool Function(RecordedRequest), BackendHandler)> _handlers = [];

  /// When set, every request fails the way the client reports a connection
  /// failure, before any handler sees it.
  Response Function(RecordedRequest request)? networkFailure;

  void on(bool Function(RecordedRequest request) matches, BackendHandler h) =>
      _handlers.add((matches, h));

  Iterable<RecordedRequest> get posts => requests.where((r) => r.isPost);

  void clearRecords() {
    requests.clear();
    unhandled.clear();
  }

  @override
  Future<bool> triggerNetworkAccessPermission({
    required Uri url,
    bool sslVerify = true,
    bool isRetry = false,
  }) async => true;

  @override
  Future<Response> doPost({
    required Uri url,
    required Map<String, String?> body,
    bool sslVerify = true,
    Set<int> expectedErrorStatusCodes = const {},
  }) {
    final nullEntries = body.entries.where((e) => e.value == null);
    if (nullEntries.isNotEmpty) {
      throw ArgumentError(
        'Cannot send request because the argument [body] contains null values'
        ' at entries ${nullEntries.map((e) => e.key).toList()}, this is not '
        'permitted.',
      );
    }
    return _handle(
      RecordedRequest(
        method: 'POST',
        url: url,
        data: Map.of(body),
        sslVerify: sslVerify,
      ),
    );
  }

  @override
  Future<Response> doGet({
    required Uri url,
    required Map<String, String?> parameters,
    bool sslVerify = true,
  }) {
    return _handle(
      RecordedRequest(
        method: 'GET',
        url: url,
        data: Map.of(parameters),
        sslVerify: sslVerify,
      ),
    );
  }

  Future<Response> _handle(RecordedRequest request) async {
    requests.add(request);
    final failure = networkFailure;
    if (failure != null) return failure(request);
    for (final (matches, handler) in _handlers) {
      if (matches(request)) return handler(request);
    }
    unhandled.add(request);
    return Response('No fake route for $request', 404);
  }

  /// A privacyIDEA style JSON response.
  static Response json(
    Object? value, {
    bool status = true,
    Map<String, dynamic>? detail,
    int statusCode = 200,
  }) => Response(
    jsonEncode({
      'id': 1,
      'jsonrpc': '2.0',
      'result': {'status': status, 'value': value},
      'time': 1700000000.0,
      'version': 'privacyIDEA 3.12',
      'detail': ?detail,
    }),
    statusCode,
    headers: {'content-type': 'application/json'},
  );

  /// A privacyIDEA error response.
  static Response error(int code, String message, {int statusCode = 400}) =>
      Response(
        jsonEncode({
          'id': 1,
          'jsonrpc': '2.0',
          'result': {
            'status': false,
            'error': {'code': code, 'message': message},
          },
          'time': 1700000000.0,
          'version': 'privacyIDEA 3.12',
        }),
        statusCode,
        headers: {'content-type': 'application/json'},
      );

  /// What the client returns when the server cannot be reached at all.
  static Response unreachable(RecordedRequest _) =>
      ResponseBuilder.fromMessage('Connection refused');

  /// What the client returns when the request timed out, so it may have
  /// reached the server.
  static Response timedOut(RecordedRequest _) =>
      ResponseBuilder.fromStatusCode(408, mayHaveBeenDelivered: true);
}
