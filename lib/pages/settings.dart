import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<FitnessProvider>(
        builder: (context, fitness, child) {
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
                child: Text('Theme Color', style: TextStyle(fontWeight: FontWeight.bold)),
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
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text('Notifications'),
                onTap: () {},
              ),
            ],
          );
        },
      ),
    );
  }
}
