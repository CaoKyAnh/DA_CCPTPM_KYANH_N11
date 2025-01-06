// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class GetBookingService {
  Future<Map<String, dynamic>?> fetchBookingById(String id) async {
    final String url =
        'http://10.0.2.2:3000/api/bookingMoto/$id'; // Thay localhost bằng địa chỉ IP thực tế khi chạy trên thiết bị thật.

    try {
      // Gửi yêu cầu GET tới API
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Giải mã JSON nếu thành công
        final data = jsonDecode(response.body);
        print('Booking data: $data');
        return data; // Trả về dữ liệu
      } else {
        // Xử lý lỗi nếu không thành công
        print('Failed to fetch booking: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      // Bắt lỗi nếu có sự cố
      print('Error fetching booking by ID: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>> getBookingsByEmail(String email) async {
    final url = Uri.parse(
        'http://10.0.2.2:3000/api/bookingMoto/email/$email'); // API endpoint

    try {
      // Send a GET request to the API
      final response = await http.get(url);

      // Check if the server responded successfully
      if (response.statusCode == 200) {
        // Decode the JSON response
        final Map<String, dynamic> data = jsonDecode(response.body);

        // If "bookings" is present, parse the dates to Dart `DateTime` objects
        if (data.containsKey('bookings')) {
          final bookings = (data['bookings'] as List)
              .map((booking) => {
                    ...booking,
                    'bookingDate': DateTime.parse(booking['bookingDate']),
                    'returnDate': DateTime.parse(booking['returnDate']),
                    'acceptTime': DateTime.parse(booking['acceptTime']),
                  })
              .toList();

          return {'bookings': bookings};
        } else {
          return {'error': 'Bookings data not found in response'};
        }
      } else {
        // If the server response status is not 200
        return {
          'error':
              'Failed to load bookings, status code: ${response.statusCode}'
        };
      }
    } catch (error) {
      // Catch and return any error that occurs during the HTTP request
      return {'error': 'Error occurred: $error'};
    }
  }
}
