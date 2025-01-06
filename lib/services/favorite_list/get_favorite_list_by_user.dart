// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';

/// Fetches the favorite list of a user by their userId.
Future<List<Map<String, dynamic>>> getFavoriteListByUserService(
    String userId) async {
  final String apiUrl =
      'http://10.0.2.2:3000/api/favoriteListByUser/$userId'; // URL to the API endpoint

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Received data: $data'); // Print data to verify structure

      if (data['success']) {
        // Ensure the data['data'] is a list
        List<dynamic> favoriteList = data['data'];
        return List<Map<String, dynamic>>.from(
            favoriteList.map((item) => item as Map<String, dynamic>));
      } else {
        throw Exception('Failed to fetch favorite list: ${data['message']}');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  } catch (error) {
    // Handle different error types and print more detailed error messages
    if (error is http.ClientException) {
      print('HTTP request failed: $error');
    } else if (error is FormatException) {
      print('Error parsing response: $error');
    } else if (error is http.Response) {
      print('HTTP Error: ${error.statusCode} - ${error.body}');
    } else {
      print('Unexpected error: $error');
    }

    throw Exception('Failed to fetch favorite list: $error');
  }
}
