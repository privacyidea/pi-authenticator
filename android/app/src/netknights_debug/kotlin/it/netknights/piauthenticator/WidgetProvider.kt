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
import android.content.res.Configuration
import android.os.Bundle
import android.content.ClipboardManager
import android.content.ClipData
import android.content.Intent

import android.app.PendingIntent
import java.io.File

class AppWidgetProvider : HomeWidgetProvider() {

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
        
        var editor = widgetData.edit()
        editor.putString("_widgetIds", appWidgetIds.joinToString(","))
        widgetData.getString("_copyText", null)?.let {
            val service = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newPlainText("token", it)
            service.setPrimaryClip(clip)
            editor.remove("_copyText")
        }
        editor.putBoolean("_widgetIsRebuilding", true)
        val rebuildingIds = widgetData.getString("_rebuildingWidgetIds", null)
        editor.remove("_rebuildingWidgetIds")
        var rebuildingWidgetIds: IntArray
        if(rebuildingIds == null || rebuildingIds.isEmpty()) {
            rebuildingWidgetIds = appWidgetIds   
        } else {
            rebuildingWidgetIds = rebuildingIds?.split(",")?.map { it.toInt() }?.toIntArray() ?: intArrayOf()
        }
        println("rebuildingWidgetIds: ${rebuildingWidgetIds.joinToString(",")}")
        editor.apply()
        rebuildingWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val tokenId = widgetData.getString("_tokenId$widgetId", null)
                
                // _loadImageFromWidgetDataString(widgetData, "_tokenBackground$nightModeSuffix", R.id.widget_background, this)
                _setBackground(context, widgetData, widgetId, nightModeSuffix, this)
                if(tokenId == null) {
                    _setContainerEmpty(context, widgetData, widgetId, nightModeSuffix, this)
                } else {
                    val showToken = widgetData.getBoolean("_showWidget$widgetId", false)
                    val tokenLocked = widgetData.getBoolean("_tokenLocked$widgetId", false)
                    val actionBlocked = widgetData.getBoolean("_actionBlocked$tokenId", false)
                    val tokenCopied = widgetData.getBoolean("_copyBlocked$widgetId", false)
                    println("showToken: $showToken")
                    _setSettingsIcon(context, widgetData, widgetId, nightModeSuffix, this)
                    if(tokenCopied) {
                        _setActionIcon(context, widgetData, widgetId, nightModeSuffix, this, false)
                        _setTokenCopy(context, widgetData, widgetId, nightModeSuffix, this)
                    } else if(showToken && !tokenLocked) {
                        _setActionIcon(context, widgetData, widgetId, nightModeSuffix, this, !actionBlocked)
                        _setTokenOtp(context, widgetData, widgetId, nightModeSuffix, this)
                    } else {
                        _setActionIcon(context, widgetData, widgetId, nightModeSuffix, this, false)
                        _setHiddenOtp(context, widgetData, widgetId, nightModeSuffix, this, tokenLocked)
                    }
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }

        editor = widgetData.edit()
        editor.putBoolean("_widgetIsRebuilding", false)
        editor.apply()
    }

    fun _setBackground(context: Context, widgetData: SharedPreferences, widgetId: Int, nightModeSuffix: String, remoteViews: RemoteViews) {
        _loadImageFromWidgetDataString(widgetData, "_tokenBackground$nightModeSuffix", R.id.widget_background, remoteViews)
        remoteViews.setOnClickPendingIntent(R.id.widget_background, null)
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
        if(tokenType == null) {
            remoteViews.setImageViewBitmap(R.id.widget_action, null)
            remoteViews.setOnClickPendingIntent(R.id.widget_action, null)
            return
        }
        if(showToken) {
            _loadImageFromWidgetDataString(widgetData, "_tokenAction_${tokenType}_active$nightModeSuffix", R.id.widget_action, remoteViews)
            val actionIntent = HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse("homewidget://action?widgetId=$widgetId"))
            remoteViews.setOnClickPendingIntent(R.id.widget_action, actionIntent)
        } else {
            _loadImageFromWidgetDataString(widgetData, "_tokenAction_${tokenType}_inactive$nightModeSuffix", R.id.widget_action, remoteViews)
            remoteViews.setOnClickPendingIntent(R.id.widget_action, null)
        }
    }

    fun _setHiddenOtp(context: Context, widgetData: SharedPreferences, widgetId: Int, nightModeSuffix: String, remoteViews: RemoteViews, tokenLocked: Boolean) {
        _loadImageFromWidgetDataString(widgetData, "_tokenOtp${widgetId}_hidden$nightModeSuffix", R.id.widget_otp, remoteViews)
        println("tokenLocked: $tokenLocked")
        if(tokenLocked) {
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context,
                MainActivity::class.java,
                Uri.parse("homewidgetnavigate://showlocked?id=$widgetId"))
            remoteViews.setOnClickPendingIntent(R.id.widget_otp, pendingIntent)
        } else {
        val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
            Uri.parse("homewidget://show?widgetId=$widgetId"))
        remoteViews.setOnClickPendingIntent(R.id.widget_otp, backgroundIntent)}
    }

    fun _setTokenOtp(context: Context, widgetData: SharedPreferences, widgetId: Int, nightModeSuffix: String, remoteViews: RemoteViews) {
        _loadImageFromWidgetDataString(widgetData, "_tokenOtp$widgetId$nightModeSuffix", R.id.widget_otp, remoteViews)
        // Otp is visible, so the user can copy it to the clipboard with the next click
        val clipIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
            Uri.parse("homewidget://copy?widgetId=$widgetId"))
        remoteViews.setOnClickPendingIntent(R.id.widget_otp, clipIntent)
    }

    fun _setTokenCopy(context: Context, widgetData: SharedPreferences, widgetId: Int, nightModeSuffix: String, remoteViews: RemoteViews) {
        _loadImageFromWidgetDataString(widgetData, "_tokenCopy$nightModeSuffix", R.id.widget_otp, remoteViews)
        // Token was just copied to clipboard, so when the user clicks again nothing should happen
        remoteViews.setOnClickPendingIntent(R.id.widget_otp, null)
    }

    fun _setContainerEmpty(context: Context, widgetData: SharedPreferences, widgetId: Int, nightModeSuffix: String, remoteViews: RemoteViews) {
        _loadImageFromWidgetDataString(widgetData, "_tokenContainerEmpty$nightModeSuffix", R.id.widget_otp, remoteViews)
        remoteViews.setImageViewBitmap(R.id.widget_settings, null);
        remoteViews.setImageViewBitmap(R.id.widget_action, null);
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
            view.setImageViewBitmap(xmlElement, null)
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
