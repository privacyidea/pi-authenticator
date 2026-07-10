package it.netknights.piauthenticator

import android.R.id.input
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.res.Configuration
import android.net.Uri
import android.provider.Settings
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.InputStream
import java.io.ObjectInputStream
import java.net.URI


class MainActivity : FlutterFragmentActivity() {

    private val channelName = "readValueFromFile"
    private val settingsChannelName = "it.netknights.piauthenticator/settings"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE);

        var channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)

        channel.setMethodCallHandler { call, result ->

                try {
                    val args = call.arguments as Map<String, String>
                    val uri = Uri.parse(args["path"] as String)
                    val inputStream = applicationContext.contentResolver.openInputStream(uri)
                    val input = ObjectInputStream(inputStream)
                    when (call.method) {
                        "json" -> {
                            val entries = input.readObject() as Map<String, *>
                            result.success(entries)
                        }
                        else -> {
                            result.error("UNAVAILABLE", "Something went wrong", null)
                        }
                    }
                }
                catch (e: Exception) {
                    result.error("UNAVAILABLE", "Something went wrong", null)
                }

        }

        var settingsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, settingsChannelName)

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
