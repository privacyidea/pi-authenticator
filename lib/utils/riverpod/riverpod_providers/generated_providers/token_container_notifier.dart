/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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

import 'package:basic_utils/basic_utils.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/model/exception_errors/pi_server_result_error.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/rollout_state_extension.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../api/privacy_idea_container_api.dart';
import '../../../../interfaces/repo/token_container_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../model/api_results/pi_server_results/pi_server_result_value.dart';
import '../../../../model/enums/rollout_state.dart';
import '../../../../model/enums/sync_state.dart';
import '../../../../model/exception_errors/localized_argument_error.dart';
import '../../../../model/exception_errors/response_error.dart';
import '../../../../model/pi_server_response.dart';
import '../../../../model/riverpod_states/token_container_state.dart';
import '../../../../model/riverpod_states/token_state.dart';
import '../../../../model/token_container.dart';
import '../../../../repo/secure_token_container_repository.dart';
import '../../../../widgets/dialog_widgets/add_container_progress_dialog.dart';
import '../../../../widgets/dialog_widgets/container_already_exists_dialog.dart';
import '../../../ecc_utils.dart';
import '../../../logger.dart';

part 'token_container_notifier.g.dart';

final tokenContainerProvider = tokenContainerNotifierProviderOf(
  repo: SecureTokenContainerRepository(),
  containerApi: const PrivacyIdeaContainerApi(ioClient: PrivacyideaIOClient()),
  eccUtils: const EccUtils(),
);

@Riverpod(keepAlive: true)
class TokenContainerNotifier extends _$TokenContainerNotifier with ResultHandler {
  final _stateMutex = Mutex();
  final _repoMutex = Mutex();

  TokenContainerNotifier({
    TokenContainerRepository? repoOverride,
    PrivacyIdeaContainerApi? containerApiOverride,
    EccUtils? eccUtilsOverride,
  })  : _repoOverride = repoOverride,
        _containerApiOverride = containerApiOverride,
        _eccUtilsOverride = eccUtilsOverride;

  @override
  TokenContainerRepository get repo => _repo;
  late TokenContainerRepository _repo;
  final TokenContainerRepository? _repoOverride;

  @override
  PrivacyIdeaContainerApi get containerApi => _containerApi;
  late PrivacyIdeaContainerApi _containerApi;
  final PrivacyIdeaContainerApi? _containerApiOverride;

  @override
  EccUtils get eccUtils => _eccUtils;
  late EccUtils _eccUtils;
  final EccUtils? _eccUtilsOverride;

  @override
  Future<TokenContainerState> build({
    required TokenContainerRepository repo,
    required PrivacyIdeaContainerApi containerApi,
    required EccUtils eccUtils,
  }) async {
    await _stateMutex.acquire();
    _repo = _repoOverride ?? repo;
    _containerApi = _containerApiOverride ?? containerApi;
    _eccUtils = _eccUtilsOverride ?? eccUtils;
    Logger.warning('Building containerProvider');

    var initState = await _repo.loadContainerState();
    final containerList = initState.containerList.map((c) {
      if (c is! TokenContainerFinalized) return c;
      final fixedSyncState = c.syncState == SyncState.syncing ? SyncState.failed : c.syncState;
      return c.copyWith(syncState: fixedSyncState);
    }).toList();
    initState = initState.copyWith(containerList: containerList);
    for (var container in initState.containerList.whereType<TokenContainerUnfinalized>()) {
      finalize(container, isManually: false);
    }
    _stateMutex.release();
    return initState;
  }

//////////////////////////////////////////////////////////////////
////////////////////////// REPO METHODS //////////////////////////
//////////////////////////////////////////////////////////////////

  Future<TokenContainerState> _saveContainerToRepo(TokenContainer container) async {
    return await _repoMutex.protect(() async => await _repo.saveContainer(container));
  }

  Future<TokenContainerState> _saveContainerListToRepo(List<TokenContainer> containers) async {
    return await _repoMutex.protect(() async => await _repo.saveContainerList(containers));
  }

  Future<TokenContainerState> _saveContainersStateToRepo(TokenContainerState containerState) async {
    return await _repoMutex.protect(() async => await _repo.saveContainerState(containerState));
  }

