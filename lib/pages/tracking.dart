import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../models/fitness_data.dart';
import 'barcode_scanner.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  List<dynamic> _searchResults = [];

  final List<Map<String, dynamic>> _defaultFoods = [
    {'food': {'label': 'Apple', 'nutrients': {'ENERC_KCAL': 52.0}}},
    {'food': {'label': 'Banana', 'nutrients': {'ENERC_KCAL': 89.0}}},
    {'food': {'label': 'Chicken Breast (100g)', 'nutrients': {'ENERC_KCAL': 165.0}}},
    {'food': {'label': 'Egg (1 Large)', 'nutrients': {'ENERC_KCAL': 70.0}}},
    {'food': {'label': 'Rice (1 Cup)', 'nutrients': {'ENERC_KCAL': 205.0}}},
  ];

  final List<Map<String, dynamic>> _defaultWorkouts = [
    {'name': 'Pushups', 'muscle': 'Chest', 'difficulty': 'Beginner', 'instructions': 'Standard pushups for chest strength.'},
    {'name': 'Squats', 'muscle': 'Legs', 'difficulty': 'Beginner', 'instructions': 'Bodyweight squats for leg power.'},
    {'name': 'Plank', 'muscle': 'Core', 'difficulty': 'Beginner', 'instructions': 'Hold a plank position to strengthen core.'},
    {'name': 'Jumping Jacks', 'muscle': 'Full Body', 'difficulty': 'Beginner', 'instructions': 'Classic cardio movement.'},
    {'name': 'Burpees', 'muscle': 'Full Body', 'difficulty': 'Intermediate', 'instructions': 'High intensity full body exercise.'},
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<FitnessProvider>(context, listen: false);
    _searchResults = provider.activeSearchType == 'food' ? _defaultFoods : _defaultWorkouts;
  }

  void _performSearch() {
    final provider = Provider.of<FitnessProvider>(context, listen: false);
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        if (provider.activeSearchType == 'food') {
          _searchResults = _defaultFoods.where((item) => 
            item['food']['label'].toString().toLowerCase().contains(query)
          ).toList();
          if (_searchResults.isEmpty && query.isEmpty) _searchResults = _defaultFoods;
        } else {
          _searchResults = _defaultWorkouts.where((item) => 
            item['name'].toString().toLowerCase().contains(query) ||
            item['muscle'].toString().toLowerCase().contains(query)
          ).toList();
          if (_searchResults.isEmpty && query.isEmpty) _searchResults = _defaultWorkouts;
        }
        _isLoading = false;
      });
    });
  }

  Future<void> _addMealWithTime(BuildContext context, FitnessProvider provider, String label, int calories) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'When did you eat this?',
    );

    if (picked != null) {
      final now = DateTime.now();
      final consumptionTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      
      provider.addMeal(Meal(
        id: DateTime.now().toString(),
        name: label,
        calories: calories,
        timestamp: consumptionTime,
      ));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added $label at ${picked.format(context)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, fitness, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Search & Track'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: fitness.activeSearchType == 'food' ? 'Search food...' : 'Search exercise...',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (_) => _performSearch(),
                      ),
                    ),
                    if (fitness.activeSearchType == 'food')
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: () async {
                          final result = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
                          );
                          if (result != null) {
                            _searchController.text = result;
                            _performSearch();
                          }
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _performSearch,
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'food', label: Text('Foods'), icon: Icon(Icons.restaurant)),
                    ButtonSegment(value: 'workout', label: Text('Workouts'), icon: Icon(Icons.fitness_center)),
                  ],
                  selected: {fitness.activeSearchType},
                  onSelectionChanged: (newSelection) {
                    fitness.setSearchType(newSelection.first);
                    setState(() {
                      _searchResults = fitness.activeSearchType == 'food' ? _defaultFoods : _defaultWorkouts;
                      _searchController.clear();
                    });
                  },
                ),
              ),
              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator())),
              if (!_isLoading)
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      if (fitness.activeSearchType == 'food') {
                        final food = item['food'];
                        final calories = food['nutrients']['ENERC_KCAL'].round();
                        return ListTile(
                          title: Text(food['label']),
                          subtitle: Text('$calories kcal'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () => _addMealWithTime(context, fitness, food['label'], calories),
                          ),
                        );
                      } else {
                        return ListTile(
                          title: Text(item['name'].toString().toUpperCase()),
                          subtitle: Text('${item['muscle']} | ${item['difficulty']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.bookmark_border, color: Colors.amber),
                                onPressed: () {
                                  fitness.saveWorkout(SavedWorkout(
                                    id: DateTime.now().toString(),
                                    name: item['name'],
                                    instructions: item['instructions'],
                                    muscle: item['muscle'],
                                    difficulty: item['difficulty'],
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Saved ${item['name']}')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.blue),
                                onPressed: () {
                                  fitness.addActivity(Activity(
                                    id: DateTime.now().toString(),
                                    name: item['name'],
                                    caloriesBurned: 150, 
                                    duration: const Duration(minutes: 30),
                                    timestamp: DateTime.now(),
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Logged ${item['name']}')),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
