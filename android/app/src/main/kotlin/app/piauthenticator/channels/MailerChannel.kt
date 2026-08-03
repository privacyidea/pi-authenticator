package app.piauthenticator.channels

import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

object MailerChannel {

    private const val CHANNEL_NAME = "pi_authenticator/mailer"

    fun register(activity: Activity, flutterEngine: FlutterEngine) {
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler { call, result ->
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
                                activity,
                                "${activity.packageName}.file_provider",
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

                        if (activity.packageManager.resolveActivity(intent, 0) != null) {
                            activity.startActivity(Intent.createChooser(intent, null))
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
