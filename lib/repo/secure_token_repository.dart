/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2025 NetKnights GmbH

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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privacyidea_authenticator/widgets/elevated_delete_button.dart';

import '../interfaces/repo/token_repository.dart';
import '../l10n/app_localizations.dart';
import '../model/tokens/token.dart';
import '../utils/globals.dart';
import '../utils/identifiers.dart';
import '../utils/logger.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../utils/view_utils.dart';
import '../views/settings_view/settings_view_widgets/send_error_dialog.dart';
import '../widgets/dialog_widgets/default_dialog.dart';
import 'secure_storage.dart';

class SecureTokenRepository implements TokenRepository {
  const SecureTokenRepository();
  static const String _TOKEN_PREFIX_LEGACY = GLOBAL_SECURE_REPO_PREFIX_LEGACY;
  static const String _TOKEN_PREFIX = '${GLOBAL_SECURE_REPO_PREFIX}_token';

  static final _storageLegacy = SecureStorage(storagePrefix: _TOKEN_PREFIX_LEGACY, storage: SecureStorage.legacyStorage);
  static final _storage = SecureStorage(storagePrefix: _TOKEN_PREFIX, storage: SecureStorage.defaultStorage);

  // ###########################################################################
  // TOKENS
  // ###########################################################################

  @override
  Future<Token?> loadToken(String id) async {
    final token = await _storage.read(key: id);
    Logger.info('Loading token from secure storage: $id');
    if (token == null) {
      Logger.warning('Token not found in secure storage');
      return null;
    }
    return Token.fromJson(jsonDecode(token));
  }

  /// Takes all tokens from the legacy storage and saves them to the new storage.
  /// Afterwards, the tokens are deleted from the legacy storage.
  Future<void> _migrate() async {
    final keyValueMap = await _storageLegacy.readAll();
    if (keyValueMap.isEmpty) return;
    Logger.info('Migrating ${keyValueMap.length} tokens from legacy secure storage');

    for (var i = 0; i < keyValueMap.length; i++) {
      final value = keyValueMap.values.elementAt(i);
      final key = keyValueMap.keys.elementAt(i);
      Map<String, dynamic>? valueJson;

      try {
        valueJson = jsonDecode(value);
      } on FormatException catch (_) {
        // Value should be a json. Skip everything that is not a json.
        Logger.debug('Value is not a json');
        continue;
      }

      if (valueJson == null) {
        // If valueJson is null or does not contain a type, it can't be a token. Skip it.
        Logger.debug('Value Json is null');
        continue;
      }
      if (!valueJson.containsKey('type')) {
        // If valueJson is null or does not contain a type, it can't be a token. Skip it.
        Logger.debug('Value Json does not contain a type');
        continue;
      }

      // When the token version (token.version) changed handle this here.
      Logger.info('Loading token from secure storage: ${valueJson['id']}');
      try {
        Logger.info('Legacy entry that meets token criteria: $key will be migrated to new secure storage');
        await _storage.write(key: key, value: value);
        await _storageLegacy.delete(key: key);
        Logger.info('Migrated token ${valueJson['id']} to new secure storage');
      } catch (e, s) {
        Logger.error('Could not load token from secure storage', error: e, stackTrace: s);
      }
    }
    Logger.info('Migration of legacy tokens to new secure storage completed');
  }

  /// Returns a list of all tokens that are saved in the secure storage of
  /// this device.
  /// If [loadLegacy] is set to true, will attempt to load old android and ios tokens.
  @override
  Future<List<Token>> loadTokens() async {
    late Map<String, String> keyValueMap;

    try {
      await _migrate();
    } catch (e) {
      Logger.warning('Could not migrate legacy tokens', error: e, verbose: true);
    }
    try {
      keyValueMap = await _storage.readAll(); // Now only reads tokens with the correct prefix.
    } on PlatformException catch (e, s) {
      Logger.warning("Token found, but could not be decrypted.", error: e, stackTrace: s, verbose: true);
      _decryptErrorDialog();
      return [];
    }

    List<Token> tokenList = [];
    for (var entry in keyValueMap.entries) {
      try {
        final token = Token.fromJson(jsonDecode(entry.value));
        tokenList.add(token);
      } catch (e, s) {
        Logger.warning('Could not load token from secure storage', error: e, stackTrace: s, verbose: true);
      }
    }

    Logger.info('Loaded ${tokenList.length}/${keyValueMap.length} tokens from secure storage');
    return tokenList;
  }

