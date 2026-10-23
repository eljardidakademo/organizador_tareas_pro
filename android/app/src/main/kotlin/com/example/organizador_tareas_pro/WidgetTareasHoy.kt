package com.example.organizador_tareas_pro

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Widget de pantalla de inicio "Tareas de hoy". La app (Flutter) le pasa los
 * textos ya preparados cada vez que se guardan los días; aquí solo se pintan.
 */
class WidgetTareasHoy : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val hoy = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val fechaDatos = widgetData.getString("widget_fecha", null)

        val titulo: String
        val contenido: String
        if (fechaDatos == hoy) {
            titulo = widgetData.getString("widget_titulo", null) ?: "Organizador"
            contenido = widgetData.getString("widget_contenido", null) ?: ""
        } else {
            // Los datos son de otro día: hace falta abrir la app para refrescarlos.
            titulo = widgetData.getString("widget_titulo_vacio", null) ?: "Organizador"
            contenido = widgetData.getString("widget_abrir_app", null)
                ?: "Abre la app para ver las tareas de hoy"
        }

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_tareas_hoy).apply {
                setTextViewText(R.id.widget_titulo, titulo)
                setTextViewText(R.id.widget_contenido, contenido)
                // Al tocar el widget se abre la app.
                setOnClickPendingIntent(
                    R.id.widget_raiz,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
