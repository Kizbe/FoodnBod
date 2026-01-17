import 'dart:convert';
import 'package:http/http.dart' as http;

class WorkoutService {
  final String apiKey = 'YOUR_API_NINJAS_KEY';

  Future<List<dynamic>> getWorkouts(String type) async {
    final url = Uri.parse('https://api.api-ninjas.com/v1/exercises?type=$type');
    
    try {
      final response = await http.get(
        url,
        headers: {'X-Api-Key': apiKey},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching workouts: $e');
    }
    return [];
  }
}
