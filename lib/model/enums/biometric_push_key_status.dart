// Modified by KW Krzysztof Wielgosz, 2026.
/*
 * privacyIDEA Authenticator
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

/// Durable client-side state of an Android Keystore protected Push key.
enum BiometricPushKeyStatus {
  /// The legacy private key still needs to be moved behind Android Keystore.
  unprotected,

  /// The private key is wrapped by an auth-per-use BIOMETRIC_STRONG key.
  protected,

  /// The Keystore key can no longer be used, e.g. after biometric enrollment
  /// changed. This state is terminal and the Push token must be re-enrolled.
  invalidated,
}
