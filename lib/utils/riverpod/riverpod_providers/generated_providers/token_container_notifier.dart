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

import 'package:collection/collection.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/model/container_policies.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/rollout_state_extension.dart';
import 'package:privacyidea_authenticator/model/extensions/token_folder_extension.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_container_processor.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/views/container_view/container_widgets/dialogs/delete_container_dialogs.dart/delete_container_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/container_rollout_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../../model/exception_errors/pi_server_result_error.dart';
import '../../../../../../../model/processor_result.dart';
import '../../../../../../../model/tokens/token.dart';
import '../../../../../../../utils/privacyidea_io_client.dart';
import '../../../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../../../utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import '../../../../../../../utils/view_utils.dart';
import '../../../../api/impl/privacy_idea_container_api.dart';
import '../../../../api/interfaces/container_api.dart';
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
import '../../../../widgets/dialog_widgets/container_dialogs/container_already_exists_dialog.dart';
import '../../../../widgets/dialog_widgets/container_dialogs/container_send_device_infos_dialog.dart';
import '../../../../widgets/dialog_widgets/container_dialogs/container_show_url_dialog.dart';
import '../../../ecc_utils.dart';
import '../../../logger.dart';

part 'token_container_notifier.g.dart';

final tokenContainerProvider = tokenContainerNotifierProviderOf(
  repo: SecureTokenContainerRepository(),
  containerApi: const PiContainerApi(ioClient: PrivacyideaIOClient()),
  eccUtils: const EccUtils(),
);

@Riverpod(keepAlive: true)
class TokenContainerNotifier extends _$TokenContainerNotifier with ResultHandler {
  final _stateMutex = Mutex();
  final _repoMutex = Mutex();

  TokenContainerNotifier({
    TokenContainerRepository? repoOverride,
    TokenContainerApi? containerApiOverride,
    EccUtils? eccUtilsOverride,
  })  : _repoOverride = repoOverride,
        _containerApiOverride = containerApiOverride,
        _eccUtilsOverride = eccUtilsOverride;

  @override
  TokenContainerRepository get repo => _repo;
  late TokenContainerRepository _repo;
  final TokenContainerRepository? _repoOverride;

  @override
  TokenContainerApi get containerApi => _containerApi;
  late TokenContainerApi _containerApi;
  final TokenContainerApi? _containerApiOverride;

  @override
  EccUtils get eccUtils => _eccUtils;
  late EccUtils _eccUtils;
  final EccUtils? _eccUtilsOverride;

