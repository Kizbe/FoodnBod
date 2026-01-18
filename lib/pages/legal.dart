import 'package:flutter/material.dart';

class LegalPage extends StatelessWidget {
  final String title;
  final String content;

  const LegalPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}

class LegalTexts {
  static const String termsOfService = """
TERMS OF SERVICE

1. Acceptance of Terms
By using FoodNBod, you agree to these terms. If you do not agree, do not use the app.

2. Health and Fitness Disclaimer
FoodNBod provides health and fitness information for educational purposes only. We are not medical professionals. Always consult with a doctor before starting a new exercise or diet program. Use of the app is at your own risk.

3. User Data
You are responsible for the accuracy of the information you provide.

4. Limitation of Liability
FoodNBod is provided "as is". We are not liable for any injuries or health complications resulting from the use of the app.

5. Changes to Terms
We may update these terms at any time. Continued use of the app constitutes acceptance of the new terms.
""";

  static const String privacyPolicy = """
PRIVACY POLICY

1. Information We Collect
We collect physical stats (height, weight, age), activity logs, and food allergy information to provide personalized fitness tracking.

2. How We Use Information
Your data is used locally on your device to calculate caloric needs and track your progress.

3. Data Storage
All data is stored locally on your device using shared preferences. We do not currently upload your personal health data to external servers.

4. Your Rights
You can delete all your data at any time via the Settings menu.

5. Security
We take reasonable measures to protect your data stored on your device.
""";
}
