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
import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:collection/collection.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../interfaces/repo/container_credentials_repository.dart';
import '../../../../model/riverpod_states/credentials_state.dart';
import '../../../../model/tokens/container_credentials.dart';
import '../../../../repo/secure_container_credentials_repository.dart';
import '../../../../widgets/dialog_widgets/enter_passphrase_dialog.dart';
import '../../../logger.dart';

part 'credential_notifier.g.dart';

@Riverpod(keepAlive: true)
class CredentialsNotifier extends _$CredentialsNotifier with ResultHandler {
  final _stateMutex = Mutex();
  final _repoMutex = Mutex();
  late PrivacyideaIOClient _ioClient;
  late ContainerCredentialsRepository _repo;

  @override
  Future<CredentialsState> build() async {
    _repo = SecureContainerCredentialsRepository();
    _ioClient = const PrivacyideaIOClient();
    Logger.warning('Building credentialsProvider', name: 'CredentialsNotifier');
    return _repo.loadCredentialsState();
  }

  @override
  Future<CredentialsState> update(
    FutureOr<CredentialsState> Function(CredentialsState state) cb, {
    FutureOr<CredentialsState> Function(Object, StackTrace)? onError,
  }) async {
    Logger.warning('Updating credentialsProvider', name: 'CredentialsNotifier');
    return super.update(cb, onError: onError);
  }

  Future<CredentialsState> addCredential(ContainerCredential credential) async {
    await _stateMutex.acquire();
    final newState = await _saveCredentialToRepo(credential);
    state = AsyncValue.data(newState);
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
    state = AsyncValue.data(newState);
    _stateMutex.release();
    return newState;
  }

  Future<CredentialsState> _saveCredentialToRepo(ContainerCredential credential) async {
    return await _repoMutex.protect(() async => await _repo.saveCredential(credential));
  }

  Future<CredentialsState> _saveCredentialsStateToRepo(CredentialsState credentialsState) async {
    return await _repoMutex.protect(() async => await _repo.saveCredentialsState(credentialsState));
  }

  Future<CredentialsState> handleCredentialResults(List<ProcessorResult<ContainerCredential>> credentialResults) async {
    final containerCredentials = credentialResults.getData();
    if (containerCredentials.isEmpty) {
      return future;
    }
    final currentState = await future;
    final stateCredentials = currentState.credentials;
    final stateCredentialsSerials = stateCredentials.map((e) => e.serial);
    final newCredentials = containerCredentials.where((element) => !stateCredentialsSerials.contains(element.serial)).toList();
    return addCredentials(newCredentials);
  }

  Future<CredentialsState?> finalize(ContainerCredential credential) async {
    await _stateMutex.acquire();
    if (credential is! ContainerCredentialUnfinalized) {
      throw ArgumentError('Credential must not be finalized');
    }

    final keyPair = CryptoUtils.generateEcKeyPair(curve: credential.ecKeyAlgorithm.curveName);

    credential = credential.withClientKeyPair(keyPair) as ContainerCredentialUnfinalized;
    final ecPrivateClientKey = credential.ecPrivateClientKey!;
    //POST /container/register/finalize
    // Request: {
    // 'container_serial': <serial>,
    // 'public_client_key': <public key container base64 url encoded>,
    // 'signature': <sig( <nonce|timestamp|registration_url|serial[|passphrase]> )>,
    // }

    final passphrase = credential.passphrase != null ? EnterPassphraseDialog.show(await globalContext) : null;

    final message = '${credential.nonce}'
        '|${credential.timestamp}'
        '|${credential.finalizationUrl}'
        '|${credential.serial}'
        '${passphrase != null ? '|$passphrase' : ''}';

    final signature = const EccUtils().trySignWithPrivateKey(ecPrivateClientKey, message);

    final body = {
      'container_serial': credential.serial,
      'public_client_key': credential.publicClientKey,
      'signature': signature,
    };

    final response = await _ioClient.doPost(url: credential.finalizationUrl, body: body);
    final Map<String, dynamic> responseJson;
    final ContainerCredentialFinalized finalizedCredential;
    try {
      responseJson = jsonDecode(response.body);
      validateMap(responseJson, {PUBLIC_SERVER_KEY: TypeMatcher<String>()});
      final publicServerKey = const EccUtils().deserializeECPublicKey(responseJson[PUBLIC_SERVER_KEY]);
      finalizedCredential = credential.finalize(publicServerKey: publicServerKey)!;
    } catch (e) {
      Logger.error('Failed to decode response body', error: e, name: 'CredentialsNotifier#finalize');
      return null;
    }
    return await addCredential(finalizedCredential);
  }

  @override
  Future<void> handleProcessorResult(ProcessorResult result, Map<String, dynamic> args) {
    // TODO: implement handleResult
    throw UnimplementedError();
  }

  @override
  Future<List> handleProcessorResults(List<ProcessorResult> results, Map<String, dynamic> args) {
    // TODO: implement handleResults
    throw UnimplementedError();
  }
}
