import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';

class customNotification {
  final FlutterLocalNotificationsPlugin plugin;
  String title = "Default Title";
  String subTitle = "Default Sub Title";

  customNotification({required this.plugin, required this.title, required this.subTitle});

  Future<void> instantNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'test_channel_id',
          'Test Notifications',
          channelDescription: 'This channel is for testing notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      subTitle,
      platformChannelSpecifics,
    );
  }

  Future<void> scheduledSimpleNotification({
    required TimeOfDay time,
    required DateTime date,
    required int id,
  }) async {

    await plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'test_channel_id',
          'Test Notifications',
          channelDescription: 'This channel is for testing notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    final tz.TZDateTime scheduledDateTime = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      subTitle,
      scheduledDateTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exact,
      // matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await plugin.cancel(id);
  }
}
