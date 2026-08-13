// SPDX-License-Identifier: Apache-2.0

package app.piauthenticator.channels

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyPermanentlyInvalidatedException
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import java.security.MessageDigest
import java.security.Signature
import java.util.concurrent.Executor
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * Protects privacyIDEA Push private keys with an Android Keystore AES key.
 *
 * The wrapping key requires BIOMETRIC_STRONG for every operation and is
 * invalidated when biometric enrollment changes if the token policy requests
 * it. Device PIN, pattern and password are deliberately not accepted.
 */
object BiometricPushKeyChannel {
    private const val CHANNEL_NAME = "biometric_push_key"
    private const val KEYSTORE = "AndroidKeyStore"
    private const val KEY_ALIAS_PREFIX = "pi_push_biometric_v1_"
    private const val PREFERENCES = "pi_push_biometric_keys_v1"
    private const val INVALIDATED = "invalidated_"
    private const val WRAPPED_KEY = "wrapped_"
    private const val IV = "iv_"

    private const val ERROR_INVALIDATED = "BIOMETRIC_KEY_INVALIDATED"
    private const val ERROR_MISSING = "BIOMETRIC_KEY_MISSING"
    private const val ERROR_UNSUPPORTED = "BIOMETRIC_KEY_UNSUPPORTED"
    private const val ERROR_STRONG_UNAVAILABLE = "BIOMETRIC_STRONG_UNAVAILABLE"
    private const val ERROR_CANCELED = "BIOMETRIC_AUTH_CANCELED"
    private const val ERROR_FAILED = "BIOMETRIC_AUTH_FAILED"

