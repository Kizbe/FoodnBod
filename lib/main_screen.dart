import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
          // Mini Clock
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: const MiniClock(),
          ),
          // Settings Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'settings_btn',
              elevation: 2,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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

class MiniClock extends StatefulWidget {
  const MiniClock({super.key});

  @override
  State<MiniClock> createState() => _MiniClockState();
}

class _MiniClockState extends State<MiniClock> {
  late Stream<String> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Stream.periodic(const Duration(seconds: 1), (_) {
      return DateFormat('h:mm a').format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: StreamBuilder<String>(
        stream: _timeStream,
        initialData: DateFormat('h:mm a').format(DateTime.now()),
        builder: (context, snapshot) {
          return Text(
            snapshot.data ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}
