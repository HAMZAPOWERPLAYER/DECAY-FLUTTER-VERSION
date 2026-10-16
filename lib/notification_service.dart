import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Gentle Reminder — ported from `src/lib/notification.ts`.
///
/// Soft local notification — max once every several days, message exactly:
/// "It's been a while." Wait — the original message is "Your companion is
/// still here." Zero urgency, zero emojis, zero exclamation points. Easily
/// disabled.
const int _reminderDays = 4;
const int _daySeconds = 24 * 60 * 60;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await _ensureInitialized();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          'gentle-reminder',
          'Gentle reminder',
          importance: Importance.defaultImportance,
          enableVibration: true,
        ),
      );
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: false,
        sound: false,
      );
      return granted ?? false;
    }
    return false;
  }

  Future<void> cancelGentleReminder() async {
    await _ensureInitialized();
    await _plugin.cancelAll();
  }

  /// There is only one reminder in Decay. Replacing it keeps the schedule
  /// correct after a visit without leaving stale notifications behind.
  Future<void> scheduleGentleReminder(int lastVisitAt) async {
    await _ensureInitialized();
    await cancelGentleReminder();

    final elapsedSeconds =
        (DateTime.now().millisecondsSinceEpoch - lastVisitAt) / 1000;
    final remainingSeconds = [
      60,
      (_reminderDays * _daySeconds - elapsedSeconds).ceil(),
    ].reduce((a, b) => a > b ? a : b);

    final when = tz.TZDateTime.now(tz.local).add(Duration(seconds: remainingSeconds));

    await _plugin.zonedSchedule(
      0,
      'Decay',
      'Your companion is still here.',
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'gentle-reminder',
          'Gentle reminder',
          channelDescription: 'One quiet reminder after four days away.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: false,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
