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

import 'dart:convert';

import 'package:http/http.dart';
import 'package:privacyidea_authenticator/model/enums/push_token_rollout_state.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/helpers/base32_helper.dart';

import '../../unit_test/model/fake_push_server.dart';
import 'fake_backend.dart';

export '../../unit_test/model/fake_push_server.dart';

/// Mounts a [FakePushServer] at [FakePushServer.url] of a [FakeBackend], the
/// way privacyIDEA serves `/ttype/push`: enrollment, polling and answers.
///
/// The fake server signs and verifies with real RSA keys, so an answer is
/// only accepted if the app signed exactly what the server expects.
class FakePushEndpoint {
  final FakePushServer server;
  final FakeBackend backend;

  /// The challenges handed out by polling until they are answered.
  final List<Map<String, dynamic>> _open = [];

  /// Every answer the server received and how it judged it.
  final List<(RecordedRequest, PushAnswerResult)> answers = [];

  /// Replaces the response to an answer, e.g. to simulate a server error.
  Response Function(RecordedRequest request, PushAnswerResult result)?
  answerResponse;

  FakePushEndpoint(this.server, this.backend) {
    final url = Uri.parse(FakePushServer.url);
    bool atEndpoint(RecordedRequest r) =>
        r.url.host == url.host && r.url.path == url.path;

    backend.on(
      (r) => r.isPost && atEndpoint(r) && r.data.containsKey('pubkey'),
      _enroll,
    );
    backend.on(
      (r) => r.isPost && atEndpoint(r) && r.data.containsKey('nonce'),
      _answer,
    );
    backend.on(
      (r) => r.isPost && atEndpoint(r) && r.data.containsKey('new_fb_token'),
      (_) => FakeBackend.json(true),
    );
    backend.on((r) => !r.isPost && atEndpoint(r), _poll);
  }

  /// A rolled out, poll only token as the app stores it after enrolling
  /// against this server.
  PushToken enrolledToken({String id = 'push-token-1', String? label}) =>
      enrollAgainst(server).copyWith(
        id: id,
        label: label ?? 'Push ${server.serial}',
        issuer: 'privacyIDEA',
        isRolledOut: true,
        rolloutState: PushTokenRollOutState.rolloutComplete,
        isPollOnly: () => true,
        fbToken: NoFirebaseUtils.NO_FIREBASE_TOKEN,
      );

  /// Queues a challenge the next poll hands out and returns its data.
  Map<String, dynamic> queueChallenge({
    String title = 'Login',
    String question = 'Do you want to login?',
    List<String>? requirePresence,
  }) {
    final data = server.createChallenge(
      title: title,
      question: question,
      requirePresence: requirePresence,
    );
    _open.add(data);
    return data;
  }

  /// Queues a code to phone challenge: the server shows nothing to type on the
  /// login screen but sends [displayCode] for the user to enter there. Signed
  /// over the sign string of PushCodeToPhoneRequest.signedData.
  Map<String, dynamic> queueCodeToPhoneChallenge({
    required String displayCode,
    String title = 'Login',
    String question = 'Enter this code on the login screen',
  }) {
    final nonce = 'code-to-phone-${_open.length}';
    final data = <String, dynamic>{
      'title': title,
      'question': question,
      'url': FakePushServer.url,
      'nonce': nonce,
      'sslverify': '1',
      'serial': server.serial,
      'display_code': displayCode,
    };
    data['signature'] = server.rsaUtils.createBase32Signature(
      server.keyPair.privateKey,
      utf8.encode(
        '$nonce|${FakePushServer.url}|${server.serial}|$question|$title|1'
        '|$displayCode',
      ),
    );
    _open.add(data);
    return data;
  }

  Response _enroll(RecordedRequest request) {
    try {
      final detail = server.enroll(request.data);
      return FakeBackend.json(true, detail: detail);
    } on ArgumentError catch (e) {
      return FakeBackend.error(905, '${e.message}');
    }
  }

  Response _answer(RecordedRequest request) {
    final result = server.handleAnswer({
      for (final entry in request.data.entries) entry.key: entry.value!,
    });
    answers.add((request, result));
    if (result.result) {
      _open.removeWhere((c) => c['nonce'] == request.data['nonce']);
    }
    final custom = answerResponse;
    if (custom != null) return custom(request, result);
    // privacyIDEA answers a rejected answer (bad signature, wrong presence
    // answer, unknown nonce) with HTTP 200 and result value false
    // (privacyidea/lib/tokens/pushtoken.py, api_endpoint -> prepare_result).
    return FakeBackend.json(result.result);
  }

  Response _poll(RecordedRequest request) {
    final serial = request.data['serial'];
    final timestamp = request.data['timestamp'];
    final signature = request.data['signature'];
    final key = server.smartphonePublicKey;
    if (serial != server.serial ||
        timestamp == null ||
        signature == null ||
        key == null ||
        !server.rsaUtils.verifyRSASignature(
          key,
          utf8.encode('$serial|$timestamp'),
          base32Decode(signature),
        )) {
      return FakeBackend.error(
        403,
        'Could not verify signature!',
        statusCode: 403,
      );
    }
    return FakeBackend.json(List.of(_open));
  }
}
