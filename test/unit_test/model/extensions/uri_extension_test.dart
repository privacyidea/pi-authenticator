import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/extensions/uri_extension.dart';

void main() {
  group('UriX.isValidEndpoint', () {
    group('accepts', () {
      const accepted = <String>[
        'http://example.com',
        'https://example.com',
        'http://example.com/',
        'https://example.com/path/to/endpoint?query=1#fragment',
        'https://user:secret@example.com:8443/validate/check',
        'http://localhost',
        'http://localhost:5000/',
        'http://192.168.0.230:5000/',
        'http://[::1]:5000/',
        'HTTPS://EXAMPLE.COM/Path',
      ];
      for (final value in accepted) {
        test(value, () {
          expect(Uri.parse(value).isValidEndpoint, isTrue);
        });
      }
    });

    group('rejects', () {
      const rejected = <String, String>{
        'ftp with host': 'ftp://example.com/file',
        'ftps with host': 'ftps://example.com',
        'file scheme': 'file:///etc/passwd',
        'websocket scheme': 'ws://example.com/socket',
        'otpauth scheme': 'otpauth://totp/Label?secret=AAAA',
        'javascript scheme': 'javascript:alert(1)',
        'javascript scheme with slashes and host': 'javascript://example.com/%0Aalert(1)',
        'data scheme': 'data:text/plain;base64,SGVsbG8=',
        'mailto scheme': 'mailto:someone@example.com',
        'http without authority': 'http:example.com',
        'http with empty authority': 'http://',
        'http with empty host and path': 'http:///path/only',
        'https with empty host and port': 'https://:8443/path',
        'https without authority': 'https:/path',
        'relative path': '/relative/path',
        'relative path without leading slash': 'relative/path',
        'host without scheme': 'example.com/path',
        'host with port without scheme': 'example.com:5000',
        'only a query': '?a=b',
        'only a fragment': '#fragment',
        'empty string': '',
      };
      rejected.forEach((description, value) {
        test('$description ("$value")', () {
          // `Uri.parse('example.com:5000')` treats "example.com" as the scheme,
          // which is also not http(s) and must be rejected.
          expect(Uri.parse(value).isValidEndpoint, isFalse);
        });
      });

      test('a uri built by the empty constructor', () {
        expect(Uri().isValidEndpoint, isFalse);
      });

      test('an http uri created via the constructor without host', () {
        expect(Uri(scheme: 'http', path: '/validate').isValidEndpoint, isFalse);
      });

      test('a non http uri created via the constructor with host', () {
        expect(Uri(scheme: 'ftp', host: 'example.com').isValidEndpoint, isFalse);
      });
    });

    group('constructed uris', () {
      test('https with host is accepted', () {
        expect(Uri(scheme: 'https', host: 'example.com', path: '/a').isValidEndpoint, isTrue);
      });

      test('uppercase scheme passed to the constructor is normalized and accepted', () {
        expect(Uri(scheme: 'HTTP', host: 'example.com').isValidEndpoint, isTrue);
      });

      test('resolving a relative reference against an https base yields a valid endpoint', () {
        final resolved = Uri.parse('https://example.com/pi/').resolve('validate/check');
        expect(resolved.toString(), 'https://example.com/pi/validate/check');
        expect(resolved.isValidEndpoint, isTrue);
      });

      test('the relative reference alone is not a valid endpoint', () {
        expect(Uri.parse('validate/check').isValidEndpoint, isFalse);
      });
    });
  });
}
