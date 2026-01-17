import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fitness_data.dart';

class FitnessProvider with ChangeNotifier {
  List<Activity> _activities = [];
  List<Meal> _meals = [];
  List<SavedWorkout> _savedWorkouts = [];
  List<WorkoutPreset> _workoutPresets = [];
  List<MealPreset> _mealPresets = [];
  
  List<MealTime> _mealTimes = [
    MealTime(name: 'Breakfast', time: const TimeOfDay(hour: 8, minute: 0)),
    MealTime(name: 'Lunch', time: const TimeOfDay(hour: 13, minute: 0)),
    MealTime(name: 'Dinner', time: const TimeOfDay(hour: 19, minute: 0)),
  ];

  int _steps = 0;
  int _stepGoal = 10000;
  bool _isDarkMode = false;
  Color _seedColor = Colors.green;
  
  // Navigation state
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

  // --- Navigation ---
  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  void setSearchType(String type) {
    _activeSearchType = type;
    notifyListeners();
  }

  void navigateToWorkoutSearch() {
    _currentTab = 1; // Search tab
    _activeSearchType = 'workout';
    notifyListeners();
  }

  // --- Theme ---
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveToPrefs();
    notifyListeners();
  }

  void setSeedColor(Color color) {
    _seedColor = color;
    _saveToPrefs();
    notifyListeners();
  }

  // --- Meals ---
  void addMeal(Meal meal) {
    _meals.add(meal);
    _saveToPrefs();
    notifyListeners();
  }

  void addMealPreset(MealPreset preset) {
    if (!_mealPresets.any((m) => m.name == preset.name)) {
      _mealPresets.add(preset);
      _saveToPrefs();
      notifyListeners();
    }
  }

  void updateMealPreset(MealPreset preset) {
    final index = _mealPresets.indexWhere((m) => m.id == preset.id);
    if (index != -1) {
      _mealPresets[index] = preset;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void removeMealPreset(String id) {
    _mealPresets.removeWhere((m) => m.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  void updateMealTime(int index, TimeOfDay newTime) {
    _mealTimes[index].time = newTime;
    _mealTimes[index].isSet = true;
    _saveToPrefs();
    notifyListeners();
  }

  // --- Activities ---
  void addActivity(Activity activity) {
    _activities.add(activity);
    _saveToPrefs();
    notifyListeners();
  }

  void saveWorkout(SavedWorkout workout) {
    if (!_savedWorkouts.any((w) => w.name == workout.name)) {
      _savedWorkouts.add(workout);
      _saveToPrefs();
      notifyListeners();
    }
  }

  void removeSavedWorkout(String id) {
    _savedWorkouts.removeWhere((w) => w.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  // --- Workout Presets ---
  void addWorkoutPreset(WorkoutPreset preset) {
    _workoutPresets.add(preset);
    _saveToPrefs();
    notifyListeners();
  }

  void updateWorkoutPreset(WorkoutPreset preset) {
    final index = _workoutPresets.indexWhere((p) => p.id == preset.id);
    if (index != -1) {
      _workoutPresets[index] = preset;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void removeWorkoutPreset(String id) {
    _workoutPresets.removeWhere((p) => p.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  void scheduleWorkout(String id, DateTime time) {
    final index = _savedWorkouts.indexWhere((w) => w.id == id);
    if (index != -1) {
      _savedWorkouts[index].scheduledTime = time;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void scheduleWorkoutPreset(String id, DateTime time) {
    final index = _workoutPresets.indexWhere((p) => p.id == id);
    if (index != -1) {
      _workoutPresets[index].scheduledTime = time;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void clearScheduledWorkout(String id) {
    final index = _savedWorkouts.indexWhere((w) => w.id == id);
    if (index != -1) {
      _savedWorkouts[index].scheduledTime = null;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void clearScheduledRoutine(String id) {
    final index = _workoutPresets.indexWhere((p) => p.id == id);
    if (index != -1) {
      _workoutPresets[index].scheduledTime = null;
      _saveToPrefs();
      notifyListeners();
    }
  }

  // --- Steps ---
  void updateSteps(int newSteps) {
    _steps = newSteps;
    _saveToPrefs();
    notifyListeners();
  }

  void setStepGoal(int goal) {
    _stepGoal = goal;
    _saveToPrefs();
    notifyListeners();
  }

  // --- Persistence ---
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('activities', jsonEncode(_activities.map((a) => a.toMap()).toList()));
    await prefs.setString('meals', jsonEncode(_meals.map((m) => m.toMap()).toList()));
    await prefs.setString('savedWorkouts', jsonEncode(_savedWorkouts.map((w) => w.toMap()).toList()));
    await prefs.setString('workoutPresets', jsonEncode(_workoutPresets.map((p) => p.toMap()).toList()));
    await prefs.setString('mealPresets', jsonEncode(_mealPresets.map((m) => m.toMap()).toList()));
    await prefs.setString('mealTimes', jsonEncode(_mealTimes.map((t) => t.toMap()).toList()));
    await prefs.setInt('steps', _steps);
    await prefs.setInt('stepGoal', _stepGoal);
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setInt('seedColor', _seedColor.value);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    final actJson = prefs.getString('activities');
    if (actJson != null) {
      _activities = (jsonDecode(actJson) as List).map((i) => Activity.fromMap(i)).toList();
    }

    final mealJson = prefs.getString('meals');
    if (mealJson != null) {
      _meals = (jsonDecode(mealJson) as List).map((i) => Meal.fromMap(i)).toList();
    }

    final savedWJson = prefs.getString('savedWorkouts');
    if (savedWJson != null) {
      _savedWorkouts = (jsonDecode(savedWJson) as List).map((i) => SavedWorkout.fromMap(i)).toList();
    }

    final wpJson = prefs.getString('workoutPresets');
    if (wpJson != null) {
      _workoutPresets = (jsonDecode(wpJson) as List).map((i) => WorkoutPreset.fromMap(i)).toList();
    }

    final presetJson = prefs.getString('mealPresets');
    if (presetJson != null) {
      _mealPresets = (jsonDecode(presetJson) as List).map((i) => MealPreset.fromMap(i)).toList();
    }

    final timesJson = prefs.getString('mealTimes');
    if (timesJson != null) {
      _mealTimes = (jsonDecode(timesJson) as List).map((i) => MealTime.fromMap(i)).toList();
    }

    _steps = prefs.getInt('steps') ?? 0;
    _stepGoal = prefs.getInt('stepGoal') ?? 10000;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final colorVal = prefs.getInt('seedColor');
    if (colorVal != null) _seedColor = Color(colorVal);

    notifyListeners();
  }

  // --- Getters ---
  List<dynamic> getItemsForDate(DateTime date) {
    final activityItems = _activities.where((a) => 
        a.timestamp.year == date.year && 
        a.timestamp.month == date.month && 
        a.timestamp.day == date.day).toList();
    
    final mealItems = _meals.where((m) => 
        m.timestamp.year == date.year && 
        m.timestamp.month == date.month && 
        m.timestamp.day == date.day).toList();
    
    return [...activityItems, ...mealItems]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  List<dynamic> get upcomingWorkouts {
    final now = DateTime.now();
    
    final List<dynamic> scheduled = [];
    
    // Add scheduled individual workouts
    scheduled.addAll(_savedWorkouts.where((w) => w.scheduledTime != null && w.scheduledTime!.isAfter(now)));
    
    // Add scheduled workout routines
    scheduled.addAll(_workoutPresets.where((p) => p.scheduledTime != null && p.scheduledTime!.isAfter(now)));
    
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

  int get totalCaloriesBurned {
    final now = DateTime.now();
    int activityCalories = _activities
        .where((a) => a.timestamp.year == now.year && a.timestamp.month == now.month && a.timestamp.day == now.day)
        .fold(0, (sum, item) => sum + item.caloriesBurned);
    return activityCalories + caloriesFromSteps;
  }

  int get totalCaloriesConsumed {
    final now = DateTime.now();
    return _meals
        .where((m) => m.timestamp.year == now.year && m.timestamp.month == now.month && m.timestamp.day == now.day)
        .fold(0, (sum, item) => sum + item.calories);
  }

  int get netCalories => totalCaloriesConsumed - totalCaloriesBurned;
  double get stepProgress => (_steps / _stepGoal).clamp(0.0, 1.0);
}
