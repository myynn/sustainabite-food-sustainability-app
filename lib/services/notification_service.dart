import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//this is the notification service for my additional feature local notifications using the flutter local notifications package
class NotificationService {
  // this is a single instance of the notifications plugin to handle scheduling and displaying notifications
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

//this initialises the notification settings for the app and must be called in main.dart first before showing notifications
  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(initSettings);
  }

  static int _autoId = 0; //this is to auto increment the id used for each notification to avoid overwriting old ones as i am using this notification for both the adding item form and reserving of the food item

  static Future<void> showNotification({ //this displays a simple notification
    required String title, //with title
    required String body, //and body text of the notification
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel_id',
      'General Notifications',
      channelDescription: 'Default channel for app notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = //wraps platform specific details into a single object for cross platform use
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      _autoId++, //the unique notification id
      title, //title
      body, //body of the notification
      platformDetails, //notification config
    );
  }
}
