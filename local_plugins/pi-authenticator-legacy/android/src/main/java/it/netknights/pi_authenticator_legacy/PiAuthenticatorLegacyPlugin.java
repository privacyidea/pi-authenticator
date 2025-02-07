package it.netknights.pi_authenticator_legacy;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/**
 * PiAuthenticatorLegacyPlugin
 */
public class PiAuthenticatorLegacyPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private static final String METHOD_CHANNEL_ID = "it.netknights.piauthenticator.legacy";

    private static final String METHOD_SIGN = "sign";
    private static final String METHOD_VERIFY = "verify";
    private static final String METHOD_LOAD_ALL_TOKENS = "load_all_tokens";
    private static final String METHOD_LOAD_FIREBASE_CONFIG = "load_firebase_config";

    private static final String PARAMETER_SERIAL = "serial";
    private static final String PARAMETER_MESSAGE = "message";
    private static final String PARAMETER_SIGNED_DATA = "signedData";
    private static final String PARAMETER_SIGNATURE = "signature";

    private Util util;

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {

        channel = new MethodChannel(messenger, METHOD_CHANNEL_ID);
        channel.setMethodCallHandler(this);

        try {
            SecretKeyWrapper secretKeyWrapper = new SecretKeyWrapper(applicationContext);
            util = new Util(secretKeyWrapper, applicationContext.getFilesDir().getAbsolutePath());
        } catch (Exception e) {
//            e.printStackTrace();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final PiAuthenticatorLegacyPlugin instance = new PiAuthenticatorLegacyPlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        if (util == null) {
            // Occurs when the secret key wrapper is not available, i.e., native app was never used.
            result.error("500",
                    "Utils not available.",
                    null);
            return;
        }

        try {
            switch (call.method) {
                case METHOD_SIGN:
                    // [serial, message]
                    String serial1 = call.argument(PARAMETER_SERIAL);
                    String message = call.argument(PARAMETER_MESSAGE);

                    if (serial1 == null || message == null) {
                        result.error("400",
                                "Serial and message must be provided.",
                                null);
                    } else {
                        result.success(util.sign(serial1, message));
                    }
                    break;

                case METHOD_VERIFY:
                    // [serial, signedData, signature]
                    String serial2 = call.argument(PARAMETER_SERIAL);
                    String signedData = call.argument(PARAMETER_SIGNED_DATA);
                    String signature = call.argument(PARAMETER_SIGNATURE);

                    if (serial2 == null || signedData == null || signature == null) {
                        result.error("400",
                                "Serial, signedData and signature must not be null.",
                                null);
                    } else {
                        result.success(util.verifySignature(serial2, signature, signedData));
                    }
                    break;

                case METHOD_LOAD_ALL_TOKENS:
                    result.success(util.loadTokensJSON());
                    break;

                case METHOD_LOAD_FIREBASE_CONFIG:
                    result.success(util.loadFirebaseConfig());
                    break;

                default:
                    result.notImplemented();
            }
        } catch (Exception e) {
            result.error("500",
                    "An unknown error occurred: " + e,
                    null);
        }
    }
}
