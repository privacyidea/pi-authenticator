package it.netknights.piauthenticator

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File
import java.io.ObjectInputStream

/**
 * Shared behavior for all product flavors. Flavor-specific `MainActivity`
 * classes should extend this instead of duplicating the channel setup.
 */
abstract class BaseMainActivity : FlutterFragmentActivity() {

    private val channelName = "readValueFromFile"
    private val settingsChannelName = "it.netknights.piauthenticator/settings"
    private val mailerChannelName = "it.netknights.piauthenticator/mailer"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel.setMethodCallHandler { call, result ->
            try {
                val args = call.arguments as Map<String, String>
                val uri = Uri.parse(args["path"] as String)
                applicationContext.contentResolver.openInputStream(uri)?.use { inputStream ->
                    ObjectInputStream(inputStream).use { input ->
                        when (call.method) {
                            "json" -> {
                                val entries = input.readObject() as Map<String, *>
                                result.success(entries)
                            }
                            else -> {
                                result.error("UNAVAILABLE", "Unsupported method: ${call.method}", null)
                            }
                        }
                    }
                } ?: result.error("UNAVAILABLE", "Could not open input stream for the given path", null)
            } catch (e: Exception) {
                result.error("UNAVAILABLE", "Failed to read value from file: ${e.message}", null)
            }
        }

        val settingsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, settingsChannelName)
        settingsChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "openLockAndPasswordSettings" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_SECURITY_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            startActivity(
                                Intent(
                                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                    Uri.parse("package:$packageName")
                                ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            )
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", "Could not open security settings", null)
                        }
                    }
                }
                "isIgnoringBatteryOptimizations" -> {
                    val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                    result.success(powerManager.isIgnoringBatteryOptimizations(packageName))
                }
                "requestIgnoreBatteryOptimizations" -> {
                    try {
                        startActivity(
                            Intent(
                                Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                Uri.parse("package:$packageName")
                            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        )
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Could not request battery optimization exemption", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        val mailerChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mailerChannelName)
        mailerChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "send" -> {
                    try {
                        @Suppress("UNCHECKED_CAST")
                        val recipients = (call.argument<List<String>>("recipients") ?: emptyList()).toTypedArray()
                        val subject = call.argument<String>("subject")
                        val body = call.argument<String>("body")
                        val attachmentPath = call.argument<String>("attachmentPath")

                        val intent = if (attachmentPath != null) {
                            val attachmentUri = FileProvider.getUriForFile(
                                this,
                                "$packageName.file_provider",
                                File(attachmentPath)
                            )
                            Intent(Intent.ACTION_SEND).apply {
                                type = "message/rfc822"
                                putExtra(Intent.EXTRA_STREAM, attachmentUri)
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            }
                        } else {
                            Intent(Intent.ACTION_SENDTO).apply {
                                data = Uri.parse("mailto:")
                            }
                        }
                        intent.putExtra(Intent.EXTRA_EMAIL, recipients)
                        subject?.let { intent.putExtra(Intent.EXTRA_SUBJECT, it) }
                        body?.let { intent.putExtra(Intent.EXTRA_TEXT, it) }

                        if (packageManager.resolveActivity(intent, 0) != null) {
                            startActivity(Intent.createChooser(intent, null))
                            result.success(true)
                        } else {
                            result.error("not_available", "No email clients found!", null)
                        }
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Failed to send mail: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
