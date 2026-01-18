import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../models/fitness_data.dart';
import '../services/notification_service.dart';
import 'legal.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 8;

  // Form Data
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _gender = 'Other';
  String _activityLevel = 'Moderate';
  final List<String> _selectedAllergies = [];
  bool _agreedToTerms = false;
  bool _notificationsEnabled = false;

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
    if (_currentPage == 0 && !_agreedToTerms) {
      _showError('Please agree to the Terms and Privacy Policy to continue.');
      return;
    }

    if (_currentPage == 2 && _nicknameController.text.trim().isEmpty) {
      _showError('Please enter a nickname.');
      return;
    }

    if (_currentPage == 3) {
      if (_heightController.text.isEmpty || _weightController.text.isEmpty || _ageController.text.isEmpty) {
        _showError('Please fill in all physical stats.');
        return;
      }
    }

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _completeOnboarding() {
    final provider = Provider.of<FitnessProvider>(context, listen: false);
    final profile = UserProfile(
      name: _nicknameController.text.trim(),
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      age: int.parse(_ageController.text),
      gender: _gender,
      activityLevel: _activityLevel,
      allergies: _selectedAllergies,
      onboardingCompleted: true,
      notificationsEnabled: _notificationsEnabled,
    );
    provider.setUserProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _totalPages,
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
                  _buildLegalStep(),
                  _buildThemeStep(),
                  _buildWelcomeStep(),
                  _buildPhysicalStatsStep(),
                  _buildGenderActivityStep(),
                  _buildAllergiesStep(),
                  _buildNotificationsStep(),
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
                    child: Text(_currentPage == _totalPages - 1 ? 'Get Started' : 'Next'),
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

  Widget _buildLegalStep() {
    return _buildStepContainer(
      'Legal Information',
      'Please review and agree to our terms to continue.',
      Column(
        children: [
          const Icon(Icons.gavel, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'To provide you with the best health and fitness experience, we need you to accept our legal terms.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 40),
          ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LegalPage(title: 'Terms of Service', content: LegalTexts.termsOfService))),
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LegalPage(title: 'Privacy Policy', content: LegalTexts.privacyPolicy))),
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.chevron_right),
          ),
          const SizedBox(height: 40),
          CheckboxListTile(
            value: _agreedToTerms,
            onChanged: (val) => setState(() => _agreedToTerms = val!),
            title: const Text('I have read and agree to the Terms of Service and Privacy Policy'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeStep() {
    return Consumer<FitnessProvider>(
      builder: (context, fitness, child) {
        return _buildStepContainer(
          'Personalize',
          'Choose your favorite color and theme mode.',
          Column(
            children: [
              SwitchListTile(
                secondary: Icon(
                  fitness.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: fitness.isDarkMode ? Colors.amber : Colors.grey,
                ),
                title: const Text('Dark Mode'),
                value: fitness.isDarkMode,
                onChanged: (bool value) => fitness.toggleTheme(),
              ),
              const SizedBox(height: 30),
              const Text('Pick a highlight color:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fitness.availableColors.length,
                  itemBuilder: (context, index) {
                    final color = fitness.availableColors[index];
                    final isSelected = fitness.seedColor == color;
                    return GestureDetector(
                      onTap: () => fitness.setSeedColor(color),
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected 
                            ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3)
                            : null,
                        ),
                        child: isSelected 
                          ? const Icon(Icons.check, color: Colors.white) 
                          : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeStep() {
    return _buildStepContainer(
      'Getting Started',
      'What should we call you?',
      TextField(
        controller: _nicknameController,
        decoration: const InputDecoration(
          labelText: 'Nickname',
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

  Widget _buildNotificationsStep() {
    return _buildStepContainer(
      'Stay on Track',
      'Would you like to receive reminders for meals and workouts?',
      Center(
        child: Column(
          children: [
            const Icon(Icons.notifications_active, size: 100, color: Colors.blue),
            const SizedBox(height: 40),
            const Text(
              'To send you reminders, we need your permission to access system notifications.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Get reminders for your scheduled activities'),
              value: _notificationsEnabled,
              onChanged: (val) async {
                if (val) {
                  bool granted = await NotificationService().requestPermissions();
                  if (granted) {
                    setState(() => _notificationsEnabled = true);
                  } else {
                    _showError('Notification permission was denied.');
                  }
                } else {
                  setState(() => _notificationsEnabled = false);
                }
              },
            ),
          ],
        ),
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
              _buildSummaryRow('Nickname', _nicknameController.text),
              _buildSummaryRow('Height', '${_heightController.text} cm'),
              _buildSummaryRow('Weight', '${_weightController.text} kg'),
              _buildSummaryRow('Age', _ageController.text),
              _buildSummaryRow('Gender', _gender),
              _buildSummaryRow('Activity', _activityLevel),
              _buildSummaryRow('Allergies', _selectedAllergies.isEmpty ? 'None' : _selectedAllergies.join(', ')),
              _buildSummaryRow('Notifications', _notificationsEnabled ? 'Enabled' : 'Disabled'),
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
