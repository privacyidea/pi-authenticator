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
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:privacyidea_authenticator/utils/helpers/mutex.dart';
import 'package:privacyidea_authenticator/model/container_policies.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/rollout_state_extension.dart';
import 'package:privacyidea_authenticator/model/extensions/token_list_extension.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_container_processor.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/views/container_view/container_widgets/dialogs/delete_container_dialogs.dart/delete_container_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/container_rollout_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../../model/exception_errors/error_codes.dart';
import '../../../../../../../model/exception_errors/pi_server_result_error.dart';
import '../../../../../../../model/processor_result.dart';
import '../../../../../../../model/tokens/token.dart';
import '../../../../../../../utils/privacyidea_io_client.dart';
import '../../../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
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
import '../../../../model/extensions/app_localizations_extension.dart';
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

final tokenContainerProvider = tokenContainerProviderOf(
  repo: SecureTokenContainerRepository(),
  containerApi: const PiContainerApi(ioClient: PrivacyideaIOClient()),
  eccUtils: const EccUtils(),
);

@Riverpod(keepAlive: true)
class TokenContainerNotifier extends _$TokenContainerNotifier
    with ResultHandler {
  final _stateMutex = Mutex();
  final _repoMutex = Mutex();
  // A sync call owns its request and commit as one ordered operation. This
  // prevents an older response from being applied after a newer invocation.
  final _syncMutex = Mutex();
  // Serializes the local commit phase of a container sync with local container
  // deletion. Network requests intentionally run outside this lock.
  final _containerLifecycleMutex = Mutex();
  final Set<String> _containersPendingDeletion = {};
  // A temporal pending flag is not enough: a delete attempt can finish before
  // an older sync response arrives. Keep a monotonic in-process generation so
  // that every response is committed only to the lifecycle it was sent for.
  final Map<String, int> _containerLifecycleRevision = {};

  TokenContainerNotifier({
    this._repoOverride,
    this._containerApiOverride,
    this._eccUtilsOverride,
  });

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
    Logger.info('Building containerProvider');
    late TokenContainerState initState;
    try {
      var loadedState = await _repo.loadContainerState();
      final containerList = loadedState.containerList.map((c) {
        if (c is! TokenContainerFinalized) return c;

        final fixedSyncState = c.syncState == SyncState.syncing
            ? SyncState.failed
            : c.syncState;
        return c.copyWith(syncState: fixedSyncState);
      }).toList();
      initState = loadedState.copyWith(containerList: containerList);
    } finally {
      _stateMutex.release();
    }
    for (var container
        in initState.containerList.whereType<TokenContainerUnfinalized>()) {
      unawaited(finalize(container, isManually: false));
    }
    return initState;
  }

  //////////////////////////////////////////////////////////////////
  ////////////////////////// REPO METHODS //////////////////////////
  //////////////////////////////////////////////////////////////////

  Future<TokenContainerState> _saveContainerToRepo(
    TokenContainer container,
  ) async {
    return await _repoMutex.protect(
      () async => await _repo.saveContainer(container),
    );
  }

  Future<TokenContainerState> _saveContainerListToRepo(
    List<TokenContainer> containers,
  ) async {
    return await _repoMutex.protect(
      () async => await _repo.saveContainerList(containers),
    );
  }

  Future<TokenContainerState> _saveContainersStateToRepo(
    TokenContainerState containerState,
  ) async {
    return await _repoMutex.protect(
      () async => await _repo.saveContainerState(containerState),
    );
  }

  Future<TokenContainerState> _deleteContainerFromRepo(
    TokenContainer container,
  ) async {
    return await _repoMutex.protect(
      () async => await _repo.deleteContainer(container.serial),
    );
  }

  /*//////////////////////////////////////////////////////////////////
////////////////////////// PUBLIC METHODS //////////////////////////
///////////////////////////////////////////////////////////////// */

  Future<Map<int, TokenContainerFinalized>> syncContainers({
    required TokenState tokenState,
    required bool isManually,
    List<TokenContainerFinalized>? containersToSync,
    bool? isInitSync,
  }) => _syncMutex.protect(
    () => _syncContainers(
      tokenState: tokenState,
      isManually: isManually,
      containersToSync: containersToSync,
      isInitSync: isInitSync,
    ),
  );

  Future<Map<int, TokenContainerFinalized>> _syncContainers({
    required TokenState tokenState,
    required bool isManually,
    List<TokenContainerFinalized>? containersToSync,
    bool? isInitSync,
  }) async {
    // A queued invocation may carry a snapshot from before the preceding sync
    // committed. Always send the latest local token state.
    tokenState = await ref.read(tokenProvider.future);
    List<TokenContainerFinalized> resolvedContainers;
    if (containersToSync == null) {
      final containerList = (await future).containerList;
      resolvedContainers = containerList
          .whereType<TokenContainerFinalized>()
          .where((e) => e.syncState != SyncState.syncing)
          .toList();
    } else {
      final current = <TokenContainer>[];
      for (final container in containersToSync) {
        final c = (await future).currentOf(container);
        if (c == null) continue;
        current.add(c);
      }
      resolvedContainers = current
          .whereType<TokenContainerFinalized>()
          .where((e) => e.syncState != SyncState.syncing)
          .toList();
    }
    late final Map<String, int> lifecycleRevisionAtRequest;
    var requestContainers = await _containerLifecycleMutex.protect(() async {
      final selected = resolvedContainers
          .where(
            (container) =>
                !_containersPendingDeletion.contains(container.serial),
          )
          .toList();
      lifecycleRevisionAtRequest = {
        for (final container in selected)
          container.serial: _containerLifecycleRevision[container.serial] ?? 0,
      };
      return selected;
    });
    if (requestContainers.isEmpty) {
      return {};
    }
    Logger.info('Syncing ${requestContainers.length} tokens');
    final syncFutures = <Future<ContainerSyncUpdates?>>[];

    Logger.debug('Change to sync state to syncing');
    requestContainers = await updateContainerList(
      requestContainers,
      (c) => c.copyWith(syncState: SyncState.syncing),
    );

    final failedContainers = <int, TokenContainerFinalized>{};

    for (var finalizedContainer in requestContainers) {
      syncFutures.add(
        _syncContainer(
          finalizedContainer,
          tokenState,
          isInitSync,
          isManually,
        ).onError((error, stackTrace) async {
          if (error is! PiServerResultError) {
            Logger.error(
              'Unexpected error type in _syncContainer',
              error: error,
              stackTrace: stackTrace,
            );
            return null;
          }
          failedContainers[error.code] = finalizedContainer;
          await _handlePiServerResultError(
            error,
            finalizedContainer,
            isManually,
          );
          return null;
        }),
      );
    }

    final newPoliciesMap = <String, ContainerPolicies>{};
    final syncUpdatesBySerial = <String, ContainerSyncUpdates>{};

    await Future.wait(syncFutures)
        .then((syncUpdates) {
          for (var syncUpdate in syncUpdates) {
            if (syncUpdate == null) continue;
            newPoliciesMap[syncUpdate.containerSerial] = syncUpdate.newPolicies;
            syncUpdatesBySerial[syncUpdate.containerSerial] = syncUpdate;
          }
        })
        .onError((error, stackTrace) {
          Logger.error(
            'Failed to sync container',
            error: error,
            stackTrace: stackTrace,
          );
        });

    return _containerLifecycleMutex.protect(() async {
      // A container can be deleted while its network request is in flight.
      // Re-resolve it at the local commit boundary and completely ignore a
      // response whose owner no longer exists. The same lifecycle lock is held
      // by deletion through token removal and container-state removal.
      var currentContainerState = await future;
      bool responseOwnerBecameStale(TokenContainerFinalized container) =>
          _containersPendingDeletion.contains(container.serial) ||
          lifecycleRevisionAtRequest[container.serial] !=
              (_containerLifecycleRevision[container.serial] ?? 0);
      final staleResponseOwners = requestContainers
          .where(
            (container) =>
                syncUpdatesBySerial.containsKey(container.serial) &&
                responseOwnerBecameStale(container) &&
                currentContainerState.containerOf(container.serial)
                    is TokenContainerFinalized,
          )
          .map(
            (container) =>
                currentContainerState.containerOf(container.serial)!
                    as TokenContainerFinalized,
          )
          .toList();
      if (staleResponseOwners.isNotEmpty) {
        // The response cannot be committed after a delete lifecycle started.
        // Keep a surviving container retryable; a successful deletion removes
        // this temporary state immediately afterwards.
        await updateContainerList(
          staleResponseOwners,
          (container) => container.copyWith(syncState: SyncState.failed),
        );
        currentContainerState = await future;
      }
      final successfullySyncedContainers = requestContainers
          .where(
            (container) =>
                syncUpdatesBySerial.containsKey(container.serial) &&
                !responseOwnerBecameStale(container) &&
                currentContainerState.containerOf(container.serial)
                    is TokenContainerFinalized,
          )
          .map(
            (container) =>
                currentContainerState.containerOf(container.serial)!
                    as TokenContainerFinalized,
          )
          .toList();
      if (successfullySyncedContainers.isEmpty) return failedContainers;

      final activeSerials = successfullySyncedContainers
          .map((container) => container.serial)
          .toSet();
      final activeUpdates = syncUpdatesBySerial.values
          .where((update) => activeSerials.contains(update.containerSerial))
          .toList();
      final newTokens = <Token>[];
      final syncedTokens = <Token>[];
      final deletedTokensNoOffline = <Token>[];
      final checkedContainersByTokenId = <String, List<String>>{};
      for (final syncUpdate in activeUpdates) {
        newTokens.addAll(syncUpdate.newTokens);
        syncedTokens.addAll(syncUpdate.updatedTokens);
        deletedTokensNoOffline.addAll(syncUpdate.deletedTokens.noOffline);
        for (final token in syncUpdate.initAssignmentChecked) {
          checkedContainersByTokenId
              .putIfAbsent(token.id, () => [])
              .add(syncUpdate.containerSerial);
        }
      }

      // Do not remove tokens that are synced in any other active container.
      deletedTokensNoOffline.removeWhere(
        (deletedToken) => syncedTokens.any(
          (syncedToken) => deletedToken.serial == syncedToken.serial,
        ),
      );

      var localUpdateSucceeded = true;
      try {
        final tokenNotifier = ref.read(tokenProvider.notifier);
        final failedUpdates = await tokenNotifier.applyContainerSync(
          updatedTokens: syncedTokens,
          newTokens: newTokens,
          deletedTokens: deletedTokensNoOffline,
          checkedContainersByTokenId: checkedContainersByTokenId,
        );
        if (failedUpdates.isNotEmpty) {
          localUpdateSucceeded = false;
          Logger.warning(
            'Container sync could not persist ${failedUpdates.length} token updates.',
          );
        }
      } catch (error, stackTrace) {
        localUpdateSucceeded = false;
        Logger.error(
          'Failed to persist container sync locally.',
          error: error,
          stackTrace: stackTrace,
        );
      }

      if (!localUpdateSucceeded) {
        await updateContainerList(
          successfullySyncedContainers,
          (container) => container.copyWith(syncState: SyncState.failed),
        );
        return failedContainers;
      }

      final completedContainers = await updateContainerList(
        successfullySyncedContainers,
        (container) => container.copyWith(
          syncState: SyncState.completed,
          initSynced: true,
          policies: newPoliciesMap[container.serial]!,
        ),
      );
      for (final container in completedContainers) {
        final syncUpdate = syncUpdatesBySerial[container.serial]!;
        ContainerSyncResultDialog.showDialog(
          container: container,
          addedTokens: syncUpdate.newTokens,
          removedTokens: syncUpdate.deletedTokens.noOffline,
        );
      }
      return failedContainers;
    });
  }

  Future<ContainerSyncUpdates?> _syncContainer(
    TokenContainerFinalized finalizedContainer,
    TokenState tokenState,
    bool? isInitSync,
    bool isManually,
  ) async {
    try {
      final syncUpdate = await _containerApi.sync(
        finalizedContainer,
        tokenState,
        isInitSync: isInitSync,
      );
      if (syncUpdate == null) {
        Logger.warning('Failed to sync container ${finalizedContainer.serial}');
        await updateContainer(
          finalizedContainer,
          (TokenContainerFinalized c) =>
              c.copyWith(syncState: SyncState.failed),
        );
        return null;
      }
      return syncUpdate;
    } catch (error, stackTrace) {
      final isMissingOnServer =
          error is PiServerResultError &&
          (error.code == PiServerResultErrorCodes.resourceNotFound ||
              error.code == PiServerResultErrorCodes.containerNotRegistered);
      if (!isMissingOnServer) {
        Logger.warning(
          'Failed to sync container ${finalizedContainer.serial}',
          error: error,
          stackTrace: stackTrace,
        );
      }
      await updateContainer(
        finalizedContainer,
        (TokenContainerFinalized c) => c.copyWith(syncState: SyncState.failed),
      );
      if (error is PiServerResultError) {
        rethrow;
      }
      if (!isManually) return null;
      showErrorStatusMessage(
        message: (localization) =>
            localization.failedToSyncContainer(finalizedContainer.serial),
        details: error is PiServerResultError
            ? (_) => error.message
            : (_) => error.toString(),
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
    final result = (await TokenContainerProcessor().processUri(
      uri,
    ))?.firstOrNull;
    if (result == null) throw StateError('Failed to process rollover uri');
    final success = await handleProcessorResult(
      result,
      args: {TokenContainerProcessor.ARG_DO_REPLACE: true},
    );
    return success;
  }

  Future<String> getRolloverQrData(TokenContainerFinalized container) async {
    final currentContainer = (await future).currentOf<TokenContainerFinalized>(
      container,
    );
    if (currentContainer == null) {
      throw StateError(
        '[${InAppErrorCodes.containerWasRemoved}] Container was removed',
      );
    }
    final qrCodeData = await _containerApi.getRolloverQrData(currentContainer);
    return qrCodeData.value;
  }

  // ADD CONTAINER

  Future<TokenContainerState> addContainer(TokenContainer container) async {
    return _containerLifecycleMutex.protect(() async {
      _advanceContainerLifecycle(container.serial);
      await _stateMutex.acquire();
      try {
        await future;
        final newState = await _saveContainerToRepo(container);
        await update((_) => newState);
        return newState;
      } finally {
        _stateMutex.release();
      }
    });
  }

  Future<TokenContainerState> addContainerList(
    List<TokenContainer> container,
  ) async {
    return _containerLifecycleMutex.protect(() async {
      for (final addedContainer in container) {
        _advanceContainerLifecycle(addedContainer.serial);
      }
      await _stateMutex.acquire();
      try {
        final newContainers = container.toList();
        final oldContainers = (await future).containerList;
        Logger.debug('Loaded container: $oldContainers');
        final combinedContainers = <TokenContainer>[];
        for (var oldContainer in oldContainers) {
          final newContainer = newContainers.firstWhereOrNull(
            (newContainer) => newContainer.serial == oldContainer.serial,
          );
          if (newContainer == null) {
            combinedContainers.add(oldContainer);
          } else {
            combinedContainers.add(newContainer);
            newContainers.remove(newContainer);
          }
        }
        combinedContainers.addAll(newContainers);
        Logger.debug('Combined container: $combinedContainers');
        final newState = await _saveContainersStateToRepo(
          TokenContainerState(containerList: combinedContainers),
        );
        Logger.debug('Saved container: $newState');
        await update((_) => newState);
        Logger.debug('Updated container: $newState');
        return newState;
      } finally {
        _stateMutex.release();
      }
    });
  }

  // UPDATE CONTAINER

  @override
  Future<TokenContainerState> update(
    FutureOr<TokenContainerState> Function(TokenContainerState state) cb, {
    FutureOr<TokenContainerState> Function(Object, StackTrace)? onError,
  }) async {
    Logger.info('Updating containerProvider');
    return super.update(cb, onError: onError);
  }

  Future<R?> updateContainer<
    R extends TokenContainer,
    T extends TokenContainer
  >(TokenContainer container, R Function(T) updater) async {
    return _containerLifecycleMutex.protect(() async {
      _advanceContainerLifecycle(container.serial);
      await _stateMutex.acquire();
      try {
        final oldState = await future;
        Logger.debug(
          'Updating container ${container.serial} updater: $updater',
        );
        final currentContainer = oldState.currentOf<T>(container);
        if (currentContainer == null) {
          Logger.info(
            'Failed to update container. It was probably removed in the meantime.',
          );
          return null;
        }
        Logger.info('Updating container ${currentContainer.serial}');
        final updated = updater(currentContainer);
        final newState = await _saveContainerToRepo(updated);
        await update((_) => newState);
        return updated;
      } finally {
        _stateMutex.release();
      }
    });
  }

  Future<List<T>> updateContainerList<T extends TokenContainer>(
    List<T> container,
    T Function(T) updater,
  ) async {
    if (container.isEmpty) return [];
    await _stateMutex.acquire();
    try {
      final oldState = await future;
      final currentContainers = <T>[];
      Logger.info('Updating ${container.length} containers');
      for (var c in container) {
        final current = oldState.currentOf<T>(c);
        if (current == null) {
          Logger.warning(
            'Failed to update container. It was probably removed in the meantime.',
          );
          continue;
        }
        currentContainers.add(current);
      }
      if (currentContainers.isEmpty) {
        Logger.warning(
          'Failed to update containers. They were probably removed in the meantime.',
        );
        return [];
      }
      final updated = <T>[];

      for (var c in currentContainers) {
        updated.add(updater(c));
      }
      final newState = await _saveContainerListToRepo(updated);
      await update((_) => newState);
      return updated;
    } finally {
      _stateMutex.release();
    }
  }

  // DELETE CONTAINER

  void _advanceContainerLifecycle(String serial) {
    _containerLifecycleRevision[serial] =
        (_containerLifecycleRevision[serial] ?? 0) + 1;
  }

  Future<bool> _beginContainerDeletion(String serial) =>
      _containerLifecycleMutex.protect(() async {
        if (!_containersPendingDeletion.add(serial)) return false;
        _advanceContainerLifecycle(serial);
        return true;
      });

  Future<void> _endContainerDeletion(String serial) =>
      _containerLifecycleMutex.protect(() async {
        _containersPendingDeletion.remove(serial);
      });

  Future<bool> _deleteLocalContainerAndTokens(TokenContainer container) async {
    return _containerLifecycleMutex.protect(() async {
      final tokenNotifier = ref.read(tokenProvider.notifier);
      final containerTokens = (await ref.read(
        tokenProvider.future,
      )).containerTokens(container.serial);

      await tokenNotifier.removeTokens(containerTokens);

      final remainingContainerTokens = (await ref.read(
        tokenProvider.future,
      )).containerTokens(container.serial);
      if (remainingContainerTokens.isNotEmpty) {
        Logger.warning(
          'Keeping container ${container.serial} because '
          '${remainingContainerTokens.length} managed tokens could not be removed.',
        );
        return false;
      }

      await _stateMutex.acquire();
      try {
        final newState = await _deleteContainerFromRepo(container);
        await update((_) => newState);
        return true;
      } finally {
        _stateMutex.release();
      }
    });
  }

  Future<bool> unregisterDelete(TokenContainerFinalized container) async {
    if (!await _beginContainerDeletion(container.serial)) return false;
    try {
      try {
        if (!(await _containerApi.unregister(container)).success) return false;
      } on PiServerResultError catch (e) {
        if (e.code == PiServerResultErrorCodes.resourceNotFound ||
            e.code == PiServerResultErrorCodes.containerNotRegistered) {
          // Server confirmed the container doesn't exist — proceed with local deletion.
        } else if (e.code !=
            PiServerResultErrorCodes.containerInvalidChallenge) {
          showErrorStatusMessage(
            message: (localization) =>
                localization.piServerCode(e.code.toString()),
            details: (localization) => e.message,
          );
          return false;
        }
      } on ResponseError catch (e) {
        if (e.statusCode == HttpStatusCodes.webServerReturnedUnknownError &&
            e.message != "Unknown Error") {
          showErrorStatusMessage(message: (localization) => e.toString());
          return false;
        } else {
          showErrorStatusMessage(
            message: (localization) => localization.httpStatusFor(e.statusCode),
          );
        }
        return false;
      }
      return await _deleteLocalContainerAndTokens(container);
    } finally {
      await _endContainerDeletion(container.serial);
    }
  }

  Future<bool> deleteContainer(TokenContainer container) async {
    if (!await _beginContainerDeletion(container.serial)) return false;
    try {
      return await _deleteLocalContainerAndTokens(container);
    } finally {
      await _endContainerDeletion(container.serial);
    }
  }

  Future<TokenContainerState> deleteContainerList(
    List<TokenContainer> container,
  ) async {
    return _containerLifecycleMutex.protect(() async {
      for (final deletedContainer in container) {
        _advanceContainerLifecycle(deletedContainer.serial);
      }
      await _stateMutex.acquire();
      try {
        final newContainers = container.toList();
        final oldContainers = (await future).containerList;
        final combinedContainers = <TokenContainer>[];
        for (var oldContainer in oldContainers) {
          final newContainer = newContainers.firstWhereOrNull(
            (newContainer) => newContainer.serial == oldContainer.serial,
          );
          if (newContainer == null) {
            combinedContainers.add(oldContainer);
          } else {
            newContainers.remove(newContainer);
          }
        }
        final newState = await _saveContainersStateToRepo(
          TokenContainerState(containerList: combinedContainers),
        );
        await update((_) => newState);
        return newState;
      } finally {
        _stateMutex.release();
      }
    });
  }

  /* /////////////////////////////////////////////////////////////////////////
  /////////////////////// HANDLE PROCESSOR RESULTS ///////////////////////////
  ///////////////////////////////////////////////////////////////////////// */

  /// Returns true if the processor result was handled successfully
  @override
  Future<bool> handleProcessorResult(
    ProcessorResult result, {
    Map<String, dynamic> args = const {},
  }) async {
    final failedContainer = await handleProcessorResults([result], args: args);
    return failedContainer?.isEmpty ?? false;
  }

  /// Returns a list of containers that failed to add
  @override
  Future<List<TokenContainerUnfinalized>?> handleProcessorResults(
    List<ProcessorResult> results, {
    Map<String, dynamic> args = const {},
  }) async {
    Logger.info('Handling processor results');
    final newContainers = results
        .getData()
        .whereType<TokenContainerUnfinalized>()
        .toList();
    final validatedArgs = TokenContainerProcessor.validateArgs(args);
    final doReplace = validatedArgs[TokenContainerProcessor.ARG_DO_REPLACE];
    bool? addDeviceInfos =
        validatedArgs[TokenContainerProcessor.ARG_ADD_DEVICE_INFOS];
    final initSync =
        validatedArgs[TokenContainerProcessor.ARG_INIT_SYNC] ?? true;
    final urlIsOk = validatedArgs[TokenContainerProcessor.ARG_URL_IS_OK];

    if (newContainers.isEmpty) return null;
    final currentState = await future;
    final stateContainers = currentState.containerList;
    final stateContainersSerials = stateContainers.map((e) => e.serial);
    List<TokenContainerUnfinalized> newContainerList = newContainers
        .where((element) => !stateContainersSerials.contains(element.serial))
        .toList();
    final existingContainers = newContainers
        .where((element) => stateContainersSerials.contains(element.serial))
        .toList();
    Logger.info('Handling processor results: adding Container');
    final replaceContainers = <TokenContainerUnfinalized>[];
    if (existingContainers.isNotEmpty) {
      final replaceableExisting = <TokenContainerUnfinalized>[];
      final blockedContainers = <TokenContainerUnfinalized>[];
      for (final newContainer in existingContainers) {
        final stateContainer = stateContainers.firstWhereOrNull(
          (c) => c.serial == newContainer.serial,
        );
        // Finalized containers can't be re-finalized on the server, so replacing
        // a locally finalized container always fails. Block it regardless of
        // the disabledUnregister policy.
        if (stateContainer is TokenContainerFinalized) {
          blockedContainers.add(newContainer);
        } else {
          replaceableExisting.add(newContainer);
        }
      }
      if (blockedContainers.isNotEmpty) {
        showErrorStatusMessage(message: (l) => l.containerAlreadyExists);
      }
      if (replaceableExisting.isNotEmpty) {
        replaceContainers.addAll(switch (doReplace) {
          true => replaceableExisting,
          false => [],
          null =>
            await ContainerAlreadyExistsDialog.showDialog(
                  replaceableExisting,
                ) ??
                [],
        });
      }
    }

    if (replaceContainers.isNotEmpty) {
      await deleteContainerList(replaceContainers);
      newContainerList.addAll(replaceContainers);
    }

    final stateAfterAdding = await addContainerList(newContainerList);
    final failedToAdd = <TokenContainerUnfinalized>[];
    Logger.info(
      'Handling processor results: adding done (${newContainerList.length})',
    );
    final List<Future<TokenContainerFinalized?>> finalizeFutures = [];
    for (var container in newContainerList) {
      if (!stateAfterAdding.containerList.contains(container)) {
        failedToAdd.add(container);
        continue;
      }
      Logger.info('Handling processor results: finalize');
      finalizeFutures.add(
        finalize(
          container,
          isManually: true,
          addDeviceInfos: addDeviceInfos,
          urlIsOk: urlIsOk,
        ),
      );
    }

    final containersForInitSync = (await Future.wait(
      finalizeFutures,
    )).whereType<TokenContainerFinalized>().toList();
    if (initSync) {
      syncContainers(
        tokenState: await ref.read(tokenProvider.future),
        containersToSync: containersForInitSync,
        isManually: true,
        isInitSync: initSync,
      );
    }

    return failedToAdd;
  }

  final Mutex _finalizationMutex = Mutex();
  Future<TokenContainerFinalized?> finalize(
    TokenContainer container, {
    required bool isManually,
    bool? addDeviceInfos,
    bool? urlIsOk,
  }) async {
    await _finalizationMutex.acquire();
    if (container is! TokenContainerUnfinalized) {
      _finalizationMutex.release();
      if (container is TokenContainerFinalized) {
        Logger.info(
          'Container is already finalized, skipping rollout: ${container.serial}',
        );
        return container;
      }
      Logger.error(
        'Unexpected container type for rollout: ${container.runtimeType}',
      );
      return null;
    }
    if (container.expirationDate != null &&
        container.expirationDate!.isBefore(DateTime.now())) {
      if (isManually) {
        showErrorStatusMessage(
          message: (l) => l.containerRolloutExpired(container.serial),
        );
      }
      await deleteContainer(container);
      _finalizationMutex.release();
      return null;
    }
    urlIsOk ??=
        ((await ContainerShowContainerUrlDialog.showDialog(container)) == true);
    if (!urlIsOk) {
      Logger.info(
        'Url check declined: Aborting finalization (${container.serial})',
      );
      _finalizationMutex.release();
      return null;
    }
    addDeviceInfos ??=
        (await ContainerSendDeviceInfosDialog.showDialog()) == true;
    final updatedContainer = await updateContainer(
      container,
      (TokenContainerUnfinalized c) =>
          c.copyWith(addDeviceInfos: addDeviceInfos),
    );
    if (updatedContainer == null) {
      _finalizationMutex.release();
      return null;
    }
    container = updatedContainer;

    bool finalizationSucceeded = false;
    try {
      container = await _generateKeyPair(container);
      container = await _currentOf<TokenContainerUnfinalized>(container);
      final ContainerFinalizationResponse response = await _sendPublicKey(
        container,
      );
      container = await _currentOf<TokenContainerUnfinalized>(container);
      final finalizedContainer = await _applyFinalizationResponse(
        await _currentOf(container),
        response,
      );
      finalizationSucceeded = true;
      return finalizedContainer;
    } on StateError catch (e) {
      if (isManually) {
        showErrorStatusMessage(
          message: (localization) => container.finalizationState.asFailed
              .rolloutMsgLocalized(localization),
          details: (_) => e.toString(),
        );
      }
    } on LocalizedArgumentError catch (e) {
      if (isManually) {
        showErrorStatusMessage(
          message: container.finalizationState.asFailed.rolloutMsgLocalized,
          details: e.localizedMessage,
        );
      }
    } on PiServerResultError catch (e) {
      if (isManually) {
        showErrorStatusMessage(
          message: container.finalizationState.asFailed.rolloutMsgLocalized,
          details: (_) => e.message,
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
      Logger.error(
        'Failed to finalize container ${container.serial}',
        error: e,
      );
    } finally {
      if (!finalizationSucceeded) {
        await updateContainer(
          container,
          (TokenContainerUnfinalized c) =>
              c.copyWith(finalizationState: c.finalizationState.asFailed),
        );
      }
      _finalizationMutex.release();
    }
    return null;
  }

  /* /////////////////////////////////////////////////////////////////////////
////////////////// PRIVATE HELPER METHODS FINALIZATION /////////////////////
///////////////////////////////////////////////////////////////////////// */

  Future<T> _currentOf<T extends TokenContainer>(
    TokenContainer container,
  ) async {
    final current = (await future).currentOf(container);
    if (current == null) {
      throw StateError(
        '[${InAppErrorCodes.containerWasRemoved}] Container was removed',
      );
    }
    if (current is! T) throw StateError('Container is not of type $T');
    return current;
  }

  /// Finalization substep 1: Generate key pair
  Future<TokenContainerUnfinalized> _generateKeyPair(
    TokenContainerUnfinalized tokenContainer,
  ) async {
    if (tokenContainer.clientKeyPair != null ||
        (tokenContainer.publicClientKey != null &&
            tokenContainer.privateClientKey != null)) {
      return tokenContainer;
    }
    // generatingKeyPair,
    // generatingKeyPairFailed,
    // generatingKeyPairCompleted,
    TokenContainerUnfinalized? container = tokenContainer;
    container =
        await updateContainer<
          TokenContainerUnfinalized,
          TokenContainerUnfinalized
        >(
          container,
          (c) => c.copyWith(
            finalizationState: FinalizationState.generatingKeyPair,
          ),
        );
    if (container == null) {
      throw StateError(
        '[${InAppErrorCodes.containerWasRemoved}] Container was removed',
      );
    }
    if (container.clientKeyPair != null) return container;
    final keyPair = eccUtils.generateKeyPair(container.ecKeyAlgorithm);
    container =
        await updateContainer<
          TokenContainerUnfinalized,
          TokenContainerUnfinalized
        >(
          container,
          (c) => c.withClientKeyPair(keyPair) as TokenContainerUnfinalized,
        );
    if (container == null) {
      throw StateError(
        '[${InAppErrorCodes.containerWasRemoved}] Container was removed',
      );
    }
    return container;
  }

  /// Finalization substep 2: Send public key
  Future<ContainerFinalizationResponse> _sendPublicKey(
    TokenContainerUnfinalized tokenContainer,
  ) async {
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
    container = await updateContainer(
      container,
      (TokenContainerUnfinalized c) =>
          c.copyWith(finalizationState: FinalizationState.sendingPublicKey),
    );
    if (container == null) {
      throw StateError(
        '[${InAppErrorCodes.containerWasRemoved}] Container was removed',
      );
    }
    try {
      response = (await _containerApi.finalizeContainer(container, eccUtils));
    } on ResponseError catch (e) {
      Logger.debug(
        "Failed to parse container finalization response: Response is not from privacyIDEA server",
        error: e,
      );
      rethrow;
    }

    container = await updateContainer(
      container,
      (TokenContainerUnfinalized c) => c.copyWith(
        finalizationState: FinalizationState.sendingPublicKeyCompleted,
      ),
    );
    if (container == null) {
      throw StateError(
        '[${InAppErrorCodes.containerWasRemoved}] Container was removed',
      );
    }
    return response;
  }

  /// Finalization substep 3: Apply finalization response to container
  Future<TokenContainerFinalized> _applyFinalizationResponse(
    TokenContainer tokenContainer,
    ContainerFinalizationResponse response,
  ) async {
    // parsingResponse,
    // parsingResponseFailed,
    // parsingResponseCompleted,
    TokenContainer? container = tokenContainer;

    container = await updateContainer(
      container,
      (TokenContainerUnfinalized c) => c.copyWith(
        finalizationState: FinalizationState.sendingPublicKeyCompleted,
      ),
    );
    if (container == null) {
      throw StateError(
        '[${InAppErrorCodes.containerWasRemoved}] Container was removed',
      );
    }

    container = await updateContainer(
      container,
      (TokenContainerUnfinalized c) =>
          c.copyWith(finalizationState: FinalizationState.parsingResponse),
    );
    if (container == null) {
      throw StateError(
        '[${InAppErrorCodes.containerWasRemoved}] Container was removed',
      );
    }

    // final signature = finalizationResponse.signature;
    final finalizedContainer = await updateContainer(container, (
      TokenContainerUnfinalized c,
    ) {
      final finalized = c.copyWith(policies: response.policies).finalize();
      if (finalized == null) {
        throw StateError(
          'Unable to finalize container ${c.serial}: missing client key pair',
        );
      }
      return finalized;
    });
    if (finalizedContainer == null) {
      throw StateError(
        '[${InAppErrorCodes.containerWasRemoved}] Container was removed',
      );
    }
    return finalizedContainer;
  }

  Future<void> _handlePiServerResultError(
    PiServerResultError error,
    TokenContainerFinalized container,
    bool isManually,
  ) async {
    if (error.code == PiServerResultErrorCodes.resourceNotFound ||
        error.code == PiServerResultErrorCodes.containerNotRegistered) {
      Logger.info(
        'Container ${container.serial} no longer exists on the server. '
        'Updating its local state.',
      );
      // Server no longer has this container — clear disabledUnregister so the
      // delete button is enabled even if the server policy previously blocked it.
      await updateContainer(
        container,
        (TokenContainerFinalized c) => c.copyWith(
          policies: c.policies.copyWith(disabledUnregister: false),
        ),
      );
      final context = (await contextedGlobalNavigatorKey).currentContext;
      if (context == null || !context.mounted || !isManually) return;
      DeleteContainerDialog.showDialog(
        container,
        titleOverride: AppLocalizations.of(
          context,
        )!.syncContainerNotFoundDialogTitle(container.serial),
        contentOverride: AppLocalizations.of(
          context,
        )!.syncContainerNotFoundDialogContent,
      );
    } else if (isManually) {
      showErrorStatusMessage(
        message: (l) => l.failedToSyncContainer(container.serial),
        details: (_) => error.message,
      );
    }
  }
}
