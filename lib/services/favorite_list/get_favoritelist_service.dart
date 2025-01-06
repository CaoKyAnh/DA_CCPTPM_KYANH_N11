import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>> getFavoriteList(String email) async {
  // Use the email parameter in the URL
  final url = Uri.parse('http://10.0.2.2:3000/api/favoriteList/$email');
  
  // Send the GET request with the proper headers
  final response = await http.get(
    url,
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    // Decode the response body
    final Map<String, dynamic> data = json.decode(response.body);

    // Check if the 'data' key exists and has the expected list
    if (data['success'] == true && data['data'] != null) {
      // Return the list of motorcycle IDs from the 'data' field
      return List<String>.from(data['data']);
    } else {
      throw Exception('No favorites found');
    }
  } else {
    throw Exception('Failed to load favorite list');
  }
}
