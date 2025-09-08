/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

import 'package:http/http.dart';
import 'package:mutex/mutex.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../../interfaces/repo/push_request_repository.dart';
import '../../../../../../../utils/rsa_utils.dart';
import '../../../../model/push_request.dart';
import '../../../../model/riverpod_states/push_request_state.dart';
import '../../../../model/tokens/push_token.dart';
import '../../../../repo/secure_push_request_repository.dart';
import '../../../http_status_checker.dart';
import '../../../logger.dart';
import '../../../privacyidea_io_client.dart';
import '../../../push_provider.dart';
import '../../../utils.dart';
import '../state_providers/status_message_provider.dart';

part 'push_request_provider.g.dart';

final pushRequestProvider = pushRequestNotifierProviderOf(
  rsaUtils: const RsaUtils(),
  ioClient: const PrivacyideaIOClient(),
  pushProvider: PushProvider(),
  pushRepo: SecurePushRequestRepository(),
);

@Riverpod(keepAlive: true)
class PushRequestNotifier extends _$PushRequestNotifier {
  final loadingRepoMutex = Mutex();
  final updatingRequestMutex = Mutex();

  final Map<String, Timer> _expirationTimers = {};

  @override
  RsaUtils get rsaUtils => _rsaUtils;
  final RsaUtils? _rsaUtilsOverride;
  late final RsaUtils _rsaUtils;

  @override
  PrivacyideaIOClient get ioClient => _ioClient;
  final PrivacyideaIOClient? _ioClientOverride;
  late final PrivacyideaIOClient _ioClient;

  @override
  PushProvider get pushProvider => _pushProvider;
  final PushProvider? _pushProviderOverride;
  late final PushProvider _pushProvider;

  @override
  PushRequestRepository get pushRepo => _pushRepo;
  final PushRequestRepository? _pushRepoOverride;
  late final PushRequestRepository _pushRepo;

  PushRequestNotifier({
    RsaUtils? rsaUtilsOverride,
    PrivacyideaIOClient? ioClientOverride,
    PushProvider? pushProviderOverride,
    PushRequestRepository? pushRepoOverride,
  })  : _pushProviderOverride = pushProviderOverride,
        _rsaUtilsOverride = rsaUtilsOverride,
        _ioClientOverride = ioClientOverride,
        _pushRepoOverride = pushRepoOverride;

  @override
  Future<PushRequestState> build({
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required PushProvider pushProvider,
    required PushRequestRepository pushRepo,
  }) async {
    _rsaUtils = _rsaUtilsOverride ?? rsaUtils;
    _ioClient = _ioClientOverride ?? ioClient;
    _pushProvider = _pushProviderOverride ?? pushProvider;
    _pushRepo = _pushRepoOverride ?? pushRepo;

    Logger.info('New PushRequestNotifier created');
    _pushProvider.subscribe(add);
    return _loadFromRepo();
  }

  void swapPushProvider(PushProvider newProvider) {
    _pushProvider.unsubscribe(add);
    _pushProvider = newProvider;
    _pushProvider.subscribe(add);
  }

  /*
  /////////////////////////////////////////////////////////////////////////////
  //////////////////// Repository and PushRequest Handling ////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /// Repository layer is always use loadingRepoMutex for the latest state
  */

  Future<PushRequestState> _loadFromRepo() async {
    await loadingRepoMutex.acquire();
    final PushRequestState loadedState;
    try {
      loadedState = await _pushRepo.loadState();
    } catch (e) {
      Logger.error('Failed to load push request state from repo.', error: e);
      loadingRepoMutex.release();
      return (await future);
    }
    _renewTimers(loadedState.pushRequests);
    state = AsyncValue.data(loadedState);
    loadingRepoMutex.release();
    return loadedState;
  }

  /// Adds a PushRequest to repo and state. Returns true if successful, false if not.
  /// If the request already exists, it will be replaced.
  Future<bool> _addOrReplacePushRequest(PushRequest pushRequest) async {
    await loadingRepoMutex.acquire();
    final oldState = (await future);
    final newState = oldState.addOrReplace(pushRequest);
    try {
      await _pushRepo.saveState(newState);
    } catch (e) {
      Logger.warning(
        'Failed to save push request: $pushRequest',
        error: e,
      );
      loadingRepoMutex.release();
      return false;
    }
    state = AsyncValue.data(newState);
    loadingRepoMutex.release();
    return true;
  }