  @override
  Future<TokenContainerState> build({
    required TokenContainerRepository repo,
    required TokenContainerApi containerApi,
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

/*//////////////////////////////////////////////////////////////////
////////////////////////// PUBLIC METHODS //////////////////////////
///////////////////////////////////////////////////////////////// */

  Future<Map<int, TokenContainerFinalized>> syncContainers({
    required TokenState tokenState,
    required bool isManually,
    List<TokenContainerFinalized>? containersToSync,
    bool? isInitSync,
  }) async {
    if (containersToSync == null) {
      final containerList = (await future).containerList;
      containersToSync = containerList.whereType<TokenContainerFinalized>().where((e) => e.syncState != SyncState.syncing).toList();
    } else {
      final current = <TokenContainer>[];
      for (final container in containersToSync) {
        current.add((await future).currentOf(container)!);
      }
      containersToSync = current.whereType<TokenContainerFinalized>().where((e) => e.syncState != SyncState.syncing).toList();
    }
    if (containersToSync.isEmpty) {
      return {};
    }
    Logger.info('Syncing ${containersToSync.length} tokens');
    final syncFutures = <Future<ContainerSyncUpdates?>>[];

    List<Token> newTokens = [];
    List<Token> syncedTokens = [];
    List<Token> deletedTokensNoOffline = [];

    Logger.debug('Change to sync state to syncing');
    containersToSync = await updateContainerList(containersToSync, (c) => c.copyWith(syncState: SyncState.syncing));

    final failedContainers = <int, TokenContainerFinalized>{};

    for (var finalizedContainer in containersToSync) {
      syncFutures.add(
        _syncContainer(finalizedContainer, tokenState, isInitSync, isManually).onError((error, stackTrace) async {
          // Only PiServerResultError is rethrown from the _syncContainer method
          assert(error is PiServerResultError, 'Only PiServerResultError is rethrown from the _syncContainer method');
          failedContainers[(error as PiServerResultError).code] = finalizedContainer;
          await _handlePiServerResultError(error, finalizedContainer, isManually);
          return null;
        }),
      );
    }

    Map<String, ContainerPolicies> newPoliciesMap = {};

    await Future.wait(syncFutures).then((syncUpdates) {
      for (var syncUpdate in syncUpdates) {
        if (syncUpdate == null) continue;
        newTokens.addAll(syncUpdate.newTokens);
        syncedTokens.addAll(syncUpdate.updatedTokens);
        deletedTokensNoOffline.addAll(syncUpdate.deletedTokens.noOffline);
        ref
            .read(tokenProvider.notifier)
            .updateTokens(syncUpdate.initAssignmentChecked, (t) => t.copyWith(checkedContainer: t.checkedContainer..add(syncUpdate.containerSerial)));
        newPoliciesMap[syncUpdate.containerSerial] = syncUpdate.newPolicies;
      }
    }).onError((error, stackTrace) {
      Logger.error('Failed to sync container', error: error, stackTrace: stackTrace);
    });

    // Do not remove tokens that are synced in any other container
    deletedTokensNoOffline.removeWhere((deletedToken) => syncedTokens.any((syncedToken) => deletedToken.serial == syncedToken.serial));

    await ref.read(tokenProvider.notifier).removeTokens(deletedTokensNoOffline);
    await ref.read(tokenProvider.notifier).addOrReplaceTokens([...syncedTokens, ...newTokens]);
    await updateContainerList((await future).containerList, (c) => newPoliciesMap[c.serial] == null ? c : c.copyWith(policies: newPoliciesMap[c.serial]!));
    return failedContainers;
  }

  Future<ContainerSyncUpdates?> _syncContainer(TokenContainerFinalized finalizedContainer, TokenState tokenState, bool? isInitSync, bool isManually) async {
    try {
      final syncUpdate = await _containerApi.sync(
        finalizedContainer,
        tokenState,
        isInitSync: isInitSync,
      );
      if (syncUpdate == null) {
        Logger.warning('Failed to sync container ${finalizedContainer.serial}');
        await updateContainer(finalizedContainer, (TokenContainerFinalized c) => c.copyWith(syncState: SyncState.failed));
        return null;
      }
      await updateContainer(finalizedContainer, (TokenContainerFinalized c) => c.copyWith(syncState: SyncState.completed));
      ContainerSyncResultDialog.showDialog(
        container: finalizedContainer,
        addedTokens: syncUpdate.newTokens,
        removedTokens: syncUpdate.deletedTokens.noOffline,
      );
      return syncUpdate;
    } catch (error, stackTrace) {
      Logger.warning('Failed to sync container ${finalizedContainer.serial}', error: error, stackTrace: stackTrace);
      await updateContainer(finalizedContainer, (TokenContainerFinalized c) => c.copyWith(syncState: SyncState.failed));
      if (error is PiServerResultError) {
        rethrow;
      }
      if (!isManually) return null;
      showErrorStatusMessage(
        message: (localization) => localization.failedToSyncContainer(finalizedContainer.serial),
        details: error is PiServerResultError ? (_) => error.message : (_) => error.toString(),
      );
    }
    return null;
  }

  Future<bool> rolloverTokens({
    required TokenState tokenState,
    required TokenContainerFinalized container,
  }) async {
    final rollover = await getRolloverQrData(container);
    final uri = Uri.tryParse(rollover);
    if (uri == null) throw ArgumentError('Invalid rollover uri');
    final result = (await TokenContainerProcessor().processUri(uri, fromInit: false))?.firstOrNull;
    if (result == null) throw StateError('Failed to process rollover uri');
    final success = await handleProcessorResult(result, args: {TokenContainerProcessor.ARG_DO_REPLACE: true});
    return success;
  }

  Future<String> getRolloverQrData(TokenContainerFinalized container) async {
    final currentContainer = (await future).currentOf<TokenContainerFinalized>(container);
    if (currentContainer == null) throw StateError('Container was removed');
    final qrCodeData = await _containerApi.getRolloverQrData(currentContainer);
    return qrCodeData.value;
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
    final newState = await _saveContainersStateToRepo(TokenContainerState(containerList: combinedContainers));
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

  Future<R?> updateContainer<R extends TokenContainer, T extends TokenContainer>(TokenContainer container, R Function(T) updater) async {
    await _stateMutex.acquire();
    final oldState = await future;
    Logger.debug('Updating container ${container.serial} updater: $updater');
    final currentContainer = oldState.currentOf<T>(container);
    if (currentContainer == null) {
      Logger.info('Failed to update container. It was probably removed in the meantime.');
      _stateMutex.release();
      return null;
    }
    Logger.info('Updating container ${currentContainer.serial}');
    final updated = updater(currentContainer);
    final newState = await _saveContainerToRepo(updated);
    await update((_) => newState);
    _stateMutex.release();
    return updated;
  }

  Future<List<T>> updateContainerList<T extends TokenContainer>(List<T> container, T Function(T) updater) async {
    if (container.isEmpty) return [];
    await _stateMutex.acquire();
    final oldState = await future;
    final currentContainers = <T>[];
    Logger.info('Updating ${container.length} containers');
    for (var c in container) {
      final current = oldState.currentOf<T>(c);
      if (current == null) {
        Logger.warning('Failed to update container. It was probably removed in the meantime.');
        continue;
      }
      currentContainers.add(current);
    }
    if (currentContainers.isEmpty) {
      Logger.warning('Failed to update containers. They were probably removed in the meantime.');
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

  Future<bool> unregisterDelete(TokenContainerFinalized container) async {
    try {
      if (!(await _containerApi.unregister(container)).success) return false;
    } on PiServerResultError catch (e) {
      if (e.code != PiServerResultErrorCodes.couldNotVerifySignature) {
        showErrorStatusMessage(
          message: (localization) => localization.piServerCode(e.code.toString()),
          details: (localization) => e.message,
        );
        return false;
      }
    } on ResponseError catch (e) {
      if (e.statusCode == 520 && e.message != "Unknown Error") {
        showErrorStatusMessage(
          message: (localization) => e.toString(),
        );
        return false;
      } else {
        showErrorStatusMessage(
          message: (localization) => localization.httpStatus(e.statusCode.toString()),
        );
      }
      return false;
    }

    await _stateMutex.acquire();
    final newState = await _deleteContainerFromRepo(container);
    await update((_) => newState);
    _stateMutex.release();
    return true;
  }

  Future<bool> deleteContainer(TokenContainer container) async {
    await _stateMutex.acquire();
    final newState = await _deleteContainerFromRepo(container);
    await update((_) => newState);
    _stateMutex.release();
    return true;
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
    final newState = await _saveContainersStateToRepo(TokenContainerState(containerList: combinedContainers));
    await update((_) => newState);
    _stateMutex.release();
    return newState;
  }

  /* /////////////////////////////////////////////////////////////////////////
  /////////////////////// HANDLE PROCESSOR RESULTS ///////////////////////////
  ///////////////////////////////////////////////////////////////////////// */

  /// Returns true if the processor result was handled successfully
  @override
  Future<bool> handleProcessorResult(ProcessorResult result, {Map<String, dynamic> args = const {}}) async {
    final failedContainer = await handleProcessorResults([result], args: args);
    return failedContainer?.isEmpty ?? false;
  }

  /// Returns a list of containers that failed to add
  @override
  Future<List<TokenContainerUnfinalized>?> handleProcessorResults(List<ProcessorResult> results, {Map<String, dynamic> args = const {}}) async {
    Logger.info('Handling processor results');
    final newContainers = results.getData().whereType<TokenContainerUnfinalized>().toList();
    final validatedArgs = TokenContainerProcessor.validateArgs(args);
    final doReplace = validatedArgs[TokenContainerProcessor.ARG_DO_REPLACE];
    bool? addDeviceInfos = validatedArgs[TokenContainerProcessor.ARG_ADD_DEVICE_INFOS];
    final initSync = validatedArgs[TokenContainerProcessor.ARG_INIT_SYNC] ?? true;
    final urlIsOk = validatedArgs[TokenContainerProcessor.ARG_URL_IS_OK];

    if (newContainers.isEmpty) return null;
    final currentState = await future;
    final stateContainers = currentState.containerList;
    final stateContainersSerials = stateContainers.map((e) => e.serial);
    List<TokenContainerUnfinalized> newContainerList = newContainers.where((element) => !stateContainersSerials.contains(element.serial)).toList();
    final existingContainers = newContainers.where((element) => stateContainersSerials.contains(element.serial)).toList();
    Logger.info('Handling processor results: adding Container');
    final replaceContainers = <TokenContainerUnfinalized>[];
    if (existingContainers.isNotEmpty) {
      replaceContainers.addAll(switch (doReplace) {
        true => existingContainers,
        false => [],
        null => await ContainerAlreadyExistsDialog.showDialog(existingContainers) ?? [],
      });
    }

    if (replaceContainers.isNotEmpty) {
      await deleteContainerList(replaceContainers);
      newContainerList.addAll(replaceContainers);
    }

    final stateAfterAdding = await addContainerList(newContainerList);
    final failedToAdd = <TokenContainerUnfinalized>[];
    Logger.info('Handling processor results: adding done (${newContainerList.length})');
    final List<Future<TokenContainerFinalized?>> finalizeFutures = [];
    for (var container in newContainerList) {
      if (!stateAfterAdding.containerList.contains(container)) {
        failedToAdd.add(container);
        continue;
      }
      Logger.info('Handling processor results: finalize');
      finalizeFutures.add(finalize(container, isManually: true, addDeviceInfos: addDeviceInfos, urlIsOk: urlIsOk));
    }

    final containersForInitSync = (await Future.wait(finalizeFutures)).whereType<TokenContainerFinalized>().toList();
    if (initSync) {
      syncContainers(tokenState: ref.read(tokenProvider), containersToSync: containersForInitSync, isManually: true, isInitSync: initSync);
    }

    return failedToAdd;
  }

  final Mutex _finalizationMutex = Mutex();
  Future<TokenContainerFinalized?> finalize(TokenContainer container, {required bool isManually, bool? addDeviceInfos, bool? urlIsOk}) async {
    await _finalizationMutex.acquire();
    if (container is! TokenContainerUnfinalized) {
      _finalizationMutex.release();
      throw ArgumentError('Container must not be finalized');
    }
    urlIsOk ??= ((await ContainerShowContainerUrlDialog.showDialog(container)) == true);
    if (!urlIsOk) {
      Logger.info('Url check declined: Aborting finalization (${container.serial})');
      _finalizationMutex.release();
      return null;
    }
    addDeviceInfos ??= (await ContainerSendDeviceInfosDialog.showDialog()) == true;
    final updatedContainer = await updateContainer(container, (TokenContainerUnfinalized c) => c.copyWith(addDeviceInfos: addDeviceInfos));
    if (updatedContainer == null) {
      _finalizationMutex.release();
      return null;
    }
    container = updatedContainer;
    if (container.expirationDate != null && container.expirationDate!.isBefore(DateTime.now())) {
      showErrorStatusMessage(message: (l) => l.containerRolloutExpired(container.serial));
      await deleteContainer(container);
      _finalizationMutex.release();
      return null;
    }

    try {
      container = await _generateKeyPair(container);
      container = await _curentOf<TokenContainerUnfinalized>(container);
      final ContainerFinalizationResponse response = await _sendPublicKey(container);
      container = await _curentOf<TokenContainerUnfinalized>(container);
      final finalizedContainer = await _applyFinalizationResponse(await _curentOf(container), response);
      _finalizationMutex.release();
      return finalizedContainer;
    } on StateError catch (e) {
      if (isManually) {
        ref.read(statusMessageProvider.notifier).state = StatusMessage(
          message: (localization) => container.finalizationState.asFailed.rolloutMsgLocalized(localization),
          details: (localization) => e.toString(),
        );
      }
    } on LocalizedArgumentError catch (e) {
      if (isManually) {
        showErrorStatusMessage(
          message: container.finalizationState.asFailed.rolloutMsgLocalized,
          details: e.localizedMessage,
        );
      }
    } on PiErrorResponse catch (e) {
      if (isManually) {
        showErrorStatusMessage(
          message: container.finalizationState.asFailed.rolloutMsgLocalized,
          details: (_) => e.piServerResultError.message,
        );
      }
    } on ResponseError catch (e) {
      if (isManually) {
        showErrorStatusMessage(
          message: container.finalizationState.asFailed.rolloutMsgLocalized,
          details: (_) => e.toString(),
        );
      }
    } catch (e) {
      Logger.error('Failed to finalize container ${container.serial}', error: e);
    }
    await updateContainer(container, (TokenContainerUnfinalized c) => c.copyWith(finalizationState: c.finalizationState.asFailed));
    _finalizationMutex.release();
    return null;
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

  /// Finalization substep 1: Generate key pair
  Future<TokenContainerUnfinalized> _generateKeyPair(TokenContainerUnfinalized tokenContainer) async {
    // generatingKeyPair,
    // generatingKeyPairFailed,
    // generatingKeyPairCompleted,
    TokenContainerUnfinalized? container = tokenContainer;
    container = await updateContainer<TokenContainerUnfinalized, TokenContainerUnfinalized>(
        container, (c) => c.copyWith(finalizationState: FinalizationState.generatingKeyPair));
    if (container == null) throw StateError('Container was removed');
    final keyPair = eccUtils.generateKeyPair(container.ecKeyAlgorithm);
    container = await updateContainer<TokenContainerUnfinalized, TokenContainerUnfinalized>(
        container, (c) => c.withClientKeyPair(keyPair) as TokenContainerUnfinalized);
    if (container == null) throw StateError('Container was removed');
    return container;
  }

  /// Finalization substep 2: Send public key
  Future<ContainerFinalizationResponse> _sendPublicKey(TokenContainerUnfinalized tokenContainer) async {
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

    final ContainerFinalizationResponse response;
    container = await updateContainer(container, (TokenContainerUnfinalized c) => c.copyWith(finalizationState: FinalizationState.sendingPublicKey));
    if (container == null) throw StateError('Container was removed');
    try {
      response = (await _containerApi.finalizeContainer(container, eccUtils));
    } catch (_) {
      container = await updateContainer(container, (TokenContainerUnfinalized c) => c.copyWith(finalizationState: FinalizationState.sendingPublicKeyFailed));
      rethrow;
    }

    container = await updateContainer(container, (TokenContainerUnfinalized c) => c.copyWith(finalizationState: FinalizationState.sendingPublicKeyCompleted));
    return response;
  }

  /// Finalization substep 3: Apply finalization response to container
  Future<TokenContainerFinalized> _applyFinalizationResponse(TokenContainer tokenContainer, ContainerFinalizationResponse response) async {
    // parsingResponse,
    // parsingResponseFailed,
    // parsingResponseCompleted,
    TokenContainer? container = tokenContainer;

    container = await updateContainer(container, (TokenContainerUnfinalized c) => c.copyWith(finalizationState: FinalizationState.sendingPublicKeyCompleted));
    if (container == null) throw StateError('Container was removed');

    container = await updateContainer(container, (TokenContainerUnfinalized c) => c.copyWith(finalizationState: FinalizationState.parsingResponse));
    if (container == null) throw StateError('Container was removed');

    // final signature = finalizationResponse.signature;
    final finalizedContainer = await updateContainer(
      container,
      (TokenContainerUnfinalized c) => c.copyWith(policies: response.policies).finalize()!,
    );
    if (finalizedContainer == null) throw StateError('Container was removed');
    return finalizedContainer;
  }

  Future<void> _handlePiServerResultError(PiServerResultError error, TokenContainerFinalized container, bool isManually) async {
    final context = (await contextedGlobalNavigatorKey).currentContext;
    if (error.code == PiServerResultErrorCodes.containerNotFound) {
      if (context == null || !context.mounted || !isManually) return;
      DeleteContainerDialog.showDialog(
        container,
        titleOverride: AppLocalizations.of(context)!.syncContainerNotFoundDialogTitle(container.serial),
        contentOverride: AppLocalizations.of(context)!.syncContainerNotFoundDialogContent,
      );
    }
  }
}

class PiServerResultErrorCodes {
  // Unable to find container with serial {serial}.
  static const containerNotFound = 601;
  static const couldNotVerifySignature = 3002;
}
