import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/pia_scheme_processor.dart';

void main() {
  _testPrivacyideaAuthenticatorQrProcessor();
}

void _testPrivacyideaAuthenticatorQrProcessor() {
  group('Pia Scheme Processor test', () {
    test('processUri', () async {
      final tokensList = [
        HOTPToken(id: 'id1', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret1'),
        TOTPToken(period: 30, id: 'id2', algorithm: Algorithms.SHA256, digits: 8, secret: 'secret2'),
        SteamToken(id: 'id3', secret: 'secret3'),
        DayPasswordToken(period: const Duration(hours: 24), id: 'id4', algorithm: Algorithms.SHA512, digits: 10, secret: 'secret4'),
        PushToken(serial: 'serial', id: 'id5'),
      ];
      const uriStrings = [
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQxIiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IkhPVFAiLCJhbGdvcml0aG0iOiJTSEExIiwiZGlnaXRzIjo2LCJzZWNyZXQiOiJzZWNyZXQxIiwiY291bnRlciI6MH0=',
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQyIiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IlRPVFAiLCJhbGdvcml0aG0iOiJTSEEyNTYiLCJkaWdpdHMiOjgsInNlY3JldCI6InNlY3JldDIiLCJwZXJpb2QiOjMwfQ==',
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQzIiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IlNURUFNIiwic2VjcmV0Ijoic2VjcmV0MyJ9',
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQ0IiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IkRBWVBBU1NXT1JEIiwiYWxnb3JpdGhtIjoiU0hBNTEyIiwiZGlnaXRzIjoxMCwic2VjcmV0Ijoic2VjcmV0NCIsInZpZXdNb2RlIjoiVkFMSURGT1IiLCJwZXJpb2QiOjg2NDAwMDAwMDAwfQ==',
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQ1IiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IlBJUFVTSCIsImV4cGlyYXRpb25EYXRlIjpudWxsLCJzZXJpYWwiOiJzZXJpYWwiLCJmYlRva2VuIjpudWxsLCJzc2xWZXJpZnkiOmZhbHNlLCJlbnJvbGxtZW50Q3JlZGVudGlhbHMiOm51bGwsInVybCI6bnVsbCwiaXNSb2xsZWRPdXQiOmZhbHNlLCJyb2xsb3V0U3RhdGUiOiJyb2xsb3V0Tm90U3RhcnRlZCIsInB1YmxpY1NlcnZlcktleSI6bnVsbCwicHJpdmF0ZVRva2VuS2V5IjpudWxsLCJwdWJsaWNUb2tlbktleSI6bnVsbH0=',
      ];
      const processor = PiaSchemeProcessor();
      for (var i = 0; i < uriStrings.length; i++) {
        final token = tokensList[i];
        final uri = Uri.parse(uriStrings[i]);
        final result = await processor.processUri(uri);
        expect(result?.length, 1);
        expect(result![0].isSuccess, true);
        expect(result[0].asSuccess, isNotNull);
        expect(result[0].asSuccess!.resultData, token);
      }
    });
  });
}
