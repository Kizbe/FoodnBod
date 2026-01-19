import 'dart:math';
import 'package:flutter/material.dart';
import 'notification_service.dart';

class NotificationContent {
  final String title;
  final String body;
  NotificationContent({required this.title, required this.body});
}

class NotificationScheduleManager {
  final NotificationService _notificationService;

  NotificationScheduleManager(this._notificationService);

  static final Random _random = Random();

  static final List<String> _mealTitles = [
    'Meal Time! 🥗',
    'Fuel Your Body 🍎',
    'Time to Eat 😋',
    'Nutrition Alert 🍗',
  ];

  static final List<String> _mealBodies = [
    'It\'s time for your %s. Enjoy your meal!',
    'Your %s is scheduled now. Don\'t skip it!',
    'Ready for %s? Consistency is key to your goals.',
    'Fuel up with your %s. Your body will thank you!',
  ];

  static final List<String> _workoutTitles = [
    'Get Moving! 💪',
    'Workout Time ⚡',
    'Time to Sweat 💦',
    'Fitness Goal Alert 🎯',
  ];

  static final List<String> _workoutBodies = [
    'Time for your workout: %s. Let\'s go!',
    'Your %s session is starting. Push yourself!',
    'Ready for %s? You\'re getting stronger every day.',
    'Don\'t miss your %s. Future you will be glad you did it!',
  ];

  static final List<String> _morningTitles = [
    'Good Morning! ☀️',
    'Rise and Shine! 🌅',
    'A New Day Awaits! 🚀',
  ];

  static final List<String> _morningBodies = [
    'Time for your morning check-in with FoodNBod! Let\'s crush today.',
    'Ready to start your day right? Let\'s see your plan!',
    'Good morning! Consistency is the bridge between goals and accomplishment.',
  ];

  static final List<String> _eveningTitles = [
    'Good Evening! 🌙',
    'Reflection Time ✨',
    'Day Wrap-up 📝',
  ];

  static final List<String> _eveningBodies = [
    'How was your day? Let\'s check in and log your progress!',
    'Time for your evening check-in. You did great today!',
    'The day is winding down. Let\'s see how close you got to your goals!',
  ];

  /// Schedules two daily reminders for the morning and evening.
  Future<void> scheduleDailyReminders() async {
    print('[NotificationScheduleManager] Scheduling daily reminders...');
    const TimeOfDay morningReminderTime = TimeOfDay(hour: 8, minute: 0);
    const TimeOfDay eveningReminderTime = TimeOfDay(hour: 12, minute: 06);

    final morning = _getMorningReminder();
    await _notificationService.scheduleDailyNotification(
      0,
      morning.title,
      morning.body,
      morningReminderTime,
    );

    final evening = _getEveningReminder();
    await _notificationService.scheduleDailyNotification(
      1,
      evening.title,
      evening.body,
      eveningReminderTime,
    );
    print('[NotificationScheduleManager] All daily reminders scheduled.');
  }

  /// Schedules randomized meal reminders based on the user's set times.
  Future<void> scheduleMealReminders(String mealName, TimeOfDay time, int index) async {
    final content = getMealReminder(mealName);
    await _notificationService.scheduleDailyNotification(
      100 + index,
      content.title,
      content.body,
      time,
    );
  }

  /// Schedules randomized workout reminders based on a specific DateTime.
  Future<void> scheduleWorkoutReminder(String workoutName, DateTime scheduledDate, int index, {bool isRoutine = false}) async {
    final content = getWorkoutReminder(workoutName);
    await _notificationService.scheduleSingleNotification(
      (isRoutine ? 300 : 200) + index,
      content.title,
      content.body,
      scheduledDate,
    );
  }

  /// Cancels all scheduled reminders.
  Future<void> cancelAllReminders() async {
    print('[NotificationScheduleManager] Cancelling all reminders...');
    await _notificationService.cancelAllNotifications();
  }

  NotificationContent getMealReminder(String mealName) {
    return NotificationContent(
      title: _mealTitles[_random.nextInt(_mealTitles.length)],
      body: _mealBodies[_random.nextInt(_mealBodies.length)].replaceFirst('%s', mealName),
    );
  }

  NotificationContent getWorkoutReminder(String workoutName) {
    return NotificationContent(
      title: _workoutTitles[_random.nextInt(_workoutTitles.length)],
      body: _workoutBodies[_random.nextInt(_workoutBodies.length)].replaceFirst('%s', workoutName),
    );
  }

  NotificationContent _getMorningReminder() {
    return NotificationContent(
      title: _morningTitles[_random.nextInt(_morningTitles.length)],
      body: _morningBodies[_random.nextInt(_morningBodies.length)],
    );
  }

  NotificationContent _getEveningReminder() {
    return NotificationContent(
      title: _eveningTitles[_random.nextInt(_eveningTitles.length)],
      body: _eveningBodies[_random.nextInt(_eveningBodies.length)],
    );
  }
}
