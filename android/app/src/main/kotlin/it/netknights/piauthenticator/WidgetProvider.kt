package it.netknights.piauthenticator

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import android.graphics.BitmapFactory
import android.graphics.Bitmap
import androidx.appcompat.app.AppCompatDelegate
import android.content.res.Configuration
import android.os.Bundle
import android.content.ClipboardManager
import android.content.ClipData
import android.content.Intent

import android.app.PendingIntent
import java.io.File

// val WIDGET_BUTTON = "it.netknights.piauthenticator.WIDGET_BUTTON"

class AppWidgetProvider : HomeWidgetProvider() {

    fun onConfigurationChanged(newConfiguration: Configuration) {
        println("onConfigurationChanged#AppWidgetProvider")
        // val nightModeSuffix = if(newConfiguration.uiMode.and(Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES) "_dark" else "_light"
        // val widgetData = getWidgetData(newConfiguration)
        // val widgetIds = widgetData.getString("_widgetIds", null)
        // if(widgetIds != null) {
        //     val appWidgetIds = widgetIds.split(",").map { it.toInt() }.toIntArray()
        //     onUpdate(newConfiguration.applicationContext, AppWidgetManager.getInstance(newConfiguration.applicationContext), appWidgetIds, widgetData)
        // }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        println("onReceive")
        // if (WIDGET_BUTTON.equals(intent.getAction())) {
        //     println("onReceive2")
        //     // do something here
        // }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        val nightModeSuffix: String
        val currentThemeMode = widgetData.getString("_currentThemeMode", "system")
        println("currentThemeMode: $currentThemeMode")
        if(currentThemeMode == "system") {
            val isNightMode = context.resources?.configuration?.uiMode?.and(Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
            nightModeSuffix = if(isNightMode) "_dark" else "_light"
        } else {
            nightModeSuffix = if(currentThemeMode == "dark") "_dark" else "_light"
        }
        println("nightModeSuffix: $nightModeSuffix")

        val editor = widgetData.edit()
        editor.putString("_widgetIds", appWidgetIds.joinToString(","))
        widgetData.getString("_copyText", null)?.let {
            val service = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newPlainText("token", it)
            service.setPrimaryClip(clip)
            editor.remove("_copyText")
        }
        editor.apply()

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val tokenId = widgetData.getString("_tokenId$widgetId", null)
                
                // _loadImageFromWidgetDataString(widgetData, "_tokenBackground$nightModeSuffix", R.id.widget_background, this)
                _setBackground(context, widgetData, widgetId, nightModeSuffix, this)
                if(tokenId == null) {
                    _setContainerEmpty(context, widgetData, widgetId, nightModeSuffix, this)
                } else {
                    val showToken = widgetData.getBoolean("_showWidget$widgetId", false)
                    println("showToken: $showToken")
                    _setSettingsIcon(context, widgetData, widgetId, nightModeSuffix, this)
                    _setActionIcon(context, widgetData, widgetId, nightModeSuffix, this, showToken)
                    if(showToken) {
                        _setTokenOtp(context, widgetData, widgetId, nightModeSuffix, this)
                    } else {
                        _setHiddenOtp(context, widgetData, widgetId, nightModeSuffix, this)
                    }
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    fun _setBackground(context: Context, widgetData: SharedPreferences, widgetId: Int, nightModeSuffix: String, remoteViews: RemoteViews) {
        _loadImageFromWidgetDataString(widgetData, "_tokenBackground$nightModeSuffix", R.id.widget_background, remoteViews)
    }
    fun _setSettingsIcon(context: Context, widgetData: SharedPreferences, widgetId: Int, nightModeSuffix: String, remoteViews: RemoteViews) {
        _loadImageFromWidgetDataString(widgetData, "_settingsIcon$nightModeSuffix", R.id.widget_settings, remoteViews)
        val pendingIntent = HomeWidgetLaunchIntent.getActivity(context,
            MainActivity::class.java,
            Uri.parse("homewidgetnavigate://link?id=$widgetId"))
        remoteViews.setOnClickPendingIntent(R.id.widget_settings, pendingIntent) 
    }
    fun _setActionIcon(context: Context, widgetData: SharedPreferences, widgetId: Int, nightModeSuffix: String, remoteViews: RemoteViews, showToken: Boolean) {
        println("getString: _tokenType$widgetId")
        val tokenType = widgetData.getString("_tokenType$widgetId", null)
        if(tokenType == null || showToken == false) {
            remoteViews.setOnClickPendingIntent(R.id.widget_action, null)
            if(tokenType == null) {
                remoteViews.setImageViewBitmap(R.id.widget_action, null)
                return
            }
        }
        val activeSuffix = if(showToken) "_active" else "_inactive"
        _loadImageFromWidgetDataString(widgetData, "_tokenAction_$tokenType$activeSuffix$nightModeSuffix", R.id.widget_action, remoteViews)
        val actionIntent = HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse("homewidget://action?widgetId=$widgetId"))
        remoteViews.setOnClickPendingIntent(R.id.widget_action, actionIntent)
    }

    fun _setHiddenOtp(context: Context, widgetData: SharedPreferences, widgetId: Int, nightModeSuffix: String, remoteViews: RemoteViews) {
        _loadImageFromWidgetDataString(widgetData, "_tokenOtp${widgetId}_hidden$nightModeSuffix", R.id.widget_otp, remoteViews)
        println("Uri.parse(homewidget://show?widgetId=$widgetId)")
        val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
            Uri.parse("homewidget://show?widgetId=$widgetId"))
        remoteViews.setOnClickPendingIntent(R.id.widget_otp, backgroundIntent)
    }

    fun _setTokenOtp(context: Context, widgetData: SharedPreferences, widgetId: Int, nightModeSuffix: String, remoteViews: RemoteViews) {
        _loadImageFromWidgetDataString(widgetData, "_tokenOtp$widgetId$nightModeSuffix", R.id.widget_otp, remoteViews)
        // copy token to clipboard
        val clipIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
            Uri.parse("homewidget://copy?widgetId=$widgetId"))
        remoteViews.setOnClickPendingIntent(R.id.widget_otp, clipIntent)
    }

    fun _setContainerEmpty(context: Context, widgetData: SharedPreferences, widgetId: Int, nightModeSuffix: String, remoteViews: RemoteViews) {
        _loadImageFromWidgetDataString(widgetData, "_tokenContainerEmpty$nightModeSuffix", R.id.widget_otp, remoteViews)
        // No token yet, so the user has to select one
        val pendingIntent = HomeWidgetLaunchIntent.getActivity(context,
                MainActivity::class.java,
                Uri.parse("homewidgetnavigate://link?id=$widgetId"))
        remoteViews.setOnClickPendingIntent(R.id.widget_background, pendingIntent)
    }



    fun _loadImageFromWidgetDataString(widgetData: SharedPreferences, key: String, xmlElement: Int, view: RemoteViews): Boolean {
        
        println("Try to load image from key: $key")
        val imagePath = widgetData.getString("$key", null)
        if(imagePath == null) {
            println("imagePath is null")
            return false
        } 
        
        val imageFile = File(imagePath)
        val imageExists = imageFile.exists()
        if (imageExists && imageFile.absolutePath == null) {
            println("image not found!, looked @: $imagePath")
            return false
        }
       
        println("imagePath is $imagePath")
        try {
            val myBitmap: Bitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
            view.setImageViewBitmap(xmlElement, myBitmap)
        } catch (e: Exception) {
            println("Exception: $e")
            return false
        }
        return true
    }
}
