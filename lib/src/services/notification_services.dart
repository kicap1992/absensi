import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/tzdata.dart' as tz;

// ignore: avoid_classes_with_only_static_members
class NotificationServices {
  // Below is the code for initializing the plugin using var _notificationPlugin
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future showNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificanDetails(),
        payload: payload,
      );

  // static Future showScheduleNotification() async =>
  //     _notifications.zonedSchedule(
  //       0,
  //       'Cek Laporan',
  //       "Laporan Baru Mungkin Ada, Sila Cek Di Aplikasi",
  //       // tz.TZDateTime.from(scheduledDate, tz.local),
  //       _scheduleDaily(const Time(18)),
  //       await _notificanDetails(),
  //       payload: "Laporan Baru Mungkin Ada, Sila Cek Di Aplikasi",
  //       androidAllowWhileIdle: true,
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime,
  //       matchDateTimeComponents: DateTimeComponents.time,
  //     );

  static Future _notificanDetails() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      // priority: Priority.high,
      // ticker: 'ticker',
    );
    return const NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: IOSNotificationDetails(),
    );
  }

  static Future init(
      {bool initScheduled = false, BuildContext? context}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = IOSInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);

    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotifications.add(details.payload);
    }

    await _notifications.initialize(
      settings,
      onSelectNotification: (payload) async {
        onNotifications.add(payload);
      },
    );

    if (initScheduled) {
      final locationName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    }
  }

  // static tz.TZDateTime _scheduleDaily(Time time) {
  //   final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  //   final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
  //       time.hour, time.minute, time.second);
  //   // if (scheduledDate.isBefore(now)) {
  //   //   scheduledDate = scheduledDate.add(const Duration(days: 1));
  //   // }
  //   return scheduledDate.isBefore(now)
  //       ? scheduledDate.add(const Duration(days: 1))
  //       : scheduledDate;
  // }
}
