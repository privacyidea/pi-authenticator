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
import 'package:privacyidea_authenticator/model/extensions/enums/ec_key_algorithm_extension.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../api/token_container_api_endpoint.dart';
import '../../../../interfaces/repo/token_container_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../model/enums/container_finalization_state.dart';
import '../../../../model/riverpod_states/token_container_state.dart';
import '../../../../model/riverpod_states/token_state.dart';
import '../../../../model/token_container.dart';
import '../../../../repo/secure_token_container_repository.dart';
import '../../../ecc_utils.dart';
import '../../../errors.dart';
import '../../../logger.dart';

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
    Logger.warning('Building containerProvider', name: 'CredentialsNotifier');

    final initState = await _repo.loadCredentialsState();
    for (var container in initState.container.whereType<TokenContainerUnfinalized>()) {
      finalize(container);
    }
    _stateMutex.release();
    return initState;
  }

//////////////////////////////////////////////////////////////////
////////////////////////// REPO METHODS //////////////////////////
//////////////////////////////////////////////////////////////////

  Future<TokenContainerState> _saveCredentialToRepo(TokenContainer container) async {
    return await _repoMutex.protect(() async => await _repo.saveCredential(container));
  }

  Future<TokenContainerState> _saveCredentialsStateToRepo(TokenContainerState containerState) async {
    return await _repoMutex.protect(() async => await _repo.saveCredentialsState(containerState));
  }

  Future<TokenContainerState> _deleteCredentialFromRepo(TokenContainer container) async {
    return await _repoMutex.protect(() async => await _repo.deleteCredential(container.serial));
  }

  Future<TokenContainerState> _deleteCredentialsStateToRepo() async {
    return await _repoMutex.protect(() async => await _repo.deleteAllCredentials());
  }

/*//////////////////////////////////////////////////////////////////
////////////////////////// PUBLIC METHODS //////////////////////////
///////////////////////////////////////////////////////////////// */

