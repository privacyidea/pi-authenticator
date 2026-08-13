package app.piauthenticator

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.enableEdgeToEdge
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import app.piauthenticator.channels.MailerChannel
import app.piauthenticator.channels.SettingsChannel
import app.piauthenticator.channels.BiometricPushKeyChannel

/**
 * Shared behavior for all product flavors. Flavor-specific `MainActivity`
 * classes should extend this instead of duplicating the channel setup.
 */
abstract class BaseMainActivity : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)

        SettingsChannel.register(this, flutterEngine)
        MailerChannel.register(this, flutterEngine)
        BiometricPushKeyChannel.register(this, flutterEngine)
    }
}
