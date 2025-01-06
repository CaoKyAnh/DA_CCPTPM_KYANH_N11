import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> addFavoriteList(
    String email, List<String> favoriteList) async {
  // Define the backend API endpoint
  final url = Uri.parse('http://10.0.2.2:3000/api/favoriteList');

  // Construct the request payload
  final Map<String, dynamic> body = {
    'email': email,
    'favoriteList': favoriteList,
  };

  try {
    // Send the PATCH request to the backend
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    // Check the response status
    if (response.statusCode == 200) {
      // Parse the JSON response if the request is successful
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      // Handle client errors, such as validation errors
      final errorResponse = json.decode(response.body);
      throw Exception(errorResponse['message']);
    } else {
      // Handle unexpected server errors
      throw Exception('An unexpected error occurred.');
    }
  } catch (error) {
    // Handle any other errors that might occur
    throw Exception('Failed to update favorite list: $error');
  }
}
