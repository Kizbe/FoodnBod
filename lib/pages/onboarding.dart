import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../models/fitness_data.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form Data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _gender = 'Other';
  String _activityLevel = 'Moderate';
  final List<String> _selectedAllergies = [];

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

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    final provider = Provider.of<FitnessProvider>(context, listen: false);
    final profile = UserProfile(
      name: _nameController.text,
      height: double.tryParse(_heightController.text) ?? 0.0,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      age: int.tryParse(_ageController.text) ?? 0,
      gender: _gender,
      activityLevel: _activityLevel,
      allergies: _selectedAllergies,
      onboardingCompleted: true,
    );
    provider.setUserProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 5,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildNameStep(),
                  _buildPhysicalStatsStep(),
                  _buildGenderActivityStep(),
                  _buildAllergiesStep(),
                  _buildSummaryStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: Text(_currentPage == 4 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContainer(String title, String subtitle, Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 40),
          child,
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return _buildStepContainer(
      'Welcome!',
      'What should we call you?',
      TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Full Name',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.person),
        ),
      ),
    );
  }

  Widget _buildPhysicalStatsStep() {
    return _buildStepContainer(
      'Physical Stats',
      'This helps us calculate your needs accurately.',
      Column(
        children: [
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.height),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.monitor_weight),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderActivityStep() {
    return _buildStepContainer(
      'About You',
      'Tell us about your lifestyle.',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 30),
          const Text('Daily Activity Level', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _activityLevel,
            items: _activityLevels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: (v) => setState(() => _activityLevel = v!),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesStep() {
    return _buildStepContainer(
      'Safety First',
      'Do you have any food allergies?',
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
            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryStep() {
    return _buildStepContainer(
      'All Set!',
      'Double check your details before we begin.',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSummaryRow('Name', _nameController.text),
              _buildSummaryRow('Height', '${_heightController.text} cm'),
              _buildSummaryRow('Weight', '${_weightController.text} kg'),
              _buildSummaryRow('Age', _ageController.text),
              _buildSummaryRow('Gender', _gender),
              _buildSummaryRow('Activity', _activityLevel),
              _buildSummaryRow('Allergies', _selectedAllergies.isEmpty ? 'None' : _selectedAllergies.join(', ')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