// ADD CREDENTIALS

  Future<TokenContainerState> addCredential(TokenContainer container) async {
    await _stateMutex.acquire();
    final newState = await _saveCredentialToRepo(container);
    await update((_) => newState);
    _stateMutex.release();
    return newState;
  }

  Future<TokenContainerState> addCredentials(List<TokenContainer> container) async {
    await _stateMutex.acquire();
    final newCredentials = container.toList();
    final oldCredentials = (await future).container;
    Logger.debug('Loaded container: $oldCredentials', name: 'CredentialsNotifier#addCredentials');
    final combinedCredentials = <TokenContainer>[];
    for (var oldCredential in oldCredentials) {
      final newCredential = newCredentials.firstWhereOrNull((newCredential) => newCredential.serial == oldCredential.serial);
      if (newCredential == null) {
        combinedCredentials.add(oldCredential);
      } else {
        combinedCredentials.add(newCredential);
        newCredentials.remove(newCredential);
      }
    }
    combinedCredentials.addAll(newCredentials);
    Logger.debug('Combined container: $combinedCredentials', name: 'CredentialsNotifier#addCredentials');
    final newState = await _saveCredentialsStateToRepo(TokenContainerState(container: combinedCredentials));
    Logger.debug('Saved container: $newState', name: 'CredentialsNotifier#addCredentials');
    await update((_) => newState);
    Logger.debug('Updated container: $newState', name: 'CredentialsNotifier#addCredentials');
    _stateMutex.release();
    return newState;
  }

  // UPDATE CREDENTIALS

  @override
  Future<TokenContainerState> update(
    FutureOr<TokenContainerState> Function(TokenContainerState state) cb, {
    FutureOr<TokenContainerState> Function(Object, StackTrace)? onError,
  }) async {
    Logger.warning('Updating containerProvider', name: 'CredentialsNotifier');
    return super.update(cb, onError: onError);
  }

  Future<T?> updateCredential<T extends TokenContainer>(T container, T Function(T) updater) async {
    await _stateMutex.acquire();
    final oldState = await future;
    final currentCredential = oldState.currentOf<T>(container);
    if (currentCredential == null) {
      Logger.info('Failed to update container. It was probably removed in the meantime.', name: 'CredentialsNotifier#updateCredential');
      _stateMutex.release();
      return null;
    }
    final updated = updater(currentCredential);
    final newState = await _saveCredentialToRepo(updated);
    await update((_) => newState);
    _stateMutex.release();
    return updated;
  }

  // DELETE CREDENTIALS

  Future<TokenContainerState> deleteCredential(TokenContainer container) async {
    await _stateMutex.acquire();
    final newState = await _deleteCredentialFromRepo(container);
    await update((_) => newState);
    _stateMutex.release();
    return newState;
  }

  Future<TokenContainerState> deleteCredentials(List<TokenContainer> container) async {
    await _stateMutex.acquire();
    final newCredentials = container.toList();
    final oldCredentials = (await future).container;
    final combinedCredentials = <TokenContainer>[];
    for (var oldCredential in oldCredentials) {
      final newCredential = newCredentials.firstWhereOrNull((newCredential) => newCredential.serial == oldCredential.serial);
      if (newCredential == null) {
        combinedCredentials.add(oldCredential);
      } else {
        newCredentials.remove(newCredential);
      }
    }
    final newState = await _saveCredentialsStateToRepo(TokenContainerState(container: combinedCredentials));
    await update((_) => newState);
    _stateMutex.release();
    return newState;
  }

  // HANDLE PROCESSOR RESULTS

  @override
  Future<void> handleProcessorResult(ProcessorResult result, Map<String, dynamic> args) {
    // TODO: implement handleResult
    throw UnimplementedError();
  }

  @override
  Future<List?> handleProcessorResults(List<ProcessorResult> results, Map<String, dynamic> args) async {
    Logger.info('Handling processor results', name: 'CredentialsNotifier#handleProcessorResults');
    final containerCredentials = results.getData().whereType<TokenContainer>().toList();
    if (containerCredentials.isEmpty) {
      return null;
    }
    final currentState = await future;
    final stateCredentials = currentState.container;
    final stateCredentialsSerials = stateCredentials.map((e) => e.serial);
    final newCredentials = containerCredentials.where((element) => !stateCredentialsSerials.contains(element.serial)).toList();
    Logger.info('Handling processor results: adding Credential', name: 'CredentialsNotifier#handleProcessorResults');
    await addCredentials(newCredentials);
    Logger.info('Handling processor results: adding done (${newCredentials.length})', name: 'CredentialsNotifier#handleProcessorResults');
    for (var container in newCredentials) {
      Logger.info('Handling processor results: finalize check ()', name: 'CredentialsNotifier#handleProcessorResults');
      if (container is! TokenContainerUnfinalized) continue;
      Logger.info('Handling processor results: finalize', name: 'CredentialsNotifier#handleProcessorResults');
      await finalize(container);
    }
    return null;
  }

  final Mutex _finalizationMutex = Mutex();
  Future<void> finalize(TokenContainer container) async {
    await _finalizationMutex.acquire();
    if (container is! TokenContainerUnfinalized) {
      _finalizationMutex.release();
      throw ArgumentError('Container must not be finalized');
    }
    Logger.info('Finalizing container ${container.serial}', name: 'CredentialsNotifier#finalize');
    try {
      container = await _generateKeyPair(container);
      final Response response;
      (container, response) = await _sendPublicKey(container);
      if (response.statusCode != 200) {
        if (response.piServerMessage != null) {
          ref.read(statusMessageProvider.notifier).state = (
            'Failed to finalize container: ${response.piServerMessage}',
            response.piStatusCode != null ? 'PI Server code ${response.piStatusCode}' : 'Status code ${response.body}'
          );
        } else {
          ref.read(statusMessageProvider.notifier).state = ('Failed to finalize container: ${response.body}', 'Status code ${response.statusCode}');
        }
        _finalizationMutex.release();
        return;
      }
      final ECPublicKey publicServerKey;
      (container, publicServerKey) = await _parseResponse(container, response);
      await updateCredential(container, (c) => c.finalize(publicServerKey: publicServerKey)!);
    } on StateError {
      Logger.info('Container was removed while finalizing', name: 'CredentialsNotifier#finalize');
    } on LocalizedArgumentError catch (e) {
      ref.read(statusMessageProvider.notifier).state = ('Failed to decode response body', e.localizedMessage(AppLocalizations.of(await globalContext)!));
      await updateCredential(container, (c) => c.copyWith(finalizationState: ContainerFinalizationState.parsingResponseFailed));
    } catch (e) {
      Logger.error('Failed to finalize container ${container.serial}', name: 'CredentialsNotifier#finalize', error: e);
      _finalizationMutex.release();
      return;
    }
    _finalizationMutex.release();
  }

