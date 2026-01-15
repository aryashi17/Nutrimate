import 'notification_service.dart';
import 'water_suggestion_service.dart';

class WaterReminderScheduler {
  static Future<void> scheduleEveryTwoHours() async {
    final now = DateTime.now();

    for (int i = 1; i <= 6; i++) {
      // final reminderTime = now.add(Duration(hours: i * 2));
final reminderTime = now.add(Duration(minutes: i * 1));

      await NotificationService.scheduleWaterReminder(
        id: 100 + i,
        dateTime: reminderTime,
        body: WaterSuggestionService.getSuggestion(),
      );
    }
  }
}
