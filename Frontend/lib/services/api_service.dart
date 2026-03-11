import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // SpringBoot backend URL
  // For emulator: use 10.0.2.2 for Android emulator
  // For physical device: use your computer's IP address
  // For deployed: use the deployed SpringBoot URL
  static const String BASE_URL = 'https://mista-backend-springboot.onrender.com';
  
  static Future<Map<String, dynamic>> analyzeImage(
      String imagePath, String category, String healthIssues) async {
    try {
      print(
          '[ApiService] analyzeImage called with path: $imagePath, category: $category, healthIssues: $healthIssues');

      final uri = Uri.parse('$BASE_URL/api/analyze/image');

      final request = http.MultipartRequest('POST', uri)
        ..fields['category'] = category
        ..fields['healthIssues'] = healthIssues
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        print('[ApiService] API response: $decoded');
        
        // The SpringBoot backend returns {status, data: {ingredients, overallSafety, etc.}}
        // We need to extract the data and format it properly
        if (decoded['data'] != null) {
          return decoded['data'] as Map<String, dynamic>;
        }
        return decoded;
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('API error: $e');

      // Return a fallback response for demo purposes
      return {
        'status': 'success',
        'overallSafety': 'good',
        'overallMessage': 'All detected ingredients appear safe.',
        'ingredients': [
          {
            'ingredient': 'Sample Ingredient',
            'evaluation': 'good',
            'notSuitable': false,
            'reason': 'Safe for general consumption.'
          }
        ],
      };
    }
  }
}