  Future<TokenContainerState> _deleteContainerFromRepo(TokenContainer container) async {
    return await _repoMutex.protect(() async => await _repo.deleteContainer(container.serial));
  }

  Future<TokenContainerState> _deleteContainersStateToRepo() async {
    return await _repoMutex.protect(() async => await _repo.deleteAllContainer());
  }

/*//////////////////////////////////////////////////////////////////
////////////////////////// PUBLIC METHODS //////////////////////////
///////////////////////////////////////////////////////////////// */

  Future<void> syncTokens(
    TokenState tokenState, {
    List<TokenContainerFinalized>? containersToSync,
    required bool isManually,
  }) async {
    Logger.info('Syncing ${containersToSync?.length} tokens');
    if (containersToSync == null || containersToSync.isEmpty) {
      final containerList = (await future).containerList;
      containersToSync = containerList.whereType<TokenContainerFinalized>().where((e) => e.syncState != SyncState.syncing).toList();
    } else {
      final current = <TokenContainer>[];
      for (final container in containersToSync) {
        current.add((await future).currentOf(container)!);
      }
      containersToSync = current.whereType<TokenContainerFinalized>().where((e) => e.syncState != SyncState.syncing).toList();
    }
    final syncFutures = <Future<(List<Token>, List<String>)?>>[];

    List<Token> syncedTokens = [];
    List<String> deletedTokens = [];

    containersToSync = await updateContainers(containersToSync, (c) => c.copyWith(syncState: SyncState.syncing));

    for (var finalizedContainer in containersToSync) {
      syncFutures.add(
        Future(() async {
          final syncResult = await _containerApi.sync(
            finalizedContainer,
            tokenState,
          );
          if (syncResult == null) {
            await updateContainer(finalizedContainer, (c) => c.copyWith(syncState: SyncState.failed));
            return null;
          }
          await updateContainer(finalizedContainer, (c) => c.copyWith(syncState: SyncState.completed));
          return syncResult;
        }).catchError((error, stackTrace) async {
          await updateContainer(finalizedContainer, (c) => c.copyWith(syncState: SyncState.failed));
          if (!isManually) return null;
          Logger.debug('Failed to sync container ${error.runtimeType}', error: error); //stackTrace: stackTrace);
          showStatusMessage(
            message: AppLocalizations.of(await globalContext)!.failedToSyncContainer(finalizedContainer.serial),
            subMessage: error is PiServerResultError ? error.message : error.toString(),
          );
          return null;
        }),
      );
    }

    await Future.wait(syncFutures).then((tuples) {
      for (var tuple in tuples) {
        if (tuple == null) continue;
        syncedTokens.addAll(tuple.$1);
        deletedTokens.addAll(tuple.$2);
      }
    }).onError((error, stackTrace) {
      Logger.error('Failed to sync container', error: error, stackTrace: stackTrace);
    });

    // Do not remove tokens that are synced in any other container
    deletedTokens.removeWhere((serial) => syncedTokens.any((token) => token.serial == serial));

    await ref.read(tokenProvider.notifier).addOrReplaceTokens(syncedTokens);
    await ref.read(tokenProvider.notifier).removeTokensBySerials(deletedTokens);
  }

// ADD CONTAINER

  Future<TokenContainerState> addContainer(TokenContainer container) async {
    await _stateMutex.acquire();
    await future;
    final newState = await _saveContainerToRepo(container);
    await update((_) => newState);
    _stateMutex.release();
    return newState;
  }

  Future<TokenContainerState> addContainerList(List<TokenContainer> container) async {
    await _stateMutex.acquire();
    final newContainers = container.toList();
    final oldContainers = (await future).containerList;
    Logger.debug('Loaded container: $oldContainers');
    final combinedContainers = <TokenContainer>[];
    for (var oldContainer in oldContainers) {
      final newContainer = newContainers.firstWhereOrNull((newContainer) => newContainer.serial == oldContainer.serial);
      if (newContainer == null) {
        combinedContainers.add(oldContainer);
      } else {
        combinedContainers.add(newContainer);
        newContainers.remove(newContainer);
      }
    }
    combinedContainers.addAll(newContainers);
    Logger.debug('Combined container: $combinedContainers');
    final newState = await _saveContainersStateToRepo(TokenContainerState(container: combinedContainers));
    Logger.debug('Saved container: $newState');
    await update((_) => newState);
    Logger.debug('Updated container: $newState');
    _stateMutex.release();
    return newState;
  }

// UPDATE CONTAINER

