package it.netknights.piauthenticator

import android.R.id.input
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.res.Configuration
import android.net.Uri
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
    }

    override fun onConfigurationChanged(newConfiguration: Configuration) {
        super.onConfigurationChanged(newConfiguration)
        updateHomeWidget()
    }

    fun updateHomeWidget() {
        val intent = Intent(this, AppWidgetProvider::class.java)
        intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        val ids = AppWidgetManager.getInstance(application).getAppWidgetIds(ComponentName(application, AppWidgetProvider::class.java))
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        sendBroadcast(intent)

    }
}
