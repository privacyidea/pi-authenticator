/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2023 NetKnights GmbH

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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/interfaces/repo/push_request_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/network_utils.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

import '../model/states/push_request_state.dart';
import '../repo/secure_push_request_repository.dart';
import '../utils/custom_int_buffer.dart';

class PushRequestNotifier extends StateNotifier<PushRequestState> {
  late final Future<PushRequestState> initState;
  final loadingRepoMutex = Mutex();
  final updatingRequestMutex = Mutex();
  final PushRequestRepository _pushRepo;

  PushProvider _pushProvider;
  PushProvider get pushProvider => _pushProvider;
  final PrivacyIdeaIOClient _ioClient;
  final RsaUtils _rsaUtils;

  final Map<String, Timer> _expirationTimers = {};

  PushRequestNotifier({
    PushRequestState? initState,
    PrivacyIdeaIOClient? ioClient,
    required PushProvider pushProvider,
    RsaUtils? rsaUtils,
    PushRequestRepository? pushRepo,
  })  : _ioClient = ioClient ?? const PrivacyIdeaIOClient(),
        _pushProvider = pushProvider,
        _rsaUtils = rsaUtils ?? const RsaUtils(),
        _pushRepo = pushRepo ?? const SecurePushRequestRepository(),
        super(
          initState ?? const PushRequestState(pushRequests: [], knownPushRequests: CustomIntBuffer(list: [])),
        ) {
    _init(initState);
  }

  void swapPushProvider(PushProvider newProvider) {
    _pushProvider.unsubscribe(add);
    _pushProvider = newProvider;
    _pushProvider.subscribe(add);
  }

  Future<void> _init(PushRequestState? initialState) async {
    initState = initialState != null ? Future.value(initialState) : _loadFromRepo();
    _pushProvider.subscribe(add);
    await initState;
    Logger.info('PushRequestNotifier initialized', name: 'push_request_notifier.dart#_init');
  }

