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
import java.io.File

class AppWidgetProvider : HomeWidgetProvider() {
    override fun onAppWidgetOptionsChanged( context: Context, 
     appWidgetManager: AppWidgetManager, 
     appWidgetId: Int, 
     newOptions: Bundle) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        println("onAppWidgetOptionsChanged")
    }


    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        when (context.resources?.configuration?.uiMode?.and(Configuration.UI_MODE_NIGHT_MASK)) {
            Configuration.UI_MODE_NIGHT_YES -> { 
                println("night mode")
            }
            Configuration.UI_MODE_NIGHT_NO -> {
                println("day mode")
            }
            Configuration.UI_MODE_NIGHT_UNDEFINED -> {
                println("undefined mode")
            }
        }
        val isNightMode = AppCompatDelegate.getDefaultNightMode() == AppCompatDelegate.MODE_NIGHT_YES
        println("isNightMode: $isNightMode")
        val editor = widgetData.edit()
        editor.putString("_widgetIds", appWidgetIds.joinToString(","))
        editor.apply()
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {

                val tokenId = widgetData.getString("_tokenId$widgetId", null)
                if(tokenId == null) {
                  val success =  _loadImageFromWidgetDataString(widgetData, "_tokenContainerEmpty", R.id.widget_image, this)
                    // No token yet, so the user has to select one
                    val pendingIntent = HomeWidgetLaunchIntent.getActivity(context,
                            MainActivity::class.java,
                            Uri.parse("homewidgetnavigate://link?id=$widgetId"))
                    setOnClickPendingIntent(R.id.widget_root, pendingIntent)
                }  else {
                    _loadImageFromWidgetDataString(widgetData, "_tokenContainer$widgetId", R.id.widget_image, this)
                    
                    val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
                        Uri.parse("homewidget://show?widgetId=$widgetId&tokenId=$tokenId"))
                    setOnClickPendingIntent(R.id.widget_root, backgroundIntent)

                    _loadImageFromWidgetDataString(widgetData, "_settingsIcon", R.id.widget_settings, this)
                    val pendingIntent = HomeWidgetLaunchIntent.getActivity(context,
                        MainActivity::class.java,
                        Uri.parse("homewidgetnavigate://link?id=$widgetId"))
                    setOnClickPendingIntent(R.id.widget_settings, pendingIntent)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
    fun _loadImageFromWidgetDataString(widgetData: SharedPreferences, key: String, xmlElement: Int, view: RemoteViews): Boolean {
        
        val imagePath = widgetData.getString("$key", null)
        if(imagePath == null) {
            return false
            println("imagePath is null")
        } 
        
        val imageFile = File(imagePath)
        val imageExists = imageFile.exists()
        if (imageExists && imageFile.absolutePath == null) {
            return false
            println("image not found!, looked @: $imagePath")
        }
       
        println("imagePath is $imagePath")
        try {
            val myBitmap: Bitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
            view.setImageViewBitmap(xmlElement, myBitmap)
        } catch (e: Exception) {
            return false
        }
        return true
    }
}
