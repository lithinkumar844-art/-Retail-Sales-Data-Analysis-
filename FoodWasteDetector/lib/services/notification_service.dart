import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(initSettings);
  }

  static Future<void> showSpoilageAlert(String foodName) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'spoilage_channel',
        'Spoilage Alerts',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      0,
      'Food Spoilage Alert',
      '$foodName is Spoiled. Please discard or compost.',
      details,
    );
  }

  static Future<void> scheduleExpiryReminder(String foodName) async {
    final days = _expiryDays(foodName);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'expiry_channel',
        'Expiry Reminders',
      ),
    );

    await _plugin.periodicallyShow(
      foodName.hashCode,
      'Expiry Reminder',
      '$foodName may expire in ~$days days. Check it now.',
      RepeatInterval.daily,
      details,
    );
  }

  static int _expiryDays(String foodName) {
    switch (foodName.toLowerCase()) {
      case 'banana':
        return 2;
      case 'apple':
        return 5;
      case 'orange':
        return 6;
      default:
        return 3;
    }
  }
}