/* /////////////////////////////////////////////////////////////////////////
////////////////////////// PRIVATE HELPER METHODS //////////////////////////
///////////////////////////////////////////////////////////////////////// */

  /// Finalization substep 1: Generate key pair
  Future<TokenContainerUnfinalized> _generateKeyPair(TokenContainerUnfinalized containerCredential) async {
    // generatingKeyPair,
    // generatingKeyPairFailed,
    // generatingKeyPairCompleted,
    TokenContainerUnfinalized? container = containerCredential;
    container = await updateCredential(container, (c) => c.copyWith(finalizationState: ContainerFinalizationState.generatingKeyPair));
    if (container == null) throw StateError('Credential was removed');
    final keyPair = CryptoUtils.generateEcKeyPair(curve: container.ecKeyAlgorithm.curveName) as AsymmetricKeyPair<ECPublicKey, ECPrivateKey>;
    container = await updateCredential(container, (c) => c.withClientKeyPair(keyPair) as TokenContainerUnfinalized);
    if (container == null) throw StateError('Credential was removed');
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
    container = await updateCredential<TokenContainerUnfinalized>(container, (c) => c.copyWith(finalizationState: ContainerFinalizationState.sendingPublicKey));
    if (container == null) throw StateError('Credential was removed');
    try {
      response = (await _containerApi.finalizeContainer(container, eccUtils))!;
    } catch (e) {
      ref.read(statusMessageProvider.notifier).state = ('Failed to finalize container', e.toString());
      await updateCredential(container, (c) => c.copyWith(finalizationState: ContainerFinalizationState.sendingPublicKeyFailed));
      rethrow;
    }
    if (response.statusCode != 200) {
      container = await updateCredential(container, (c) => c.copyWith(finalizationState: ContainerFinalizationState.sendingPublicKeyFailed));
      if (container == null) throw StateError('Credential was removed');
      return (container, response);
    }

    container = await updateCredential(container, (c) => c.copyWith(finalizationState: ContainerFinalizationState.sendingPublicKeyCompleted));
    if (container == null) throw StateError('Credential was removed');
    return (container, response);
  }

  /// Finalization substep 3: Parse response
  Future<(TokenContainer, ECPublicKey)> _parseResponse(TokenContainer containerCredential, Response response) async {
    // parsingResponse,
    // parsingResponseFailed,
    // parsingResponseCompleted,

    TokenContainer? container = containerCredential;
    ECPublicKey publicServerKey;
    String responseBody = response.body;
    Map<String, dynamic> responseJson;
    container = await updateCredential(container, (c) => c.copyWith(finalizationState: ContainerFinalizationState.parsingResponse));
    if (container == null) throw StateError('Credential was removed');
    responseJson = jsonDecode(responseBody);
    Logger.debug('Response JSON: $responseJson', name: 'CredentialsNotifier#_parseResponse');
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
    container =
        await updateCredential(container, (c) => c.copyWith(finalizationState: ContainerFinalizationState.parsingResponseCompleted, syncUrl: syncUrlUri));
    if (container == null) throw StateError('Credential was removed');
    return (container, publicServerKey);
  }

  Future<void> syncTokens(TokenState tokenState) async {
    final containerCredentials = (await future).container;
    final containerCredential = containerCredentials.whereType<TokenContainerFinalized>().first;

    List<Token> syncedTokens;
    List<String> deletedTokens;
    final tuple = await _containerApi.sync(
      containerCredential,
      tokenState,
    );
    if (tuple == null) {
      return;
    }
    syncedTokens = tuple.$1;
    deletedTokens = tuple.$2;

    await ref.read(tokenProvider.notifier).addOrReplaceTokens(syncedTokens);
    await ref.read(tokenProvider.notifier).removeTokensBySerials(deletedTokens);
  }
}
