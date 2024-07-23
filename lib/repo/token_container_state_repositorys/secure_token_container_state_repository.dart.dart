import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import '../../interfaces/repo/container_repository.dart';
import '../../model/states/token_container_state.dart';

class SecureTokenContainerStateRepository implements TokenContainerStateRepository {
  static String prefix = 'token_container_state_';
  String get _containerStateKey => '$prefix${containerId}_container_state';
  final Mutex _m = Mutex();
  Future<void> _protect(Future<void> Function() f) => _m.protect(f);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String containerId;

  SecureTokenContainerStateRepository({
    required this.containerId,
  });

  Future<void> _write(String key, String value) => _protect(() => _storage.write(key: key, value: value));
  Future<String?> _read(String key) async {
    String? value;
    await _protect(() async => value = await _storage.read(key: key));
    return value;
  }

  Future<void> _delete(String key) => _protect(() => _storage.delete(key: key));
  Future<Map<String, String>> _readAll() async {
    Map<String, String>? keys;
    await _protect(() async => keys = await _storage.readAll());
    keys!.removeWhere((key, value) => !key.startsWith(prefix + containerId));
    return keys!;
  }

  @override
  Future<TokenContainerState> saveContainerState(TokenContainerState containerState) async {
    await _write(_containerStateKey, jsonEncode(containerState));
    return containerState;
  }

  @override

  /// Load the container state from the shared preferences
  Future<TokenContainerState> loadContainerState() async {
    String? containerStateJsonString = await _read(_containerStateKey);
    if (containerStateJsonString == null) {
      Logger.info('No container state found in secure storage', name: 'SecureTokenContainerStateRepository');
      return TokenContainerState.uninitialized([]);
    }
    final json = jsonDecode(containerStateJsonString);
    return TokenContainerState.fromJson(json);
  }

  // @override
  // Future<TokenTemplate?> loadTokenTemplate(String tokenTemplateId) async {
  //   final state = await loadContainerState();
  //   final template = state.tokenTemplates.firstWhereOrNull((template) => template.id == tokenTemplateId);
  //   return template;
  // }

  // @override
  // Future<TokenTemplate> saveTokenTemplate(TokenTemplate tokenTemplate) async {
  //   TokenContainerState state = await loadContainerState();
  //   final templates = state.tokenTemplates;
  //   templates.removeWhere((template) => template.id == tokenTemplate.id);
  //   templates.add(tokenTemplate);
  //   state = state.copyWith(tokenTemplates: templates);
  //   await saveContainerState(state);
  //   return tokenTemplate;
  // }
}
