import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fitness_data.dart';
import '../services/notification_service.dart';
import '../services/notification_schedule_manager.dart';

class FitnessProvider with ChangeNotifier {
  UserProfile _userProfile = UserProfile.empty();
  List<Activity> _activities = [];
  List<Meal> _meals = [];
  List<SavedWorkout> _savedWorkouts = [];
  List<WorkoutPreset> _workoutPresets = [];
  List<MealPreset> _mealPresets = [];
  List<DailyStepCount> _stepHistory = [];
  
  List<MealTime> _mealTimes = [
    MealTime(name: 'Breakfast', time: const TimeOfDay(hour: 8, minute: 0)),
    MealTime(name: 'Lunch', time: const TimeOfDay(hour: 13, minute: 0)),
    MealTime(name: 'Dinner', time: const TimeOfDay(hour: 16, minute: 35)),
  ];

  int _steps = 0;
  DateTime _lastStepUpdate = DateTime.now();
  int _stepGoal = 10000;
  bool _isDarkMode = false;
  Color _seedColor = Colors.green;
  
  int _currentTab = 0;
  String _activeSearchType = 'food';

  final List<Color> _availableColors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];

  static const double _caloriesPerStep = 0.045;

  FitnessProvider() {
    _loadFromPrefs();
  }

  UserProfile get userProfile => _userProfile;
  List<Activity> get activities => [..._activities];
  List<Meal> get meals => [..._meals];
  List<SavedWorkout> get savedWorkouts => [..._savedWorkouts];
  List<WorkoutPreset> get workoutPresets => [..._workoutPresets];
  List<MealPreset> get mealPresets => [..._mealPresets];
  List<MealTime> get mealTimes => _mealTimes;
  bool get isDarkMode => _isDarkMode;
  Color get seedColor => _seedColor;
  List<Color> get availableColors => _availableColors;
  int get currentTab => _currentTab;
  String get activeSearchType => _activeSearchType;

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    _syncAllNotifications();
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await NotificationService().cancelAllNotifications();
    
    _userProfile = UserProfile.empty();
    _activities = [];
    _meals = [];
    _savedWorkouts = [];
    _workoutPresets = [];
    _mealPresets = [];
    _stepHistory = [];
    _steps = 0;
    _currentTab = 0;
    _activeSearchType = 'food';
    _isDarkMode = false;
    _seedColor = Colors.green;
    
    notifyListeners();
  }

  void _syncAllNotifications() async {
    final notificationService = NotificationService();
    final scheduleManager = NotificationScheduleManager(notificationService);
    
    await notificationService.cancelAllNotifications();
    if (!_userProfile.notificationsEnabled) return;

    // 1. Schedule Daily Reminders (Check-ins)
    await scheduleManager.scheduleDailyReminders();

    // 2. Schedule Meal Times
    for (int i = 0; i < _mealTimes.length; i++) {
      final meal = _mealTimes[i];
      await scheduleManager.scheduleMealReminders(meal.name, meal.time, i);
    }

    // 3. Schedule Individual Scheduled Workouts
    for (int i = 0; i < _savedWorkouts.length; i++) {
      final w = _savedWorkouts[i];
      if (w.scheduledTime != null) {
        await scheduleManager.scheduleWorkoutReminder(w.name, w.scheduledTime!, i);
      }
    }

    // 4. Schedule Workout Routines
    for (int i = 0; i < _workoutPresets.length; i++) {
      final p = _workoutPresets[i];
      if (p.scheduledTime != null) {
        await scheduleManager.scheduleWorkoutReminder(p.name, p.scheduledTime!, i, isRoutine: true);
      }
    }
  }

  // --- Meals ---
  void addMeal(Meal meal) {
    _meals.add(meal);
    _saveToPrefs();
    notifyListeners();
  }

  void updateMealTime(int index, TimeOfDay newTime) {
    _mealTimes[index].time = newTime;
    _mealTimes[index].isSet = true;
    _syncAllNotifications();
    _saveToPrefs();
    notifyListeners();
  }

  // --- Activities ---
  void addActivity(Activity activity) {
    _activities.add(activity);
    _saveToPrefs();
    notifyListeners();
  }

  void scheduleWorkout(String id, DateTime time) {
    final index = _savedWorkouts.indexWhere((w) => w.id == id);
    if (index != -1) {
      _savedWorkouts[index].scheduledTime = time;
      _syncAllNotifications();
      _saveToPrefs();
      notifyListeners();
    }
  }

  void scheduleWorkoutPreset(String id, DateTime time) {
    final index = _workoutPresets.indexWhere((p) => p.id == id);
    if (index != -1) {
      _workoutPresets[index].scheduledTime = time;
      _syncAllNotifications();
      _saveToPrefs();
      notifyListeners();
    }
  }

  void clearScheduledWorkout(String id) {
    final index = _savedWorkouts.indexWhere((w) => w.id == id);
    if (index != -1) {
      _savedWorkouts[index].scheduledTime = null;
      _syncAllNotifications();
      _saveToPrefs();
      notifyListeners();
    }
  }

  void clearScheduledRoutine(String id) {
    final index = _workoutPresets.indexWhere((p) => p.id == id);
    if (index != -1) {
      _workoutPresets[index].scheduledTime = null;
      _syncAllNotifications();
      _saveToPrefs();
      notifyListeners();
    }
  }

  // --- Navigation & Theme ---
  void setTab(int index) { _currentTab = index; notifyListeners(); }
  void setSearchType(String type) { _activeSearchType = type; notifyListeners(); }
  void navigateToWorkoutSearch() { _currentTab = 1; _activeSearchType = 'workout'; notifyListeners(); }
  void toggleTheme() { _isDarkMode = !_isDarkMode; _saveToPrefs(); notifyListeners(); }
  void setSeedColor(Color color) { _seedColor = color; _saveToPrefs(); notifyListeners(); }

  // --- Standard CRUD ---
  void addMealPreset(MealPreset p) { if (!_mealPresets.any((m) => m.name == p.name)) _mealPresets.add(p); _saveToPrefs(); notifyListeners(); }
  void updateMealPreset(MealPreset p) { final i = _mealPresets.indexWhere((m) => m.id == p.id); if (i != -1) _mealPresets[i] = p; _saveToPrefs(); notifyListeners(); }
  void removeMealPreset(String id) { _mealPresets.removeWhere((m) => m.id == id); _saveToPrefs(); notifyListeners(); }
  void removeMeal(String id) { _meals.removeWhere((m) => m.id == id); _saveToPrefs(); notifyListeners(); }
  void saveWorkout(SavedWorkout w) { if (!_savedWorkouts.any((s) => s.name == w.name)) _savedWorkouts.add(w); _saveToPrefs(); notifyListeners(); }
  void removeSavedWorkout(String id) { _savedWorkouts.removeWhere((w) => w.id == id); _saveToPrefs(); notifyListeners(); }
  void addWorkoutPreset(WorkoutPreset p) { _workoutPresets.add(p); _saveToPrefs(); notifyListeners(); }
  void updateWorkoutPreset(WorkoutPreset p) { final i = _workoutPresets.indexWhere((wp) => wp.id == p.id); if (i != -1) _workoutPresets[i] = p; _saveToPrefs(); notifyListeners(); }
  void removeWorkoutPreset(String id) { _workoutPresets.removeWhere((p) => p.id == id); _saveToPrefs(); notifyListeners(); }
  void removeActivity(String id) { _activities.removeWhere((a) => a.id == id); _saveToPrefs(); notifyListeners(); }

  // --- Steps ---
  void updateSteps(int newSteps) {
    final now = DateTime.now();
    if (now.day != _lastStepUpdate.day || now.month != _lastStepUpdate.month || now.year != _lastStepUpdate.year) {
      _stepHistory.removeWhere((s) => s.date.year == _lastStepUpdate.year && s.date.month == _lastStepUpdate.month && s.date.day == _lastStepUpdate.day);
      _stepHistory.add(DailyStepCount(date: _lastStepUpdate, steps: _steps));
      _steps = 0; 
    }
    _steps = newSteps;
    _lastStepUpdate = now;
    _saveToPrefs();
    notifyListeners();
  }
  void setStepGoal(int goal) { _stepGoal = goal; _saveToPrefs(); notifyListeners(); }

  // --- Persistence ---
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userProfile', jsonEncode(_userProfile.toMap()));
    await prefs.setString('activities', jsonEncode(_activities.map((a) => a.toMap()).toList()));
    await prefs.setString('meals', jsonEncode(_meals.map((m) => m.toMap()).toList()));
    await prefs.setString('savedWorkouts', jsonEncode(_savedWorkouts.map((w) => w.toMap()).toList()));
    await prefs.setString('workoutPresets', jsonEncode(_workoutPresets.map((p) => p.toMap()).toList()));
    await prefs.setString('mealPresets', jsonEncode(_mealPresets.map((m) => m.toMap()).toList()));
    await prefs.setString('mealTimes', jsonEncode(_mealTimes.map((t) => t.toMap()).toList()));
    await prefs.setString('stepHistory', jsonEncode(_stepHistory.map((s) => s.toMap()).toList()));
    await prefs.setInt('steps', _steps);
    await prefs.setString('lastStepUpdate', _lastStepUpdate.toIso8601String());
    await prefs.setInt('stepGoal', _stepGoal);
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setInt('seedColor', _seedColor.value);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final profJson = prefs.getString('userProfile');
    if (profJson != null) _userProfile = UserProfile.fromMap(jsonDecode(profJson));
    final actJson = prefs.getString('activities');
    if (actJson != null) _activities = (jsonDecode(actJson) as List).map((i) => Activity.fromMap(i)).toList();
    final mealJson = prefs.getString('meals');
    if (mealJson != null) _meals = (jsonDecode(mealJson) as List).map((i) => Meal.fromMap(i)).toList();
    final savedWJson = prefs.getString('savedWorkouts');
    if (savedWJson != null) _savedWorkouts = (jsonDecode(savedWJson) as List).map((i) => SavedWorkout.fromMap(i)).toList();
    final wpJson = prefs.getString('workoutPresets');
    if (wpJson != null) _workoutPresets = (jsonDecode(wpJson) as List).map((i) => WorkoutPreset.fromMap(i)).toList();
    final presetJson = prefs.getString('mealPresets');
    if (presetJson != null) _mealPresets = (jsonDecode(presetJson) as List).map((i) => MealPreset.fromMap(i)).toList();
    final timesJson = prefs.getString('mealTimes');
    if (timesJson != null) _mealTimes = (jsonDecode(timesJson) as List).map((i) => MealTime.fromMap(i)).toList();
    final historyJson = prefs.getString('stepHistory');
    if (historyJson != null) _stepHistory = (jsonDecode(historyJson) as List).map((i) => DailyStepCount.fromMap(i)).toList();
    _steps = prefs.getInt('steps') ?? 0;
    final lastUpdateStr = prefs.getString('lastStepUpdate');
    if (lastUpdateStr != null) _lastStepUpdate = DateTime.parse(lastUpdateStr);
    _stepGoal = prefs.getInt('stepGoal') ?? 10000;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final colorVal = prefs.getInt('seedColor');
    if (colorVal != null) _seedColor = Color(colorVal);
    
    _syncAllNotifications();
    notifyListeners();
  }

  // --- Getters ---
  List<dynamic> getItemsForDate(DateTime date) {
    final activityItems = _activities.where((a) => a.timestamp.year == date.year && a.timestamp.month == date.month && a.timestamp.day == date.day).toList();
    final mealItems = _meals.where((m) => m.timestamp.year == date.year && m.timestamp.month == date.month && m.timestamp.day == date.day).toList();
    return [...activityItems, ...mealItems]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  int getStepsForDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) return _steps;
    final history = _stepHistory.firstWhere((s) => s.date.year == date.year && s.date.month == date.month && s.date.day == date.day, orElse: () => DailyStepCount(date: date, steps: 0));
    return history.steps;
  }
  
  List<dynamic> get upcomingWorkouts {
    final now = DateTime.now();
    final List<dynamic> scheduled = [];
    
    // Scheduled individual workouts
    scheduled.addAll(_savedWorkouts.where((w) => w.scheduledTime != null));
    
    // Scheduled workout routines
    scheduled.addAll(_workoutPresets.where((p) => p.scheduledTime != null));
    
    scheduled.sort((a, b) {
      final timeA = a is SavedWorkout ? a.scheduledTime! : (a as WorkoutPreset).scheduledTime!;
      final timeB = b is SavedWorkout ? b.scheduledTime! : (b as WorkoutPreset).scheduledTime!;
      return timeA.compareTo(timeB);
    });
    
    return scheduled;
  }

  int get steps => _steps;
  int get stepGoal => _stepGoal;
  int get caloriesFromSteps => (_steps * _caloriesPerStep).round();
  int get totalCaloriesConsumed {
    final now = DateTime.now();
    return _meals.where((m) => m.timestamp.year == now.year && m.timestamp.month == now.month && m.timestamp.day == now.day).fold(0, (sum, item) => sum + item.calories);
  }
  int get netCalories => totalCaloriesConsumed - caloriesFromSteps;
  double get stepProgress => (_steps / _stepGoal).clamp(0.0, 1.0);
}
