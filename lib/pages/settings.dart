import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../models/fitness_data.dart';
import '../services/notification_service.dart';
import '../services/notification_schedule_manager.dart';
import 'profile.dart';
import 'legal.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showDeleteConfirmation(BuildContext context, FitnessProvider fitness) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This action cannot be undone. All your profile info, workouts, meals, and history will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              fitness.clearAllData();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data has been cleared.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<FitnessProvider>(
        builder: (context, fitness, child) {
          final profile = fitness.userProfile;
          
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              SwitchListTile(
                secondary: Icon(
                  fitness.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: fitness.isDarkMode ? Colors.amber : Colors.grey,
                ),
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark themes'),
                value: fitness.isDarkMode,
                onChanged: (bool value) {
                  fitness.toggleTheme();
                },
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text('Theme Color', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: fitness.availableColors.length,
                  itemBuilder: (context, index) {
                    final color = fitness.availableColors[index];
                    final isSelected = fitness.seedColor == color;
                    return GestureDetector(
                      onTap: () => fitness.setSeedColor(color),
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected 
                            ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3)
                            : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        ),
                        child: isSelected 
                          ? const Icon(Icons.check, color: Colors.white) 
                          : null,
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Account & Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                subtitle: Text(profile.name.isEmpty ? 'Set up your profile' : 'Edit height, weight, allergies'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_none),
                title: const Text('Notifications'),
                subtitle: const Text('Receive reminders for activities'),
                value: profile.notificationsEnabled,
                onChanged: (bool value) async {
                  bool shouldEnable = value;
                  if (value) {
                    final granted = await NotificationService().requestPermissions();
                    if (!granted) {
                      shouldEnable = false;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notification permissions are required.')),
                        );
                      }
                    }
                  }

                  final updatedProfile = UserProfile(
                    name: profile.name,
                    heightFeet: profile.heightFeet,
                    heightInches: profile.heightInches,
                    weight: profile.weight,
                    age: profile.age,
                    gender: profile.gender,
                    activityLevel: profile.activityLevel,
                    allergies: profile.allergies,
                    onboardingCompleted: profile.onboardingCompleted,
                    notificationsEnabled: shouldEnable,
                  );
                  fitness.setUserProfile(updatedProfile);
                },
              ),
              if (profile.notificationsEnabled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final scheduleManager = NotificationScheduleManager(NotificationService());
                      final content = scheduleManager.getMealReminder('Test');
                      NotificationService().scheduleDailyNotification(
                        999,
                        content.title,
                        content.body,
                        TimeOfDay.now(),
                      );
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Test Notification Now'),
                  ),
                ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Legal', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalPage(
                        title: 'Terms of Service',
                        content: LegalTexts.termsOfService,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalPage(
                        title: 'Privacy Policy',
                        content: LegalTexts.privacyPolicy,
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Reset App Data', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Permanently delete all your information'),
                onTap: () => _showDeleteConfirmation(context, fitness),
              ),
            ],
          );
        },
      ),
    );
  }
}