  @override
  Future<TokenContainerState> update(
    FutureOr<TokenContainerState> Function(TokenContainerState state) cb, {
    FutureOr<TokenContainerState> Function(Object, StackTrace)? onError,
  }) async {
    Logger.warning('Updating containerProvider');
    return super.update(cb, onError: onError);
  }

  Future<T?> updateContainer<T extends TokenContainer>(T container, T Function(T) updater) async {
    await _stateMutex.acquire();
    final oldState = await future;
    final currentContainer = oldState.currentOf<T>(container);
    if (currentContainer == null) {
      Logger.info('Failed to update container. It was probably removed in the meantime.');
      _stateMutex.release();
      return null;
    }
    final updated = updater(currentContainer);
    final newState = await _saveContainerToRepo(updated);
    await update((_) => newState);
    _stateMutex.release();
    return updated;
  }

  Future<List<T>> updateContainers<T extends TokenContainer>(List<T> container, T Function(T) updater) async {
    await _stateMutex.acquire();
    final oldState = await future;
    final currentContainers = <T>[];
    Logger.info('Updating ${container.length} containers');
    for (var c in container) {
      currentContainers.add(oldState.currentOf<T>(c)!);
    }
    if (currentContainers.isEmpty) {
      Logger.info('Failed to update containers. They were probably removed in the meantime.');
      _stateMutex.release();
      return [];
    }
    final updated = <T>[];

    for (var c in currentContainers) {
      updated.add(updater(c));
    }
    final newState = await _saveContainerListToRepo(updated);
    await update((_) => newState);
    _stateMutex.release();
    return updated;
  }

// DELETE CONTAINER

  Future<TokenContainerState> deleteContainer(TokenContainer container) async {
    await _stateMutex.acquire();
    final newState = await _deleteContainerFromRepo(container);
    await update((_) => newState);
    _stateMutex.release();
    return newState;
  }

  Future<TokenContainerState> deleteContainerList(List<TokenContainer> container) async {
    await _stateMutex.acquire();
    final newContainers = container.toList();
    final oldContainers = (await future).containerList;
    final combinedContainers = <TokenContainer>[];
    for (var oldContainer in oldContainers) {
      final newContainer = newContainers.firstWhereOrNull((newContainer) => newContainer.serial == oldContainer.serial);
      if (newContainer == null) {
        combinedContainers.add(oldContainer);
      } else {
        newContainers.remove(newContainer);
      }
    }
    final newState = await _saveContainersStateToRepo(TokenContainerState(container: combinedContainers));
    await update((_) => newState);
    _stateMutex.release();
    return newState;
  }

  /* /////////////////////////////////////////////////////////////////////////
  /////////////////////// HANDLE PROCESSOR RESULTS ///////////////////////////
  ///////////////////////////////////////////////////////////////////////// */

  @override
  Future handleProcessorResult(ProcessorResult result, Map<String, dynamic> args) async => (await handleProcessorResults([result], args))?.isEmpty == true;

