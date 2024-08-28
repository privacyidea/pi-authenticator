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
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../interfaces/repo/container_credentials_repository.dart';
import '../../../../model/riverpod_states/credentials_state.dart';
import '../../../../model/tokens/container_credentials.dart';
import '../../../../repo/secure_container_credentials_repository.dart';
import '../../../../widgets/dialog_widgets/enter_passphrase_dialog.dart';
import '../../../logger.dart';

part 'credential_notifier.g.dart';

final containerCredentialsProvider = containerCredentialsNotifierProviderOf(
  repo: SecureContainerCredentialsRepository(),
  ioClient: const PrivacyideaIOClient(),
  eccUtils: const EccUtils(),
);

@Riverpod(keepAlive: true)
class ContainerCredentialsNotifier extends _$ContainerCredentialsNotifier with ResultHandler {
  final _stateMutex = Mutex();
  final _repoMutex = Mutex();

  ContainerCredentialsNotifier({
    ContainerCredentialsRepository? repoOverride,
    PrivacyideaIOClient? ioClientOverride,
    EccUtils? eccUtilsOverride,
  })  : _repoOverride = repoOverride,
        _ioClientOverride = ioClientOverride,
        _eccUtilsOverride = eccUtilsOverride;

  @override
  ContainerCredentialsRepository get repo => _repo;
  late ContainerCredentialsRepository _repo;
  final ContainerCredentialsRepository? _repoOverride;

  @override
  PrivacyideaIOClient get ioClient => _ioClient;
  late PrivacyideaIOClient _ioClient;
  final PrivacyideaIOClient? _ioClientOverride;

  @override
  EccUtils get eccUtils => _eccUtils;
  late EccUtils _eccUtils;
  final EccUtils? _eccUtilsOverride;

  @override
  Future<CredentialsState> build({
    required ContainerCredentialsRepository repo,
    required PrivacyideaIOClient ioClient,
    required EccUtils eccUtils,
  }) async {
    await _stateMutex.acquire();
    _repo = _repoOverride ?? repo;
    _ioClient = _ioClientOverride ?? ioClient;
    _eccUtils = _eccUtilsOverride ?? eccUtils;
    Logger.warning('Building credentialsProvider', name: 'CredentialsNotifier');
    final initState = await _repo.loadCredentialsState();
    for (var credential in initState.credentials.whereType<ContainerCredentialUnfinalized>()) {
      finalize(credential);
    }
    _stateMutex.release();
    return initState;
  }

//////////////////////////////////////////////////////////////////
////////////////////////// REPO METHODS //////////////////////////
//////////////////////////////////////////////////////////////////

  Future<CredentialsState> _saveCredentialToRepo(ContainerCredential credential) async {
    return await _repoMutex.protect(() async => await _repo.saveCredential(credential));
  }

  Future<CredentialsState> _saveCredentialsStateToRepo(CredentialsState credentialsState) async {
    return await _repoMutex.protect(() async => await _repo.saveCredentialsState(credentialsState));
  }

  Future<CredentialsState> _deleteCredentialFromRepo(ContainerCredential credential) async {
    return await _repoMutex.protect(() async => await _repo.deleteCredential(credential.serial));
  }

  Future<CredentialsState> _deleteCredentialsStateToRepo() async {
    return await _repoMutex.protect(() async => await _repo.deleteAllCredentials());
  }

/*//////////////////////////////////////////////////////////////////
////////////////////////// PUBLIC METHODS //////////////////////////
///////////////////////////////////////////////////////////////// */

// ADD CREDENTIALS

  Future<CredentialsState> addCredential(ContainerCredential credential) async {
    await _stateMutex.acquire();
    final newState = await _saveCredentialToRepo(credential);
    await update((_) => newState);
    _stateMutex.release();
    return newState;
  }

  Future<CredentialsState> addCredentials(List<ContainerCredential> credentials) async {
    await _stateMutex.acquire();
    final newCredentials = credentials.toList();
    final oldCredentials = (await future).credentials;
    final combinedCredentials = <ContainerCredential>[];
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
    final newState = await _saveCredentialsStateToRepo(CredentialsState(credentials: combinedCredentials));
    await update((_) => newState);
    _stateMutex.release();
    return newState;
  }

