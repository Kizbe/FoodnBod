import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String name;
  final int caloriesBurned;
  final Duration duration;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.name,
    required this.caloriesBurned,
    required this.duration,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'caloriesBurned': caloriesBurned,
      'duration': duration.inMinutes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      name: map['name'],
      caloriesBurned: map['caloriesBurned'],
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
  DateTime? scheduledTime;

  SavedWorkout({
    required this.id,
    required this.name,
    this.instructions,
    this.muscle,
    this.difficulty,
    this.scheduledTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'instructions': instructions,
      'muscle': muscle,
      'difficulty': difficulty,
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
