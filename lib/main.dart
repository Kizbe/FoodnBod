import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/fitness_provider.dart';
import 'main_screen.dart';
import 'pages/onboarding.dart';
import 'services/notification_service.dart';

void main() async {
  print('[Main] Initializing app...');
  WidgetsFlutterBinding.ensureInitialized();
  
  print('[Main] Initializing NotificationService...');
  await NotificationService().init();
  
  print('[Main] Running app...');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FitnessProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, fitness, child) {
        return MaterialApp(
          title: 'FoodNBod',
          debugShowCheckedModeBanner: false,
          themeMode: fitness.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: fitness.seedColor,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: fitness.seedColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: fitness.userProfile.onboardingCompleted 
              ? const MainScreen() 
              : const OnboardingPage(),
        );
      },
    );
  }
}