  /// Replaces a PushRequest in repo and state. Returns true if successful, false if not.
  Future<bool> _replacePushRequest(PushRequest pushRequest) async {
    await loadingRepoMutex.acquire();
    final oldState = (await future);
    final (newState, replaced) = oldState.replaceRequest(pushRequest);
    if (!replaced) {
      Logger.warning(
        'Tried to replace a push request that does not exist.',
      );
      loadingRepoMutex.release();
      return false;
    }
    try {
      await _pushRepo.saveState(newState);
    } catch (e) {
      Logger.warning(
        'Failed to save push request: $pushRequest',
        error: e,
      );
      loadingRepoMutex.release();
      return false;
    }
    state = AsyncValue.data(newState);
    loadingRepoMutex.release();
    return true;
  }

  /// Removes a PushRequest from repo and state. Returns true if successful, false if not.
  Future<bool> _remove(PushRequest pushRequest) async {
    _cancelTimer(pushRequest);
    await loadingRepoMutex.acquire();
    final newState = (await future).withoutRequest(pushRequest);
    try {
      await _pushRepo.saveState(newState);
    } catch (e) {
      Logger.error(
        'Failed to save push request state after removing push request.',
        error: e,
      );
      loadingRepoMutex.release();
      _setupTimer(pushRequest);
      return false;
    }
    state = AsyncValue.data(newState);
    loadingRepoMutex.release();
    return true;
  }
  /*
  //////////////////////////////////////////////////////////////////////////////
  ////////////////////// Update PushRequest Methods ////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  /// Updating layer is always use updatingRequestMutex for the latest state
  */

  /// Updates a PushRequest of the current state. The updated PushRequest is saved to the repo and the state. Returns the updated PushRequest if successful, null if not.
  Future<PushRequest?> _updatePushRequest(PushRequest pushRequest, Future<PushRequest> Function(PushRequest) updater) async {
    await updatingRequestMutex.acquire();
    final current = (await future).currentOf(pushRequest);
    if (current == null) {
      Logger.warning('Tried to update a push request that does not exist.');
      updatingRequestMutex.release();
      return null;
    }
    final updated = await updater(current);
    final replaced = await _replacePushRequest(updated);
    updatingRequestMutex.release();
    return replaced ? updated : current;
  }

  /*
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////// Public Methods //////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  /// There is no need to use mutexes because the updating functions are always using the latest version of the updating tokens.
  */

  Future<void> pollForChallenges({required bool isManually}) => pushProvider.pollForChallenges(isManually: isManually);

  Future<PushRequestState> loadStateFromRepo() => _loadFromRepo();

  /// Accepts a push request and returns true if successful, false if not.
  /// An accepted push request is removed from the state.
  /// It should be still in the CustomIntBuffer of the state.
  Future<bool> accept(PushToken pushToken, PushRequest pushRequest, {String? selectedAnswer}) async {
    if (pushRequest.accepted != null) {
      Logger.warning('The push request is already accepted or declined.');

      return false;
    }
    Logger.info('Accept push request.');
    final updated = await _updatePushRequest(pushRequest, (p0) async {
      final updated = p0.copyWith(accepted: true, selectedAnswer: () => selectedAnswer);
      final success = await _handleReaction(pushRequest: updated, token: pushToken);
      if (!success) {
        Logger.warning('Failed to handle push request reaction.');
        return p0;
      }
      return updated;
    });
    if (updated == null || updated.accepted != true) {
      Logger.warning('Failed to accept push request.');
      return false;
    }
    await _remove(updated);
    return true;
  }

  Future<bool> decline(PushToken pushToken, PushRequest pushRequest) async {
    if (pushRequest.accepted != null) {
      Logger.warning('The push request is already accepted or declined.');
      return false;
    }
    Logger.info('Decline push request.');
    final updated = await _updatePushRequest(pushRequest, (p0) async {
      final updated = p0.copyWith(accepted: false, selectedAnswer: () => null);
      final success = await _handleReaction(pushRequest: updated, token: pushToken);
      if (!success) {
        Logger.warning('Failed to handle push request reaction.');
        return p0;
      }
      return updated;
    });
    if (updated == null || updated.accepted != false) {
      Logger.warning('Failed to decline push request.');
      return false;
    }
    await _remove(updated);
    return true;
  }

  Future<bool> add(PushRequest pr) async {
    if ((await future).knowsRequestId(pr.id)) {
      Logger.info(
        'The push request already exists.',
      );
      return false;
    }
    // Save the pending request.
    final success = await _addOrReplacePushRequest(pr);

    // Remove the request after it expires.
    if (success) _setupTimer(pr);
    Logger.info('Added push request ${pr.id} to state');
    return true;
  }

