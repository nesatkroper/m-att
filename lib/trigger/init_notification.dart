import 'dart:io';

import 'package:attendance/main.dart';
import 'package:attendance/screens/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tz_data.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(),
  );

  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // Modify initNotifications():
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => QrScannerScreen()),
      );
    },
  );
}

Future<bool> checkAndRequestExactAlarmPermission() async {
  if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool granted =
        await androidPlugin?.requestExactAlarmsPermission() ?? false;
    return granted;
  }
  return true; // iOS doesn't need this
}

Future<void> scheduleDailyScanReminder() async {
  final hasPermission = await checkAndRequestExactAlarmPermission();
  if (!hasPermission) {
    print('Exact alarm permission not granted');
    return;
  }

  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledTime = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    11, // 8 AM
    0,
  );

  if (scheduledTime.isBefore(now)) {
    scheduledTime = scheduledTime.add(const Duration(days: 1));
  }

  final tz.TZDateTime reminderTime =
      scheduledTime.subtract(const Duration(minutes: 48));

  await _scheduleNotification(
    id: 0,
    title: 'Scan Attendance Soon!',
    body: 'Scan before 8:00 AM!',
    scheduledDate: reminderTime,
  );

  await _scheduleNotification(
    id: 1,
    title: 'Scan Attendance Now!',
    body: 'Last chance to scan before its late!',
    scheduledDate: scheduledTime,
  );
}

Future<void> _scheduleNotification({
  required int id,
  required String title,
  required String body,
  required tz.TZDateTime scheduledDate,
}) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    scheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'scan_reminder_channel',
        'Attendance Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    // androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    androidScheduleMode: await checkAndRequestExactAlarmPermission()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexact,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
