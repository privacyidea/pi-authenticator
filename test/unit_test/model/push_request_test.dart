import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';

import '../utils/identifiers_test.dart';

void main() {
  _testPushRequest();
}

void _testPushRequest() {
  group('Push Request', () {
    group('creation', () {
      test('constructor', () {
        // Arrange
        final request = PushRequest(
          title: 'title',
          question: 'question',
          uri: Uri.parse('https://example.com'),
          nonce: 'nonce',
          sslVerify: true,
          id: 1,
          expirationDate: DateTime.now(),
        );
        // Assert
        expect(request.title, 'title');
        expect(request.question, 'question');
        expect(request.uri, Uri.parse('https://example.com'));
        expect(request.nonce, 'nonce');
        expect(request.sslVerify, true);
        expect(request.id, 1);
        expect(request.expirationDate, isA<DateTime>());
        expect(request.serial, '');
        expect(request.signature, '');
        expect(request.accepted, null);
      });
      test('copyWith', () {
        final dateTimeAfter = DateTime.now().add(const Duration(days: 1));
        // Arrange
        final request = PushRequest(
          title: 'title',
          question: 'question',
          uri: Uri.parse('https://example.com'),
          nonce: 'nonce',
          sslVerify: true,
          id: 1,
          expirationDate: DateTime.now(),
        );
        // Act
        final copy = request.copyWith(
          title: 'new title',
          question: 'new question',
          uri: Uri.parse('https://new.example.com'),
          nonce: 'new nonce',
          sslVerify: false,
          id: 2,
          expirationDate: dateTimeAfter,
          serial: 'serial',
          signature: 'signature',
          accepted: true,
        );
        // Assert
        expect(copy.title, 'new title');
        expect(copy.question, 'new question');
        expect(copy.uri, Uri.parse('https://new.example.com'));
        expect(copy.nonce, 'new nonce');
        expect(copy.sslVerify, false);
        expect(copy.id, 2);
        expect(copy.expirationDate, equals(dateTimeAfter));
        expect(copy.serial, 'serial');
        expect(copy.signature, 'signature');
        expect(copy.accepted, true);
      });
      test('fromMessageData', () {
        // Arrange
        final data = <String, dynamic>{
          PUSH_REQUEST_TITLE: 'title',
          PUSH_REQUEST_QUESTION: 'question',
          PUSH_REQUEST_URL: 'https://example.com',
          PUSH_REQUEST_NONCE: 'nonce',
          PUSH_REQUEST_SSL_VERIFY: '1',
          PUSH_REQUEST_SERIAL: 'serial',
          PUSH_REQUEST_SIGNATURE: 'signature',
        };
        // Act
        final request = PushRequest.fromMessageData(data);
        // Assert
        expect(request.title, 'title');
        expect(request.question, 'question');
        expect(request.uri, Uri.parse('https://example.com'));
        expect(request.nonce, 'nonce');
        expect(request.sslVerify, true);
        expect(request.id, 'nonce'.hashCode);
        expect(request.serial, 'serial');
        expect(request.signature, 'signature');
      });
    });
    group('serilization', () {
      test('toJson', () {
        // Arrange
        final request = PushRequest(
          title: 'title',
          question: 'question',
          uri: Uri.parse('https://example.com'),
          nonce: 'nonce',
          sslVerify: true,
          id: 1,
          expirationDate: DateTime.now(),
          serial: 'serial',
          signature: 'signature',
          accepted: true,
        );
        // Act
        final json = request.toJson();
        // Assert
        expect(json['title'], 'title');
        expect(json['question'], 'question');
        expect(json['uri'], 'https://example.com');
        expect(json['nonce'], 'nonce');
        expect(json['sslVerify'], true);
        expect(json['id'], 1);
        expect(json['expirationDate'], isA<String>());
        expect(json['serial'], 'serial');
        expect(json['signature'], 'signature');
        expect(json['accepted'], true);
      });

      test('fromJson', () {
        // Arrange
        final json = <String, dynamic>{
          'title': 'title',
          'question': 'question',
          'uri': 'https://example.com',
          'nonce': 'nonce',
          'sslVerify': true,
          'id': 1,
          'expirationDate': DateTime.now().toIso8601String(),
          'serial': 'serial',
          'signature': 'signature',
          'accepted': true,
        };
        // Act
        final request = PushRequest.fromJson(json);
        // Assert
        expect(request.title, 'title');
        expect(request.question, 'question');
        expect(request.uri, Uri.parse('https://example.com'));
        expect(request.nonce, 'nonce');
        expect(request.sslVerify, true);
        expect(request.id, 1);
        expect(request.expirationDate, isA<DateTime>());
        expect(request.serial, 'serial');
        expect(request.signature, 'signature');
        expect(request.accepted, true);
      });
    });

    test('verifyData', () {
      // Arrange
      final data = <String, dynamic>{
        PUSH_REQUEST_TITLE: 'title',
        PUSH_REQUEST_QUESTION: 'question',
        PUSH_REQUEST_URL: 'https://example.com',
        PUSH_REQUEST_NONCE: 'nonce',
        PUSH_REQUEST_SSL_VERIFY: '1',
        PUSH_REQUEST_SERIAL: 'serial',
        PUSH_REQUEST_SIGNATURE: 'signature',
      };
      // Assert
      expect(() => PushRequest.verifyData(data), returnsNormally);
    });

    test('verifySignature true', () async {
      // Arrange
      final token = PushToken.fromJson(const {
        "label": "PIPU00064CF0",
        "issuer": "privacyIDEA",
        "id": "94a40d5a-1dba-4985-95ce-5ce9bb36d32a",
        "pin": false,
        "isLocked": false,
        "isHidden": false,
        "tokenImage": "",
        "folderId": null,
        "sortIndex": 2,
        "origin": {
          "source": "qrScan",
          "appName": "privacyIDEA Authenticator",
          "data":
              "otpauth://pipush/PIPU00064CF0?url=https%3A//192.168.56.103/ttype/push&ttl=10&issuer=privacyIDEA&enrollment_credential=9d3100908d3c76a948b6041c8338def8b15ec06a&v=1&serial=PIPU00064CF0&sslverify=0",
          "isPrivacyIdeaToken": null,
          "createdAt": "2024-04-11T15:19:53.567296",
          "piServerVersion": null
        },
        "type": "PIPUSH",
        "expirationDate": "2024-04-11T15:29:53.562967",
        "serial": "PIPU00064CF0",
        "fbToken":
            "ffhpC7m3R7GEsTimtuA7u1:APA91bF3KB7MD2HEuS3bEB2XrLApgD7XksB1tcaDvA8HReQyFLCF7rI2U8i57dVkfqIAEmBDPYqzszkKD3lGKk6ihEgyCJzk4NC2tCetN3li-p7sRRbnePm34xxK5Se72rl9CKtMZsKX",
        "sslVerify": false,
        "enrollmentCredentials": "9d3100908d3c76a948b6041c8338def8b15ec06a",
        "url": "https://192.168.2.169/ttype/push",
        "isRolledOut": true,
        "rolloutState": "rolloutComplete",
        "publicServerKey":
            "MIICCgKCAgEA6u3K9x1poOy8upX7WjWldNdV883T+XQTxCIlqdFod3xA7uyA3tdnI+ahPB/ZSeTrCh4jzJjw9kSCN77I0c6TgyfeXHDQJu5nZ8eSbChnrLNGxaxf24LY7RukLEBdumeHbbuc3EozRCdTMDPEYnWH/ct3zMBuIBk22gIuxS979Htcc1SgmKBfiEOVG5D7/qTvg3/EttazoIfQUllY6vWLk3vdGurXj9CD9UVc5qhYI54dLSKnR0KXjXsQ1GwBivf1BFeR/NkaSsTGxDvucJdJDI9d7aWfNXQaYln6SyuSJN8FYEmfhldQyU2dgi7jfToLO5GZPdzJhWKaUG0HqCv0cYLC1fP72+KR8DVUU4yAU/npR9inwBPnqmCxE+pt6WZeLWIhk3B34WUkKsQ0MRxyds1aNP5AACQATDYmRRu05nYD/kLM9aw03dmxwOUGkIVlLkm5quucvWJ6GGfrkG0G+lq0RjG3Ra8tPda8P4wq7MZ6J1HCrtiXFeniShPZwH/jhiHzqjfHb6AEHVyv56Ycx941KXRv6LaH3LHHhiMapY0NbKdid0WFBqutFUvBVoaT0ma3gKMMbGw9zCi5PdVHk9WyhMF7IvmcTuAuFL1xc25dc7kYrp+jrKVlJdiTD9vEOODI3ZxVdbTlGI6HH3NejlQvVd0S30vNu0sMZ55k9TECAwEAAQ==",
        "privateTokenKey":
            "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",
        "publicTokenKey":
            "MIICCgKCAgEAitdUL+H0M+hIddD+2cXJ58sB77TkygmmiNft1o0gIx/1jlYk9tpy05TRuKzZT7A5qQLfwIb8qYoibvrn2qG3Vx1xM9X45NkyqnktReA8d/E7W9+WdN8x7hCLGROTI9y8cEUqJV/l4O4JcAM4CN9sn2KLBVxDkzfUyBTNNgU6v2rWonCJGSYuiWdVGwrcM6bxwHSMgIvZLdMSl7nPl0VHan+CtFarikuIN4J6YES00musVO4Ss6/nb4Z28umyGyGGXGv/nV5hABPipyDmLGxTChLn0lDYvTDhKgiQYwf+6bwnXmGUPPlUGHnlRQ0xnPt1BSHBtDnEVKkLXy8rJ1nMoBc7/tHZl7gMIPET4/WFi4/9unopLkObWZs6p+8mssC9HlbFNteMkkegc5uha5chxA/jxjRgbdEQNi9kr3Y46qJMZ+tSbioOXmCXYm9DdJGfjyAU78LJUGle1xEfiQDX6Egr6PvCyvhU2QW9aBJFKzDbEitp4cVLQ3Jz0X/yLrigLe+dVis3U3DcCe3l0dFcI6yAsVx1RG6DtgO9Wr2vzO/u8JUARYoVWroNGBg+Xr3Il0nloVsnJD7l+7vh/5JZmObWz0bTOHwZhqgagB+h/Y5ill9zqqMWIGSuuJx4tGN4iBITNM/wy8bzZc2LLzSNDsuWSBlcchF/2Ko5qz4uw3MCAwEAAQ=="
      });

      final request = PushRequest.fromJson({
        "title": "privacyIDEA",
        "question": "Do you want to confirm the login?",
        "id": 134382661,
        "uri": "https://192.168.56.103/ttype/push",
        "nonce": "DIHEUYEDNJ6AC5FSGM7T3OTHTD6T5NK4",
        "sslVerify": false,
        "expirationDate": "2024-04-11T15:52:00.136352",
        "serial": "PIPU00064CF0",
        "signature":
            "LNIZZSTEFVECXOFBHT4ANPLJXXUJA2S7CQ6S52KMWGE22LUBMWMZSF6BSQHV3NAI2RTHVUVFAPYALQ3A4W3Z4H7S26QZPRSEVHT4EMX2JPJOWNH5A6SSXLLPQJAZ3MDMKKXYSJOU27KHHHL56YQNKHOJQZPH5TPLFC6NPMQ4IGZB6TX4MLA2PIHZGGHIJM2TOXE4NFWNLDR5YKQ6JH7WO4G24VCACK7KKQRTZYXZFMSYAMO4ERBAYYQDS7SL6Y7CDKA4MBKSR2BKGYUVTR5AZUNVNHFWO7KPF3Y2THIXOSSMQ7VHHDCUQN6NGV63A27V7IX4EP6JRIDMHNOVEAVEIPFHKK55QCBFX2Y6HO4EZBP2X3ZXI5NEI7FO3CJ2VIC4ZFXOT4HKYTZRGTENAMLTAP56XCTDSKPNEUSZZMO6UQCCWGTQ5QTST47OIML4BLZJQOESXJ3OVUUWCZHCS6V46OMIRAQDIGRHGS7KQY7ZY4MKRRW4RDW7J4IYQ3EZWP777IKZCFNMQ6WV2KDA6W7T6O7VJB5NQ7VFQ3JGYPR6STX52H2RIEFKMNLMNW7UFDPZWDVCRLHI7FHOROHSKOECEC3T3LP7GLBZHHTGX46DGCOETLLEF67HU62DZHAUCOUPWHF6TY7KKKTQ3XNMDF5H4TWO7C5JTL46QC4PYFFOUDEUULTY2DVJBCMIXXF63PZ4YGAYFU4BPW3LTMBTM3PT6YBNJ6EQFUBR6N3KYAAUENZQBK3J5VZS6UWEBFL33AW3AFVV6TMVZQU4UJOJMSPL7T46F2VRRS27TA4FFE4JA5O6AVNETRYA====",
        "accepted": null
      });

      final success = await request.verifySignature(token);
      // Assert
      expect(success, true);
    });
    test('verifySignature false', () async {
      // Arrange
      final token = PushToken.fromJson(const {
        "label": "PIPU00064CF0",
        "issuer": "privacyIDEA",
        "id": "94a40d5a-1dba-4985-95ce-5ce9bb36d32a",
        "pin": false,
        "isLocked": false,
        "isHidden": false,
        "tokenImage": "",
        "folderId": null,
        "sortIndex": 2,
        "origin": {
          "source": "qrScan",
          "appName": "privacyIDEA Authenticator",
          "data":
              "otpauth://pipush/PIPU00064CF0?url=https%3A//192.168.56.103/ttype/push&ttl=10&issuer=privacyIDEA&enrollment_credential=9d3100908d3c76a948b6041c8338def8b15ec06a&v=1&serial=PIPU00064CF0&sslverify=0",
          "isPrivacyIdeaToken": null,
          "createdAt": "2024-04-11T15:19:53.567296",
          "piServerVersion": null
        },
        "type": "PIPUSH",
        "expirationDate": "2024-04-11T15:29:53.562967",
        "serial": "FALSCHER SERIAL",
        "fbToken":
            "ffhpC7m3R7GEsTimtuA7u1:APA91bF3KB7MD2HEuS3bEB2XrLApgD7XksB1tcaDvA8HReQyFLCF7rI2U8i57dVkfqIAEmBDPYqzszkKD3lGKk6ihEgyCJzk4NC2tCetN3li-p7sRRbnePm34xxK5Se72rl9CKtMZsKX",
        "sslVerify": false,
        "enrollmentCredentials": "9d3100908d3c76a948b6041c8338def8b15ec06a",
        "url": "https://192.168.2.169/ttype/push",
        "isRolledOut": true,
        "rolloutState": "rolloutComplete",
        "publicServerKey":
            "MIICCgKCAgEA6u3K9x1poOy8upX7WjWldNdV883T+XQTxCIlqdFod3xA7uyA3tdnI+ahPB/ZSeTrCh4jzJjw9kSCN77I0c6TgyfeXHDQJu5nZ8eSbChnrLNGxaxf24LY7RukLEBdumeHbbuc3EozRCdTMDPEYnWH/ct3zMBuIBk22gIuxS979Htcc1SgmKBfiEOVG5D7/qTvg3/EttazoIfQUllY6vWLk3vdGurXj9CD9UVc5qhYI54dLSKnR0KXjXsQ1GwBivf1BFeR/NkaSsTGxDvucJdJDI9d7aWfNXQaYln6SyuSJN8FYEmfhldQyU2dgi7jfToLO5GZPdzJhWKaUG0HqCv0cYLC1fP72+KR8DVUU4yAU/npR9inwBPnqmCxE+pt6WZeLWIhk3B34WUkKsQ0MRxyds1aNP5AACQATDYmRRu05nYD/kLM9aw03dmxwOUGkIVlLkm5quucvWJ6GGfrkG0G+lq0RjG3Ra8tPda8P4wq7MZ6J1HCrtiXFeniShPZwH/jhiHzqjfHb6AEHVyv56Ycx941KXRv6LaH3LHHhiMapY0NbKdid0WFBqutFUvBVoaT0ma3gKMMbGw9zCi5PdVHk9WyhMF7IvmcTuAuFL1xc25dc7kYrp+jrKVlJdiTD9vEOODI3ZxVdbTlGI6HH3NejlQvVd0S30vNu0sMZ55k9TECAwEAAQ==",
        "privateTokenKey":
            "MIILKgIBAAKCAgEAitdUL+H0M+hIddD+2cXJ58sB77TkygmmiNft1o0gIx/1jlYk9tpy05TRuKzZT7A5qQLfwIb8qYoibvrn2qG3Vx1xM9X45NkyqnktReA8d/E7W9+WdN8x7hCLGROTI9y8cEUqJV/l4O4JcAM4CN9sn2KLBVxDkzfUyBTNNgU6v2rWonCJGSYuiWdVGwrcM6bxwHSMgIvZLdMSl7nPl0VHan+CtFarikuIN4J6YES00musVO4Ss6/nb4Z28umyGyGGXGv/nV5hABPipyDmLGxTChLn0lDYvTDhKgiQYwf+6bwnXmGUPPlUGHnlRQ0xnPt1BSHBtDnEVKkLXy8rJ1nMoBc7/tHZl7gMIPET4/WFi4/9unopLkObWZs6p+8mssC9HlbFNteMkkegc5uha5chxA/jxjRgbdEQNi9kr3Y46qJMZ+tSbioOXmCXYm9DdJGfjyAU78LJUGle1xEfiQDX6Egr6PvCyvhU2QW9aBJFKzDbEitp4cVLQ3Jz0X/yLrigLe+dVis3U3DcCe3l0dFcI6yAsVx1RG6DtgO9Wr2vzO/u8JUARYoVWroNGBg+Xr3Il0nloVsnJD7l+7vh/5JZmObWz0bTOHwZhqgagB+h/Y5ill9zqqMWIGSuuJx4tGN4iBITNM/wy8bzZc2LLzSNDsuWSBlcchF/2Ko5qz4uw3MCggIBAIeCxUN62Rt0ooyDcMpilr8qz/gC6a8cHjO/9P4MfgpqXgQPpkJdUeeaf9sssWlqycxg5ryFw8NB9Hu3XmZwon5fWSbLuAK8zwu9++cQhlRW2aXBI5tsYNJHyUuvZFSDVFSL3SffYoHYMtPmAGIAl4c06hVQSRA+VOr4CpaoIf/EKjsfdWBbeN5ZQaKERgoP7jL2TlAErvNf6Oy3yZqOXrbeP1b+pKz1Lb1oF0MwrAAYYXn/Z7eDf3LFngFXAKQkY3x/WFxjSm+F+RlALge7rozNiQAoMnLta0bYVvyhSDcfkpk2yjV88Ix3JMPxrbPXZg6dNO9P1oT+/P9pDUh6CBHU7CPBQIl+FkcEhVErqMXHkedfApjFNvejkEoyBdehojDTdP8t1Xk7T9IEoXvF1DB5H2TpiJlhe3IDSZ0k+S76OweJmxq3mjpfpo+W8ECML/Pl3eZPZ9qkwJlbEkC5EGfaJg00N6eqJQcBSkCwURhY3b2ynN0Jcs1ede/Xx+Jf6DTbop9S5bW9/E0epbNBWLFPIr3YAZ2t45sJ1tjj/FzdBYxDA4Dznu6k5fuxg/ps3PcoyJ7kmMDjc0WSDFrTVdY4DqJhy0fyJIlpaibXZU76z8H6rg0y7EPnOLw26aIPSw8qdKcUvIKVtls/pJXNNjsXmlZp5xVRDPSdxCLY80sRAoICAQCHgsVDetkbdKKMg3DKYpa/Ks/4AumvHB4zv/T+DH4Kal4ED6ZCXVHnmn/bLLFpasnMYOa8hcPDQfR7t15mcKJ+X1kmy7gCvM8LvfvnEIZUVtmlwSObbGDSR8lLr2RUg1RUi90n32KB2DLT5gBiAJeHNOoVUEkQPlTq+AqWqCH/xCo7H3VgW3jeWUGihEYKD+4y9k5QBK7zX+jst8majl623j9W/qSs9S29aBdDMKwAGGF5/2e3g39yxZ4BVwCkJGN8f1hcY0pvhfkZQC4Hu66MzYkAKDJy7WtG2Fb8oUg3H5KZNso1fPCMdyTD8a2z12YOnTTvT9aE/vz/aQ1IeggR1OwjwUCJfhZHBIVRK6jFx5HnXwKYxTb3o5BKMgXXoaIw03T/LdV5O0/SBKF7xdQweR9k6YiZYXtyA0mdJPku+jsHiZsat5o6X6aPlvBAjC/z5d3mT2fapMCZWxJAuRBn2iYNNDenqiUHAUpAsFEYWN29spzdCXLNXnXv18fiX+g026KfUuW1vfxNHqWzQVixTyK92AGdreObCdbY4/xc3QWMQwOA857upOX7sYP6bNz3KMie5JjA43NFkgxa01XWOA6iYctH8iSJaWom12VO+s/B+q4NMuxD5zi8NumiD0sPKnSnFLyClbZbP6SVzTY7F5pWaecVUQz0ncQi2PNLEQKCAQEA/G9PEH0qrMia7UvI4CRgW0KLMHFPKulzmD8DLJFuLbFDg/d+9v/jBVA13ZrFW1rAOEh8Oz7T2ujQwFw0RGkewYqaWsTI5jYB9ddEKfN3TPb2BHA1wxXSvlrR6T1Fp88aT9KFXDPlHur/q9qBCvkvP7n/1rd6Okx1wsy/zloJKrkyjTPNXjFC8zpGQurRo1t1tkcoOl7fLE2E8qC7I7XtNtZv3Wk0AISlWXDDw3UvRy+jV7ieclKKwaCxMHyAZJ0Op1xS1q/wG24ymafb8d0+h+4vd2iE7F0Kj7EQchwWBHhNnsnG1EtTVB8n0bP8U/T4Hc5D4q16jT71Zg23U5xEyQKCAQEAjM1Q8SBBCpu7N3f1jhoQav+Fty+tiLu1W+JGUbaUWBhDg5zsz47B6gJKCw/llDKqJ+pAgyUKJYU+3Z59UkaxkN+Se1fXxRJx4p3EOTfuI17RQFxADg9x6kkLovwXC9oG/r216kqoMT4j+YM56Vt4T2FgY1vRiifPhKHByol8bj8jnXRhZrg4Iz0ANIhMYZVEJABnjkjplLtPCpzayl6Y/J98y/herty0e0hhkouDDLO2IhlSZ3L56tFkSAQTdgNrquv7fmo8DJbe9emCYdIGIbHUEobSzO7rXu6F2yrGhn1xZfjnR58eJGwkL4aKdUFZEmHy1cvm3Ou+FkqlqkfQWwKCAQEA7clUKu4c0uGsvrbSpADgG1cVki5KKtv5nYJN1R+xL615MchjevwTt5+U/giau7FCvEHbdFt8aQtCCNFSEtcKt7l+KN6Rd/mL4y5B8Vp8GK3RlOC2Y+wctl8KuLCU+rvlxydBpFbmDzfCWvna8KFF1ru4uWPf6Sa5DySb0R+S3wHREp2naIDy1fcg1Ewp6b1vpqJkzIctpqfnAj5RyhPHPg7FFUXSTGKm9xd38JhkTqQbM7ie2IXUWwypnEjLEPu5IAGhrsXQYaZuV7t9Pdnw206Mu+hivdvu5Ogf272FJ/TC+T6M4tGJzwYCFlF68QMi7cCsxcwwUvjpZJarCEF9sQKCAQBex8b4ydF+pp48FJBDe+AZZrBIQ9v48wJ+O69CSjlJo+uuqO/wOBToxWm6UJUmUYShIdsTbNeLskpDPPD3dYcKErW0OcmRa30mIzV3nuK7BJSvUmn8DQGNyGYA7NlGrRmQWXwfnunhXAczataM83nlVZNgzuoaqfnTOmANSsdsHyyGTVVTpCaF8gY1Vpq0BZq88VjEOuihqgTnC/dryooJZALJ+wMhiogjhPHJiAhLgJ3WDl2eLZN2MkXjBHtlMaBEil3dFv4dK2Ii/3E5D/v4qpAreH5mXV4rpTyN8Bl7Zu3yyr5FRCMyOWmSZGrHy5l9+llQ+dUKWda3gsBKA9WJAoIBAQC+3ybL8bHxhM4FqXVxEBMxsavxsdEBHvUSqi6D8wSLpwnKhP+487ZaRw0Ez0hcbQjXzitbKGHpFKZccN+e1vVBsGra0uZHo8GV0AERTTOZs9pHNjYva8dJ4Kg+G1qT5xqM3c4kWa9w44ExgS8lVcKlXrestO30HLXRZOgf8wmaCy5ybvVqRlARgUcUPMltPdevOMfJnFXO6YmcqRV1ugCauCqPydp6TC1cy1uanVs3K6H/D2jB2JLTdLQUtrwugHVR1GMhyeiPpstdxmrWVfZNPfUF7WRq5KXloAiC7XHIl0frO+KM7D6lXxQYxSwS1lTnXLwuvQ9yQLZOeCcwkjD0",
        "publicTokenKey":
            "MIICCgKCAgEAitdUL+H0M+hIddD+2cXJ58sB77TkygmmiNft1o0gIx/1jlYk9tpy05TRuKzZT7A5qQLfwIb8qYoibvrn2qG3Vx1xM9X45NkyqnktReA8d/E7W9+WdN8x7hCLGROTI9y8cEUqJV/l4O4JcAM4CN9sn2KLBVxDkzfUyBTNNgU6v2rWonCJGSYuiWdVGwrcM6bxwHSMgIvZLdMSl7nPl0VHan+CtFarikuIN4J6YES00musVO4Ss6/nb4Z28umyGyGGXGv/nV5hABPipyDmLGxTChLn0lDYvTDhKgiQYwf+6bwnXmGUPPlUGHnlRQ0xnPt1BSHBtDnEVKkLXy8rJ1nMoBc7/tHZl7gMIPET4/WFi4/9unopLkObWZs6p+8mssC9HlbFNteMkkegc5uha5chxA/jxjRgbdEQNi9kr3Y46qJMZ+tSbioOXmCXYm9DdJGfjyAU78LJUGle1xEfiQDX6Egr6PvCyvhU2QW9aBJFKzDbEitp4cVLQ3Jz0X/yLrigLe+dVis3U3DcCe3l0dFcI6yAsVx1RG6DtgO9Wr2vzO/u8JUARYoVWroNGBg+Xr3Il0nloVsnJD7l+7vh/5JZmObWz0bTOHwZhqgagB+h/Y5ill9zqqMWIGSuuJx4tGN4iBITNM/wy8bzZc2LLzSNDsuWSBlcchF/2Ko5qz4uw3MCAwEAAQ=="
      });

      final request = PushRequest.fromJson({
        "title": "privacyIDEA",
        "question": "Do you want to confirm the login?",
        "id": 134382661,
        "uri": "https://192.168.56.103/ttype/push",
        "nonce": "DIHEUYEDNJ6AC5FSGM7T3OTHTD6T5NK4",
        "sslVerify": false,
        "expirationDate": "2024-04-11T15:52:00.136352",
        "serial": "FALSCHER SERIAL",
        "signature":
            "LNIZZSTEFVECXOFBHT4ANPLJXXUJA2S7CQ6S52KMWGE22LUBMWMZSF6BSQHV3NAI2RTHVUVFAPYALQ3A4W3Z4H7S26QZPRSEVHT4EMX2JPJOWNH5A6SSXLLPQJAZ3MDMKKXYSJOU27KHHHL56YQNKHOJQZPH5TPLFC6NPMQ4IGZB6TX4MLA2PIHZGGHIJM2TOXE4NFWNLDR5YKQ6JH7WO4G24VCACK7KKQRTZYXZFMSYAMO4ERBAYYQDS7SL6Y7CDKA4MBKSR2BKGYUVTR5AZUNVNHFWO7KPF3Y2THIXOSSMQ7VHHDCUQN6NGV63A27V7IX4EP6JRIDMHNOVEAVEIPFHKK55QCBFX2Y6HO4EZBP2X3ZXI5NEI7FO3CJ2VIC4ZFXOT4HKYTZRGTENAMLTAP56XCTDSKPNEUSZZMO6UQCCWGTQ5QTST47OIML4BLZJQOESXJ3OVUUWCZHCS6V46OMIRAQDIGRHGS7KQY7ZY4MKRRW4RDW7J4IYQ3EZWP777IKZCFNMQ6WV2KDA6W7T6O7VJB5NQ7VFQ3JGYPR6STX52H2RIEFKMNLMNW7UFDPZWDVCRLHI7FHOROHSKOECEC3T3LP7GLBZHHTGX46DGCOETLLEF67HU62DZHAUCOUPWHF6TY7KKKTQ3XNMDF5H4TWO7C5JTL46QC4PYFFOUDEUULTY2DVJBCMIXXF63PZ4YGAYFU4BPW3LTMBTM3PT6YBNJ6EQFUBR6N3KYAAUENZQBK3J5VZS6UWEBFL33AW3AFVV6TMVZQU4UJOJMSPL7T46F2VRRS27TA4FFE4JA5O6AVNETRYA====",
        "accepted": null
      });

      final success = await request.verifySignature(token);
      // Assert
      expect(success, false);
    });
  });
}
