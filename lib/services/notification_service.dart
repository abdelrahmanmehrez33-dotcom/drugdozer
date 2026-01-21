import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> init() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'drugdozer_channel',
          'تذكير الجرعات',
          channelDescription: 'تذكير لمواعيد أدويتك',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleReminderNotifications(
      String drugName, 
      String dosage, 
      List<DateTime> times, 
      int durationDays,
      String reminderId) async {
    await init();
    
    for (int day = 0; day < durationDays; day++) {
      for (int i = 0; i < times.length; i++) {
        final notificationTime = times[i].add(Duration(days: day));
        final notificationId = int.parse('${reminderId.hashCode}${day}${i}');
        
        await scheduleNotification(
          id: notificationId,
          title: '⏰ تذكير بجرعة $drugName',
          body: 'الجرعة: $dosage - الوقت: ${notificationTime.hour}:${notificationTime.minute}',
          scheduledTime: notificationTime,
        );
      }
    }
  }
}