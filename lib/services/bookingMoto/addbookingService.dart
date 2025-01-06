import 'dart:convert';
import 'package:http/http.dart' as http;

class AddBookingService {
  final String baseUrl = 'http://10.0.2.2:3000/api/bookingMoto';

  Future<Map<String, dynamic>> addBooking({
    required String email,
    required String numberPlate,
    required DateTime bookingDate,
    required DateTime returnDate,
    required int numberOfRentalDay,
    required int totalAmount,
    bool isAccept = false,
    bool isHide = false,
  }) async {
    final url = Uri.parse(baseUrl);

    // Convert booking and return dates to ISO format, keeping Vietnam timezone
    final adjustedBookingDate =
        bookingDate.toUtc(); // Không cần add 7 giờ vì backend tự xử lý múi giờ
    final adjustedReturnDate =
        returnDate.toUtc(); // Không cần add 7 giờ vì backend tự xử lý múi giờ

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'numberPlate': numberPlate,
          'bookingDate': adjustedBookingDate.toIso8601String(),
          'returnDate': adjustedReturnDate.toIso8601String(),
          'numberOfRentalDay': numberOfRentalDay,
          'totalAmount': totalAmount,
          'isAccept': isAccept,
          'isHide': isHide,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body); // Return the response as a map
      } else {
        throw Exception('Failed to add booking: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error while calling addBooking: $error');
    }
  }
}
