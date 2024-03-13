import "package:flutter_local_notifications/flutter_local_notifications.dart";

class Notifications {
  static final Notifications instance = Notifications._();

  Notifications._();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> setup() async {
    const InitializationSettings initializationSettings = InitializationSettings(iOS: DarwinInitializationSettings());
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(String title, String body) {
    const notificationDetails = NotificationDetails(iOS: DarwinNotificationDetails());
    _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }
}
