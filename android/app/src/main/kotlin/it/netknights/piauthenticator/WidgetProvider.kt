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
import java.io.File

class AppWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {

                val tokenId = widgetData.getString("_tokenId$widgetId", null)
                if(tokenId == null) {
                    val imagePath = widgetData.getString("_tokenContainerEmpty", null)
                    println("imagePath is $imagePath")
                    if(imagePath != null) {
                        val imageFile = File(imagePath)
                        val imageExists = imageFile.exists()
                        if (imageExists && imageFile.absolutePath != null) {
                           val myBitmap: Bitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
                           setImageViewBitmap(R.id.widget_image, myBitmap)
                        } else {
                           println("image not found!, looked @: $imagePath")
                        }
                    }
                    // No token yet, so the user has to select one
                    val pendingIntent = HomeWidgetLaunchIntent.getActivity(context,
                            MainActivity::class.java,
                            Uri.parse("homewidgetnavigate://link?id=$widgetId"))
                    setOnClickPendingIntent(R.id.widget_root, pendingIntent)
                }  else {
                    val imagePath = widgetData.getString("_tokenContainer$widgetId", null)
                    if(imagePath != null) {
                        val imageFile = File(imagePath)
                        val imageExists = imageFile.exists()
                        if (imageExists && imageFile.absolutePath != null) {
                            println("imagePath is $imagePath")
                            val myBitmap: Bitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
                            setImageViewBitmap(R.id.widget_image, myBitmap)
                        } else {
                            println("image not found!, looked @: $imagePath")
                        }
                                  // Pending intent to update counter on button click
                        val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
                        Uri.parse("homewidget://show?widgetId=$widgetId&tokenId=$tokenId"))
                        setOnClickPendingIntent(R.id.widget_root, backgroundIntent)
                    } else {
                        println("imagePath is null")
                    } 
                }


                // var imagePath = widgetData.getString("_tokenContainer$widgetId", null)
                // var needInit = false
                // if(imagePath == null) {
                //     println("imagePath is null")
                //     needInit = true
                //     imagePath = widgetData.getString("_tokenContainerEmpty", null)
                // } 
                // if(imagePath != null) {
                //     println("imagePath is $imagePath")
                //     val imageFile = File(imagePath)
                //     val imageExists = imageFile.exists()
                //     if (imageExists) {
                //        val myBitmap: Bitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
                //        setImageViewBitmap(R.id.widget_image, myBitmap)
                //     } else {
                //        println("image not found!, looked @: $imagePath")
                //     }
                // } 
 
                // if(needInit) {
                //     // No token yet, so the user has to select one
                //     val pendingIntent = HomeWidgetLaunchIntent.getActivity(context,
                //             MainActivity::class.java,
                //             Uri.parse("homewidgetnavigate://link?id=$widgetId"))
                //     setOnClickPendingIntent(R.id.widget_root, pendingIntent)
                // }


                // val currentPassword = widgetData.getString("_password", "No password")
                // val tokenId = widgetData.getString("_tokenId", "No token id")

                // val tokenPwText = "$currentPassword"
                // if(tokenPwText.length < 1) {
                //     setTextViewText(R.id.token_pw, "No password")
                // } else {
                //     setTextViewText(R.id.token_pw, tokenPwText)
                // }

                // Pending intent to update counter on button click
                // val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
                //         Uri.parse("myappwidget://getpassword?tokenId=$tokenId"))
                // setOnClickPendingIntent(R.id.widget_root, backgroundIntent)
                // val backgroundIntent2 = HomeWidgetBackgroundIntent.getBroadcast(context,
                //         Uri.parse("myappwidget://getpassword?tokenId=tokenIds2"))
                // setOnClickPendingIntent(R.id.widget_root, backgroundIntent2)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}