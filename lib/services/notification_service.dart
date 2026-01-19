import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    print('[NotificationService] Initializing...');
    tz.initializeTimeZones();
    
    // Set default timezone to UTC if not otherwise specified. 
    // Note: zonedSchedule with absoluteTime handles local conversion if scheduledDate is a local TZDateTime.
    tz.setLocalLocation(tz.getLocation('UTC')); 

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    print('[NotificationService] Plugin initialized.');
  }

  Future<bool> requestPermissions() async {
    print('[NotificationService] Requesting permissions...');
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    final notificationPermissionGranted = await android?.requestNotificationsPermission() ?? false;
    print('[NotificationService] Notification permission: $notificationPermissionGranted');

    final alarmPermissionGranted = await Permission.scheduleExactAlarm.request().isGranted;
    print('[NotificationService] Exact alarm permission: $alarmPermissionGranted');

    return notificationPermissionGranted && alarmPermissionGranted;
  }

  /// Schedules a recurring daily notification.
  Future<void> scheduleDailyNotification(
    int id,
    String title,
    String body,
    TimeOfDay time,
  ) async {
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);

    print('[NotificationService] Scheduling recurring notification id: $id at $scheduledDate');

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Daily reminders for check-ins.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedules a single notification at a specific DateTime.
  Future<void> scheduleSingleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      print('[NotificationService] Skipping notification $id as the date is in the past: $scheduledDate');
      return;
    }

    final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    print('[NotificationService] Scheduling single notification id: $id at $tzDate');

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'activity_reminders',
          'Activity Reminders',
          channelDescription: 'Reminders for workouts and meals.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final DateTime now = DateTime.now();
    DateTime scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return tz.TZDateTime.from(scheduled, tz.local);
  }

  Future<void> cancelAllNotifications() async {
    print('[NotificationService] Cancelling all notifications...');
    await _notificationsPlugin.cancelAll();
  }
}