  // UPDATE CREDENTIALS

  @override
  Future<CredentialsState> update(
    FutureOr<CredentialsState> Function(CredentialsState state) cb, {
    FutureOr<CredentialsState> Function(Object, StackTrace)? onError,
  }) async {
    Logger.warning('Updating credentialsProvider', name: 'CredentialsNotifier');
    return super.update(cb, onError: onError);
  }

  Future<T?> updateCredential<T extends ContainerCredential>(ContainerCredential credential, T Function(ContainerCredential) updater) async {
    await _stateMutex.acquire();
    final oldState = await future;
    final currentCredential = oldState.currentOf(credential);
    if (currentCredential == null) {
      Logger.info('Failed to update credential. It was probably removed in the meantime.', name: 'CredentialsNotifier#updateCredential');
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

  Future<CredentialsState> deleteCredential(ContainerCredential credential) async {
    await _stateMutex.acquire();
    final newState = await _deleteCredentialFromRepo(credential);
    await update((_) => newState);
    _stateMutex.release();
    return newState;
  }

  Future<CredentialsState> deleteCredentials(List<ContainerCredential> credentials) async {
    await _stateMutex.acquire();
    final newCredentials = credentials.toList();
    final oldCredentials = (await future).credentials;
    final combinedCredentials = <ContainerCredential>[];
    for (var oldCredential in oldCredentials) {
      final newCredential = newCredentials.firstWhereOrNull((newCredential) => newCredential.serial == oldCredential.serial);
      if (newCredential == null) {
        combinedCredentials.add(oldCredential);
      } else {
        newCredentials.remove(newCredential);
      }
    }
    final newState = await _saveCredentialsStateToRepo(CredentialsState(credentials: combinedCredentials));
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
    final containerCredentials = results.getData().whereType<ContainerCredential>().toList();
    if (containerCredentials.isEmpty) {
      return null;
    }
    final currentState = await future;
    final stateCredentials = currentState.credentials;
    final stateCredentialsSerials = stateCredentials.map((e) => e.serial);
    final newCredentials = containerCredentials.where((element) => !stateCredentialsSerials.contains(element.serial)).toList();
    Logger.info('Handling processor results: adding Credential', name: 'CredentialsNotifier#handleProcessorResults');
    await addCredentials(newCredentials);
    Logger.info('Handling processor results: adding done (${newCredentials.length})', name: 'CredentialsNotifier#handleProcessorResults');
    for (var credential in newCredentials) {
      Logger.info('Handling processor results: finalize check ()', name: 'CredentialsNotifier#handleProcessorResults');
      if (credential is! ContainerCredentialUnfinalized) continue;
      Logger.info('Handling processor results: finalize', name: 'CredentialsNotifier#handleProcessorResults');
      await finalize(credential);
    }
    return null;
  }

  final Mutex _finalizationMutex = Mutex();
  Future<void> finalize(ContainerCredential credential) async {
    await _finalizationMutex.acquire();
    if (credential is! ContainerCredentialUnfinalized) {
      _finalizationMutex.release();
      throw ArgumentError('Container must not be finalized');
    }
    Logger.info('Finalizing container ${credential.serial}', name: 'CredentialsNotifier#finalize');
    try {
      credential = await _generateKeyPair(credential);
      final Response response;
      (credential, response) = await _sendPublicKey(credential);
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
      (credential, publicServerKey) = await _parseResponse(credential, response);
      await updateCredential(credential, (c) => c.finalize(publicServerKey: publicServerKey)!);
    } on StateError {
      Logger.info('Container was removed while finalizing', name: 'CredentialsNotifier#finalize');
    } catch (e) {
      Logger.error('Failed to finalize container ${credential.serial}', name: 'CredentialsNotifier#finalize', error: e);
      _finalizationMutex.release();
      return;
    }
    _finalizationMutex.release();
  }

////////////////////////////////////////////////////////////////////////////
////////////////////////// PRIVATE HELPER METHODS //////////////////////////
////////////////////////////////////////////////////////////////////////////

  /// Finalization substep 1: Generate key pair
  Future<ContainerCredential> _generateKeyPair(ContainerCredential containerCredential) async {
    // generatingKeyPair,
    // generatingKeyPairFailed,
    // generatingKeyPairCompleted,
    ContainerCredential? credential = containerCredential;
    credential = await updateCredential(credential, (c) => c.copyWith(finalizationState: ContainerFinalizationState.generatingKeyPair));
    if (credential == null) throw StateError('Credential was removed');
    final keyPair = CryptoUtils.generateEcKeyPair(curve: credential.ecKeyAlgorithm.curveName);
    credential = await updateCredential(credential, (c) => c.withClientKeyPair(keyPair) as ContainerCredentialUnfinalized);
    if (credential == null) throw StateError('Credential was removed');
    return credential;
  }

  /// Finalization substep 2: Send public key
  Future<(ContainerCredential, Response)> _sendPublicKey(ContainerCredential containerCredential) async {
    // sendingPublicKey,
    // sendingPublicKeyFailed,
    // sendingPublicKeyCompleted,
    ContainerCredential? container = containerCredential;
    final ecPrivateClientKey = container.ecPrivateClientKey!;
    //POST /container/register/finalize
    // Request: {
    // 'container_serial': <serial>,
    // 'public_client_key': <public key container base64 url encoded>,
    // 'signature': <sig( <nonce|timestamp|registration_url|serial[|passphrase]> )>,
    // }

    final passphrase = container.passphrase != null ? EnterPassphraseDialog.show(await globalContext) : null;
    final message = '${container.nonce}'
        '|${container.timestamp.toIso8601String().replaceFirst('Z', '+00:00')}'
        '|${container.finalizationUrl}'
        '|${container.serial}'
        '${passphrase != null ? '|$passphrase' : ''}';
    print(message);
    final signature = eccUtils.trySignWithPrivateKey(ecPrivateClientKey, message);

    final body = {
      'container_serial': container.serial,
      'public_client_key': container.publicClientKey,
      'signature': signature,
    };
    final Response response;
    container = await updateCredential(container, (c) => c.copyWith(finalizationState: ContainerFinalizationState.sendingPublicKey));
    if (container == null) throw StateError('Credential was removed');
    try {
      response = await _ioClient.doPost(url: container.finalizationUrl, body: body, sslVerify: false); //TODO: sslVerify
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
  Future<(ContainerCredential, ECPublicKey)> _parseResponse(ContainerCredential containerCredential, Response response) async {
    // parsingResponse,
    // parsingResponseFailed,
    // parsingResponseCompleted,

    ContainerCredential? credential = containerCredential;
    ECPublicKey publicServerKey;
    String responseBody = response.body;
    Map<String, dynamic> responseJson;
    credential = await updateCredential(credential, (c) => c.copyWith(finalizationState: ContainerFinalizationState.parsingResponse));
    if (credential == null) throw StateError('Credential was removed');
    try {
      responseJson = jsonDecode(responseBody);
      validateMap(responseJson, {'result': const TypeMatcher<Map<String, dynamic>>()});
      final result = responseJson['result'];
      validateMap(result, {'value': const TypeMatcher<Map<String, dynamic>>()});
      final value = result['value'];
      validateMap(value, {'public_server_key': const TypeMatcher<String>()});
      publicServerKey = const EccUtils().deserializeECPublicKey(value['public_server_key']);
    } catch (e) {
      ref.read(statusMessageProvider.notifier).state = ('Failed to decode response body', e.toString());
      await updateCredential(credential, (c) => c.copyWith(finalizationState: ContainerFinalizationState.parsingResponseFailed));
      rethrow;
    }
    credential = await updateCredential(credential, (c) => c.copyWith(finalizationState: ContainerFinalizationState.parsingResponseCompleted));
    if (credential == null) throw StateError('Credential was removed');
    return (credential, publicServerKey);
  }
}