  Future<bool> remove(PushRequest pushRequest) => _remove(pushRequest);

  Future<void> initFirebase() => pushProvider.initFirebase();

  //////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Helper Methods /////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  void _renewTimers(List<PushRequest> pushRequests) {
    _cancalAllTimers();
    _setupAllTimers(pushRequests);
  }

  void _cancelTimer(PushRequest pr) {
    Logger.info('Canceling timer for push request ${pr.id}');
    final timer = _expirationTimers.remove(pr.id.toString())?..cancel();
    if (timer == null) {
      Logger.warning('Timer for push request ${pr.id} not found.');
    }
  }

  void _cancalAllTimers() {
    if (_expirationTimers.keys.isNotEmpty) {
      Logger.info('Canceling all timers: [${_expirationTimers.keys}]');
    }
    final ids = _expirationTimers.keys.toList();
    for (var id in ids) {
      _expirationTimers.remove(id.toString())?.cancel();
    }
  }

  /// Sets up a timer to remove the push request after it expires.
  /// If the request is already expired, it will be removed immediately.
  /// When the timer is set up, the old timer is canceled.
  void _setupTimer(PushRequest pr) {
    _expirationTimers[pr.id.toString()]?.cancel();
    int time = pr.expirationDate.difference(DateTime.now()).inMilliseconds;
    if (time < 1) {
      _remove(pr);
      return;
    }
    _expirationTimers[pr.id.toString()] = Timer(Duration(milliseconds: time), () async => _remove(pr));
  }

  void _setupAllTimers(List<PushRequest> pushRequests) {
    _cancalAllTimers();
    for (var pr in pushRequests) {
      int time = pr.expirationDate.difference(DateTime.now()).inMilliseconds;
      if (time < 1) {
        _remove(pr);
      }
      _expirationTimers[pr.id.toString()] = Timer(Duration(milliseconds: time), () async => _remove(pr));
    }
  }

  Future<bool> _handleReaction({required PushRequest pushRequest, required PushToken token}) async {
    if (pushRequest.accepted == null) return false;
    Logger.info('Push auth request accepted=${pushRequest.accepted}, sending response to privacyidea');
    //    POST https://privacyideaserver/validate/check
    //    nonce=<nonce_from_request>
    //    serial=<serial>
    //    signature=<signature>
    //    decline=1 (optional)
    //    presence_answer=<answer> (optional)
    final Map<String, String> body = {
      'nonce': pushRequest.nonce,
      'serial': token.serial,
    };
    // signature ::=  {nonce}|{serial}[|decline]
    String msg = '${pushRequest.nonce}|${token.serial}';
    if (pushRequest.accepted! == false) {
      body['decline'] = '1';
      msg += '|decline';
    }
    if (pushRequest.possibleAnswers != null && pushRequest.selectedAnswer != null) {
      body['presence_answer'] = pushRequest.selectedAnswer!;
      msg += '|${pushRequest.selectedAnswer!}';
    }
    Logger.warning('Signature message: $msg');
    String? signature = await _rsaUtils.trySignWithToken(token, msg);
    if (signature == null) {
      Logger.warning('Failed to sign push request response.');
      return false;
    }

    body['signature'] = signature;

    Response response;
    try {
      Logger.info('Sending push request response.');
      response = await _ioClient.doPost(sslVerify: pushRequest.sslVerify, url: pushRequest.uri, body: body);
    } catch (_) {
      Logger.warning('Sending push request response failed. Retrying.');
      try {
        response = await _ioClient.doPost(sslVerify: pushRequest.sslVerify, url: pushRequest.uri, body: body);
      } catch (e) {
        Logger.warning('Sending push request response failed consistently.', error: e);
        ref.read(statusMessageProvider.notifier).state = StatusMessage(message: (l) => l.connectionFailed);
        return false;
      }
    }
    if (HttpStatusChecker.isError(response.statusCode)) {
      ref.read(statusMessageProvider.notifier).state = StatusMessage(
        message: (l) => '${l.sendPushRequestResponseFailed}\n${l.statusCode(response.statusCode)}',
        details: (_) => (tryJsonDecode(response.body)?['result']?['error']?['message']) ?? '',
      );
      Logger.warning('Sending push request response failed.');
      return false;
    }
    return true;
  }
}
