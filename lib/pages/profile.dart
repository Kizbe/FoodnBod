import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../models/fitness_data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _heightFeetController;
  late TextEditingController _heightInchesController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  late String _gender;
  late String _activityLevel;
  late List<String> _selectedAllergies;

  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderate',
    'Very Active',
    'Extra Active'
  ];

  final List<String> _commonAllergies = [
    'Peanuts',
    'Dairy',
    'Gluten',
    'Soy',
    'Eggs',
    'Shellfish',
    'Tree Nuts',
    'Fish'
  ];

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<FitnessProvider>(context, listen: false).userProfile;
    _nameController = TextEditingController(text: profile.name);
    _heightFeetController = TextEditingController(text: profile.heightFeet.toString());
    _heightInchesController = TextEditingController(text: profile.heightInches.toString());
    _weightController = TextEditingController(text: profile.weight.toString());
    _ageController = TextEditingController(text: profile.age.toString());
    _gender = profile.gender.isEmpty ? 'Other' : profile.gender;
    _activityLevel = profile.activityLevel.isEmpty ? 'Moderate' : profile.activityLevel;
    _selectedAllergies = List.from(profile.allergies);
  }

  void _saveProfile() {
    final provider = Provider.of<FitnessProvider>(context, listen: false);
    final updatedProfile = UserProfile(
      name: _nameController.text,
      heightFeet: int.tryParse(_heightFeetController.text) ?? 0,
      heightInches: int.tryParse(_heightInchesController.text) ?? 0,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      age: int.tryParse(_ageController.text) ?? 0,
      gender: _gender,
      activityLevel: _activityLevel,
      allergies: _selectedAllergies,
      onboardingCompleted: true,
    );
    provider.setUserProfile(updatedProfile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile Updated!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(onPressed: _saveProfile, icon: const Icon(Icons.check)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Height', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _heightFeetController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'ft', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _heightInchesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'in', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Weight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'lbs', border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Radio<String>(value: 'Male', groupValue: _gender, onChanged: (v) => setState(() => _gender = v!)),
                const Text('Male'),
                Radio<String>(value: 'Female', groupValue: _gender, onChanged: (v) => setState(() => _gender = v!)),
                const Text('Female'),
                Radio<String>(value: 'Other', groupValue: _gender, onChanged: (v) => setState(() => _gender = v!)),
                const Text('Other'),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Daily Activity Level', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _activityLevel,
              items: _activityLevels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setState(() => _activityLevel = v!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            const Text('Food Allergies', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonAllergies.map((allergy) {
                final isSelected = _selectedAllergies.contains(allergy);
                return FilterChip(
                  label: Text(allergy),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedAllergies.add(allergy);
                      } else {
                        _selectedAllergies.remove(allergy);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
