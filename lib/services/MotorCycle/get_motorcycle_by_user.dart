// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';

/// Fetches the motorcycle list of a user by their userId.
Future<List<Map<String, dynamic>>> getMotorcycleListByUser(
    String userId) async {
  final String apiUrl =
      'http://10.0.2.2:3000/api/motorcycleListByUser/$userId'; // URL to the API endpoint

  try {
    final response = await http.get(Uri.parse(apiUrl));

    // Check if the server returned a successful response
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Received data: $data'); // Print data to verify structure

      // Ensure the response contains success and the 'data' is a list
      if (data['success'] == true) {
        // Check if 'data' is a list before parsing
        if (data['data'] is List) {
          List<dynamic> favoriteList = data['data'];
          return List<Map<String, dynamic>>.from(
              favoriteList.map((item) => item as Map<String, dynamic>));
        } else {
          throw Exception('Invalid data format: "data" should be a list.');
        }
      } else {
        throw Exception('Failed to fetch motorcycle list: ${data['message']}');
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

    // Re-throw the exception with a more general message
    throw Exception('Failed to fetch motorcycle list: $error');
  }
}
