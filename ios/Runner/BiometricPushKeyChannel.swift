import Flutter
import Foundation
import LocalAuthentication
import Security

/// Stores each biometric-only Push private key as a non-migrating Keychain
/// item. `biometryCurrentSet` binds the item to the enrolled Face ID/Touch ID
/// set; `biometryAny` keeps per-use biometric authentication without binding.
final class BiometricPushKeyChannel {
  private static let channelName = "biometric_push_key"
  private static let service = "it.netknights.piauthenticator.push-biometric-key.v1"
  private static let protectedPrefix = "biometric_push_key_protected_"

  private static let invalidatedError = "BIOMETRIC_KEY_INVALIDATED"
  private static let missingError = "BIOMETRIC_KEY_MISSING"
  private static let unsupportedError = "BIOMETRIC_KEY_UNSUPPORTED"
  private static let unavailableError = "BIOMETRIC_STRONG_UNAVAILABLE"
  private static let canceledError = "BIOMETRIC_AUTH_CANCELED"
  private static let failedError = "BIOMETRIC_AUTH_FAILED"

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard let arguments = call.arguments as? [String: Any],
            let tokenId = nonEmptyString(arguments["tokenId"]) else {
        result(error(failedError, "Missing tokenId"))
        return
      }

      switch call.method {
      case "status":
        result(status(tokenId: tokenId))
      case "delete":
        delete(tokenId: tokenId)
        result(nil)
      case "protect":
        protect(arguments: arguments, tokenId: tokenId, result: result)
      case "sign":
        sign(arguments: arguments, tokenId: tokenId, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func status(tokenId: String) -> String {
    let query: [String: Any] = baseQuery(tokenId: tokenId).merging([
      kSecReturnAttributes as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
      kSecUseAuthenticationUI as String: kSecUseAuthenticationUIFail,
    ]) { _, new in new }
    let status = SecItemCopyMatching(query as CFDictionary, nil)
    if status == errSecSuccess { return "protected" }
    if wasProtected(tokenId: tokenId) {
      // Attribute-only queries for an access-controlled item can return
      // interaction-not-allowed while the device is locked. The durable marker
      // lets startup reconciliation distinguish that from a never-migrated key.
      return status == errSecItemNotFound ? "invalidated" : "protected"
    }
    return status == errSecItemNotFound ? "unprotected" : "unsupported"
  }

  private static func protect(
    arguments: [String: Any],
    tokenId: String,
    result: @escaping FlutterResult
  ) {
    guard let privateKey = nonEmptyString(arguments["privateKey"]),
          let reason = nonEmptyString(arguments["reason"]),
          let cancelLabel = nonEmptyString(arguments["cancelLabel"]),
          let invalidate = arguments["invalidateOnBiometricChange"] as? Bool else {
      result(error(failedError, "Missing biometric Push key arguments"))
      return
    }
    authenticate(reason: reason, cancelLabel: cancelLabel) { context, authenticationError in
      guard let context = context else {
        result(mapAuthenticationError(authenticationError))
        return
      }
      do {
        try store(
          Data(base64Encoded: privateKey) ?? Data(),
          tokenId: tokenId,
          invalidateOnChange: invalidate,
          context: context
        )
        result(nil)
      } catch let keyError as KeyError {
        result(error(keyError.code, keyError.message))
      } catch {
        result(self.error(failedError, "Could not protect the Push key"))
      }
    }
  }

  private static func sign(
    arguments: [String: Any],
    tokenId: String,
    result: @escaping FlutterResult
  ) {
    guard let message = nonEmptyString(arguments["message"]),
          let reason = nonEmptyString(arguments["reason"]),
          let cancelLabel = nonEmptyString(arguments["cancelLabel"]),
          let invalidate = arguments["invalidateOnBiometricChange"] as? Bool else {
      result(error(failedError, "Missing biometric Push signing arguments"))
      return
    }

    if status(tokenId: tokenId) == "invalidated" {
      result(error(invalidatedError, "Biometric Push key is invalid"))
      return
    }

    if let legacyKey = nonEmptyString(arguments["privateKey"]),
       status(tokenId: tokenId) == "unprotected" {
      authenticate(reason: reason, cancelLabel: cancelLabel) { context, authenticationError in
        guard let context = context else {
          result(mapAuthenticationError(authenticationError))
          return
        }
        guard let keyData = Data(base64Encoded: legacyKey) else {
          result(error(failedError, "Invalid Push private key"))
          return
        }
        do {
          try store(
            keyData,
            tokenId: tokenId,
            invalidateOnChange: invalidate,
            context: context
          )
          result([
            "signature": try signMessage(keyData, message: message),
            "protectedNow": true,
          ])
        } catch let keyError as KeyError {
          delete(tokenId: tokenId)
          result(error(keyError.code, keyError.message))
        } catch {
          delete(tokenId: tokenId)
          result(self.error(failedError, "Could not protect the Push key"))
        }
      }
      return
    }

    let context = LAContext()
    context.localizedFallbackTitle = ""
    context.localizedCancelTitle = cancelLabel
    context.localizedReason = reason
    context.touchIDAuthenticationAllowableReuseDuration = 0
    let query: [String: Any] = baseQuery(tokenId: tokenId).merging([
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
      kSecUseAuthenticationContext as String: context,
    ]) { _, new in new }
    var item: CFTypeRef?
    let keychainStatus = SecItemCopyMatching(query as CFDictionary, &item)
    guard keychainStatus == errSecSuccess, let keyData = item as? Data else {
      if keychainStatus == errSecItemNotFound && wasProtected(tokenId: tokenId) {
        result(error(invalidatedError, "Biometric Push key is invalid"))
      } else if keychainStatus == errSecItemNotFound {
        result(error(missingError, "Biometric Push key is missing"))
      } else if keychainStatus == errSecUserCanceled {
        result(error(canceledError, "Biometric authentication was canceled"))
      } else {
        result(error(failedError, "Biometric authentication failed"))
      }
      return
    }
    do {
      result([
        "signature": try signMessage(keyData, message: message),
        "protectedNow": false,
      ])
    } catch let keyError as KeyError {
      result(error(keyError.code, keyError.message))
    } catch {
      result(self.error(failedError, "Could not sign the Push response"))
    }
  }

  private static func authenticate(
    reason: String,
    cancelLabel: String,
    completion: @escaping (LAContext?, Error?) -> Void
  ) {
    let context = LAContext()
    context.localizedFallbackTitle = ""
    context.localizedCancelTitle = cancelLabel
    context.touchIDAuthenticationAllowableReuseDuration = 0
    var evaluationError: NSError?
    guard context.canEvaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics,
      error: &evaluationError
    ) else {
      completion(nil, evaluationError)
      return
    }
    context.evaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics,
      localizedReason: reason
    ) { success, authenticationError in
      DispatchQueue.main.async {
        completion(success ? context : nil, authenticationError)
      }
    }
  }

