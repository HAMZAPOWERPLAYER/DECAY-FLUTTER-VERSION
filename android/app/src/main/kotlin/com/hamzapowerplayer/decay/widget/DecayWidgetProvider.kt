package com.hamzapowerplayer.decay.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.hamzapowerplayer.decay.R

/**
 * A window onto the companion, with no words in it at all. It mirrors whatever
 * stage the app last reported and then ages on its own between updates, so the
 * home screen never needs the app to be open.
 *
 * Ported from the original `plugins/with-decay-widget.js`. The Flutter side
 * (home_widget) writes the stage into the "HomeWidgetPreferences" prefs, which
 * is read here.
 */
class DecayWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) render(context, appWidgetManager, id)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_REFRESH) renderAll(context)
    }

    companion object {
        const val PREFS = "HomeWidgetPreferences"
        const val KEY_STAGE = "stage"
        const val ACTION_REFRESH = "com.hamzapowerplayer.decay.widget.REFRESH"

        private val CORE = intArrayOf(
            0xFFFFF7E8.toInt(), 0xFFF6E9D8.toInt(), 0xFFE8E9E6.toInt(),
            0xFFD5DEE4.toInt(), 0xFFDCD4EA.toInt(), 0xFFB8B2C4.toInt()
        )

        private val GLOW = intArrayOf(
            0xFFE8C888.toInt(), 0xFFD8C1A2.toInt(), 0xFFB3B9B6.toInt(),
            0xFF8FA3B0.toInt(), 0xFFA594C4.toInt(), 0xFF7A7488.toInt()
        )

        private val ALPHA = floatArrayOf(1.0f, 0.88f, 0.70f, 0.55f, 0.34f, 0.12f)

        private val SCALE = floatArrayOf(1.0f, 0.97f, 0.93f, 0.88f, 0.80f, 0.72f)

        fun readStage(context: Context): Int =
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getInt(KEY_STAGE, 0)
                .coerceIn(0, 5)

        fun renderAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context) ?: return
            val ids = manager.getAppWidgetIds(
                ComponentName(context, DecayWidgetProvider::class.java)
            )
            for (id in ids) render(context, manager, id)
        }

        private fun render(context: Context, manager: AppWidgetManager, id: Int) {
            // Graceful fallback: never blank/broken; default to last known good stage
            val stage = try { readStage(context) } catch (e: Exception) { 0 }
            try {
                val views = RemoteViews(context.packageName, R.layout.decay_widget)

                val glow = GLOW[stage]
                val core = CORE[stage]

                // A little unsteady once there is barely anything left to hold on to.
                val tremble = if (stage >= 4) 0.72f + Math.random().toFloat() * 0.28f else 1.0f

                views.setInt(R.id.decay_widget_bloom, "setColorFilter", glow)
                views.setFloat(R.id.decay_widget_bloom, "setAlpha", 0.62f * ALPHA[stage] * tremble)
                views.setInt(R.id.decay_widget_core, "setColorFilter", core)
                views.setFloat(R.id.decay_widget_core, "setAlpha", 0.96f * ALPHA[stage] * tremble)
                views.setFloat(R.id.decay_widget_core, "setScaleX", SCALE[stage])
                views.setFloat(R.id.decay_widget_core, "setScaleY", SCALE[stage])

                manager.updateAppWidget(id, views)
            } catch (e: Exception) {
                // Fallback: keep existing widget state rather than showing broken/blank
            }
        }
    }
}
