package it.netknights.piauthenticator

import android.app.Application
import android.content.Context
import androidx.annotation.Keep
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.util.concurrent.TimeUnit

class PiApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Keep a far-future no-op WorkRequest permanently enqueued so WorkManager never
        // disables RescheduleReceiver. Without this, toggling the receiver fires
        // ACTION_PACKAGE_CHANGED which causes AppWidgetServiceImpl to reset all widget
        // RemoteViews (flashing the initialLayout) and re-send ACTION_APPWIDGET_UPDATE.
        // See: https://issuetracker.google.com/issues/115575872
        val request = OneTimeWorkRequestBuilder<KeepAliveWorker>()
            .setInitialDelay(3650, TimeUnit.DAYS)
            .build()
        WorkManager.getInstance(this)
            .enqueueUniqueWork("rescheduleReceiverKeepAlive", ExistingWorkPolicy.KEEP, request)
    }
}

@Keep
class KeepAliveWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result = Result.success()
}