  private static func store(
    _ keyData: Data,
    tokenId: String,
    invalidateOnChange: Bool,
    context: LAContext
  ) throws {
    guard !keyData.isEmpty else { throw KeyError(failedError, "Invalid Push private key") }
    delete(tokenId: tokenId)
    let flags: SecAccessControlCreateFlags = invalidateOnChange
      ? .biometryCurrentSet
      : .biometryAny
    var accessError: Unmanaged<CFError>?
    guard let access = SecAccessControlCreateWithFlags(
      nil,
      kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
      flags,
      &accessError
    ) else {
      throw KeyError(unsupportedError, "Could not create biometric access control")
    }
    let query: [String: Any] = baseQuery(tokenId: tokenId).merging([
      kSecValueData as String: keyData,
      kSecAttrAccessControl as String: access,
      kSecUseAuthenticationContext as String: context,
    ]) { _, new in new }
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw KeyError(failedError, "Could not store biometric Push key")
    }
    UserDefaults.standard.set(true, forKey: protectedPrefix + tokenId)
  }

  private static func signMessage(_ keyData: Data, message: String) throws -> String {
    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
      kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
    ]
    var createError: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateWithData(
      keyData as CFData,
      attributes as CFDictionary,
      &createError
    ) else {
      throw KeyError(failedError, "Invalid Push private key")
    }
    var signatureError: Unmanaged<CFError>?
    guard let signature = SecKeyCreateSignature(
      privateKey,
      .rsaSignatureMessagePKCS1v15SHA256,
      Data(message.utf8) as CFData,
      &signatureError
    ) else {
      throw KeyError(failedError, "Could not sign the Push response")
    }
    return (signature as Data).base64EncodedString()
  }

  private static func delete(tokenId: String) {
    SecItemDelete(baseQuery(tokenId: tokenId) as CFDictionary)
    UserDefaults.standard.removeObject(forKey: protectedPrefix + tokenId)
  }

  private static func baseQuery(tokenId: String) -> [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: tokenId,
      kSecAttrSynchronizable as String: false,
    ]
  }

  private static func wasProtected(tokenId: String) -> Bool {
    UserDefaults.standard.bool(forKey: protectedPrefix + tokenId)
  }

  private static func mapAuthenticationError(_ source: Error?) -> FlutterError {
    let code = (source as? LAError)?.code
    if code == .userCancel || code == .systemCancel || code == .appCancel {
      return error(canceledError, "Biometric authentication was canceled")
    }
    if code == .biometryNotAvailable ||
       code == .biometryNotEnrolled ||
       code == .passcodeNotSet {
      return error(unavailableError, "Strong biometrics are unavailable")
    }
    return error(failedError, "Biometric authentication failed")
  }

  private static func nonEmptyString(_ value: Any?) -> String? {
    guard let value = value as? String, !value.isEmpty else { return nil }
    return value
  }

  private static func error(_ code: String, _ message: String) -> FlutterError {
    FlutterError(code: code, message: message, details: nil)
  }

  private struct KeyError: Error {
    let code: String
    let message: String

    init(_ code: String, _ message: String) {
      self.code = code
      self.message = message
    }
  }
}
