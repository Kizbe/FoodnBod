import 'dart:convert';
import 'package:http/http.dart' as http;

class NutritionService {
  final String appId = 'YOUR_EDAMAM_APP_ID';
  final String appKey = 'YOUR_EDAMAM_APP_KEY';

  Future<Map<String, dynamic>?> getNutrition(String foodQuery) async {
    final url = Uri.parse(
        'https://api.edamam.com/api/food-database/v2/parser?app_id=$appId&app_key=$appKey&ingr=$foodQuery');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching nutrition: $e');
    }
    return null;
  }
}
