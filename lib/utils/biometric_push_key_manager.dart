/*
 * privacyIDEA Authenticator
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'helpers/mutex.dart';

enum BiometricPushKeyNativeStatus {
  unprotected,
  protected,
  invalidated,
  unsupported,
}

class BiometricPushKeyResult {
  final String signature;
  final bool protectedNow;

  const BiometricPushKeyResult({
    required this.signature,
    required this.protectedNow,
  });
}

class BiometricPushKeyException implements Exception {
  final String code;

  const BiometricPushKeyException(this.code);

  bool get isInvalidated =>
      code == BiometricPushKeyManager.invalidatedCode ||
      code == BiometricPushKeyManager.keyMissingCode;
  bool get isStateNotPersisted =>
      code == BiometricPushKeyManager.stateNotPersistedCode;

  @override
  String toString() => 'BiometricPushKeyException($code)';
}

/// Bridges biometric-only Push signing to Android Keystore or iOS Keychain.
///
/// * requires BIOMETRIC_STRONG for every use;
/// * never permits a device-credential fallback;
/// * can be invalidated when biometric enrollment changes.
///
/// The native side stores only the wrapped private key and its IV. Dart keeps
/// no private key after a successful migration.
class BiometricPushKeyManager {
  static const channelName = 'biometric_push_key';
  static const invalidatedCode = 'BIOMETRIC_KEY_INVALIDATED';
  static const keyMissingCode = 'BIOMETRIC_KEY_MISSING';
  static const unsupportedCode = 'BIOMETRIC_KEY_UNSUPPORTED';
  static const canceledCode = 'BIOMETRIC_AUTH_CANCELED';
  static const stateNotPersistedCode = 'BIOMETRIC_KEY_STATE_NOT_PERSISTED';

  /// Native biometric operations for one token must never overlap. In
  /// particular, a periodic poll must not replace a Keystore key while an
  /// approval or a legacy-key migration is still authenticating.
  static final Map<String, Mutex> _tokenMutexes = {};

  final MethodChannel channel;
  final bool? supportedPlatformOverride;

  const BiometricPushKeyManager({
    this.channel = const MethodChannel(channelName),
    this.supportedPlatformOverride,
  });

  bool get isSupportedPlatform =>
      supportedPlatformOverride ?? (Platform.isAndroid || Platform.isIOS);

  Mutex _mutexFor(String tokenId) =>
      _tokenMutexes.putIfAbsent(tokenId, Mutex.new);

  Future<BiometricPushKeyNativeStatus> status(String tokenId) async {
    if (!isSupportedPlatform) {
      return BiometricPushKeyNativeStatus.unsupported;
    }
    return _mutexFor(tokenId).protect(() async {
      final value = await _invoke<String>('status', {'tokenId': tokenId});
      return switch (value) {
        'protected' => BiometricPushKeyNativeStatus.protected,
        'invalidated' => BiometricPushKeyNativeStatus.invalidated,
        'unsupported' => BiometricPushKeyNativeStatus.unsupported,
        _ => BiometricPushKeyNativeStatus.unprotected,
      };
    });
  }

  Future<void> protect({
    required String tokenId,
    required String privateKey,
    required String reason,
    required String cancelLabel,
    required bool invalidateOnBiometricChange,
  }) => _mutexFor(tokenId).protect(
    () => _invoke<void>('protect', {
      'tokenId': tokenId,
      'privateKey': privateKey,
      'reason': reason,
      'cancelLabel': cancelLabel,
      'invalidateOnBiometricChange': invalidateOnBiometricChange,
    }),
  );

  Future<BiometricPushKeyResult> sign({
    required String tokenId,
    required String message,
    required String reason,
    required String cancelLabel,
    required bool invalidateOnBiometricChange,
    String? privateKey,
  }) async {
    return _mutexFor(tokenId).protect(() async {
      final value = await _invoke<Map<Object?, Object?>>('sign', {
        'tokenId': tokenId,
        'message': message,
        'reason': reason,
        'cancelLabel': cancelLabel,
        'invalidateOnBiometricChange': invalidateOnBiometricChange,
        'privateKey': ?privateKey,
      });
      final signature = value['signature'];
      if (signature is! String) {
        throw const BiometricPushKeyException('INVALID_NATIVE_RESPONSE');
      }
      return BiometricPushKeyResult(
        signature: base64.normalize(signature),
        protectedNow: value['protectedNow'] == true,
      );
    });
  }

  Future<void> delete(String tokenId) async {
    if (!isSupportedPlatform) return;
    await _mutexFor(
      tokenId,
    ).protect(() => _invoke<void>('delete', {'tokenId': tokenId}));
  }

  Future<T> _invoke<T>(String method, Map<String, Object> arguments) async {
    try {
      final result = await channel.invokeMethod<T>(method, arguments);
      return result as T;
    } on PlatformException catch (error) {
      throw BiometricPushKeyException(error.code);
    } on MissingPluginException {
      throw const BiometricPushKeyException(unsupportedCode);
    }
  }
}
