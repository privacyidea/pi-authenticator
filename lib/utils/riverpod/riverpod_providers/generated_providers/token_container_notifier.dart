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
import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../api/token_container_api_endpoint.dart';
import '../../../../interfaces/repo/token_container_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../model/enums/rollout_state.dart';
import '../../../../model/riverpod_states/token_container_state.dart';
import '../../../../model/riverpod_states/token_state.dart';
import '../../../../model/token_container.dart';
import '../../../../repo/secure_token_container_repository.dart';
import '../../../../widgets/dialog_widgets/add_container_progress_dialog.dart';
import '../../../../widgets/dialog_widgets/container_already_exists_dialog.dart';
import '../../../ecc_utils.dart';
import '../../../errors.dart';
import '../../../logger.dart';
import '../../../object_validator.dart';

part 'token_container_notifier.g.dart';

final tokenContainerProvider = tokenContainerNotifierProviderOf(
  repo: SecureTokenContainerRepository(),
  containerApi: const PrivacyideaContainerApi(ioClient: PrivacyideaIOClient()),
  eccUtils: const EccUtils(),
);

@Riverpod(keepAlive: true)
class TokenContainerNotifier extends _$TokenContainerNotifier with ResultHandler {
  final _stateMutex = Mutex();
  final _repoMutex = Mutex();

  TokenContainerNotifier({
    TokenContainerRepository? repoOverride,
    PrivacyideaContainerApi? containerApiOverride,
    EccUtils? eccUtilsOverride,
  })  : _repoOverride = repoOverride,
        _containerApiOverride = containerApiOverride,
        _eccUtilsOverride = eccUtilsOverride;

  @override
  TokenContainerRepository get repo => _repo;
  late TokenContainerRepository _repo;
  final TokenContainerRepository? _repoOverride;

  @override
  PrivacyideaContainerApi get containerApi => _containerApi;
  late PrivacyideaContainerApi _containerApi;
  final PrivacyideaContainerApi? _containerApiOverride;

  @override
  EccUtils get eccUtils => _eccUtils;
  late EccUtils _eccUtils;
  final EccUtils? _eccUtilsOverride;

  @override
  Future<TokenContainerState> build({
    required TokenContainerRepository repo,
    required PrivacyideaContainerApi containerApi,
    required EccUtils eccUtils,
  }) async {
    await _stateMutex.acquire();
    _repo = _repoOverride ?? repo;
    _containerApi = _containerApiOverride ?? containerApi;
    _eccUtils = _eccUtilsOverride ?? eccUtils;
    Logger.warning('Building containerProvider');

    final initState = await _repo.loadContainerState();
    for (var container in initState.containerList.whereType<TokenContainerUnfinalized>()) {
      finalize(container);
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

// ADD CONTAINER

  Future<TokenContainerState> addContainer(TokenContainer container) async {
    await _stateMutex.acquire();
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

  /* /////////////////////////////////////////////////////////////////////////
  ////////////////////////// UPDATE CONTAINER ////////////////////////////////
  ///////////////////////////////////////////////////////////////////////// */

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

  /* /////////////////////////////////////////////////////////////////////////
  ///////////////////////// DELETE CONTAINER /////////////////////////////////
  ///////////////////////////////////////////////////////////////////////// */

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
    if (existingContainers.isNotEmpty) await _showContainerAlreadyExistsDialog(existingContainers);
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
      finalizeFutures.add(finalize(container));
    }
    await Future.wait(finalizeFutures);
    await syncTokens(ref.read(tokenProvider), isManually: true);

    return failedToAdd;
  }

  final Mutex _finalizationMutex = Mutex();
  Future<void> finalize(TokenContainer container) async {
    await _finalizationMutex.acquire();
    if (container is! TokenContainerUnfinalized) {
      _finalizationMutex.release();
      throw ArgumentError('Container must not be finalized');
    }
    Logger.info('Finalizing container ${container.serial}');
    try {
      container = await _generateKeyPair(container);
      final Response response;
      (container, response) = await _sendPublicKey(container);
      if (response.statusCode != 200) {
        if (response.piServerMessage != null) {
          final AppLocalizations appLocalizations = AppLocalizations.of(await globalContext)!;
          ref.read(statusMessageProvider.notifier).state = (
            appLocalizations.failedToFinalizeContainer(response.piServerMessage.toString(), container.serial),
            response.piStatusCode != null ? appLocalizations.piServerCode(response.piStatusCode!) : appLocalizations.statusCode(response.piStatusCode ?? '520'),
            // response.piStatusCode != null ? 'PI Server code ${response.piStatusCode}' : 'Status code ${response.body}'
          );
        } else {
          ref.read(statusMessageProvider.notifier).state = ('Failed to finalize container: ${response.body}', 'Status code ${response.statusCode}');
        }
        _finalizationMutex.release();
        return;
      }
      final ECPublicKey publicServerKey;
      (container, publicServerKey) = await _parseResponse(container, response);
      await updateContainer(container, (c) => c.finalize(publicServerKey: publicServerKey)!);
    } on StateError {
      Logger.info('Container was removed while finalizing');
    } on LocalizedArgumentError catch (e) {
      ref.read(statusMessageProvider.notifier).state = ('Failed to decode response body', e.localizedMessage(AppLocalizations.of(await globalContext)!));
      await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.parsingResponseFailed));
    } catch (e) {
      Logger.error('Failed to finalize container ${container.serial}', error: e);
      _finalizationMutex.release();
      return;
    }
    _finalizationMutex.release();
  }