  @override
  Future handleProcessorResults(List<ProcessorResult> results, Map<String, dynamic> args) async {
    Logger.info('Handling processor results');
    final containerContainers = results.getData().whereType<TokenContainer>().toList();
    if (containerContainers.isEmpty) return null;
    final currentState = await future;
    final stateContainers = currentState.containerList;
    final stateContainersSerials = stateContainers.map((e) => e.serial);
    final newContainerList = containerContainers.where((element) => !stateContainersSerials.contains(element.serial)).toList();
    final existingContainers = containerContainers.where((element) => stateContainersSerials.contains(element.serial)).toList();
    Logger.info('Handling processor results: adding Container');
    final replaceContainers = <TokenContainer>[];
    if (existingContainers.isNotEmpty) {
      replaceContainers.addAll(await _showContainerAlreadyExistsDialog(existingContainers) ?? []);
    }

    if (replaceContainers.isNotEmpty) {
      await deleteContainerList(replaceContainers);
      newContainerList.addAll(replaceContainers);
    }

    if (newContainerList.isNotEmpty) _showAddContainerProgressDialog(newContainerList);
    final stateAfterAdding = await addContainerList(newContainerList);
    final failedToAdd = [];
    Logger.info('Handling processor results: adding done (${newContainerList.length})');
    final List<Future> finalizeFutures = [];
    for (var container in newContainerList) {
      Logger.info('Handling processor results: finalize check ()');

      if (!stateAfterAdding.containerList.contains(container)) {
        failedToAdd.add(container);
        continue;
      }
      if (container is! TokenContainerUnfinalized) continue;
      Logger.info('Handling processor results: finalize');
      finalizeFutures.add(finalize(container, isManually: true));
    }
    await Future.wait(finalizeFutures);
    await syncTokens(ref.read(tokenProvider), isManually: true);

    return failedToAdd;
  }

  final Mutex _finalizationMutex = Mutex();
  Future<void> finalize(TokenContainer container, {required bool isManually}) async {
    await _finalizationMutex.acquire();
    if (container is! TokenContainerUnfinalized) {
      _finalizationMutex.release();
      throw ArgumentError('Container must not be finalized');
    }
    Logger.info('Finalizing container ${container.serial}');
    try {
      container = await _generateKeyPair(container);
      container = await _curentOf<TokenContainerUnfinalized>(container);
      final Response response = await _sendPublicKey((container));
      container = await _curentOf<TokenContainerUnfinalized>(container);
      final ECPublicKey publicServerKey = await _parseResponse(await _curentOf(container), response);
      container = await _curentOf<TokenContainerUnfinalized>(container);
      await updateContainer(await _curentOf(container), (c) => c.finalize(publicServerKey: publicServerKey)!);
    } on StateError catch (e) {
      final applocalizations = AppLocalizations.of(await globalContext)!;
      if (isManually) {
        ref.read(statusMessageProvider.notifier).state = (
          container.finalizationState.asFailed.rolloutMsgLocalized(applocalizations),
          e.toString(),
        );
      }
    } on LocalizedArgumentError catch (e) {
      final applocalizations = AppLocalizations.of(await globalContext)!;
      if (isManually) {
        ref.read(statusMessageProvider.notifier).state = (
          container.finalizationState.asFailed.rolloutMsgLocalized(applocalizations),
          e.localizedMessage(applocalizations),
        );
      }
      await updateContainer(container, (c) => c.copyWith(finalizationState: c.finalizationState.asFailed));
    } on PiErrorResponse catch (e) {
      final applocalizations = AppLocalizations.of(await globalContext)!;
      if (isManually) {
        ref.read(statusMessageProvider.notifier).state = (
          container.finalizationState.asFailed.rolloutMsgLocalized(applocalizations),
          e.piServerResultError.message,
        );
      }
      await updateContainer(container, (c) => c.copyWith(finalizationState: c.finalizationState.asFailed));
    } on ResponseError catch (e) {
      final applocalizations = AppLocalizations.of(await globalContext)!;
      if (isManually) {
        ref.read(statusMessageProvider.notifier).state = (
          container.finalizationState.asFailed.rolloutMsgLocalized(applocalizations),
          e.toString(),
        );
      }
    } catch (e) {
      Logger.error('Failed to finalize container ${container.serial}', error: e);
    }
    _finalizationMutex.release();
  }

/* /////////////////////////////////////////////////////////////////////////
////////////////// PRIVATE HELPER METHODS FINALIZATION /////////////////////
///////////////////////////////////////////////////////////////////////// */

  Future<T> _curentOf<T extends TokenContainer>(TokenContainer container) async {
    final current = (await future).currentOf(container);
    if (current == null) throw StateError('Container was removed');
    if (current is! T) throw StateError('Container is not of type $T');
    return current;
  }

