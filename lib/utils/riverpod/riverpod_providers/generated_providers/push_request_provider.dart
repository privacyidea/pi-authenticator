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
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../../interfaces/repo/push_request_repository.dart';
import '../../../../../../../utils/rsa_utils.dart';
import '../../../../model/api_results/pi_server_results/pi_server_result_detail.dart';
import '../../../../model/api_results/pi_server_results/pi_server_result_value.dart';
import '../../../../model/pi_server_response.dart';
import '../../../../model/riverpod_states/push_request_state.dart';
import '../../../../model/tokens/push_token.dart';
import '../../../../repo/secure_push_request_repository.dart';
import '../../../logger.dart';
import '../../../privacyidea_io_client.dart';
import '../../../push_provider.dart';
import '../state_providers/status_message_provider.dart';

part 'push_request_provider.g.dart';

final pushRequestProvider = pushRequestProviderOf(
  rsaUtils: const RsaUtils(),
  ioClient: const PrivacyideaIOClient(),
  pushProvider: PushProvider(),
  pushRepo: SecurePushRequestRepository(),
);

@Riverpod(keepAlive: true)
class PushRequestNotifier extends _$PushRequestNotifier {
  final _loadingRepoMutex = Mutex();
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
  }) : _pushProviderOverride = pushProviderOverride,
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

    // Ensure timers and subscription are cleaned up if the provider is disposed
    ref.onDispose(() {
      _pushProvider.unsubscribe(add);
      _cancalAllTimers();
    });

    return _loadFromRepo();
  }

  void swapPushProvider(PushProvider newProvider) {
    _pushProvider.unsubscribe(add);
    _pushProvider = newProvider;
    _pushProvider.subscribe(add);
  }

  /*
  /////////////////////////////////////////////////////////////////////////////
  //////////////////// Repository and PushMessageRequest Handling ////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /// Repository layer is always use loadingRepoMutex for the latest state
  */

  Future<PushRequestState> _loadFromRepo() async {
    await _loadingRepoMutex.acquire();
    try {
      final loadedState = await _pushRepo.loadState();
      _renewTimers(loadedState.pushRequests);
      state = AsyncValue.data(loadedState);
      return loadedState;
    } catch (e) {
      Logger.error('Failed to load push request state from repo.', error: e);
      return (state.value ?? PushRequestState.empty());
    } finally {
      _loadingRepoMutex.release();
    }
  }

  /// Adds a PushMessageRequest to repo and state. Returns true if successful, false if not.
  /// If the request already exists, it will be replaced.
  Future<bool> _addOrReplacePushRequest(PushRequest pushRequest) async {
    await _loadingRepoMutex.acquire();
    try {
      final oldState = (await future);
      final newState = oldState.addOrReplace(pushRequest);
      await _pushRepo.saveState(newState);
      state = AsyncValue.data(newState);
      return true;
    } catch (e) {
      Logger.warning('Failed to save push request: $pushRequest', error: e);
      return false;
    } finally {
      _loadingRepoMutex.release();
    }
  }

  // TODO: LÖSCHEN VORM COMMITTEN
  // /// Replaces a PushMessageRequest in repo and state. Returns true if successful, false if not.
  // Future<bool> _replacePushRequest(PushRequest pushRequest) async {
  //   await _loadingRepoMutex.acquire();
  //   try {
  //     final oldState = (await future);
  //     final (newState, replaced) = oldState.replaceRequest(pushRequest);
  //     if (!replaced) {
  //       Logger.warning('Tried to replace a push request that does not exist.');
  //       return false;
  //     }
  //     await _pushRepo.saveState(newState);
  //     state = AsyncValue.data(newState);
  //     return true;
  //   } catch (e) {
  //     Logger.warning('Failed to save push request: $pushRequest', error: e);
  //     return false;
  //   } finally {
  //     _loadingRepoMutex.release();
  //   }
  // }

  /// Removes a PushMessageRequest from repo and state. Returns true if successful, false if not.
  Future<bool> _remove(PushRequest pushRequest) async {
    _cancelTimer(pushRequest);
    await _loadingRepoMutex.acquire();
    try {
      final newState = (await future).withoutRequest(pushRequest);
      await _pushRepo.saveState(newState);
      state = AsyncValue.data(newState);
      return true;
    } catch (e) {
      Logger.error(
        'Failed to save push request state after removing push request.',
        error: e,
      );
      _setupTimer(pushRequest);
      return false;
    } finally {
      _loadingRepoMutex.release();
    }
  }
  /*
  //////////////////////////////////////////////////////////////////////////////
  ////////////////////// Update PushMessageRequest Methods ////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  /// Updating layer is always use updatingRequestMutex for the latest state
  */

  /// Updates a PushMessageRequest of the current state. The updated PushMessageRequest is saved to the repo and the state. Returns the updated PushMessageRequest if successful, null if not.
  Future<T?> _updatePushRequest<T extends PushRequest>(
    T pushRequest,
    Future<T> Function(T) updater,
  ) async {
    await _loadingRepoMutex.acquire();
    try {
      final current = (await future).currentOf(pushRequest);
      if (current == null) {
        Logger.warning('Tried to update a push request that does not exist.');
        return null;
      }
      final updated = await updater(current);
      final (newState, replaced) = (await future).replaceRequest(updated);
      if (!replaced) {
        return null;
      }
      await _pushRepo.saveState(newState);
      state = AsyncValue.data(newState);
      return updated;
    } catch (e) {
      Logger.error('Failed to update push request', error: e);
      return null;
    } finally {
      _loadingRepoMutex.release();
    }
  }
  /*
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////// Public Methods //////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  /// There is no need to use mutexes because the updating functions are always using the latest version of the updating tokens.
  */

  Future<void> pollForChallenges({required bool isManually}) =>
      pushProvider.pollForChallenges(isManually: isManually);

  Future<PushRequestState> loadStateFromRepo() => _loadFromRepo();

  /// Accepts a push request and returns true if successful, false if not.
  /// An accepted push request is removed from the state.
  Future<PiSuccessResponse<T, D>?> accept<
    T extends PiServerResultValue,
    D extends PiServerResultDetail
  >(PushToken token, PushRequest request, {String? selectedAnswer}) async {
    return _handleReaction<T, D>(
      pushRequest: request,
      token: token,
      updater: (p0) async => p0.dynamicCopyWith(
        accepted: () => true,
        selectedAnswer: selectedAnswer,
      ),
    );
  }

  Future<PiSuccessResponse<T, D>?> decline<
    T extends PiServerResultValue,
    D extends PiServerResultDetail
  >(PushToken token, PushRequest request) async {
    return _handleReaction<T, D>(
      pushRequest: request,
      token: token,
      updater: (p0) async => p0.dynamicCopyWith(accepted: () => false),
    );
  }

  Future<bool> add(PushRequest pr) async {
    if ((await future).knowsRequestId(pr.id)) {
      Logger.info('The push request already exists.');
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
    _expirationTimers[pr.id.toString()] = Timer(
      Duration(milliseconds: time),
      () async => _remove(pr),
    );
  }

  void _setupAllTimers(List<PushRequest> pushRequests) {
    _cancalAllTimers();
    for (var pr in pushRequests) {
      int time = pr.expirationDate.difference(DateTime.now()).inMilliseconds;
      if (time < 1) {
        _remove(pr);
      } else {
        _expirationTimers[pr.id.toString()] = Timer(
          Duration(milliseconds: time),
          () async => _remove(pr),
        );
      }
    }
  }

  final _reactionMutex = Mutex();

  /// Handles the reaction to a push request (accept or decline).
  /// Returns the response body if successful, null if not.
  /// The reaction is handled by sending a POST request to the push request's URI with the appropriate data and signature.
  /// If the request fails, it will be retried once. If it fails again, an error message will be shown.
  /// If the response has an error status code, an error message will be shown.
  Future<PiSuccessResponse<T, D>?> _handleReaction<
    T extends PiServerResultValue,
    D extends PiServerResultDetail
  >({
    required PushRequest pushRequest,
    required PushToken token,
    required Future<PushRequest> Function(PushRequest) updater,
  }) async {
    await _reactionMutex.acquire();

    // Backup des aktuellen Zustands für ein mögliches Rollback
    final oldRequest = pushRequest;

    try {
      final updated = await _updatePushRequest(pushRequest, updater);

      if (updated == null || updated.accepted == null) {
        return null;
      }

      final Map<String, String> body = {
        'serial': token.serial,
        'nonce': updated.nonce,
        if (updated.accepted == false) 'decline': '1',
        ...updated.getResponseData(token),
      };

      String msg = updated.getResponseSignMsg(token);
      String? signature = await _rsaUtils.trySignWithToken(token, msg);
      if (signature == null) {
        await _addOrReplacePushRequest(oldRequest);
        return null;
      }
      body['signature'] = signature;

      Response response;
      try {
        response = await _ioClient.doPost(
          sslVerify: updated.sslVerify,
          url: updated.uri,
          body: body,
        );
      } catch (_) {
        try {
          response = await _ioClient.doPost(
            sslVerify: updated.sslVerify,
            url: updated.uri,
            body: body,
          );
        } catch (e) {
          await _addOrReplacePushRequest(oldRequest);
          ref.read(statusMessageProvider.notifier).state = StatusMessage(
            message: (l) => l.connectionFailed,
          );
          return null;
        }
      }
      Logger.debug('Response Body: ${response.body}');
      PiServerResponse<T, D> piResponse;
      try {
        piResponse = response.asPiServerResponse<T, D>();
      } catch (e) {
        ref.read(statusMessageProvider.notifier).state = StatusMessage(
          message: (l) =>
              '${l.sendPushRequestResponseFailed}\n${l.statusCode(response.statusCode)}',
          details: (_) => 'Failed to parse response: $e',
        );
        await _addOrReplacePushRequest(oldRequest);
        return null;
      }
      if (piResponse.isError) {
        await _addOrReplacePushRequest(oldRequest);
        final errorResponse = piResponse.asError!;
        ref.read(statusMessageProvider.notifier).state = StatusMessage(
          message: (l) =>
              '${l.sendPushRequestResponseFailed}\n${l.statusCode(errorResponse.statusCode)}',
          details: (_) =>
              '${errorResponse.piServerResultError.code}: ${errorResponse.piServerResultError.message}',
        );
        return null;
      }

      await _remove(updated);
      return piResponse.asSuccess;
    } finally {
      _reactionMutex.release();
    }
  }
}