/* /////////////////////////////////////////////////////////////////////////
////////////////////////// PRIVATE HELPER METHODS //////////////////////////
///////////////////////////////////////////////////////////////////////// */

  void _showAddContainerProgressDialog(List<TokenContainer> containers) {
    final serials = containers.map((e) => e.serial).toList();
    showAsyncDialog(builder: (context) => AddContainerProgressDialog(serials), barrierDismissible: false);
  }

  Future<void> _showContainerAlreadyExistsDialog(List<TokenContainer> containers) {
    final serials = containers.map((e) => e.serial).toList();
    return showAsyncDialog(builder: (context) => ContainerAlreadyExistsDialog(serials), barrierDismissible: false);
  }

  /// Finalization substep 1: Generate key pair
  Future<TokenContainerUnfinalized> _generateKeyPair(TokenContainerUnfinalized containerContainer) async {
    // generatingKeyPair,
    // generatingKeyPairFailed,
    // generatingKeyPairCompleted,
    TokenContainerUnfinalized? container = containerContainer;
    container = await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.generatingKeyPair));
    if (container == null) throw StateError('Container was removed');
    final keyPair = eccUtils.generateKeyPair(container.ecKeyAlgorithm);
    container = await updateContainer(container, (c) => c.withClientKeyPair(keyPair) as TokenContainerUnfinalized);
    if (container == null) throw StateError('Container was removed');
    return container;
  }

  /// Finalization substep 2: Send public key
  Future<(TokenContainer, Response)> _sendPublicKey(TokenContainerUnfinalized containerc) async {
    // sendingPublicKey,
    // sendingPublicKeyFailed,
    // sendingPublicKeyCompleted,

    //POST /container/register/finalize
    // Request: {
    // 'container_serial': <serial>,
    // 'public_client_key': <public key container base64 url encoded>,
    // 'signature': <sig( <nonce|timestamp|registration_url|serial[|passphrase]> )>,
    // }

    TokenContainerUnfinalized? container = containerc;

    final Response response;
    container = await updateContainer<TokenContainerUnfinalized>(container, (c) => c.copyWith(finalizationState: RolloutState.sendingPublicKey));
    if (container == null) throw StateError('Container was removed');
    try {
      response = (await _containerApi.finalizeContainer(container, eccUtils))!;
    } catch (e) {
      ref.read(statusMessageProvider.notifier).state = ('Failed to finalize container', e.toString());
      await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.sendingPublicKeyFailed));
      rethrow;
    }
    if (response.statusCode != 200) {
      container = await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.sendingPublicKeyFailed));
      if (container == null) throw StateError('Container was removed');
      return (container, response);
    }

    container = await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.sendingPublicKeyCompleted));
    if (container == null) throw StateError('Container was removed');
    return (container, response);
  }

  /// Finalization substep 3: Parse response
  Future<(TokenContainer, ECPublicKey)> _parseResponse(TokenContainer containerContainer, Response response) async {
    // parsingResponse,
    // parsingResponseFailed,
    // parsingResponseCompleted,

    TokenContainer? container = containerContainer;
    ECPublicKey publicServerKey;
    String responseBody = response.body;
    Map<String, dynamic> responseJson;
    container = await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.parsingResponse));
    if (container == null) throw StateError('Container was removed');
    responseJson = jsonDecode(responseBody);
    Logger.debug('Response JSON: $responseJson');
    final result = validate(value: responseJson['result'], validator: const ObjectValidator<Map<String, dynamic>>(), name: 'result');
    final value = validate(value: result['value'], validator: const ObjectValidator<Map<String, dynamic>>(), name: 'value');
    publicServerKey = validate(
      value: value['public_server_key'],
      validator: ObjectValidator<ECPublicKey>(transformer: (v) => const EccUtils().deserializeECPublicKey(v)),
      name: 'public_server_key',
    );
    final syncUrlUri = validate(
      value: value['container_sync_url'],
      validator: ObjectValidator<Uri>(transformer: (v) => Uri.parse(v)),
      name: 'container_sync_url',
    );
    container = await updateContainer(container, (c) => c.copyWith(finalizationState: RolloutState.parsingResponseCompleted, syncUrl: syncUrlUri));
    if (container == null) throw StateError('Container was removed');
    return (container, publicServerKey);
  }

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

    for (var finalized in containersToSync) {
      syncFutures.add(Future(() async {
        final syncResult = await _containerApi.sync(
          finalized,
          tokenState,
          isManually: isManually,
        );
        if (syncResult == null) {
          await updateContainer(finalized, (c) => c.copyWith(syncState: SyncState.failed));
          return null;
        }
        await updateContainer(finalized, (c) => c.copyWith(syncState: SyncState.completed));
        return syncResult;
      }));
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
}