  void _showAddContainerProgressDialog(List<TokenContainer> containers) {
    final serials = containers.map((e) => e.serial).toList();
    showAsyncDialog(builder: (context) => AddContainerProgressDialog(serials), barrierDismissible: false);
  }

  Future<List<TokenContainer>?> _showContainerAlreadyExistsDialog(List<TokenContainer> containers) {
    return showAsyncDialog<List<TokenContainer>>(builder: (context) => ContainerAlreadyExistsDialog(containers), barrierDismissible: false);
  }

  /// Finalization substep 1: Generate key pair
  Future<TokenContainerUnfinalized> _generateKeyPair(TokenContainerUnfinalized tokenContainer) async {
    // generatingKeyPair,
    // generatingKeyPairFailed,
    // generatingKeyPairCompleted,
    TokenContainerUnfinalized? container = tokenContainer;
    container = await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.generatingKeyPair));
    if (container == null) throw StateError('Container was removed');
    final keyPair = eccUtils.generateKeyPair(container.ecKeyAlgorithm);
    container = await updateContainer(container, (c) => c.withClientKeyPair(keyPair) as TokenContainerUnfinalized);
    if (container == null) throw StateError('Container was removed');
    return container;
  }

  /// Finalization substep 2: Send public key
  Future<Response> _sendPublicKey(TokenContainerUnfinalized tokenContainer) async {
    // sendingPublicKey,
    // sendingPublicKeyFailed,
    // sendingPublicKeyCompleted,

    //POST /container/register/finalize
    // Request: {
    // 'container_serial': <serial>,
    // 'public_client_key': <public key container base64 url encoded>,
    // 'signature': <sig( <nonce|timestamp|registration_url|serial[|passphrase]> )>,
    // }

    TokenContainerUnfinalized? container = tokenContainer;

    final Response? response;
    container = await updateContainer<TokenContainerUnfinalized>(container, (c) => c.copyWith(finalizationState: RolloutState.sendingPublicKey));
    if (container == null) throw StateError('Container was removed');

    response = (await _containerApi.finalizeContainer(container, eccUtils));
    if (response.statusCode != 200) {
      container = await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.sendingPublicKeyFailed));
      if (container == null) throw StateError('Container was removed');
      return response;
    }

    return response;
  }

  /// Finalization substep 3: Parse response
  Future<ECPublicKey> _parseResponse(TokenContainer tokenContainer, Response response) async {
    // parsingResponse,
    // parsingResponseFailed,
    // parsingResponseCompleted,
    TokenContainer? container = tokenContainer;
    PiServerResponse<ContainerFinalizationResponse>? piResponse;
    try {
      piResponse = response.asPiServerResponse<ContainerFinalizationResponse>();
    } catch (e) {
      Logger.error('Failed to parse response', error: e);
      container = await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.parsingResponseFailed));
      if (container == null) throw StateError('Container was removed');
      rethrow;
    }

    if (piResponse == null || piResponse.isError) {
      Logger.debug('Status code: ${response.statusCode}');
      Logger.debug('Response body: ${response.body}');
      container = await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.sendingPublicKeyFailed));
      if (container == null) throw StateError('Container was removed');
      final error = piResponse?.asError;
      if (error != null) throw error;
      throw ResponseError(response);
    }

    container = await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.sendingPublicKeyCompleted));
    if (container == null) throw StateError('Container was removed');

    container = await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.parsingResponse));
    if (container == null) throw StateError('Container was removed');
    ContainerFinalizationResponse resultValue = piResponse.asSuccess!.resultValue;
    try {
      resultValue = piResponse.asSuccess!.resultValue;
    } catch (e) {
      Logger.error('Failed to parse response', error: e);
      container = await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.parsingResponseFailed));
      if (container == null) throw StateError('Container was removed');
      rethrow;
    }

    container = await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.parsingResponseCompleted));
    if (container == null) throw StateError('Container was removed');
    return resultValue.publicServerKey;
  }

  Future<String> getTransferQrData(TokenContainerFinalized container) async {
    final currentContainer = (await future).currentOf(container);
    if (currentContainer == null) throw StateError('Container was removed');
    final qrCode = await _containerApi.getTransferQrData(currentContainer);
    return qrCode;
  }
}
