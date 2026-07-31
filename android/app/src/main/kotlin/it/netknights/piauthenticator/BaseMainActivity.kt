package it.netknights.piauthenticator

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import androidx.activity.enableEdgeToEdge
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.ObjectInputStream

/**
 * Shared behavior for all product flavors. Flavor-specific `MainActivity`
 * classes should extend this instead of duplicating the channel setup.
 */
abstract class BaseMainActivity : FlutterFragmentActivity() {

    private val channelName = "readValueFromFile"
    private val settingsChannelName = "it.netknights.piauthenticator/settings"

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }

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
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
