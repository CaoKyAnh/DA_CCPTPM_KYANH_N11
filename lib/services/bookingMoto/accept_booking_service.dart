import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding the JSON response

class AcceptBookingService {
  // Method to accept a booking by bookingId
  Future<Map<String, dynamic>> acceptBooking(String bookingId) async {
    try {
      final response = await http.patch(
        Uri.parse(
            'http://10.0.2.2:3000/api/bookingMoto/accept/$bookingId'), // Replace with your backend URL
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // If the server returns a successful response
        final responseData =
            json.decode(response.body); // Decode the response body

        // You can handle the response like this:
        return {
          'message': responseData['message'], // Message from backend
          'acceptTime': DateTime.parse(responseData[
              'acceptTime']), // Convert timestamp to DateTime object
        };
      } else {
        // If the response is not successful, return an error message
        return {'error': 'Failed to accept the booking.'};
      }
    } catch (e) {
      // Catch and return any error
      return {'error': 'Error: $e'};
    }
  }
}