  @override
  void dispose() {
    _pushProvider.unsubscribe(add);
    _cancalAllTimers();
    super.dispose();
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
      Logger.error('Failed to load push request state from repo.', name: 'push_request_notifier.dart#_loadFromRepo', error: e);
      loadingRepoMutex.release();
      return state;
    }
    _renewTimers(loadedState.pushRequests);
    state = loadedState;
    loadingRepoMutex.release();
    return loadedState;
  }

  /// Adds a PushRequest to repo and state. Returns true if successful, false if not.
  /// If the request already exists, it will be replaced.
  Future<bool> _addOrReplacePushRequest(PushRequest pushRequest) async {
    await loadingRepoMutex.acquire();
    final oldState = state;
    final newState = oldState.addOrReplace(pushRequest);
    try {
      await _pushRepo.saveState(newState);
    } catch (e) {
      Logger.warning(
        'Failed to save push request: $pushRequest',
        name: 'push_request_notifier.dart#_addOrReplacePushRequest',
        error: e,
      );
      loadingRepoMutex.release();
      return false;
    }
    state = newState;
    loadingRepoMutex.release();
    return true;
  }

  /// Replaces a PushRequest in repo and state. Returns true if successful, false if not.
  Future<bool> _replacePushRequest(PushRequest pushRequest) async {
    await loadingRepoMutex.acquire();
    final oldState = state;
    final (newState, replaced) = oldState.replaceRequest(pushRequest);
    if (!replaced) {
      Logger.warning(
        'Tried to replace a push request that does not exist.',
        name: 'push_request_notifier.dart#_replacePushRequest',
      );
      loadingRepoMutex.release();
      return false;
    }
    try {
      await _pushRepo.saveState(newState);
    } catch (e) {
      Logger.warning(
        'Failed to save push request: $pushRequest',
        name: 'push_request_notifier.dart#_replacePushRequest',
        error: e,
      );
      loadingRepoMutex.release();
      return false;
    }
    state = newState;
    loadingRepoMutex.release();
    return true;
  }

  /// Removes a PushRequest from repo and state. Returns true if successful, false if not.
  Future<bool> _remove(PushRequest pushRequest) async {
    await loadingRepoMutex.acquire();
    final newState = state.withoutRequest(pushRequest);
    try {
      await _pushRepo.saveState(newState);
    } catch (e) {
      Logger.error(
        'Failed to save push request state after removing push request.',
        name: 'push_request_notifier.dart#_remove',
        error: e,
      );
      loadingRepoMutex.release();
      return false;
    }
    state = newState;
    _cancelTimer(pushRequest);
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
    final current = state.currentOf(pushRequest);
    if (current == null) {
      Logger.warning('Tried to update a push request that does not exist.', name: 'push_request_notifier.dart#updatePushRequest');
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
  Future<bool> accept(PushToken pushToken, PushRequest pushRequest) async {
    if (pushRequest.accepted != null) {
      Logger.warning('The push request is already accepted or declined.', name: 'push_request_notifier.dart#decline');

      return false;
    }
    Logger.info('Decline push request.', name: 'push_request_notifier.dart#decline');
    final updated = await _updatePushRequest(pushRequest, (p0) async {
      final updated = p0.copyWith(accepted: true);
      final success = await _handleReaction(pushRequest: updated, token: pushToken);
      if (!success) {
        return p0;
      }
      return updated;
    });
    if (updated == null || updated.accepted != true) return false;
    await _remove(updated);
    return true;
  }

  Future<bool> decline(PushToken pushToken, PushRequest pushRequest) async {
    if (pushRequest.accepted != null) {
      Logger.warning('The push request is already accepted or declined.', name: 'push_request_notifier.dart#decline');
      return false;
    }
    Logger.info('Decline push request.', name: 'push_request_notifier.dart#decline');
    final updated = await _updatePushRequest(pushRequest, (p0) async {
      final updated = p0.copyWith(accepted: false);
      final success = await _handleReaction(pushRequest: updated, token: pushToken);
      if (!success) {
        return p0;
      }
      return updated;
    });
    if (updated == null || updated.accepted != false) return false;
    await _remove(updated);
    return true;
  }

  Future<bool> add(PushRequest pr) async {
    if (state.knowsRequestId(pr.id)) {
      Logger.info(
        'The push request already exists.',
        name: 'token_notifier.dart#addPushRequestToToken',
      );
      return false;
    }
    // Save the pending request.
    await _addOrReplacePushRequest(pr);
    // Remove the request after it expires.
    _setupTimer(pr);
    Logger.info('Added push request ${pr.id} to state', name: 'token_notifier.dart#addPushRequestToToken');
    return true;
  }

  Future<bool> remove(PushRequest pushRequest) => _remove(pushRequest);

  //////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Helper Methods /////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  void _renewTimers(List<PushRequest> pushRequests) {
    _cancalAllTimers();
    _setupAllTimers(pushRequests);
  }

  void _cancelTimer(PushRequest pr) => _expirationTimers.remove(pr.id.toString())?.cancel();

  void _cancalAllTimers() {
    for (var i = 0; i < _expirationTimers.length; i++) {
      _expirationTimers.remove(i.toString())?.cancel();
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
    Logger.info('Push auth request accepted=${pushRequest.accepted}, sending response to privacyidea', name: 'token_widgets.dart#handleReaction');
    // signature ::=  {nonce}|{serial}[|decline]
    String msg = '${pushRequest.nonce}|${token.serial}';
    if (pushRequest.accepted! == false) {
      msg += '|decline';
    }
    String? signature = await _rsaUtils.trySignWithToken(token, msg);
    if (signature == null) {
      return false;
    }
    //    POST https://privacyideaserver/validate/check
    //    nonce=<nonce_from_request>
    //    serial=<serial>
    //    signature=<signature>
    //    decline=1 (optional)
    final Map<String, String> body = {
      'nonce': pushRequest.nonce,
      'serial': token.serial,
      'signature': signature,
    };
    if (pushRequest.accepted! == false) {
      body["decline"] = "1";
    }
    Response response;
    try {
      response = await _ioClient.doPost(sslVerify: pushRequest.sslVerify, url: pushRequest.uri, body: body);
    } catch (e) {
      Logger.warning('Sending push request response failed. Retrying.', name: 'token_widgets.dart#handleReaction');
      try {
        response = await _ioClient.doPost(sslVerify: pushRequest.sslVerify, url: pushRequest.uri, body: body);
      } catch (e) {
        Logger.warning('Sending push request response failed consistently.', name: 'token_widgets.dart#handleReaction', error: e);
        globalRef?.read(statusMessageProvider.notifier).state = (AppLocalizations.of(await globalContext)!.connectionFailed, null);
        return false;
      }
    }
    if (response.statusCode != 200) {
      Logger.warning('Sending push request response failed.', name: 'token_widgets.dart#handleReaction');
      return false;
    }
    return true;
  }
}
