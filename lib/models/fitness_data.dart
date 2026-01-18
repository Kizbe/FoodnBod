import 'package:flutter/material.dart';

class UserProfile {
  final String name;
  final double height; // in cm
  final double weight; // in kg
  final int age;
  final String gender;
  final String activityLevel;
  final List<String> allergies;
  final bool onboardingCompleted;
  final bool notificationsEnabled;

  UserProfile({
    required this.name,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.allergies,
    this.onboardingCompleted = false,
    this.notificationsEnabled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'allergies': allergies,
      'onboardingCompleted': onboardingCompleted,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      height: (map['height'] ?? 0.0).toDouble(),
      weight: (map['weight'] ?? 0.0).toDouble(),
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      activityLevel: map['activityLevel'] ?? '',
      allergies: List<String>.from(map['allergies'] ?? []),
      onboardingCompleted: map['onboardingCompleted'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? false,
    );
  }

  factory UserProfile.empty() {
    return UserProfile(
      name: '',
      height: 0.0,
      weight: 0.0,
      age: 0,
      gender: '',
      activityLevel: '',
      allergies: [],
      onboardingCompleted: false,
      notificationsEnabled: false,
    );
  }
}

class DailyStepCount {
  final DateTime date;
  final int steps;

  DailyStepCount({required this.date, required this.steps});

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
    };
  }

  factory DailyStepCount.fromMap(Map<String, dynamic> map) {
    return DailyStepCount(
      date: DateTime.parse(map['date']),
      steps: map['steps'],
    );
  }
}

class Activity {
  final String id;
  final String name;
  final int? sets;
  final int? reps;
  final Duration duration;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.name,
    this.sets,
    this.reps,
    required this.duration,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'duration': duration.inMinutes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      name: map['name'],
      sets: map['sets'],
      reps: map['reps'],
      duration: Duration(minutes: map['duration']),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class SavedWorkout {
  final String id;
  final String name;
  final String? instructions;
  final String? muscle;
  final String? difficulty;
  final int? defaultSets;
  final int? defaultReps;
  DateTime? scheduledTime;

  SavedWorkout({
    required this.id,
    required this.name,
    this.instructions,
    this.muscle,
    this.difficulty,
    this.defaultSets,
    this.defaultReps,
    this.scheduledTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'instructions': instructions,
      'muscle': muscle,
      'difficulty': difficulty,
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
      'scheduledTime': scheduledTime?.toIso8601String(),
    };
  }

  factory SavedWorkout.fromMap(Map<String, dynamic> map) {
    return SavedWorkout(
      id: map['id'],
      name: map['name'],
      instructions: map['instructions'],
      muscle: map['muscle'],
      difficulty: map['difficulty'],
      defaultSets: map['defaultSets'],
      defaultReps: map['defaultReps'],
      scheduledTime: map['scheduledTime'] != null ? DateTime.parse(map['scheduledTime']) : null,
    );
  }
}

class WorkoutPreset {
  final String id;
  final String name;
  final List<SavedWorkout> exercises;
  DateTime? scheduledTime;

  WorkoutPreset({
    required this.id,
    required this.name,
    required this.exercises,
    this.scheduledTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'scheduledTime': scheduledTime?.toIso8601String(),
    };
  }

  factory WorkoutPreset.fromMap(Map<String, dynamic> map) {
    return WorkoutPreset(
      id: map['id'],
      name: map['name'],
      exercises: (map['exercises'] as List).map((e) => SavedWorkout.fromMap(e)).toList(),
      scheduledTime: map['scheduledTime'] != null ? DateTime.parse(map['scheduledTime']) : null,
    );
  }
}

class Meal {
  final String id;
  final String name;
  final int calories;
  final DateTime timestamp;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class MealPreset {
  final String id;
  final String name;
  final int calories;

  MealPreset({
    required this.id,
    required this.name,
    required this.calories,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
    };
  }

  factory MealPreset.fromMap(Map<String, dynamic> map) {
    return MealPreset(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
    );
  }
}

class MealTime {
  final String name;
  TimeOfDay time;
  bool isSet;

  MealTime({
    required this.name,
    required this.time,
    this.isSet = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hour': time.hour,
      'minute': time.minute,
      'isSet': isSet,
    };
  }

  factory MealTime.fromMap(Map<String, dynamic> map) {
    return MealTime(
      name: map['name'],
      time: TimeOfDay(hour: map['hour'], minute: map['minute']),
      isSet: map['isSet'],
    );
  }
}
