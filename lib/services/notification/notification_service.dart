// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  Future<void> addNotification({
    required String title,
    required String body,
    required String email,
    required String bookingId,
    required DateTime bookingDate,
    required DateTime returnDate,
  }) async {
    final url = Uri.parse('http://10.0.2.2:3000/api/notification');

    // Convert DateTime to String (ISO format) for the API
    String bookingDateStr = bookingDate.toIso8601String();
    String returnDateStr = returnDate.toIso8601String();

    // Create the request body
    final Map<String, dynamic> requestBody = {
      'title': title,
      'body': body,
      'email': email,
      'bookingId': bookingId,
      'bookingDate': bookingDateStr,
      'returnDate': returnDateStr,
    };

    try {
      // Send POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Check if the response status is OK (200)
      if (response.statusCode == 201) {
        print('Notification saved successfully');
        final responseData = jsonDecode(response.body);
        print(responseData['message']);
      } else {
        print('Error adding notification: ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        print('Error: ${errorData['error']}');
      }
    } catch (error) {
      print('Request failed: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getNotificationsByEmail(
      String email) async {
    final String apiUrl = 'http://10.0.2.2:3000/api/notification/$email';

    try {
      // Send a GET request to the backend
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        List<dynamic> notifications =
            json.decode(response.body)['notifications'];

        // Convert the dynamic list to a list of maps
        return List<Map<String, dynamic>>.from(notifications);
      } else if (response.statusCode == 404) {
        // No notifications found for this email
        print('No notifications found for this email');
        return []; // Return an empty list if no notifications are found
      } else {
        // Handle other response errors
        print('Failed to load notifications. Error: ${response.statusCode}');
        return []; // Return an empty list in case of failure
      }
    } catch (e) {
      // Handle any errors that occur during the HTTP request
      print('Error fetching notifications: $e');
      return [];
    }
  }
}