  /// Saves [token]s securely on the device, if [token] already exists
  /// in the storage the existing value is overwritten.
  /// Returns all tokens that could not be saved.
  @override
  Future<List<T>> saveOrReplaceTokens<T extends Token>(List<T> tokens) async {
    if (tokens.isEmpty) return [];
    final failedTokens = <T>[];
    for (var element in tokens) {
      if (!await saveOrReplaceToken(element)) {
        failedTokens.add(element);
      }
    }
    if (failedTokens.isNotEmpty) {
      Logger.error('Could not save all tokens (${tokens.length - failedTokens.length}/${tokens.length}) to secure storage', stackTrace: StackTrace.current);
    } else {
      Logger.info('Saved ${tokens.length}/${tokens.length} tokens to secure storage');
    }
    return failedTokens;
  }

  @override
  Future<bool> saveOrReplaceToken(Token token) async {
    try {
      await _storage.write(key: token.id, value: jsonEncode(token.toJson()));
    } catch (e) {
      Logger.warning('Could not save token to secure storage', error: e, verbose: true);
      return false;
    }
    return true;
  }

  /// Deletes the saved jsons of [tokens] from the secure storage.
  @override
  Future<List<T>> deleteTokens<T extends Token>(List<T> tokens) async {
    final failedTokens = <T>[];
    for (var element in tokens) {
      if (!await deleteToken(element)) {
        failedTokens.add(element);
      }
    }
    if (failedTokens.isNotEmpty) {
      Logger.warning('Could not delete all tokens from secure storage', error: 'Failed tokens: $failedTokens', stackTrace: StackTrace.current);
    }
    return failedTokens;
  }

  /// Deletes the saved json of [token] from the secure storage.
  @override
  Future<bool> deleteToken(Token token) async {
    try {
      _storage.delete(key: token.id);
    } catch (e, s) {
      Logger.warning('Could not delete token from secure storage', error: e, stackTrace: s);
      return false;
    }
    Logger.info('Token deleted from secure storage');
    return true;
  }

  // ###########################################################################
  // ERROR HANDLING
  // ###########################################################################

  Future<void> _decryptErrorDialog() => showAsyncDialog(
    barrierDismissible: false,
    builder: (context) => DefaultDialog(
      title: Text(AppLocalizations.of(context)!.decryptErrorTitle),
      content: Text(AppLocalizations.of(context)!.decryptErrorContent),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.decryptErrorButtonSendError),
          onPressed: () async {
            Logger.info('Sending error report');
            await showDialog(context: context, builder: (context) => const SendErrorDialog(), useRootNavigator: false);
          },
        ),
        ElevatedDeleteButton(
          onPressed: () async {
            final isDataDeleted = await _decryptErrorDeleteTokenConfirmationDialog();
            if (isDataDeleted == true) {
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              globalRef?.read(tokenProvider.notifier).loadStateFromRepo();
            }
          },
          text: AppLocalizations.of(context)!.decryptErrorButtonDelete,
        ),
        ElevatedButton(
          onPressed: () async {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => const Center(child: SizedBox(height: 50, width: 50, child: CircularProgressIndicator.adaptive())),
            );
            await Future.delayed(const Duration(milliseconds: 500));
            if (!context.mounted) return;
            Navigator.pop(context);
            Navigator.pop(context);
            globalRef?.read(tokenProvider.notifier).loadStateFromRepo();
          },
          child: Text(AppLocalizations.of(context)!.decryptErrorButtonRetry),
        ),
      ],
    ),
  );

  Future<bool?> _decryptErrorDeleteTokenConfirmationDialog() => showAsyncDialog<bool>(
    builder: (context) => DefaultDialog(
      title: Text(AppLocalizations.of(context)!.decryptErrorTitle),
      content: Text(AppLocalizations.of(context)!.decryptErrorDeleteConfirmationContent),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel)),
        ElevatedDeleteButton(
          onPressed: () async {
            Logger.info('Deleting all tokens from secure storage', verbose: true);
            Navigator.pop(context, true);
            await SecureTokenRepository._storage.deleteAll();
          },
          text: AppLocalizations.of(context)!.decryptErrorButtonDelete,
        ),
      ],
    ),
  );
}
