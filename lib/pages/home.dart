import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../providers/fitness_provider.dart';
import '../models/fitness_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<StepCount> _stepCountStream;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    Provider.of<FitnessProvider>(context, listen: false).updateSteps(event.steps);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
  }

  Future<void> initPlatformState() async {
    if (await Permission.activityRecognition.request().isGranted) {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(onStepCount).onError(onStepCountError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodNBod'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: Consumer<FitnessProvider>(
        builder: (context, fitness, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStepMeter(context, fitness),
                const SizedBox(height: 24),
                _buildSummaryCard(context, fitness),
                const SizedBox(height: 24),
                _buildMealSchedule(context, fitness),
                const SizedBox(height: 24),
                _buildUpcomingWorkouts(context, fitness),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepMeter(BuildContext context, FitnessProvider fitness) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircularPercentIndicator(
      radius: 80.0,
      lineWidth: 10.0,
      animation: true,
      percent: fitness.stepProgress,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_walk, size: 30, color: colorScheme.primary),
          Text("${fitness.steps}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
          Text("Goal: ${fitness.stepGoal}", style: const TextStyle(fontSize: 10.0, color: Colors.grey)),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: colorScheme.primary,
      backgroundColor: colorScheme.primaryContainer,
    );
  }

  Widget _buildSummaryCard(BuildContext context, FitnessProvider fitness) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn('Consumed', '${fitness.totalCaloriesConsumed}', colorScheme.primary),
            _buildStatColumn('Burned', '${fitness.totalCaloriesBurned}', Colors.red),
            _buildStatColumn('Net', '${fitness.netCalories}', colorScheme.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSchedule(BuildContext context, FitnessProvider fitness) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Meal Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: List.generate(fitness.mealTimes.length, (index) {
              final meal = fitness.mealTimes[index];
              return ListTile(
                leading: Icon(Icons.restaurant_menu, color: colorScheme.primary),
                title: Text(meal.name),
                trailing: TextButton(
                  onPressed: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: meal.time,
                    );
                    if (picked != null) {
                      fitness.updateMealTime(index, picked);
                    }
                  },
                  child: Text(meal.time.format(context), style: TextStyle(color: colorScheme.primary)),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingWorkouts(BuildContext context, FitnessProvider fitness) {
    final colorScheme = Theme.of(context).colorScheme;
    final workouts = fitness.upcomingWorkouts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Upcoming Workouts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: () => _showAddWorkoutFromPresetsDialog(context, fitness),
              icon: const Icon(Icons.add_circle_outline),
              color: colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (workouts.isEmpty)
          const Card(
            child: ListTile(
              title: Text('No workouts scheduled', style: TextStyle(color: Colors.grey)),
              subtitle: Text('Tap + to schedule from presets or saved items'),
            )
          )
        else
          ...workouts.map((w) {
            final isRoutine = w is WorkoutPreset;
            final String name = isRoutine ? w.name : (w as SavedWorkout).name;
            final DateTime time = isRoutine ? w.scheduledTime! : (w as SavedWorkout).scheduledTime!;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: isRoutine
                  ? ExpansionTile(
                      leading: Icon(Icons.bookmarks, color: colorScheme.primary),
                      title: Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('jm').format(time)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => fitness.clearScheduledRoutine(w.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: () {
                              for (var ex in w.exercises) {
                                fitness.addActivity(Activity(
                                  id: DateTime.now().toString(),
                                  name: ex.name,
                                  caloriesBurned: 150,
                                  duration: const Duration(minutes: 30),
                                  timestamp: DateTime.now(),
                                ));
                              }
                              fitness.clearScheduledRoutine(w.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Completed $name')),
                              );
                            },
                          ),
                        ],
                      ),
                      children: [
                        ...w.exercises.map((ex) => ListTile(
                              dense: true,
                              leading: const Icon(Icons.fiber_manual_record, size: 8),
                              title: Text(ex.name),
                              subtitle: Text(ex.muscle ?? 'General'),
                            )),
                      ],
                    )
                  : ListTile(
                      leading: Icon(Icons.event, color: colorScheme.primary),
                      title: Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('jm').format(time)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => fitness.clearScheduledWorkout(w.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: () {
                              fitness.addActivity(Activity(
                                id: DateTime.now().toString(),
                                name: w.name,
                                caloriesBurned: 150,
                                duration: const Duration(minutes: 30),
                                timestamp: DateTime.now(),
                              ));
                              fitness.clearScheduledWorkout(w.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Completed $name')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            );
          }),
      ],
    );
  }

  void _showAddWorkoutFromPresetsDialog(BuildContext context, FitnessProvider fitness) {
    if (fitness.savedWorkouts.isEmpty && fitness.workoutPresets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved items or routines! Go to Search or Journal to add some.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Schedule a Workout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        if (fitness.workoutPresets.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('Routines', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                          ...fitness.workoutPresets.map((p) => ListTile(
                            leading: const Icon(Icons.bookmarks, size: 20),
                            title: Text(p.name.toUpperCase()),
                            subtitle: Text('${p.exercises.length} Exercises'),
                            onTap: () => _pickTimeAndSchedule(context, fitness, p.id, true),
                          )),
                        ],
                        if (fitness.savedWorkouts.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('Individual Exercises', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                          ...fitness.savedWorkouts.map((w) => ListTile(
                            leading: const Icon(Icons.fitness_center, size: 20),
                            title: Text(w.name.toUpperCase()),
                            subtitle: Text(w.muscle ?? 'General'),
                            onTap: () => _pickTimeAndSchedule(context, fitness, w.id, false),
                          )),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickTimeAndSchedule(BuildContext context, FitnessProvider fitness, String id, bool isRoutine) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year, now.month, now.day, picked.hour, picked.minute
      );
      if (isRoutine) {
        fitness.scheduleWorkoutPreset(id, scheduledDate);
      } else {
        fitness.scheduleWorkout(id, scheduledDate);
      }
      if (context.mounted) Navigator.pop(context);
    }
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
