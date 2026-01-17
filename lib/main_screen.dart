import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'pages/tracking.dart';
import 'pages/journal.dart';
import 'pages/settings.dart';
import 'providers/fitness_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _pages = [
    const HomePage(),
    const TrackingPage(),
    const JournalPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final fitness = Provider.of<FitnessProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: fitness.currentTab,
            children: _pages,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'settings_btn',
              elevation: 2,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              child: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurfaceVariant),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) => fitness.setTab(index),
        selectedIndex: fitness.currentTab,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search),
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.book),
            icon: Icon(Icons.book_outlined),
            label: 'Journal',
          ),
        ],
      ),
    );
  }
}
