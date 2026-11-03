import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local (on-device) reminders — no server needed.
///
/// * id 1 — peak-hour nudge, daily 17:30 (Gujarat ToD peak starts 18:00)
/// * id 2 — streak reminder, daily 20:30 (before quiet hours 22:00–07:00)
/// * id 3 — monthly bill reminder, 1st of month 09:00
/// * id 100+ — instant notifications (FCM foreground, task feedback)
///
/// Every method is safe to call on web / in tests: failures are swallowed and
/// reported through [debugPrint] so the UI never breaks.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static const int peakNudgeId = 1;
  static const int streakReminderId = 2;
  static const int billReminderId = 3;

  static const NotificationDetails _nudgeDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'life_nudges',
      'LiFE nudges',
      channelDescription: 'Peak-hour tips, streak and bill reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(),
  );

  static const NotificationDetails _alertDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'life_alerts',
      'GEDA alerts & campaigns',
      channelDescription: 'Grid alerts, community updates and GEDA campaigns',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Call once from `main()` after `Firebase.initializeApp`.
  static Future<void> init() async {
    if (kIsWeb) return; // web uses browser notifications via FCM only
    try {
      tzdata.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      }
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      _ready = true;
    } catch (e) {
      debugPrint('NotificationService.init skipped: $e');
    }
  }

  /// Ask for Android 13+ / iOS permission. Returns true when granted.
  static Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final ok = await android.requestNotificationsPermission();
        return ok ?? true;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final ok =
            await ios.requestPermissions(alert: true, badge: true, sound: true);
        return ok ?? true;
      }
    } catch (e) {
      debugPrint('requestPermission failed: $e');
    }
    return true;
  }

  /// Daily 17:30 "peak hours start at 6 pm" nudge.
  static Future<void> schedulePeakNudge({required bool enabled}) =>
      _scheduleDaily(
        id: peakNudgeId,
        enabled: enabled,
        hour: 17,
        minute: 30,
        title: 'Peak hours start at 6 pm ⚡',
        body:
            'Run the washing machine & geyser now, or after 11 pm — save ~₹6 and 0.4 kg CO₂ today.',
      );

  /// Daily 20:30 streak reminder (only fires if the day's task is pending —
  /// the app cancels it when a task is completed, see [markTaskDoneToday]).
  static Future<void> scheduleStreakReminder({required bool enabled}) =>
      _scheduleDaily(
        id: streakReminderId,
        enabled: enabled,
        hour: 20,
        minute: 30,
        title: 'Your LiFE streak needs one task 🌱',
        body: 'Complete any eco-task before midnight to keep your streak alive.',
      );

  /// 1st of every month 09:00 — "add your electricity bill".
  static Future<void> scheduleBillReminder({required bool enabled}) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: billReminderId);
      if (!enabled) return;
      final now = tz.TZDateTime.now(tz.local);
      var when = tz.TZDateTime(tz.local, now.year, now.month, 1, 9);
      if (when.isBefore(now)) {
        when = tz.TZDateTime(tz.local, now.year, now.month + 1, 1, 9);
      }
      await _plugin.zonedSchedule(
        id: billReminderId,
        title: 'New month, new bill 📄',
        body:
            'Add last month\'s electricity units to update your carbon offset and earn credits.',
        scheduledDate: when,
        notificationDetails: _nudgeDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    } catch (e) {
      debugPrint('scheduleBillReminder failed: $e');
    }
  }

  /// Apply all user preferences in one go (after sign-in / toggle change).
  static Future<void> syncPreferences({
    required bool peakNudge,
    required bool streakReminders,
    required bool billReminder,
  }) async {
    await schedulePeakNudge(enabled: peakNudge);
    await scheduleStreakReminder(enabled: streakReminders);
    await scheduleBillReminder(enabled: billReminder);
  }

  /// Called when the user completes a task — today's streak reminder is no
  /// longer needed; it is re-armed for tomorrow automatically.
  static Future<void> markTaskDoneToday({required bool streakReminders}) async {
    if (!_ready || !streakReminders) return;
    try {
      await _plugin.cancel(id: streakReminderId);
      final now = tz.TZDateTime.now(tz.local);
      final tomorrow = tz.TZDateTime(
          tz.local, now.year, now.month, now.day + 1, 20, 30);
      await _plugin.zonedSchedule(
        id: streakReminderId,
        title: 'Your LiFE streak needs one task 🌱',
        body: 'Complete any eco-task before midnight to keep your streak alive.',
        scheduledDate: tomorrow,
        notificationDetails: _nudgeDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('markTaskDoneToday failed: $e');
    }
  }

  /// Show an immediate notification (used for FCM messages received while the
  /// app is in the foreground and for one-off confirmations).
  static Future<void> showNow({
    required String title,
    required String body,
    bool alert = false,
    String? payload,
  }) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        id: 100 + DateTime.now().millisecondsSinceEpoch % 10000,
        title: title,
        body: body,
        notificationDetails: alert ? _alertDetails : _nudgeDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('showNow failed: $e');
    }
  }

  /// Clear everything (sign-out).
  static Future<void> cancelAll() async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------

  static Future<void> _scheduleDaily({
    required int id,
    required bool enabled,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: id);
      if (!enabled) return;
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: _nextInstance(hour, minute),
        notificationDetails: _nudgeDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('schedule #$id failed: $e');
    }
  }

  static tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var when =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (when.isBefore(now)) when = when.add(const Duration(days: 1));
    return when;
  }
}
