import 'package:flutter_test/flutter_test.dart';
import 'package:foodnbod/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Check for the app name in the home page
    expect(find.text('FoodNBod'), findsAtLeastNWidgets(1));
  });
}
