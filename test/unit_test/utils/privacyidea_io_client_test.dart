import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show Response;
import 'package:logger/logger.dart' as printer;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';

const _appVersion = '7.3.9';
const _requestTimeout = Duration(seconds: 15);

class _Received {
  _Received({
    required this.method,
    required this.uri,
    required this.userAgent,
    required this.mimeType,
    required this.body,
  });

  final String method;
  final Uri uri;
  final String? userAgent;
  final String? mimeType;
  final String body;
}

class _CapturingOutput extends printer.LogOutput {
  final List<printer.OutputEvent> events = [];

  @override
  void output(printer.OutputEvent event) => events.add(event);

  bool contains(printer.Level level, String text) => events.any(
    (event) => event.level == level && event.lines.any((l) => l.contains(text)),
  );
}

class _PlainPrinter extends printer.LogPrinter {
  @override
  List<String> log(printer.LogEvent event) => [event.message.toString()];
}

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient(this._openUrl);

  final Future<HttpClientRequest> Function() _openUrl;

  bool Function(X509Certificate cert, String host, int port)?
  badCertificateCallbackValue;
  bool closedWithForce = false;
  int openUrlCalls = 0;

  @override
  String? userAgent;

  @override
  set badCertificateCallback(
    bool Function(X509Certificate cert, String host, int port)? callback,
  ) => badCertificateCallbackValue = callback;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    openUrlCalls++;
    return _openUrl();
  }

  @override
  void close({bool force = false}) => closedWithForce = force;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ManualTimer implements Timer {
  _ManualTimer(this.duration, this._callback, this._zone);

  final Duration duration;
  final void Function() _callback;
  final Zone _zone;
  bool _active = true;

  void fire() {
    if (!_active) return;
    _active = false;
    _zone.run(_callback);
  }

  @override
  void cancel() => _active = false;

  @override
  bool get isActive => _active;

  @override
  int get tick => _active ? 0 : 1;
}

Future<void> _settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

_FakeHttpClient _hangingClient() =>
    _FakeHttpClient(() => Completer<HttpClientRequest>().future);

_FakeHttpClient _throwingClient(Object error) =>
    _FakeHttpClient(() => Future<HttpClientRequest>.error(error));

Future<T> _withHttpClient<T>(
  _FakeHttpClient client,
  Future<T> Function() body,
) => HttpOverrides.runZoned(body, createHttpClient: (_) => client);

Future<Response> _runWithManualTimeout({
  required _FakeHttpClient client,
  required Future<Response> Function() request,
}) async {
  final timers = <_ManualTimer>[];
  late Future<Response> pending;
  runZoned(
    () {
      pending = _withHttpClient(client, request);
    },
    zoneSpecification: ZoneSpecification(
      createTimer: (self, parent, zone, duration, callback) {
        if (duration != _requestTimeout) {
          return parent.createTimer(zone, duration, callback);
        }
        final timer = _ManualTimer(duration, callback, zone);
        timers.add(timer);
        return timer;
      },
    ),
  );
  var done = false;
  unawaited(pending.whenComplete(() => done = true));
  await _settle();
  expect(timers, hasLength(1), reason: 'exactly one 15 second timer');
  expect(client.openUrlCalls, 1);
  expect(done, isFalse, reason: 'no response before the timeout fired');
  timers.single.fire();
  return pending;
}

