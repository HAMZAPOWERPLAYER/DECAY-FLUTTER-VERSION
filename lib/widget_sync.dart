import 'dart:io';

import 'package:home_widget/home_widget.dart';

/// Mirror the current decay stage onto the home screen widget. The widget is
/// the part of Decay people see when the app is closed, so it is kept in step
/// whenever the app is opened or the companion changes state.
///
/// Ported from `src/lib/widget.ts`; the native Android RemoteViews renderer
/// reads the saved `stage` value.
class WidgetSync {
  static Future<void> syncStage(int stage) async {
    if (!Platform.isAndroid) return;
    try {
      await HomeWidget.saveWidgetData<int>('stage', stage);
      await HomeWidget.updateWidget(
        name: 'DecayWidgetProvider',
        androidName: 'com.hamzapowerplayer.decay.widget.DecayWidgetProvider',
      );
    } catch (_) {
      // Running in a build without the widget provider — never fatal.
    }
  }
}
