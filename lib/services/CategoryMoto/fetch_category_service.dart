// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';

class FetchCategoryService {
  final String baseUrl =
      'http://10.0.2.2:3000/api/categoryMoto'; // Adjust URL if needed

  // Method to fetch all categories or a specific category by ID
  Future<List<Map<String, dynamic>>> fetchCategories({String? id}) async {
    try {
      final response = id != null
          ? await http.get(
              Uri.parse('$baseUrl/$id'), // Fetch specific category by ID
              headers: {'Content-Type': 'application/json'},
            )
          : await http.get(
              Uri.parse(baseUrl), // Fetch all categories
              headers: {'Content-Type': 'application/json'},
            );

      // Check for successful response (status code 200)
      if (response.statusCode == 200) {
        // Parse the response body and return the list of categories
        List<dynamic> responseBody = json.decode(response.body);
        return responseBody
            .map((category) => category as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception(
            'Failed to load categories. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching categories: $error");
      throw Exception('An error occurred while fetching categories');
    }
  }
}
