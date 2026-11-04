package app.piauthenticator.channels

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object SettingsChannel {

    private const val CHANNEL_NAME = "pi_authenticator/settings"

    fun register(activity: Activity, flutterEngine: FlutterEngine) {
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "openLockAndPasswordSettings" -> {
                    try {
                        activity.startActivity(Intent(Settings.ACTION_SECURITY_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            activity.startActivity(
                                Intent(
                                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                    Uri.parse("package:${activity.packageName}")
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