    fun register(activity: FragmentActivity, flutterEngine: FlutterEngine) {
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        )
        channel.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "status" -> result.success(status(activity, tokenId(call)))
                    "delete" -> {
                        delete(activity, tokenId(call))
                        result.success(null)
                    }
                    "protect" -> protect(activity, call, result)
                    "sign" -> sign(activity, call, result)
                    else -> result.notImplemented()
                }
            } catch (exception: BiometricKeyException) {
                result.error(exception.code, exception.message, null)
            } catch (exception: Exception) {
                result.error(ERROR_FAILED, "Biometric Push key operation failed", null)
            }
        }
    }

    private fun status(activity: FragmentActivity, tokenId: String): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return "unsupported"
        val key = storageKey(tokenId)
        val preferences = preferences(activity)
        if (preferences.getBoolean(INVALIDATED + key, false)) return "invalidated"
        val wrapped = preferences.getString(WRAPPED_KEY + key, null)
            ?: return "unprotected"
        val iv = preferences.getString(IV + key, null)
            ?: return markInvalidated(activity, key)

        return try {
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            cipher.init(
                Cipher.DECRYPT_MODE,
                loadSecretKey(key),
                GCMParameterSpec(128, Base64.decode(iv, Base64.NO_WRAP)),
            )
            // Merely initializing the operation proves that the auth-bound key
            // still exists and was not invalidated. No plaintext is released.
            if (wrapped.isEmpty()) markInvalidated(activity, key) else "protected"
        } catch (_: KeyPermanentlyInvalidatedException) {
            markInvalidated(activity, key)
        } catch (_: BiometricKeyException) {
            markInvalidated(activity, key)
        }
    }

    private fun protect(
        activity: FragmentActivity,
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        ensureSupported(activity)
        val tokenId = tokenId(call)
        val privateKey = requiredString(call, "privateKey")
        authenticateAndProtect(
            activity = activity,
            tokenId = tokenId,
            privateKeyBase64 = privateKey,
            reason = requiredString(call, "reason"),
            cancelLabel = requiredString(call, "cancelLabel"),
            invalidateOnBiometricChange = requiredBoolean(
                call,
                "invalidateOnBiometricChange",
            ),
            message = null,
            result = result,
        )
    }

    private fun sign(
        activity: FragmentActivity,
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val tokenId = tokenId(call)
        // Validate all required call data before starting BiometricPrompt. An
        // exception thrown later from its asynchronous callback would otherwise
        // leave the Dart MethodChannel call without a completion.
        val message = requiredString(call, "message")
        val reason = requiredString(call, "reason")
        val cancelLabel = requiredString(call, "cancelLabel")
        val invalidateOnBiometricChange = requiredBoolean(
            call,
            "invalidateOnBiometricChange",
        )
        val key = storageKey(tokenId)
        val preferences = preferences(activity)
        if (preferences.getBoolean(INVALIDATED + key, false)) {
            throw BiometricKeyException(ERROR_INVALIDATED)
        }

        val wrapped = preferences.getString(WRAPPED_KEY + key, null)
        val iv = preferences.getString(IV + key, null)
        if (wrapped == null || iv == null) {
            // There is no existing enrollment-bound operation to inspect. The
            // legacy key may be migrated only while strong biometrics are
            // currently available.
            ensureSupported(activity)
            val privateKey = call.argument<String>("privateKey")
                ?: throw BiometricKeyException(ERROR_MISSING)
            authenticateAndProtect(
                activity = activity,
                tokenId = tokenId,
                privateKeyBase64 = privateKey,
                reason = reason,
                cancelLabel = cancelLabel,
                invalidateOnBiometricChange = invalidateOnBiometricChange,
                message = message,
                result = result,
            )
            return
        }

        // Initialize the already-enrolled key before checking whether a strong
        // biometric is currently available. Removing all enrolled biometrics
        // makes canAuthenticate() report NONE_ENROLLED; checking it first would
        // mask KeyPermanentlyInvalidatedException (or a deleted Keystore alias)
        // as the non-terminal STRONG_UNAVAILABLE error.
        val cipher = try {
            Cipher.getInstance("AES/GCM/NoPadding").apply {
                init(
                    Cipher.DECRYPT_MODE,
                    loadSecretKey(key),
                    GCMParameterSpec(128, Base64.decode(iv, Base64.NO_WRAP)),
                )
            }
        } catch (_: KeyPermanentlyInvalidatedException) {
            markInvalidated(activity, key)
            throw BiometricKeyException(ERROR_INVALIDATED)
        } catch (_: BiometricKeyException) {
            markInvalidated(activity, key)
            throw BiometricKeyException(ERROR_MISSING)
        } catch (_: Exception) {
            throw BiometricKeyException(ERROR_FAILED)
        }

        ensureSupported(
            activity,
            enrollmentBoundKey = key.takeIf { invalidateOnBiometricChange },
        )

        authenticate(
            activity = activity,
            cipher = cipher,
            reason = reason,
            cancelLabel = cancelLabel,
            onSuccess = { authenticatedCipher ->
                var privateKeyBytes: ByteArray? = null
                try {
                    privateKeyBytes = authenticatedCipher.doFinal(
                        Base64.decode(wrapped, Base64.NO_WRAP),
                    )
                    result.success(
                        mapOf(
                            "signature" to signMessage(
                                privateKeyBytes,
                                message,
                            ),
                            "protectedNow" to false,
                        ),
                    )
                } catch (_: KeyPermanentlyInvalidatedException) {
                    completeInvalidated(activity, key, result)
                } catch (_: Exception) {
                    result.error(
                        ERROR_FAILED,
                        "Could not sign the Push response",
                        null,
                    )
                } finally {
                    privateKeyBytes?.fill(0)
                }
            },
            onError = result,
        )
    }

    /** Protects a legacy key and optionally signs in the same authenticated operation. */
    private fun authenticateAndProtect(
        activity: FragmentActivity,
        tokenId: String,
        privateKeyBase64: String,
        reason: String,
        cancelLabel: String,
        invalidateOnBiometricChange: Boolean,
        message: String?,
        result: MethodChannel.Result,
    ) {
        val key = storageKey(tokenId)
        deleteNativeKey(key)
        val cleared = preferences(activity).edit()
            .remove(WRAPPED_KEY + key)
            .remove(IV + key)
            .remove(INVALIDATED + key)
            .commit()
        if (!cleared) {
            throw BiometricKeyException(ERROR_FAILED, "Could not reset Push key state")
        }

        val secretKey = createSecretKey(key, invalidateOnBiometricChange)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding").apply {
            init(Cipher.ENCRYPT_MODE, secretKey)
        }
        authenticate(
            activity = activity,
            cipher = cipher,
            reason = reason,
            cancelLabel = cancelLabel,
            onSuccess = { authenticatedCipher ->
                var privateKeyBytes: ByteArray? = null
                try {
                    // Decoding belongs inside the callback's guarded section:
                    // malformed legacy data must complete the MethodChannel
                    // call with an error instead of escaping on the main thread.
                    privateKeyBytes = Base64.decode(privateKeyBase64, Base64.DEFAULT)
                    PushPrivateKeyCodec.decode(privateKeyBytes)
                    val wrapped = authenticatedCipher.doFinal(privateKeyBytes)
                    val stored = preferences(activity).edit()
                        .putString(
                            WRAPPED_KEY + key,
                            Base64.encodeToString(wrapped, Base64.NO_WRAP),
                        )
                        .putString(
                            IV + key,
                            Base64.encodeToString(authenticatedCipher.iv, Base64.NO_WRAP),
                        )
                        .putBoolean(INVALIDATED + key, false)
                        .commit()
                    if (!stored) {
                        throw BiometricKeyException(
                            ERROR_FAILED,
                            "Could not persist protected Push key state",
                        )
                    }
                    if (message == null) {
                        result.success(null)
                    } else {
                        result.success(
                            mapOf(
                                "signature" to signMessage(privateKeyBytes, message),
                                "protectedNow" to true,
                            ),
                        )
                    }
                } catch (_: Exception) {
                    val cleanupSucceeded = try {
                        delete(activity, tokenId)
                        true
                    } catch (_: Exception) {
                        false
                    }
                    val details = if (cleanupSucceeded) {
                        "Could not protect the Push key"
                    } else {
                        "Could not protect or clean up the Push key"
                    }
                    result.error(ERROR_FAILED, details, null)
                } finally {
                    privateKeyBytes?.fill(0)
                }
            },
            onError = result,
            deleteKeyOnError = key,
        )
    }

    private fun authenticate(
        activity: FragmentActivity,
        cipher: Cipher,
        reason: String,
        cancelLabel: String,
        onSuccess: (Cipher) -> Unit,
        onError: MethodChannel.Result,
        deleteKeyOnError: String? = null,
    ) {
        val executor: Executor = activity.mainExecutor
        val prompt = BiometricPrompt(
            activity,
            executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(
                    authenticationResult: BiometricPrompt.AuthenticationResult,
                ) {
                    if (authenticationResult.authenticationType ==
                        BiometricPrompt.AUTHENTICATION_RESULT_TYPE_DEVICE_CREDENTIAL
                    ) {
                        deleteKeyOnError?.let { runCatching { deleteNativeKey(it) } }
                        onError.error(
                            ERROR_FAILED,
                            "Device credentials cannot authorize this Push key",
                            null,
                        )
                        return
                    }
                    val authenticatedCipher = authenticationResult.cryptoObject?.cipher
                    if (authenticatedCipher == null) {
                        val cleanupFailed = deleteKeyOnError
                            ?.let { runCatching { deleteNativeKey(it) }.isFailure }
                            ?: false
                        val details = if (cleanupFailed) {
                            "Missing authenticated cipher; key cleanup also failed"
                        } else {
                            "Missing authenticated cipher"
                        }
                        onError.error(ERROR_FAILED, details, null)
                        return
                    }
                    onSuccess(authenticatedCipher)
                }

                override fun onAuthenticationError(code: Int, message: CharSequence) {
                    val cleanupFailed = deleteKeyOnError
                        ?.let { runCatching { deleteNativeKey(it) }.isFailure }
                        ?: false
                    val errorCode = when (code) {
                        BiometricPrompt.ERROR_CANCELED,
                        BiometricPrompt.ERROR_NEGATIVE_BUTTON,
                        BiometricPrompt.ERROR_USER_CANCELED -> ERROR_CANCELED
                        else -> ERROR_FAILED
                    }
                    val details = if (cleanupFailed) {
                        "$message (Push key cleanup failed)"
                    } else {
                        message.toString()
                    }
                    onError.error(errorCode, details, null)
                }

                override fun onAuthenticationFailed() {
                    // The system prompt remains open and permits another attempt.
                }
            },
        )
        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle(reason)
            .setNegativeButtonText(cancelLabel)
            .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
            .setConfirmationRequired(true)
            .build()
        prompt.authenticate(promptInfo, BiometricPrompt.CryptoObject(cipher))
    }

    private fun createSecretKey(
        key: String,
        invalidateOnBiometricChange: Boolean,
    ): SecretKey {
        val builder = KeyGenParameterSpec.Builder(
            alias(key),
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setRandomizedEncryptionRequired(true)
            .setUserAuthenticationRequired(true)
            .setInvalidatedByBiometricEnrollment(invalidateOnBiometricChange)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            builder.setUserAuthenticationParameters(
                0,
                KeyProperties.AUTH_BIOMETRIC_STRONG,
            )
        } else {
            @Suppress("DEPRECATION")
            builder.setUserAuthenticationValidityDurationSeconds(-1)
        }
        // Android 12-14 have documented unlocked-device-required key bugs.
        // The auth-per-use requirement already protects earlier releases.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            builder.setUnlockedDeviceRequired(true)
        }

        return KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, KEYSTORE)
            .apply { init(builder.build()) }
            .generateKey()
    }

    private fun loadSecretKey(key: String): SecretKey {
        val keyStore = KeyStore.getInstance(KEYSTORE).apply { load(null) }
        return keyStore.getKey(alias(key), null) as? SecretKey
            ?: throw BiometricKeyException(ERROR_MISSING)
    }

    private fun signMessage(privateKeyPkcs1: ByteArray, message: String): String {
        val privateKey = PushPrivateKeyCodec.decode(privateKeyPkcs1).privateKey
        val signature = Signature.getInstance("SHA256withRSA")
        signature.initSign(privateKey)
        signature.update(message.toByteArray(Charsets.UTF_8))
        return Base64.encodeToString(signature.sign(), Base64.NO_WRAP)
    }

    private fun ensureSupported(
        activity: FragmentActivity,
        enrollmentBoundKey: String? = null,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            throw BiometricKeyException(ERROR_UNSUPPORTED)
        }
        val status = BiometricManager.from(activity).canAuthenticate(
            BiometricManager.Authenticators.BIOMETRIC_STRONG,
        )
        if (status == BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED &&
            enrollmentBoundKey != null
        ) {
            markInvalidated(activity, enrollmentBoundKey)
            throw BiometricKeyException(ERROR_INVALIDATED)
        }
        if (status != BiometricManager.BIOMETRIC_SUCCESS) {
            throw BiometricKeyException(ERROR_STRONG_UNAVAILABLE)
        }
    }

    private fun delete(activity: FragmentActivity, tokenId: String) {
        val key = storageKey(tokenId)
        deleteNativeKey(key)
        val cleared = preferences(activity).edit()
            .remove(WRAPPED_KEY + key)
            .remove(IV + key)
            .remove(INVALIDATED + key)
            .commit()
        if (!cleared) {
            throw BiometricKeyException(
                ERROR_FAILED,
                "Could not remove persisted Push key state",
            )
        }
    }

    private fun deleteNativeKey(key: String) {
        val keyStore = KeyStore.getInstance(KEYSTORE).apply { load(null) }
        if (keyStore.containsAlias(alias(key))) keyStore.deleteEntry(alias(key))
    }

    private fun markInvalidated(activity: FragmentActivity, key: String): String {
        val stored = preferences(activity).edit()
            .putBoolean(INVALIDATED + key, true)
            .commit()
        if (!stored) {
            // Keep the semantic error as INVALIDATED. The Keystore operation
            // already proved that this key must never be used again, even if
            // persisting the convenience marker failed.
            throw BiometricKeyException(
                ERROR_INVALIDATED,
                "Biometric Push key is invalid and its marker could not be persisted",
            )
        }
        return "invalidated"
    }

    private fun completeInvalidated(
        activity: FragmentActivity,
        key: String,
        result: MethodChannel.Result,
    ) {
        val details = try {
            markInvalidated(activity, key)
            "Biometric Push key is invalid"
        } catch (_: Exception) {
            // The authenticated operation already failed. Always complete the
            // asynchronous MethodChannel call and remain fail-closed even if
            // the invalidation marker could not be written.
            "Biometric Push key is invalid and its marker could not be persisted"
        }
        result.error(ERROR_INVALIDATED, details, null)
    }

    private fun preferences(activity: FragmentActivity) =
        activity.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)

    private fun tokenId(call: MethodCall): String = requiredString(call, "tokenId")

    private fun requiredString(call: MethodCall, name: String): String =
        call.argument<String>(name)?.takeIf { it.isNotBlank() }
            ?: throw BiometricKeyException(ERROR_FAILED, "Missing $name")

    private fun requiredBoolean(call: MethodCall, name: String): Boolean =
        call.argument<Boolean>(name)
            ?: throw BiometricKeyException(ERROR_FAILED, "Missing $name")

    private fun storageKey(tokenId: String): String = MessageDigest.getInstance("SHA-256")
        .digest(tokenId.toByteArray(Charsets.UTF_8))
        .joinToString("") { "%02x".format(it) }

    private fun alias(key: String) = KEY_ALIAS_PREFIX + key

    private class BiometricKeyException(
        val code: String,
        override val message: String = code,
    ) : Exception(message)
}
