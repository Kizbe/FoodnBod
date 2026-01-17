import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../models/fitness_data.dart';

class SavedWorkoutsPage extends StatelessWidget {
  const SavedWorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Workouts')),
      body: Consumer<FitnessProvider>(
        builder: (context, fitness, child) {
          if (fitness.savedWorkouts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No saved workouts yet.', style: TextStyle(color: Colors.grey)),
                  Text('Save them from the Tracking tab!', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fitness.savedWorkouts.length,
            itemBuilder: (context, index) {
              final workout = fitness.savedWorkouts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(workout.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${workout.muscle} | ${workout.difficulty}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (workout.instructions != null) ...[
                            const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(workout.instructions!),
                            const SizedBox(height: 16),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  fitness.removeSavedWorkout(workout.id);
                                },
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                label: const Text('Remove', style: TextStyle(color: Colors.red)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  fitness.addActivity(Activity(
                                    id: DateTime.now().toString(),
                                    name: workout.name,
                                    caloriesBurned: 150,
                                    duration: const Duration(minutes: 30),
                                    timestamp: DateTime.now(),
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Logged ${workout.name}')),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Log Activity'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