void main() {
  const client = PrivacyideaIOClient();

  late HttpServer server;
  late List<_Received> received;
  late Future<void> Function(HttpRequest request) respond;
  late _CapturingOutput logOutput;
  late printer.Logger originalPrinter;

  Uri serverUrl([String path = '/path']) =>
      Uri.parse('http://127.0.0.1:${server.port}$path');

  Future<void> respondWith(
    HttpRequest request, {
    int status = 200,
    String body = 'ok',
    Map<String, String> headers = const {},
  }) async {
    request.response.statusCode = status;
    headers.forEach(request.response.headers.set);
    request.response.write(body);
    await request.response.close();
  }

  Future<Uri> closedPortUrl() async {
    final probe = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = probe.port;
    await probe.close(force: true);
    return Uri.parse('http://127.0.0.1:$port/path');
  }

  setUpAll(() async {
    PackageInfo.setMockInitialValues(
      appName: 'privacyIDEA',
      packageName: 'it.netknights.pi',
      version: _appVersion,
      buildNumber: '1',
      buildSignature: '',
    );
    Logger.info('Initialize logger before capturing');
    await _settle();
  });

  setUp(() async {
    received = [];
    respond = (request) => respondWith(request);
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final body = await utf8.decodeStream(request);
      received.add(
        _Received(
          method: request.method,
          uri: request.uri,
          userAgent: request.headers.value(HttpHeaders.userAgentHeader),
          mimeType: request.headers.contentType?.mimeType,
          body: body,
        ),
      );
      await respond(request);
    });
    originalPrinter = Logger.print;
    logOutput = _CapturingOutput();
    Logger.print = printer.Logger(
      filter: printer.ProductionFilter(),
      printer: _PlainPrinter(),
      output: logOutput,
    );
  });

  tearDown(() async {
    Logger.print = originalPrinter;
    await server.close(force: true);
  });

  group('ResponseBuilder', () {
    test('fromStatusCode with mayHaveBeenDelivered sets both headers', () {
      final response = ResponseBuilder.fromStatusCode(
        408,
        mayHaveBeenDelivered: true,
      );

      expect(response.statusCode, 408);
      expect(response.body, 'Request Timeout');
      expect(response.headers[ResponseBuilder.connectionFailureHeader], 'true');
      expect(
        response.headers[ResponseBuilder.mayHaveBeenDeliveredHeader],
        'true',
      );
      expect(response.isConnectionFailure, isTrue);
      expect(response.mayHaveBeenDelivered, isTrue);
    });

    test('fromStatusCode without mayHaveBeenDelivered sets only the connection '
        'failure header', () {
      final response = ResponseBuilder.fromStatusCode(500);

      expect(response.statusCode, 500);
      expect(response.body, 'Internal Server Error');
      expect(response.headers, {
        ResponseBuilder.connectionFailureHeader: 'true',
      });
      expect(response.isConnectionFailure, isTrue);
      expect(response.mayHaveBeenDelivered, isFalse);
    });

    test('fromStatusCode with an unmapped code keeps the code and uses the '
        'generic message', () {
      final response = ResponseBuilder.fromStatusCode(999);

      expect(response.statusCode, 999);
      expect(response.body, 'Unknown Error');
      expect(response.isConnectionFailure, isTrue);
      expect(response.mayHaveBeenDelivered, isFalse);
    });

    test('fromStatusCode maps the handshake failure code to its message', () {
      final response = ResponseBuilder.fromStatusCode(525);

      expect(response.statusCode, 525);
      expect(response.body, 'Handshake Failed');
      expect(response.mayHaveBeenDelivered, isFalse);
    });

    test('fromMessage with an unknown message returns 520 as connection '
        'failure without mayHaveBeenDelivered', () {
      final response = ResponseBuilder.fromMessage('No route to host');

      expect(response.statusCode, 520);
      expect(response.body, 'No route to host');
      expect(response.headers, {
        ResponseBuilder.connectionFailureHeader: 'true',
      });
      expect(response.isConnectionFailure, isTrue);
      expect(response.mayHaveBeenDelivered, isFalse);
    });

    test('fromMessage maps known socket messages to their codes', () {
      expect(ResponseBuilder.fromMessage('Connection failed').statusCode, 503);
      expect(ResponseBuilder.fromMessage('Connection refused').statusCode, 599);
      expect(
        ResponseBuilder.fromMessage('Connection Reset By Peer').statusCode,
        104,
      );
      expect(ResponseBuilder.fromMessage('Request Timeout').statusCode, 408);
      for (final message in [
        'Connection failed',
        'Connection refused',
        'Connection Reset By Peer',
      ]) {
        final response = ResponseBuilder.fromMessage(message);
        expect(response.body, message);
        expect(response.isConnectionFailure, isTrue);
        expect(response.mayHaveBeenDelivered, isFalse);
      }
    });

    test('a normal Response is neither a connection failure nor possibly '
        'delivered', () {
      final plain = Response('ok', 200);
      final withOtherHeaders = Response(
        'ok',
        200,
        headers: {'content-type': 'application/json'},
      );

      expect(plain.isConnectionFailure, isFalse);
      expect(plain.mayHaveBeenDelivered, isFalse);
      expect(withOtherHeaders.isConnectionFailure, isFalse);
      expect(withOtherHeaders.mayHaveBeenDelivered, isFalse);
    });

    test('the getters only react to the exact value true', () {
      final response = Response(
        'x',
        500,
        headers: {
          ResponseBuilder.connectionFailureHeader: 'false',
          ResponseBuilder.mayHaveBeenDeliveredHeader: 'yes',
        },
      );

      expect(response.isConnectionFailure, isFalse);
      expect(response.mayHaveBeenDelivered, isFalse);
    });

    test('every code in messageToCode has a message in codeToMessage', () {
      for (final entry in ResponseBuilder.messageToCode.entries) {
        expect(
          ResponseBuilder.codeToMessage.containsKey(entry.value),
          isTrue,
          reason: 'code ${entry.value} of "${entry.key}" has no message',
        );
      }
    });

    test('codeToMessage and messageToCode agree for every code below 520', () {
      for (final entry in ResponseBuilder.codeToMessage.entries) {
        if (entry.key >= 520) continue;
        expect(
          ResponseBuilder.messageToCode[entry.value],
          entry.key,
          reason: 'message "${entry.value}" does not map back to ${entry.key}',
        );
      }
    });
  });

  group('PrivacyideaIOClient.doPost', () {
    test('passes a successful response through unchanged', () async {
      respond = (request) => respondWith(
        request,
        status: 201,
        body: '{"result":{"status":true}}',
        headers: {'x-custom': 'abc'},
      );

      final response = await client.doPost(
        url: serverUrl('/validate/check'),
        body: {'user': 'alice', 'pass': '1234'},
      );

      expect(response.statusCode, 201);
      expect(response.body, '{"result":{"status":true}}');
      expect(response.headers['x-custom'], 'abc');
      expect(response.isConnectionFailure, isFalse);
      expect(response.mayHaveBeenDelivered, isFalse);
    });

    test('sends the body form encoded with UTF-8', () async {
      await client.doPost(
        url: serverUrl('/validate/check'),
        body: {'name': 'x y&z=ä€', 'empty': '', 'plus': '+'},
      );

      expect(received, hasLength(1));
      expect(received.single.method, 'POST');
      expect(received.single.uri.path, '/validate/check');
      expect(received.single.mimeType, 'application/x-www-form-urlencoded');
      expect(Uri.splitQueryString(received.single.body), {
        'name': 'x y&z=ä€',
        'empty': '',
        'plus': '+',
      });
    });

    test('sends an empty body for an empty map', () async {
      final response = await client.doPost(url: serverUrl(), body: {});

      expect(response.statusCode, 200);
      expect(received.single.body, isEmpty);
    });

    test('throws an ArgumentError naming every null entry and sends '
        'nothing', () async {
      await expectLater(
        client.doPost(
          url: serverUrl(),
          body: {'ok': 'value', 'first': null, 'second': null},
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString(),
            'message',
            allOf(contains('first'), contains('second'), isNot(contains('ok'))),
          ),
        ),
      );

      expect(received, isEmpty);
    });

    test('returns an expected error status code unchanged without a '
        'warning', () async {
      respond = (request) =>
          respondWith(request, status: 404, body: 'no such token');

      final response = await client.doPost(
        url: serverUrl(),
        body: {'a': 'b'},
        expectedErrorStatusCodes: {404},
      );

      expect(response.statusCode, 404);
      expect(response.body, 'no such token');
      expect(response.isConnectionFailure, isFalse);
      expect(response.mayHaveBeenDelivered, isFalse);
      expect(
        logOutput.contains(
          printer.Level.info,
          'Received expected HTTP 404 response',
        ),
        isTrue,
      );
      expect(
        logOutput.contains(
          printer.Level.warning,
          'Received unexpected response',
        ),
        isFalse,
      );
    });

    test('returns an unexpected error status code unchanged and logs a '
        'warning', () async {
      respond = (request) => respondWith(request, status: 404, body: 'gone');

      final response = await client.doPost(
        url: serverUrl(),
        body: {'a': 'b'},
        expectedErrorStatusCodes: {500},
      );

      expect(response.statusCode, 404);
      expect(response.body, 'gone');
      expect(response.isConnectionFailure, isFalse);
      expect(
        logOutput.contains(
          printer.Level.warning,
          'Received unexpected response',
        ),
        isTrue,
      );
      expect(
        logOutput.contains(
          printer.Level.info,
          'Received expected HTTP 404 response',
        ),
        isFalse,
      );
    });

    test(
      'does not log an unexpected response for a successful status',
      () async {
        await client.doPost(url: serverUrl(), body: {'a': 'b'});

        expect(
          logOutput.contains(
            printer.Level.warning,
            'Received unexpected response',
          ),
          isFalse,
        );
      },
    );

    test('a refused connection is a connection failure that cannot have been '
        'delivered', () async {
      final response = await client.doPost(
        url: await closedPortUrl(),
        body: {'a': 'b'},
      );

      expect(response.isConnectionFailure, isTrue);
      expect(response.mayHaveBeenDelivered, isFalse);
      expect(response.statusCode, isNot(408));
      expect(response.statusCode, greaterThanOrEqualTo(500));
      expect(received, isEmpty);
    });

    test(
      'a connection dropped after the server received the request may have '
      'been delivered',
      () async {
        respond = (request) async {
          final socket = await request.response.detachSocket(
            writeHeaders: false,
          );
          socket.destroy();
        };

        final response = await client.doPost(
          url: serverUrl(),
          body: {'a': 'b'},
        );

        expect(received, hasLength(1));
        expect(response.isConnectionFailure, isTrue);
        expect(response.mayHaveBeenDelivered, isTrue);
      },
      skip:
          'BUG: SocketException/ClientException after the request reached the '
          'server is not flagged mayHaveBeenDelivered, push answer is re-sent',
    );

    test('a timeout returns 408 as possibly delivered after exactly 15 '
        'seconds', () async {
      final httpClient = _hangingClient();

      final response = await _runWithManualTimeout(
        client: httpClient,
        request: () => client.doPost(url: serverUrl(), body: {'a': 'b'}),
      );

      expect(response.statusCode, 408);
      expect(response.body, 'Request Timeout');
      expect(response.isConnectionFailure, isTrue);
      expect(response.mayHaveBeenDelivered, isTrue);
      expect(httpClient.closedWithForce, isTrue);
    });

    test('a handshake failure returns 525 as connection failure that cannot '
        'have been delivered', () async {
      final httpClient = _throwingClient(
        const HandshakeException('bad certificate'),
      );

      final response = await _withHttpClient(
        httpClient,
        () => client.doPost(url: serverUrl(), body: {'a': 'b'}),
      );

      expect(response.statusCode, 525);
      expect(response.isConnectionFailure, isTrue);
      expect(response.mayHaveBeenDelivered, isFalse);
      expect(httpClient.closedWithForce, isTrue);
    });

    test('a socket exception with a known message uses the mapped code and is '
        'not possibly delivered', () async {
      final httpClient = _throwingClient(
        const SocketException('Connection failed'),
      );

      final response = await _withHttpClient(
        httpClient,
        () => client.doPost(url: serverUrl(), body: {'a': 'b'}),
      );

      expect(response.statusCode, 503);
      expect(response.body, 'Connection failed');
      expect(response.isConnectionFailure, isTrue);
      expect(response.mayHaveBeenDelivered, isFalse);
    });

    test('an unexpected exception returns 520 as possibly delivered', () async {
      final httpClient = _throwingClient(StateError('boom'));

      final response = await _withHttpClient(
        httpClient,
        () => client.doPost(url: serverUrl(), body: {'a': 'b'}),
      );

      expect(response.statusCode, 520);
      expect(response.body, 'Unknown Error');
      expect(response.isConnectionFailure, isTrue);
      expect(response.mayHaveBeenDelivered, isTrue);
      expect(httpClient.closedWithForce, isTrue);
    });

    test(
      'sslVerify true rejects bad certificates and false accepts them',
      () async {
        final strict = _throwingClient(StateError('stop'));
        final lenient = _throwingClient(StateError('stop'));

        await _withHttpClient(
          strict,
          () => client.doPost(url: serverUrl(), body: {'a': 'b'}),
        );
        await _withHttpClient(
          lenient,
          () => client.doPost(
            url: serverUrl(),
            body: {'a': 'b'},
            sslVerify: false,
          ),
        );

        expect(
          strict.badCertificateCallbackValue!(_FakeCertificate(), 'host', 443),
          isFalse,
        );
        expect(
          lenient.badCertificateCallbackValue!(_FakeCertificate(), 'host', 443),
          isTrue,
        );
      },
    );

    test('sends the app version, operating system and its version as '
        'User-Agent', () async {
      await client.doPost(url: serverUrl(), body: {'a': 'b'});

      expect(
        received.single.userAgent,
        'privacyIDEA-App/$_appVersion ${Platform.operatingSystem}'
        '/${Platform.operatingSystemVersion}',
      );
    });
  });

  group('PrivacyideaIOClient.doGet', () {
    test('passes a successful response through unchanged', () async {
      respond = (request) => respondWith(
        request,
        status: 202,
        body: 'body text',
        headers: {'x-custom': 'abc'},
      );

      final response = await client.doGet(
        url: serverUrl('/container/sync'),
        parameters: {'a': 'b'},
      );

      expect(received.single.method, 'GET');
      expect(received.single.uri.path, '/container/sync');
      expect(response.statusCode, 202);
      expect(response.body, 'body text');
      expect(response.headers['x-custom'], 'abc');
      expect(response.isConnectionFailure, isFalse);
      expect(response.mayHaveBeenDelivered, isFalse);
    });

    test('merges parameters into an existing query and encodes them '
        'correctly', () async {
      await client.doGet(
        url: serverUrl('/path?a=1'),
        parameters: {'b': 'x y&z', 'c': '+'},
      );

      final query = received.single.uri.queryParametersAll;
      expect(query, {
        'a': ['1'],
        'b': ['x y&z'],
        'c': ['+'],
      });
      final rawQuery = received.single.uri.query;
      expect(rawQuery, contains('c=%2B'));
      expect(rawQuery, contains('%26z'));
      expect(rawQuery, isNot(contains('&z')));
    });

    test('keeps repeated keys of the existing query', () async {
      await client.doGet(
        url: serverUrl('/path?a=1&a=2'),
        parameters: {'b': 'x'},
      );

      expect(received.single.uri.queryParametersAll, {
        'a': ['1', '2'],
        'b': ['x'],
      });
    });

    test(
      'a parameter replaces an existing query key with the same name',
      () async {
        await client.doGet(url: serverUrl('/path?a=1'), parameters: {'a': '2'});

        expect(received.single.uri.queryParametersAll, {
          'a': ['2'],
        });
      },
    );

    test('an empty string parameter is sent as an empty value', () async {
      await client.doGet(url: serverUrl(), parameters: {'a': ''});

      expect(received.single.uri.queryParametersAll, {
        'a': [''],
      });
    });

    test('empty parameters leave the URL untouched', () async {
      await client.doGet(
        url: serverUrl('/path?q=a%20b+c&r=%2B'),
        parameters: {},
      );

      expect(received.single.uri.path, '/path');
      expect(received.single.uri.query, 'q=a%20b+c&r=%2B');
    });

    test('empty parameters on a URL without a query send no query', () async {
      await client.doGet(url: serverUrl(), parameters: {});

      expect(received.single.uri.toString(), '/path');
    });

    test('throws an ArgumentError naming every null parameter and sends '
        'nothing', () async {
      await expectLater(
        client.doGet(
          url: serverUrl(),
          parameters: {'ok': 'value', 'first': null, 'second': null},
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString(),
            'message',
            allOf(contains('first'), contains('second'), isNot(contains('ok'))),
          ),
        ),
      );

      expect(received, isEmpty);
    });

    test(
      'passes a 404 response through unchanged and logs a warning',
      () async {
        respond = (request) =>
            respondWith(request, status: 404, body: 'no such container');

        final response = await client.doGet(
          url: serverUrl(),
          parameters: {'a': 'b'},
        );

        expect(response.statusCode, 404);
        expect(response.body, 'no such container');
        expect(response.isConnectionFailure, isFalse);
        expect(
          logOutput.contains(
            printer.Level.warning,
            'Received unexpected response: 404',
          ),
          isTrue,
        );
      },
    );

    test('does not log a warning for a successful status', () async {
      await client.doGet(url: serverUrl(), parameters: {'a': 'b'});

      expect(
        logOutput.contains(
          printer.Level.warning,
          'Received unexpected response',
        ),
        isFalse,
      );
    });

    test('a refused connection is a connection failure that cannot have been '
        'delivered', () async {
      final response = await client.doGet(
        url: await closedPortUrl(),
        parameters: {'a': 'b'},
      );

      expect(response.isConnectionFailure, isTrue);
      expect(response.mayHaveBeenDelivered, isFalse);
      expect(response.statusCode, isNot(408));
      expect(response.statusCode, greaterThanOrEqualTo(500));
      expect(received, isEmpty);
    });

    test('a timeout returns 408 as connection failure after exactly 15 '
        'seconds and is not flagged as possibly delivered', () async {
      final httpClient = _hangingClient();

      final response = await _runWithManualTimeout(
        client: httpClient,
        request: () => client.doGet(url: serverUrl(), parameters: {'a': 'b'}),
      );

      expect(response.statusCode, 408);
      expect(response.body, 'Request Timeout');
      expect(response.isConnectionFailure, isTrue);
      expect(response.mayHaveBeenDelivered, isFalse);
      expect(httpClient.closedWithForce, isTrue);
    });

    test('a handshake failure returns 525 as connection failure', () async {
      final httpClient = _throwingClient(
        const HandshakeException('bad certificate'),
      );

      final response = await _withHttpClient(
        httpClient,
        () => client.doGet(url: serverUrl(), parameters: {'a': 'b'}),
      );

      expect(response.statusCode, 525);
      expect(response.isConnectionFailure, isTrue);
      expect(response.mayHaveBeenDelivered, isFalse);
    });

    test(
      'a socket exception with a known message uses the mapped code',
      () async {
        final httpClient = _throwingClient(
          const SocketException('Connection failed'),
        );

        final response = await _withHttpClient(
          httpClient,
          () => client.doGet(url: serverUrl(), parameters: {'a': 'b'}),
        );

        expect(response.statusCode, 503);
        expect(response.body, 'Connection failed');
        expect(response.isConnectionFailure, isTrue);
        expect(response.mayHaveBeenDelivered, isFalse);
      },
    );

    test('an unexpected exception returns 520 as connection failure', () async {
      final httpClient = _throwingClient(StateError('boom'));

      final response = await _withHttpClient(
        httpClient,
        () => client.doGet(url: serverUrl(), parameters: {'a': 'b'}),
      );

      expect(response.statusCode, 520);
      expect(response.body, 'Unknown Error');
      expect(response.isConnectionFailure, isTrue);
      expect(response.mayHaveBeenDelivered, isFalse);
      expect(httpClient.closedWithForce, isTrue);
    });

    test(
      'sslVerify true rejects bad certificates and false accepts them',
      () async {
        final strict = _throwingClient(StateError('stop'));
        final lenient = _throwingClient(StateError('stop'));

        await _withHttpClient(
          strict,
          () => client.doGet(url: serverUrl(), parameters: {'a': 'b'}),
        );
        await _withHttpClient(
          lenient,
          () => client.doGet(
            url: serverUrl(),
            parameters: {'a': 'b'},
            sslVerify: false,
          ),
        );

        expect(
          strict.badCertificateCallbackValue!(_FakeCertificate(), 'host', 443),
          isFalse,
        );
        expect(
          lenient.badCertificateCallbackValue!(_FakeCertificate(), 'host', 443),
          isTrue,
        );
      },
    );

    test('sends the operating system and app version as User-Agent', () async {
      await client.doGet(url: serverUrl(), parameters: {'a': 'b'});

      final userAgent = received.single.userAgent!;
      expect(userAgent, startsWith('privacyIDEA-App'));
      expect(userAgent, contains(Platform.operatingSystem));
      expect(userAgent, contains(_appVersion));
    });
  });
}

class _FakeCertificate implements X509Certificate {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
