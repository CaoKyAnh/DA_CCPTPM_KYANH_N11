import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> deleteFavoriteListService(String email, String motorcycleId) async {
  final url = Uri.parse('http://10.0.2.2:3000/api/favoriteList/$email/$motorcycleId');

  try {
    // Sending a DELETE request to the backend with the email and motorcycleId
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    // Check if the response status code is 200 (success)
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success']) {
        // Return the success message
        return responseData['message'];
      } else {
        // Return an error message if the API response indicates failure
        return 'Failed to delete from favorite list: ${responseData['message']}';
      }
    } else {
      // Handle the case where the backend returns an error
      return 'Failed to delete favorite list item: ${response.statusCode}';
    }
  } catch (e) {
    // Catch any exceptions that may occur during the request
    return 'Error: $e';
  }
}
