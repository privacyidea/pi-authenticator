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
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/helpers/otp_helper.dart';

/// Tests against frozen golden vectors.
/// Additionally, RFC 4226/6238 reference vectors serve as an independent anchor.

class _TotpVector {
  final String secret;
  final int time;
  final int length;
  final int interval;
  final OtpHashAlgorithm algo;
  final String code;
  final bool isGoogle;

  const _TotpVector({
    required this.secret,
    required this.time,
    required this.length,
    required this.interval,
    required this.algo,
    required this.code,
    this.isGoogle = true,
  });
}

class _HotpVector {
  final String secret;
  final int counter;
  final int length;
  final OtpHashAlgorithm algo;
  final String code;
  final bool isGoogle;

  const _HotpVector({
    required this.secret,
    required this.counter,
    required this.length,
    required this.algo,
    required this.code,
  }) : isGoogle = true;
}

void main() {
  // The secret used for TOTP golden vectors (seed 100, 20 random bytes base32 encoded).
  const totpSecret = 'JIBBL3TDEED5Y4HGYRUOHJKDEONV4RIV';
  // The secret used for HOTP golden vectors (seed 200, 20 random bytes base32 encoded).
  const hotpSecret = 'XSMOLLLRIZ5YUA54MJ4KUDJ54KCDOC7S';

  group('TOTP golden vectors (isGoogle=true)', () {
    test('SHA1 steps 0-6', () {
      const expected = [
        '571663',
        '393054',
        '251327',
        '001860',
        '763141',
        '035340',
        '020989',
      ];
      for (var step = 0; step < expected.length; step++) {
        final timeMs = step * 30 * 1000;
        expect(
          generateTOTPCodeString(
            secret: totpSecret,
            time: timeMs,
            length: 6,
            interval: 30,
            algorithm: OtpHashAlgorithm.sha1,
          ),
          expected[step],
          reason: 'sha1 step=$step',
        );
      }
    });

    test('SHA256 steps 0-6', () {
      const expected = [
        '645127',
        '978824',
        '250244',
        '785100',
        '954199',
        '071470',
        '995884',
      ];
      for (var step = 0; step < expected.length; step++) {
        final timeMs = step * 30 * 1000;
        expect(
          generateTOTPCodeString(
            secret: totpSecret,
            time: timeMs,
            length: 6,
            interval: 30,
            algorithm: OtpHashAlgorithm.sha256,
          ),
          expected[step],
          reason: 'sha256 step=$step',
        );
      }
    });

    test('SHA512 steps 0-6', () {
      const expected = [
        '767130',
        '309594',
        '522902',
        '973442',
        '380015',
        '859384',
        '328729',
      ];
      for (var step = 0; step < expected.length; step++) {
        final timeMs = step * 30 * 1000;
        expect(
          generateTOTPCodeString(
            secret: totpSecret,
            time: timeMs,
            length: 6,
            interval: 30,
            algorithm: OtpHashAlgorithm.sha512,
          ),
          expected[step],
          reason: 'sha512 step=$step',
        );
      }
    });

    test('diverse frozen fuzz vectors (seed 101)', () {
      const cases = <_TotpVector>[
        _TotpVector(
          secret: 'KPIGFT4G5PWIHLDTU2LA6JYPUW6FDQO4WRR76N47JOJLPOQ=',
          time: 1849091666631,
          length: 6,
          interval: 30,
          algo: OtpHashAlgorithm.sha256,
          code: '632309',
        ),
        _TotpVector(
          secret: 'PSJZFLV267PJZWFOEMVGQCKHBVMHZXEIAAXQ====',
          time: 73103966495,
          length: 6,
          interval: 60,
          algo: OtpHashAlgorithm.sha1,
          code: '783317',
        ),
        _TotpVector(
          secret: '6LPJSU2U4APDXY7X',
          time: 80263974140,
          length: 7,
          interval: 60,
          algo: OtpHashAlgorithm.sha512,
          code: '6136162',
        ),
        _TotpVector(
          secret: '45DSC4OHGJO7TP3PRKXPXIF5JG6YS5K3HA======',
          time: 506914279543,
          length: 6,
          interval: 60,
          algo: OtpHashAlgorithm.sha1,
          code: '958381',
        ),
        _TotpVector(
          secret: 'Q72UQEOPOTJONQRHFJ2KNGB5YU======',
          time: 2000866327966,
          length: 7,
          interval: 30,
          algo: OtpHashAlgorithm.sha512,
          code: '5784548',
        ),
        _TotpVector(
          secret: 'MSH2WIMKOF4C6SUA6WVDUUYP77KA====',
          time: 665892652757,
          length: 6,
          interval: 1,
          algo: OtpHashAlgorithm.sha1,
          code: '408571',
        ),
      ];
      for (final c in cases) {
        expect(
          generateTOTPCodeString(
            secret: c.secret,
            time: c.time,
            length: c.length,
            interval: c.interval,
            algorithm: c.algo,
          ),
          c.code,
          reason: '${c.secret.substring(0, 8)}...',
        );
      }
    });
  });

  group('HOTP golden vectors (isGoogle=true)', () {
    test('SHA1 counters 0-9', () {
      const expected = [
        '832835',
        '496527',
        '280776',
        '252477',
        '980714',
        '952720',
        '577310',
        '274311',
        '084066',
        '724219',
      ];
      for (var c = 0; c < expected.length; c++) {
        expect(
          generateHOTPCodeString(
            secret: hotpSecret,
            counter: c,
            length: 6,
            algorithm: OtpHashAlgorithm.sha1,
          ),
          expected[c],
          reason: 'sha1 counter=$c',
        );
      }
    });

    test('SHA256 counters 0-9', () {
      const expected = [
        '582435',
        '029292',
        '288844',
        '620005',
        '778976',
        '834803',
        '417186',
        '625280',
        '194815',
        '892671',
      ];
      for (var c = 0; c < expected.length; c++) {
        expect(
          generateHOTPCodeString(
            secret: hotpSecret,
            counter: c,
            length: 6,
            algorithm: OtpHashAlgorithm.sha256,
          ),
          expected[c],
          reason: 'sha256 counter=$c',
        );
      }
    });

    test('SHA512 counters 0-9', () {
      const expected = [
        '109538',
        '429925',
        '404661',
        '651819',
        '663479',
        '755984',
        '954349',
        '134121',
        '369695',
        '370169',
      ];
      for (var c = 0; c < expected.length; c++) {
        expect(
          generateHOTPCodeString(
            secret: hotpSecret,
            counter: c,
            length: 6,
            algorithm: OtpHashAlgorithm.sha512,
          ),
          expected[c],
          reason: 'sha512 counter=$c',
        );
      }
    });

    test('diverse frozen fuzz vectors (seed 201, mixed isGoogle)', () {
      const cases = <_HotpVector>[
        _HotpVector(
          secret: '2QKHTRM4F4Y2YVCF2RDDA66X3S342AH4HQIDO6GNAAUBMSIW',
          counter: 1082585718,
          length: 8,
          algo: OtpHashAlgorithm.sha256,
          code: '79791757',
        ),
        _HotpVector(
          secret:
              'IHZCJCUDM7I7Z5LBV5P5WHV2NNMCGFZ3XYNR7VLKMS76Z33XYGNNWVKQLM======',
          counter: 1561999579,
          length: 6,
          algo: OtpHashAlgorithm.sha1,
          code: '624736',
        ),
        _HotpVector(
          secret:
              'DWNGUJMQIVGWEA5JFQ7VUXG5IQ4ZVDGDAOGDLP2KJ3H3YNYGE6LSMNM2BVMA====',
          counter: 685604438,
          length: 6,
          algo: OtpHashAlgorithm.sha1,
          code: '898975',
        ),
        _HotpVector(
          secret: 'AHJBXT5ODNUQXGTBN6BCBWXNJD2FKSW2CM======',
          counter: 1376524407,
          length: 6,
          algo: OtpHashAlgorithm.sha1,
          code: '372586',
        ),
        _HotpVector(
          secret: 'TXU2ZERMQHU2A7EYD7OOUR4OGKRORBDAIMGWCGCJ2ACMSFSDVE======',
          counter: 866481616,
          length: 6,
          algo: OtpHashAlgorithm.sha512,
          code: '951511',
        ),
        _HotpVector(
          secret: 'V4YQBZ3LEJOKLLN6UJZAZ7FK2X4RNTQAYAVQS===',
          counter: 1361559856,
          length: 7,
          algo: OtpHashAlgorithm.sha1,
          code: '6719480',
        ),
        _HotpVector(
          secret: '77Q2NAND5QPHBVNL4PIA====',
          counter: 1226086109,
          length: 7,
          algo: OtpHashAlgorithm.sha256,
          code: '4997640',
        ),
        _HotpVector(
          secret: 'N7Z47XDROGLVEASLBXHTM4K7SNBT46IX22POM===',
          counter: 2022261377,
          length: 6,
          algo: OtpHashAlgorithm.sha1,
          code: '887864',
        ),
        _HotpVector(
          secret: 'F4G2PT4K5ONLYRKJIEKGQ4RDUNRXW===',
          counter: 4261956,
          length: 6,
          algo: OtpHashAlgorithm.sha256,
          code: '605455',
        ),
        _HotpVector(
          secret: '3CAWRHMKLCOMCBC6QPHQEHXIBRZEA6QJNH22M===',
          counter: 1854213223,
          length: 7,
          algo: OtpHashAlgorithm.sha256,
          code: '3130618',
        ),
        _HotpVector(
          secret: '24YAYOY5KHEZGPM2WTRC2PGJNZBESJY=',
          counter: 1090299761,
          length: 7,
          algo: OtpHashAlgorithm.sha512,
          code: '1919481',
        ),
        _HotpVector(
          secret: '6WDDQSBJCMP7MNQLMA======',
          counter: 97342768,
          length: 7,
          algo: OtpHashAlgorithm.sha256,
          code: '8235850',
        ),
      ];
      for (final c in cases) {
        expect(
          generateHOTPCodeString(
            secret: c.secret,
            counter: c.counter,
            length: c.length,
            algorithm: c.algo,
            isGoogle: c.isGoogle,
          ),
          c.code,
          reason: '${c.secret.substring(0, 8)}... counter=${c.counter}',
        );
      }
    });
  });

  group('RFC reference vectors (independent correctness anchor)', () {
    test(
      'RFC 4226 HOTP (secret "12345678901234567890", SHA1, isGoogle false)',
      () {
        const secret = '12345678901234567890';
        const expected = [
          '755224',
          '287082',
          '359152',
          '969429',
          '338314',
          '254676',
          '287922',
          '162583',
          '399871',
          '520489',
        ];
        for (var c = 0; c < expected.length; c++) {
          expect(
            generateHOTPCodeString(
              secret: secret,
              counter: c,
              length: 6,
              algorithm: OtpHashAlgorithm.sha1,
              isGoogle: false,
            ),
            expected[c],
            reason: 'counter=$c',
          );
        }
      },
    );

    test('RFC 6238 TOTP 8-digit vectors (isGoogle false)', () {
      const secretSha1 = '12345678901234567890';
      const secretSha256 = '12345678901234567890123456789012';
      const secretSha512 =
          '1234567890123456789012345678901234567890123456789012345678901234';
      final cases = <_TotpVector>[
        _TotpVector(
          secret: secretSha1,
          time: 59 * 1000,
          length: 8,
          interval: 30,
          algo: OtpHashAlgorithm.sha1,
          code: '94287082',
          isGoogle: false,
        ),
        _TotpVector(
          secret: secretSha256,
          time: 59 * 1000,
          length: 8,
          interval: 30,
          algo: OtpHashAlgorithm.sha256,
          code: '46119246',
          isGoogle: false,
        ),
        _TotpVector(
          secret: secretSha512,
          time: 59 * 1000,
          length: 8,
          interval: 30,
          algo: OtpHashAlgorithm.sha512,
          code: '90693936',
          isGoogle: false,
        ),
        _TotpVector(
          secret: secretSha1,
          time: 1111111109 * 1000,
          length: 8,
          interval: 30,
          algo: OtpHashAlgorithm.sha1,
          code: '07081804',
          isGoogle: false,
        ),
        _TotpVector(
          secret: secretSha1,
          time: 1111111111 * 1000,
          length: 8,
          interval: 30,
          algo: OtpHashAlgorithm.sha1,
          code: '14050471',
          isGoogle: false,
        ),
        _TotpVector(
          secret: secretSha1,
          time: 1234567890 * 1000,
          length: 8,
          interval: 30,
          algo: OtpHashAlgorithm.sha1,
          code: '89005924',
          isGoogle: false,
        ),
        _TotpVector(
          secret: secretSha1,
          time: 2000000000 * 1000,
          length: 8,
          interval: 30,
          algo: OtpHashAlgorithm.sha1,
          code: '69279037',
          isGoogle: false,
        ),
        _TotpVector(
          secret: secretSha1,
          time: 20000000000 * 1000,
          length: 8,
          interval: 30,
          algo: OtpHashAlgorithm.sha1,
          code: '65353130',
          isGoogle: false,
        ),
      ];
      for (final c in cases) {
        expect(
          generateTOTPCodeString(
            secret: c.secret,
            time: c.time,
            length: c.length,
            interval: c.interval,
            algorithm: c.algo,
            isGoogle: c.isGoogle,
          ),
          c.code,
          reason: 'time=${c.time} algo=${c.algo}',
        );
      }
    });
  });
}
