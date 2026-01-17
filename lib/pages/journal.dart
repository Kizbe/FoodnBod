import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/fitness_provider.dart';
import '../models/fitness_data.dart';
import '../main_screen.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Journal'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Daily Log', icon: Icon(Icons.history)),
            Tab(text: 'Presets', icon: Icon(Icons.bookmarks)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyLog(context),
          _buildPresets(context),
        ],
      ),
    );
  }

  Widget _buildDailyLog(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, fitness, child) {
        final items = fitness.getItemsForDate(_selectedDay ?? _focusedDay);

        return Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: CalendarFormat.twoWeeks,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), shape: BoxShape.circle),
              ),
            ),
            const Divider(),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No entries for this day'))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        if (item is Activity) {
                          return ListTile(
                            leading: CircleAvatar(backgroundColor: Colors.blue, child: const Icon(Icons.fitness_center, color: Colors.white, size: 20)),
                            title: Text(item.name.toUpperCase()),
                            subtitle: Text(DateFormat('jm').format(item.timestamp)),
                            trailing: Text('-${item.caloriesBurned} kcal', style: const TextStyle(color: Colors.red)),
                          );
                        } else if (item is Meal) {
                          return ListTile(
                            leading: CircleAvatar(backgroundColor: Colors.green, child: const Icon(Icons.restaurant, color: Colors.white, size: 20)),
                            title: Text(item.name),
                            subtitle: Text(DateFormat('jm').format(item.timestamp)),
                            trailing: Text('+${item.calories} kcal', style: const TextStyle(color: Colors.green)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPresets(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<FitnessProvider>(
      builder: (context, fitness, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader(context, 'Workout Routines', Icons.fitness_center, () => _showWorkoutPresetDialog(context, fitness)),
            ...fitness.workoutPresets.map((p) => Card(
              child: ExpansionTile(
                title: Text(p.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${p.exercises.length} Exercises'),
                leading: Icon(Icons.fitness_center, color: colorScheme.primary),
                children: [
                  ...p.exercises.map((ex) => ListTile(
                    dense: true,
                    title: Text(ex.name),
                    subtitle: Text(ex.muscle ?? 'General'),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => fitness.removeWorkoutPreset(p.id),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                        TextButton.icon(
                          onPressed: () => _showWorkoutPresetDialog(context, fitness, preset: p),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            for (var ex in p.exercises) {
                              fitness.addActivity(Activity(
                                id: DateTime.now().toString(),
                                name: ex.name,
                                caloriesBurned: 150,
                                duration: const Duration(minutes: 30),
                                timestamp: DateTime.now(),
                              ));
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logged routine: ${p.name}')));
                          },
                          icon: const Icon(Icons.add_task),
                          label: const Text('Log Routine'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Meal Presets', Icons.restaurant, () => _showMealPresetDialog(context, fitness)),
            ...fitness.mealPresets.map((m) => Card(
              child: ExpansionTile(
                title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${m.calories} kcal'),
                leading: Icon(Icons.restaurant, color: colorScheme.primary),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => fitness.removeMealPreset(m.id),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                        TextButton.icon(
                          onPressed: () => _showMealPresetDialog(context, fitness, preset: m),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            if (picked != null) {
                              final now = DateTime.now();
                              fitness.addMeal(Meal(
                                id: DateTime.now().toString(),
                                name: m.name,
                                calories: m.calories,
                                timestamp: DateTime(now.year, now.month, now.day, picked.hour, picked.minute),
                              ));
                            }
                          },
                          icon: const Icon(Icons.add_task),
                          label: const Text('Log Meal'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, VoidCallback onAdd) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }

  void _showWorkoutPresetDialog(BuildContext context, FitnessProvider fitness, {WorkoutPreset? preset}) {
    final nameController = TextEditingController(text: preset?.name);
    List<SavedWorkout> selectedExercises = preset != null ? List.from(preset.exercises) : [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(preset == null ? 'New Routine' : 'Edit Routine'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Routine Name')),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      fitness.navigateToWorkoutSearch();
                    },
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('New Exercises', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              SizedBox(
                height: 200,
                width: 300,
                child: fitness.savedWorkouts.isEmpty 
                  ? const Center(child: Text('No saved exercises. Save some from Search first!', textAlign: TextAlign.center))
                  : ListView.builder(
                    itemCount: fitness.savedWorkouts.length,
                    itemBuilder: (context, index) {
                      final ex = fitness.savedWorkouts[index];
                      final isSelected = selectedExercises.any((s) => s.id == ex.id);
                      return CheckboxListTile(
                        title: Text(ex.name),
                        value: isSelected,
                        onChanged: (val) {
                          setDialogState(() {
                            if (val == true) {
                              selectedExercises.add(ex);
                            } else {
                              selectedExercises.removeWhere((s) => s.id == ex.id);
                            }
                          });
                        },
                      );
                    },
                  ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && selectedExercises.isNotEmpty) {
                  final newPreset = WorkoutPreset(
                    id: preset?.id ?? DateTime.now().toString(),
                    name: nameController.text,
                    exercises: selectedExercises,
                  );
                  if (preset == null) {
                    fitness.addWorkoutPreset(newPreset);
                  } else {
                    fitness.updateWorkoutPreset(newPreset);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(preset == null ? 'Create Routine' : 'Update Routine'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMealPresetDialog(BuildContext context, FitnessProvider fitness, {MealPreset? preset}) {
    final nameController = TextEditingController(text: preset?.name);
    final calController = TextEditingController(text: preset?.calories.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(preset == null ? 'New Meal Preset' : 'Edit Meal Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Meal Name')),
            TextField(controller: calController, decoration: const InputDecoration(labelText: 'Calories'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && calController.text.isNotEmpty) {
                final newPreset = MealPreset(
                  id: preset?.id ?? DateTime.now().toString(),
                  name: nameController.text,
                  calories: int.parse(calController.text),
                );
                if (preset == null) {
                  fitness.addMealPreset(newPreset);
                } else {
                  fitness.updateMealPreset(newPreset);
                }
                Navigator.pop(context);
              }
            },
            child: Text(preset == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }
}

class _PresetItem {
  final String name;
  final String subtitle;
  final VoidCallback onAdd;
  final VoidCallback onDelete;

  _PresetItem({required this.name, required this.subtitle, required this.onAdd, required this.onDelete});
}
