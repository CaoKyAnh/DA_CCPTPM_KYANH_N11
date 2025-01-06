import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateIsHideService {
  final String baseUrl = 'http://10.0.2.2:3000/api/notification';

  Future<Map<String, dynamic>> updateIsHide(
      String notificationId, bool isHide) async {
    final url =
        Uri.parse('$baseUrl/$notificationId'); // URL with the notificationId

    try {
      // Send a PATCH request to update the isHide field
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'isHide': isHide}), // Send the 'isHide' value in the body
      );

      if (response.statusCode == 200) {
        // If the response status is 200, return the response body
        return json.decode(response.body);
      } else {
        // If the response is not 200, return an error message
        return {
          'error':
              'Failed to update notification. Status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      // Handle any exceptions that occur during the API call
      return {'error': 'Error calling API: $e'};
    }
  }
}
